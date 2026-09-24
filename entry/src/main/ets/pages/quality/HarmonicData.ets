export const HARMONIC_COUNT: number = 63;

// IPC 数组第一维为线路，第二维为 1～63 次谐波；Qt 页面显示线路 1。
export interface HarmonicDistortionData {
  Ua_RMS?: number[][];
  Ub_RMS?: number[][];
  Uc_RMS?: number[][];
  Ia_RMS?: number[][];
  Ib_RMS?: number[][];
  Ic_RMS?: number[][];
  Ua_Angle?: number[][];
  Ub_Angle?: number[][];
  Uc_Angle?: number[][];
  Ia_Angle?: number[][];
  Ib_Angle?: number[][];
  Ic_Angle?: number[][];
}

export interface HarmonicPowerQualityData {
  VoltageTHD_A?: number[];
  VoltageTHD_B?: number[];
  VoltageTHD_C?: number[];
  VoltageOddTHD_A?: number[];
  VoltageOddTHD_B?: number[];
  VoltageOddTHD_C?: number[];
  VoltageEvenTHD_A?: number[];
  VoltageEvenTHD_B?: number[];
  VoltageEvenTHD_C?: number[];
  CurrentTHD_A?: number[];
  CurrentTHD_B?: number[];
  CurrentTHD_C?: number[];
  CurrentOddTHD_A?: number[];
  CurrentOddTHD_B?: number[];
  CurrentOddTHD_C?: number[];
  CurrentEvenTHD_A?: number[];
  CurrentEvenTHD_B?: number[];
  CurrentEvenTHD_C?: number[];
  PowerP_THD_A?: number[];
  PowerP_THD_B?: number[];
  PowerP_THD_C?: number[];
  PowerQ_THD_A?: number[];
  PowerQ_THD_B?: number[];
  PowerQ_THD_C?: number[];
  PowerS_THD_A?: number[];
  PowerS_THD_B?: number[];
  PowerS_THD_C?: number[];
  PowerF_THD_A?: number[];
  PowerF_THD_B?: number[];
  PowerF_THD_C?: number[];
  PeakFactor_Ua?: number[];
  PeakFactor_Ub?: number[];
  PeakFactor_Uc?: number[];
  PeakFactor_Ia?: number[];
  PeakFactor_Ib?: number[];
  PeakFactor_Ic?: number[];
}

export interface HarmonicRow {
  order: number;
  ratio: number | undefined;
  contentRate: string;
  rmsValue: string;
  phaseAngle: string;
  apparentPower: string;
  powerFactor: string;
}

export interface HarmonicSummaryItem {
  label: string;
  value: string;
}

interface HarmonicChannel {
  rms?: number[][];
  angle?: number[][];
}

function channelData(data: HarmonicDistortionData, channel: number): HarmonicChannel {
  switch (channel) {
    case 0: return { rms: data.Ua_RMS, angle: data.Ua_Angle };
    case 1: return { rms: data.Ub_RMS, angle: data.Ub_Angle };
    case 2: return { rms: data.Uc_RMS, angle: data.Uc_Angle };
    case 3: return { rms: data.Ia_RMS, angle: data.Ia_Angle };
    case 4: return { rms: data.Ib_RMS, angle: data.Ib_Angle };
    case 5: return { rms: data.Ic_RMS, angle: data.Ic_Angle };
    default: return {};
  }
}

function finiteValue(value: number | undefined): number | undefined {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

function arrayValue(values: number[] | undefined, index: number): number | undefined {
  return Array.isArray(values) ? finiteValue(values[index]) : undefined;
}

function harmonicValue(values: number[][] | undefined, orderIndex: number): number | undefined {
  return Array.isArray(values) ? arrayValue(values[0], orderIndex) : undefined;
}

export function formatHarmonicValue(value: number | undefined, decimals: number, unit: string = ''): string {
  const finite = finiteValue(value);
  if (finite === undefined) {
    return '--';
  }
  // 避免界面出现 -0.00。
  const rounded = Math.abs(finite) < 0.5 * Math.pow(10, -decimals) ? 0 : finite;
  return rounded.toFixed(decimals) + (unit.length > 0 ? ' ' + unit : '');
}

function formatRms(value: number | undefined, isVoltage: boolean): string {
  const unit = isVoltage ? 'V' : 'A';
  return value !== undefined && Math.abs(value) > 1000
    ? formatHarmonicValue(value / 1000, 3, 'k' + unit)
    : formatHarmonicValue(value, 3, unit);
}

export function buildHarmonicRows(voltage: HarmonicDistortionData, current: HarmonicDistortionData,
  channelIndex: number): HarmonicRow[] {
  const isVoltage = channelIndex < 3;
  const selected = channelData(isVoltage ? voltage : current, channelIndex);
  const phaseIndex = channelIndex % 3;
  const phaseVoltage = channelData(voltage, phaseIndex);
  const phaseCurrent = channelData(current, phaseIndex + 3);
  const baseRms = harmonicValue(selected.rms, 0);
  const rows: HarmonicRow[] = [];
  for (let index = 0; index < HARMONIC_COUNT; index++) {
    const rms = harmonicValue(selected.rms, index);
    const angle = harmonicValue(selected.angle, index);
    let ratio: number | undefined = undefined;
    if (rms !== undefined && baseRms !== undefined) {
      ratio = Math.abs(baseRms) > 0.0001 ? Math.max(0, Math.min(100, rms / baseRms * 100)) : 0;
    }

    const uRms = harmonicValue(phaseVoltage.rms, index);
    const iRms = harmonicValue(phaseCurrent.rms, index);
    const uAngle = harmonicValue(phaseVoltage.angle, index);
    const iAngle = harmonicValue(phaseCurrent.angle, index);
    const power = uRms !== undefined && iRms !== undefined ? finiteValue(uRms * iRms) : undefined;
    let factor: number | undefined = undefined;
    if (power !== undefined) {
      if (power <= 0.001) {
        factor = 0;
      } else if (uAngle !== undefined && iAngle !== undefined) {
        factor = Math.cos((uAngle - iAngle) * Math.PI / 180);
      }
    }
    rows.push({
      order: index + 1,
      ratio: ratio,
      contentRate: formatHarmonicValue(ratio, 2, '%'),
      rmsValue: formatRms(rms, isVoltage),
      phaseAngle: formatHarmonicValue(angle, 3, '°'),
      apparentPower: power !== undefined && power > 1000000
        ? formatHarmonicValue(power / 1000000, 3, 'MVA')
        : formatHarmonicValue(power !== undefined ? power / 1000 : undefined, 3, 'kVA'),
      powerFactor: formatHarmonicValue(factor, 2)
    });
  }
  return rows;
}

export function harmonicAxisMaximum(values: number[]): number {
  let maximum = 0;
  values.forEach((value: number) => {
    if (Number.isFinite(value)) {
      maximum = Math.max(maximum, value);
    }
  });
  return Math.min(100, Math.max(10, Math.ceil(maximum / 10) * 10));
}

export function buildHarmonicSummary(data: HarmonicPowerQualityData, channelIndex: number): HarmonicSummaryItem[] {
  const isVoltage = channelIndex < 3;
  const phase = channelIndex % 3;
  let fields: (number[] | undefined)[] = [];
  // 按 Qt 的三行三列顺序，电流通道使用 CurrentTHD 和对应 PeakFactor_I。
  switch (phase) {
    case 0:
      fields = [isVoltage ? data.VoltageTHD_A : data.CurrentTHD_A, data.PowerP_THD_A, data.PowerF_THD_A,
        isVoltage ? data.VoltageOddTHD_A : data.CurrentOddTHD_A, data.PowerQ_THD_A,
        isVoltage ? data.PeakFactor_Ua : data.PeakFactor_Ia,
        isVoltage ? data.VoltageEvenTHD_A : data.CurrentEvenTHD_A, data.PowerS_THD_A];
      break;
    case 1:
      fields = [isVoltage ? data.VoltageTHD_B : data.CurrentTHD_B, data.PowerP_THD_B, data.PowerF_THD_B,
        isVoltage ? data.VoltageOddTHD_B : data.CurrentOddTHD_B, data.PowerQ_THD_B,
        isVoltage ? data.PeakFactor_Ub : data.PeakFactor_Ib,
        isVoltage ? data.VoltageEvenTHD_B : data.CurrentEvenTHD_B, data.PowerS_THD_B];
      break;
    default:
      fields = [isVoltage ? data.VoltageTHD_C : data.CurrentTHD_C, data.PowerP_THD_C, data.PowerF_THD_C,
        isVoltage ? data.VoltageOddTHD_C : data.CurrentOddTHD_C, data.PowerQ_THD_C,
        isVoltage ? data.PeakFactor_Uc : data.PeakFactor_Ic,
        isVoltage ? data.VoltageEvenTHD_C : data.CurrentEvenTHD_C, data.PowerS_THD_C];
      break;
  }
  const labels: string[] = ['总谐波畸变率', '总谐波有功功率', '总谐波功率因数', '总奇次谐波畸变率',
    '总谐波无功功率', '峰值因子', '总偶次谐波畸变率', '总谐波视在功率'];
  const units: string[] = ['%', 'W', '', '%', 'Var', '', '%', 'VA'];
  return labels.map((label: string, index: number): HarmonicSummaryItem => {
    return { label: label, value: formatHarmonicValue(arrayValue(fields[index], 0), 2, units[index]) };
  });
}
