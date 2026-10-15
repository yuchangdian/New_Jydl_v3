import hilog from '@ohos.hilog';
import { Jybsmr131NumericField, Jybsmr131PacketValue } from 'libentry.so';
import { Jybsmr131Protocol, Jybsmr131CommonAddress, Jybsmr131TelemetryAddress } from '../../protocol/Jybsmr131';

type RealtimeMetricValue = number | number[];

// Qt 新协议使用单线路标量；格式化函数仍兼容旧数据中的线路 1 数组（索引 0）。
export interface RealtimeMetricData {
  Ua_Frequency?: RealtimeMetricValue;
  Ub_Frequency?: RealtimeMetricValue;
  Uc_Frequency?: RealtimeMetricValue;
  Ua_RMS?: RealtimeMetricValue;
  Ub_RMS?: RealtimeMetricValue;
  Uc_RMS?: RealtimeMetricValue;
  Ua_Phase?: RealtimeMetricValue;
  Ub_Phase?: RealtimeMetricValue;
  Uc_Phase?: RealtimeMetricValue;
  IA_RMS?: RealtimeMetricValue;
  IB_RMS?: RealtimeMetricValue;
  IC_RMS?: RealtimeMetricValue;
  IA_Phase?: RealtimeMetricValue;
  IB_Phase?: RealtimeMetricValue;
  IC_Phase?: RealtimeMetricValue;
  FreqDeviation_A?: RealtimeMetricValue;
  FreqDeviation_B?: RealtimeMetricValue;
  FreqDeviation_C?: RealtimeMetricValue;
  FreqQualifiRate_A?: RealtimeMetricValue;
  FreqQualifiRate_B?: RealtimeMetricValue;
  FreqQualifiRate_C?: RealtimeMetricValue;
  VoltageDeviation_A?: RealtimeMetricValue;
  VoltageDeviation_B?: RealtimeMetricValue;
  VoltageDeviation_C?: RealtimeMetricValue;
  VoltageDeviation_AB?: RealtimeMetricValue;
  VoltageDeviation_BC?: RealtimeMetricValue;
  VoltageDeviation_CA?: RealtimeMetricValue;
  VoltageQualifiRate_A?: RealtimeMetricValue;
  VoltageQualifiRate_B?: RealtimeMetricValue;
  VoltageQualifiRate_C?: RealtimeMetricValue;
  Voltage_U1?: RealtimeMetricValue;
  Voltage_U2?: RealtimeMetricValue;
  Voltage_Uo?: RealtimeMetricValue;
  Voltage_U0?: RealtimeMetricValue;
  Voltage_U2_Unbalance?: RealtimeMetricValue;
  Voltage_Uo_Unbalance?: RealtimeMetricValue;
  VoltageShortFlicke_A?: RealtimeMetricValue;
  VoltageShortFlicke_B?: RealtimeMetricValue;
  VoltageShortFlicke_C?: RealtimeMetricValue;
  VoltageLongFlicke_A?: RealtimeMetricValue;
  VoltageLongFlicke_B?: RealtimeMetricValue;
  VoltageLongFlicke_C?: RealtimeMetricValue;
  Current_I1?: RealtimeMetricValue;
  Current_I2?: RealtimeMetricValue;
  Current_Io?: RealtimeMetricValue;
  Current_I0?: RealtimeMetricValue;
  Current_I2_Unbalance?: RealtimeMetricValue;
  Current_In_Unbalance?: RealtimeMetricValue;
  Current_Io_Unbalance?: RealtimeMetricValue;
}

export interface RealtimeMetricCell {
  prefix: string;
  value: string;
}

export interface RealtimeMetricRow {
  id: string;
  title: string;
  cells: RealtimeMetricCell[];
}

function realtimeNumber(value: RealtimeMetricValue | undefined): number | undefined {
  const scalar = Array.isArray(value) ? value[0] : value;
  return typeof scalar === 'number' && Number.isFinite(scalar) ? scalar : undefined;
}

function firstRealtimeNumber(primary: RealtimeMetricValue | undefined,
  fallback: RealtimeMetricValue | undefined): number | undefined {
  const value = realtimeNumber(primary);
  return value !== undefined ? value : realtimeNumber(fallback);
}

export function formatRealtimeValue(value: RealtimeMetricValue | undefined, precision: number,
  unit: string = ''): string {
  const number = realtimeNumber(value);
  if (number === undefined) {
    return '--';
  }
  const rounded = Math.abs(number) < 0.5 * Math.pow(10, -precision) ? 0 : number;
  return rounded.toFixed(precision) + unit;
}

function realtimePhasor(prefix: string, rms: RealtimeMetricValue | undefined,
  phase: RealtimeMetricValue | undefined, unit: string): RealtimeMetricCell {
  if (realtimeNumber(rms) === undefined && realtimeNumber(phase) === undefined) {
    return { prefix: prefix, value: '--' };
  }
  return {
    prefix: prefix,
    value: formatRealtimeValue(rms, 4) + ' ' + unit + '∠' + formatRealtimeValue(phase, 3) + '°'
  };
}

function realtimeTriplet(prefixes: string[], values: (RealtimeMetricValue | undefined)[],
  unit: string): RealtimeMetricCell[] {
  return prefixes.map((prefix: string, index: number): RealtimeMetricCell => {
    return { prefix: prefix, value: formatRealtimeValue(values[index], 4, unit) };
  });
}

export function buildRealtimeRows(base: RealtimeMetricData, quality: RealtimeMetricData): RealtimeMetricRow[] {
  return [
    { id: 'Frequency', title: '频 率:', cells: realtimeTriplet(['fa:', 'fb:', 'fc:'],
      [base.Ua_Frequency, base.Ub_Frequency, base.Uc_Frequency], 'Hz') },
    { id: 'FrequencyDeviation', title: '频率偏差:', cells: realtimeTriplet(['Δfa:', 'Δfb:', 'Δfc:'],
      [quality.FreqDeviation_A, quality.FreqDeviation_B, quality.FreqDeviation_C], 'Hz') },
    { id: 'FrequencyRate', title: '频率合格率:', cells: realtimeTriplet(['γfa:', 'γfb:', 'γfc:'],
      [quality.FreqQualifiRate_A, quality.FreqQualifiRate_B, quality.FreqQualifiRate_C], '%') },
    { id: 'Voltage', title: '电 压:', cells: [
      realtimePhasor('Ua:', base.Ua_RMS, base.Ua_Phase, 'V'),
      realtimePhasor('Ub:', base.Ub_RMS, base.Ub_Phase, 'V'),
      realtimePhasor('Uc:', base.Uc_RMS, base.Uc_Phase, 'V')
    ] },
    { id: 'VoltageDeviation', title: '电压偏差:', cells: realtimeTriplet(['ΔUa:', 'ΔUb:', 'ΔUc:'],
      [quality.VoltageDeviation_A, quality.VoltageDeviation_B, quality.VoltageDeviation_C], '%') },
    { id: 'LineVoltageDeviation', title: '', cells: realtimeTriplet(['ΔUab:', 'ΔUbc:', 'ΔUca:'],
      [quality.VoltageDeviation_AB, quality.VoltageDeviation_BC, quality.VoltageDeviation_CA], '%') },
    { id: 'VoltageRate', title: '电压合格率:', cells: realtimeTriplet(['γUa:', 'γUb:', 'γUc:'],
      [quality.VoltageQualifiRate_A, quality.VoltageQualifiRate_B, quality.VoltageQualifiRate_C], '%') },
    { id: 'VoltageUnbalance', title: '电压不平衡:', cells: realtimeTriplet(['U1:', 'U2:', 'Uo:'],
      [quality.Voltage_U1, quality.Voltage_U2, firstRealtimeNumber(quality.Voltage_Uo, quality.Voltage_U0)], 'V') },
    { id: 'VoltageUnbalanceRate', title: '', cells: [
      { prefix: 'εU2:', value: formatRealtimeValue(quality.Voltage_U2_Unbalance, 4, '%') },
      { prefix: 'εUo:', value: formatRealtimeValue(quality.Voltage_Uo_Unbalance, 4, '%') },
      { prefix: '', value: '' }
    ] },
    { id: 'VoltageShortFlicke', title: '电压短闪变:', cells: realtimeTriplet(['Ua:', 'Ub:', 'Uc:'],
      [quality.VoltageShortFlicke_A, quality.VoltageShortFlicke_B, quality.VoltageShortFlicke_C], '') },
    { id: 'VoltageLongFlicke', title: '电压长闪变:', cells: realtimeTriplet(['Ua:', 'Ub:', 'Uc:'],
      [quality.VoltageLongFlicke_A, quality.VoltageLongFlicke_B, quality.VoltageLongFlicke_C], '') },
    // Qt 使用 IA/IB/IC 保护电流，不能替换成 Ia/Ib/Ic 测量电流。
    { id: 'Current', title: '电 流:', cells: [
      realtimePhasor('Ia:', base.IA_RMS, base.IA_Phase, 'A'),
      realtimePhasor('Ib:', base.IB_RMS, base.IB_Phase, 'A'),
      realtimePhasor('Ic:', base.IC_RMS, base.IC_Phase, 'A')
    ] },
    { id: 'CurrentUnbalance', title: '电流不平衡:', cells: realtimeTriplet(['I1:', 'I2:', 'Io:'],
      [quality.Current_I1, quality.Current_I2, firstRealtimeNumber(quality.Current_Io, quality.Current_I0)], 'A') },
    { id: 'CurrentUnbalanceRate', title: '', cells: [
      { prefix: 'εI2:', value: formatRealtimeValue(quality.Current_I2_Unbalance, 4, '%') },
      { prefix: 'εIo:', value: formatRealtimeValue(
        firstRealtimeNumber(quality.Current_In_Unbalance, quality.Current_Io_Unbalance), 4, '%') },
      { prefix: '', value: '' }
    ] }
  ];
}

export function hasRealtimeData(data: RealtimeMetricData, isBase: boolean): boolean {
  const rows = buildRealtimeRows(isBase ? data : {}, isBase ? {} : data);
  return rows.some((row: RealtimeMetricRow): boolean => {
    return row.cells.some((cell: RealtimeMetricCell): boolean => cell.value !== '' && cell.value !== '--');
  });
}

const REALTIME_POLL_INTERVAL: number = 200;
const REALTIME_REQUEST_INTERVAL: number = 2000;
const REALTIME_STALE_INTERVAL: number = 10000;

function realtimePacketNumber(packet: Jybsmr131PacketValue, name: string): number | undefined {
  const field = packet.fields.find((item: Jybsmr131NumericField) => item.name === name);
  if (!field || field.values.length !== 1) return undefined;
  return realtimeNumber(field.values[0]);
}

function realtimePacketData(packet: Jybsmr131PacketValue, isBase: boolean): RealtimeMetricData {
  if (isBase) {
    return {
      Ua_Frequency: realtimePacketNumber(packet, 'Ua_Frequency'),
      Ub_Frequency: realtimePacketNumber(packet, 'Ub_Frequency'),
      Uc_Frequency: realtimePacketNumber(packet, 'Uc_Frequency'),
      Ua_RMS: realtimePacketNumber(packet, 'Ua_RMS'),
      Ub_RMS: realtimePacketNumber(packet, 'Ub_RMS'),
      Uc_RMS: realtimePacketNumber(packet, 'Uc_RMS'),
      Ua_Phase: realtimePacketNumber(packet, 'Ua_Phase'),
      Ub_Phase: realtimePacketNumber(packet, 'Ub_Phase'),
      Uc_Phase: realtimePacketNumber(packet, 'Uc_Phase'),
      IA_RMS: realtimePacketNumber(packet, 'IA_RMS'),
      IB_RMS: realtimePacketNumber(packet, 'IB_RMS'),
      IC_RMS: realtimePacketNumber(packet, 'IC_RMS'),
      IA_Phase: realtimePacketNumber(packet, 'IA_Phase'),
      IB_Phase: realtimePacketNumber(packet, 'IB_Phase'),
      IC_Phase: realtimePacketNumber(packet, 'IC_Phase')
    };
  }
  return {
    FreqDeviation_A: realtimePacketNumber(packet, 'PowerQuality.FreqDeviation_A'),
    FreqDeviation_B: realtimePacketNumber(packet, 'PowerQuality.FreqDeviation_B'),
    FreqDeviation_C: realtimePacketNumber(packet, 'PowerQuality.FreqDeviation_C'),
    FreqQualifiRate_A: realtimePacketNumber(packet, 'PowerQuality.FreqQualifiRate_A'),
    FreqQualifiRate_B: realtimePacketNumber(packet, 'PowerQuality.FreqQualifiRate_B'),
    FreqQualifiRate_C: realtimePacketNumber(packet, 'PowerQuality.FreqQualifiRate_C'),
    VoltageDeviation_A: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_A'),
    VoltageDeviation_B: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_B'),
    VoltageDeviation_C: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_C'),
    VoltageDeviation_AB: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_AB'),
    VoltageDeviation_BC: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_BC'),
    VoltageDeviation_CA: realtimePacketNumber(packet, 'PowerQuality.VoltageDeviation_CA'),
    VoltageQualifiRate_A: realtimePacketNumber(packet, 'PowerQuality.VoltageQualifiRate_A'),
    VoltageQualifiRate_B: realtimePacketNumber(packet, 'PowerQuality.VoltageQualifiRate_B'),
    VoltageQualifiRate_C: realtimePacketNumber(packet, 'PowerQuality.VoltageQualifiRate_C'),
    Voltage_U1: realtimePacketNumber(packet, 'PowerQuality.Voltage_U1'),
    Voltage_U2: realtimePacketNumber(packet, 'PowerQuality.Voltage_U2'),
    Voltage_Uo: realtimePacketNumber(packet, 'PowerQuality.Voltage_Uo'),
    Voltage_U2_Unbalance: realtimePacketNumber(packet, 'PowerQuality.Voltage_U2_Unbalance'),
    Voltage_Uo_Unbalance: realtimePacketNumber(packet, 'PowerQuality.Voltage_Uo_Unbalance'),
    VoltageShortFlicke_A: realtimePacketNumber(packet, 'PowerQuality.VoltageShortFlicke_A'),
    VoltageShortFlicke_B: realtimePacketNumber(packet, 'PowerQuality.VoltageShortFlicke_B'),
    VoltageShortFlicke_C: realtimePacketNumber(packet, 'PowerQuality.VoltageShortFlicke_C'),
    VoltageLongFlicke_A: realtimePacketNumber(packet, 'PowerQuality.VoltageLongFlicke_A'),
    VoltageLongFlicke_B: realtimePacketNumber(packet, 'PowerQuality.VoltageLongFlicke_B'),
    VoltageLongFlicke_C: realtimePacketNumber(packet, 'PowerQuality.VoltageLongFlicke_C'),
    Current_I1: realtimePacketNumber(packet, 'PowerQuality.Current_I1'),
    Current_I2: realtimePacketNumber(packet, 'PowerQuality.Current_I2'),
    Current_Io: realtimePacketNumber(packet, 'PowerQuality.Current_Io'),
    Current_I2_Unbalance: realtimePacketNumber(packet, 'PowerQuality.Current_I2_Unbalance'),
    Current_In_Unbalance: realtimePacketNumber(packet, 'PowerQuality.Current_In_Unbalance')
  };
}

// 两类报文独立推进；只将新接收版本视为更新，反复读取缓存不会延长有效期。
export class RealtimeMonitoringBuffer {
  rows: RealtimeMetricRow[] = buildRealtimeRows({}, {});
  private baseData: RealtimeMetricData = {};
  private qualityData: RealtimeMetricData = {};
  private sessionId: number = -1;
  private baseRevision: number = 0;
  private qualityRevision: number = 0;
  private baseReceivedAt: number = 0;
  private qualityReceivedAt: number = 0;

  accept(packet: Jybsmr131PacketValue, isBase: boolean, now: number): boolean {
    const address = isBase ? Jybsmr131TelemetryAddress.BaseValue : Jybsmr131TelemetryAddress.PowerQuality;
    if (packet.commonAddress !== Jybsmr131CommonAddress.RemoteMetry || packet.objectAddress !== address ||
      !Number.isSafeInteger(packet.sessionId) || packet.sessionId < 0 || packet.sessionId < this.sessionId) {
      return false;
    }
    let changed = false;
    if (packet.sessionId !== this.sessionId) {
      this.sessionId = packet.sessionId;
      this.baseData = {};
      this.qualityData = {};
      this.baseRevision = 0;
      this.qualityRevision = 0;
      this.baseReceivedAt = 0;
      this.qualityReceivedAt = 0;
      changed = true;
    }
    const revision = isBase ? this.baseRevision : this.qualityRevision;
    if (packet.ready && Number.isSafeInteger(packet.revision) && packet.revision > revision) {
      const data = realtimePacketData(packet, isBase);
      if (hasRealtimeData(data, isBase)) {
        if (isBase) {
          this.baseData = data;
          this.baseRevision = packet.revision;
          this.baseReceivedAt = now;
        } else {
          this.qualityData = data;
          this.qualityRevision = packet.revision;
          this.qualityReceivedAt = now;
        }
        changed = true;
      }
    }
    if (changed) this.rows = buildRealtimeRows(this.baseData, this.qualityData);
    return changed;
  }

  isFresh(isBase: boolean, now: number, interval: number): boolean {
    const revision = isBase ? this.baseRevision : this.qualityRevision;
    const receivedAt = isBase ? this.baseReceivedAt : this.qualityReceivedAt;
    return revision > 0 && now - receivedAt < interval;
  }

  status(now: number, requestFailed: boolean): string {
    const missing: string[] = [];
    const stale: string[] = [];
    if (this.baseRevision === 0) missing.push('基波');
    else if (!this.isFresh(true, now, REALTIME_STALE_INTERVAL)) stale.push('基波');
    if (this.qualityRevision === 0) missing.push('电能质量');
    else if (!this.isFresh(false, now, REALTIME_STALE_INTERVAL)) stale.push('电能质量');
    const messages: string[] = [];
    if (missing.length > 0) messages.push('等待' + missing.join('、') + '数据，缺失值显示 --');
    if (stale.length > 0) messages.push(stale.join('、') + '数据超过 10 秒未更新，保留上次有效值');
    if (requestFailed) messages.push('数据请求未发送成功，正在重试');
    return messages.join('；');
  }
}

@Component
export struct PowerQualityRealtimeMonitoringPage {
  @State private uiScale: number = 1;
  @State private rows: RealtimeMetricRow[] = buildRealtimeRows({}, {});
  @State private statusText: string = '等待设备实时指标数据';
  @Prop @Watch('onPageActiveChanged') pageActive: boolean = true;
  private buffer: RealtimeMonitoringBuffer = new RealtimeMonitoringBuffer();
  private readonly columns: number[] = [0, 1, 2];
  private timerId: number = -1;
  private active: boolean = false;
  private nextRequestAt: number = 0;
  private requestFailed: boolean = false;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.onPageActiveChanged();
  }

  aboutToDisappear(): void {
    this.stopPolling();
  }

  private onPageActiveChanged(): void {
    if (this.pageActive) this.startPolling();
    else this.stopPolling();
  }

  private startPolling(): void {
    if (this.active) return;
    this.active = true;
    this.nextRequestAt = 0;
    this.pollData();
    this.timerId = setInterval(() => this.pollData(), REALTIME_POLL_INTERVAL);
  }

  private stopPolling(): void {
    this.active = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private readPacket(isBase: boolean, now: number): boolean {
    const address = isBase ? Jybsmr131TelemetryAddress.BaseValue : Jybsmr131TelemetryAddress.PowerQuality;
    try {
      return this.buffer.accept(Jybsmr131Protocol.telemetry(address), isBase, now);
    } catch (error) {
      hilog.error(0x0001, 'RealtimeMonitoring', '%{public}s读取失败：%{public}s',
        isBase ? '基波' : '电能质量', String(error));
      return false;
    }
  }

  private requestPacket(isBase: boolean): boolean {
    const address = isBase ? Jybsmr131TelemetryAddress.BaseValue : Jybsmr131TelemetryAddress.PowerQuality;
    try {
      return Jybsmr131Protocol.requestTelemetry(address);
    } catch (error) {
      hilog.error(0x0001, 'RealtimeMonitoring', '数据请求失败：%{public}s', String(error));
      return false;
    }
  }

  private pollData(): void {
    if (!this.active) return;
    const now = Date.now();
    const baseChanged = this.readPacket(true, now);
    const qualityChanged = this.readPacket(false, now);
    if (baseChanged || qualityChanged) this.rows = this.buffer.rows;
    if (now >= this.nextRequestAt) {
      this.nextRequestAt = now + REALTIME_REQUEST_INTERVAL;
      this.requestFailed = false;
      // Qt 会持续转发设备报文；仅对缺失或暂未更新的组补发查询，不阻塞另一组刷新。
      if (!this.buffer.isFresh(true, now, REALTIME_REQUEST_INTERVAL)) {
        if (!this.requestPacket(true)) this.requestFailed = true;
      }
      if (!this.buffer.isFresh(false, now, REALTIME_REQUEST_INTERVAL)) {
        if (!this.requestPacket(false)) this.requestFailed = true;
      }
    }
    if (this.buffer.isFresh(true, now, REALTIME_REQUEST_INTERVAL) &&
      this.buffer.isFresh(false, now, REALTIME_REQUEST_INTERVAL)) this.requestFailed = false;
    this.statusText = this.buffer.status(now, this.requestFailed);
  }

  @Builder
  metricCell(cell: RealtimeMetricCell) {
    Row({ space: 4 * this.uiScale }) {
      if (cell.prefix.length > 0) {
        Text(cell.prefix)
          .fontSize(18 * this.uiScale)
          .fontColor('#111111')
          .maxLines(1)
          .textAlign(TextAlign.End)
      }
      Text(cell.value)
        .layoutWeight(1)
        .fontSize(18 * this.uiScale)
        .minFontSize(12 * this.uiScale)
        .maxFontSize(18 * this.uiScale)
        .maxLines(1)
        .fontColor('#111111')
        .textAlign(TextAlign.Start)
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: 2 * this.uiScale, right: 2 * this.uiScale })
  }

  @Builder
  metricRow(row: RealtimeMetricRow, index: number) {
    Row() {
      Text(row.title)
        .width(115 * this.uiScale)
        .height('100%')
        .fontSize(18 * this.uiScale)
        .fontColor('#111111')
        .maxLines(1)
        .textAlign(TextAlign.End)
      ForEach(this.columns, (column: number) => {
        this.metricCell(row.cells[column])
      }, (column: number) => column.toString())
    }
    .width('100%')
    .height(39 * this.uiScale)
    .padding({ right: 8 * this.uiScale })
    .backgroundColor(index % 2 === 1 ? '#d3d3d3' : '#ffffff')
    .border({ width: { bottom: 1 }, color: '#222222' })
  }

  build() {
    Column() {
      // 保留 Qt 顶部 47 高的灰色栏，仅在读取中或异常时提示数据状态。
      Row() {
        Text(this.statusText)
          .fontSize(14 * this.uiScale)
          .fontColor('#555555')
          .maxLines(1)
      }
      .width('100%')
      .height(47 * this.uiScale)
      .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale })
      .backgroundColor('#c9c9c9')
      .border({ width: { bottom: 1 }, color: '#333333' })
      List({ scroller: this.scroller, space: 0 }) {
        ForEach(this.rows, (row: RealtimeMetricRow, index: number) => {
          ListItem() {
            this.metricRow(row, index)
          }
        }, (row: RealtimeMetricRow) => row.id + ':' + row.cells.map((cell: RealtimeMetricCell) => cell.value).join('|'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.On)
      .edgeEffect(EdgeEffect.None)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.uiScale = width / 735;
      }
    })
  }
}
