import { Jybsmr131NumericField, Jybsmr131PacketValue } from 'libentry.so';

export const WAVEFORM_POINT_COUNT: number = 400;
export const WAVEFORM_NAMES: string[] = ['Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'];
export const WAVEFORM_COLORS: string[] = ['#ccaa00', '#008000', '#ff0000', '#ccaa00', '#008000', '#ff0000'];

export interface WaveformFrame {
  samples: number[][];
  rms: string[];
}

export interface WaveformRange {
  min: number;
  max: number;
}

export function emptyWaveformFrame(): WaveformFrame {
  return { samples: [[], [], [], [], [], []], rms: ['--', '--', '--', '--', '--', '--'] };
}

export function validWaveformSamples(samples: number[]): boolean {
  return samples.length === WAVEFORM_POINT_COUNT && samples.every((value: number) => Number.isFinite(value));
}

export function waveformRms(samples: number[]): number | undefined {
  if (!validWaveformSamples(samples)) {
    return undefined;
  }
  let sum: number = 0;
  samples.forEach((value: number) => { sum += value * value; });
  return Math.sqrt(sum / WAVEFORM_POINT_COUNT);
}

export function waveformRange(samples: number[][], visible: boolean[], voltage: boolean): WaveformRange {
  let minimum: number = Number.POSITIVE_INFINITY;
  let maximum: number = Number.NEGATIVE_INFINITY;
  const start: number = voltage ? 0 : 3;
  for (let channel: number = start; channel < start + 3; channel++) {
    if (!visible[channel] || !samples[channel] || !validWaveformSamples(samples[channel])) {
      continue;
    }
    samples[channel].forEach((value: number) => {
      minimum = Math.min(minimum, value);
      maximum = Math.max(maximum, value);
    });
  }
  if (!Number.isFinite(minimum)) {
    minimum = voltage ? -100 : -1.5;
    maximum = voltage ? 100 : 1.5;
  }
  const margin: number = Math.max((maximum - minimum) * 0.05, voltage ? 1 : 0.1);
  return { min: minimum - margin, max: maximum + margin };
}

// Qt 将电压/电流分别放入居中的 95%/70% 高度区域。
export function waveformY(value: number, range: WaveformRange, voltage: boolean,
  top: number, height: number): number {
  const scale: number = voltage ? 0.95 : 0.70;
  const ratio: number = Math.max(0, Math.min(1, (value - range.min) / (range.max - range.min)));
  return top + height * (1 - scale) / 2 + (1 - ratio) * height * scale;
}

// 分离接收缓冲和显示快照：六路均有新回包时才提交；暂停不影响接收。
export class WaveformBuffer {
  displayed: WaveformFrame = emptyWaveformFrame();
  refreshing: boolean = true;
  private latest?: WaveformFrame;
  private sessionId: number = -1;
  private revisions: number[] = [0, 0, 0, 0, 0, 0];
  private received: boolean[] = [false, false, false, false, false, false];
  private pending: number[][] = [[], [], [], [], [], []];

  get receivedCount(): number {
    return this.received.filter((value: boolean) => value).length;
  }

  get hasCompleteFrame(): boolean {
    return this.latest !== undefined;
  }

  setRefreshing(refreshing: boolean): void {
    this.refreshing = refreshing;
    if (refreshing && this.latest) {
      this.displayed = this.latest;
    }
  }

  accept(packets: Jybsmr131PacketValue[]): boolean {
    if (packets.length !== 6 || !packets.every((packet: Jybsmr131PacketValue) =>
      packet.sessionId === packets[0].sessionId)) {
      return false;
    }
    if (this.sessionId !== packets[0].sessionId) {
      this.sessionId = packets[0].sessionId;
      this.revisions = [0, 0, 0, 0, 0, 0];
      this.received = [false, false, false, false, false, false];
      this.pending = [[], [], [], [], [], []];
      this.latest = undefined;
    }
    packets.forEach((packet: Jybsmr131PacketValue, index: number) => {
      if (!packet.ready || packet.commonAddress !== 0x1311 || packet.objectAddress !== 0xB1 + index ||
        !Number.isFinite(packet.revision) || packet.revision <= this.revisions[index]) {
        return;
      }
      const field = packet.fields.find((item: Jybsmr131NumericField) => item.name === 'Value');
      if (!field || !validWaveformSamples(field.values)) {
        return;
      }
      // native NumericField 已按 0.01 换算为 V/A，此处不可再次除以 100。
      this.pending[index] = field.values.slice();
      this.revisions[index] = packet.revision;
      this.received[index] = true;
    });
    if (this.receivedCount !== 6) {
      return false;
    }
    const samples: number[][] = this.pending.map((values: number[]) => values.slice());
    const rms: string[] = samples.map((values: number[], index: number) => {
      const value: number | undefined = waveformRms(values);
      return value === undefined ? '--' : value.toFixed(index < 3 ? 1 : 2) + (index < 3 ? 'V' : 'A');
    });
    this.latest = { samples: samples, rms: rms };
    this.received = [false, false, false, false, false, false];
    if (this.refreshing) {
      this.displayed = this.latest;
    }
    return true;
  }
}
