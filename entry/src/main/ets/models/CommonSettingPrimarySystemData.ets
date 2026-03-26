@Observed
export class CommonSettingPrimarySystemData {
  busPtPrimary: string = '10.0';
  busPtSecondary: string = '100';
  busZeroPtPrimary: string = '10.0';
  busZeroPtSecondary: string = '100';
  linePtPrimary: string = '10.0';
  linePtSecondary: string = '100';
  protectCtPrimary: string = '600';
  protectCtSecondary: string = '5';
  zeroCtPrimary: string = '120';
  zeroCtSecondary: string = '5';
  measureCtPrimary: string = '600';
  measureCtSecondary: string = '5';
  ratedPower: string = '1200';
  linePhase: string = 'A相';
  ctConnectionMode: string = '两相式';
  zeroCurrentMode: string = '外部';

  assignFrom(source: CommonSettingPrimarySystemData): void {
    this.busPtPrimary = source.busPtPrimary;
    this.busPtSecondary = source.busPtSecondary;
    this.busZeroPtPrimary = source.busZeroPtPrimary;
    this.busZeroPtSecondary = source.busZeroPtSecondary;
    this.linePtPrimary = source.linePtPrimary;
    this.linePtSecondary = source.linePtSecondary;
    this.protectCtPrimary = source.protectCtPrimary;
    this.protectCtSecondary = source.protectCtSecondary;
    this.zeroCtPrimary = source.zeroCtPrimary;
    this.zeroCtSecondary = source.zeroCtSecondary;
    this.measureCtPrimary = source.measureCtPrimary;
    this.measureCtSecondary = source.measureCtSecondary;
    this.ratedPower = source.ratedPower;
    this.linePhase = source.linePhase;
    this.ctConnectionMode = source.ctConnectionMode;
    this.zeroCurrentMode = source.zeroCurrentMode;
  }
}

export const COMMON_SETTING_PRIMARY_SYSTEM_LINE_PHASE_OPTIONS: string[] = [
  'A相', 'B相', 'C相', 'AB相', 'CA相', 'BC相', '三相'
];

export const COMMON_SETTING_PRIMARY_SYSTEM_CT_CONNECTION_OPTIONS: string[] = [
  '两相式', '三相式'
];

export const COMMON_SETTING_PRIMARY_SYSTEM_ZERO_CURRENT_OPTIONS: string[] = [
  '外部', '自产'
];

export function createDefaultCommonSettingPrimarySystemData(): CommonSettingPrimarySystemData {
  return new CommonSettingPrimarySystemData();
}

export function cloneCommonSettingPrimarySystemData(
  source: CommonSettingPrimarySystemData
): CommonSettingPrimarySystemData {
  let next = createDefaultCommonSettingPrimarySystemData();
  next.assignFrom(source);
  return next;
}

export interface CommonSettingPrimarySystemStructValue {
  ready: boolean;
  SystemGroundingMode: number;
  PTp_Bus_Primary: number;
  PTp_Bus_Secondary: number;
  PTo_Bus_Primary: number;
  PTo_Bus_Secondary: number;
  PT_Line_Primary: number;
  PT_Line_Secondary: number;
  PT_Line_Phase: number;
  PT_Line_Phase_Text: string;
  CTp_Protection_Primary: number;
  CTp_Protection_Secondary: number;
  CTo_Primary: number;
  CTo_Secondary: number;
  CTp_Measure_Primary: number;
  CTp_Measure_Secondary: number;
  Mode_CTConnectioin: number;
  Mode_CTConnectioin_Text: string;
  Mode_Iosample: number;
  Mode_Iosample_Text: string;
  RatedPower_Line: number;
  CRC: number;
}

function formatPrimarySystemNumber(value: number, minFractionDigits: number = 0): string {
  if (typeof value !== 'number' || !isFinite(value)) {
    return '';
  }

  let text = value.toFixed(4).replace(/0+$/, '').replace(/\.$/, '');
  if (text.length === 0) {
    text = '0';
  }
  if (minFractionDigits > 0 && text.indexOf('.') < 0) {
    text += '.0';
  }
  return text;
}

function isValidPrimarySystemNumber(value: number): boolean {
  return typeof value === 'number' && isFinite(value);
}

function normalizePrimarySystemLinePhase(value: string): string {
  if (value === 'ABC相') {
    return '三相';
  }
  return value;
}

export function isUsableCommonSettingPrimarySystemStructValue(
  source: CommonSettingPrimarySystemStructValue | undefined
): boolean {
  if (!source || !source.ready) {
    return false;
  }

  return isValidPrimarySystemNumber(source.PTp_Bus_Primary) &&
    isValidPrimarySystemNumber(source.PTp_Bus_Secondary) &&
    isValidPrimarySystemNumber(source.PTo_Bus_Primary) &&
    isValidPrimarySystemNumber(source.PTo_Bus_Secondary) &&
    isValidPrimarySystemNumber(source.PT_Line_Primary) &&
    isValidPrimarySystemNumber(source.PT_Line_Secondary) &&
    isValidPrimarySystemNumber(source.CTp_Protection_Primary) &&
    isValidPrimarySystemNumber(source.CTp_Protection_Secondary) &&
    isValidPrimarySystemNumber(source.CTo_Primary) &&
    isValidPrimarySystemNumber(source.CTo_Secondary) &&
    isValidPrimarySystemNumber(source.CTp_Measure_Primary) &&
    isValidPrimarySystemNumber(source.CTp_Measure_Secondary) &&
    isValidPrimarySystemNumber(source.RatedPower_Line);
}

export function createCommonSettingPrimarySystemDataFromStruct(
  source: CommonSettingPrimarySystemStructValue
): CommonSettingPrimarySystemData {
  let data = createDefaultCommonSettingPrimarySystemData();
  let busPtPrimary = formatPrimarySystemNumber(source.PTp_Bus_Primary, 1);
  if (busPtPrimary.length > 0) {
    data.busPtPrimary = busPtPrimary;
  }
  let busPtSecondary = formatPrimarySystemNumber(source.PTp_Bus_Secondary);
  if (busPtSecondary.length > 0) {
    data.busPtSecondary = busPtSecondary;
  }
  let busZeroPtPrimary = formatPrimarySystemNumber(source.PTo_Bus_Primary, 1);
  if (busZeroPtPrimary.length > 0) {
    data.busZeroPtPrimary = busZeroPtPrimary;
  }
  let busZeroPtSecondary = formatPrimarySystemNumber(source.PTo_Bus_Secondary);
  if (busZeroPtSecondary.length > 0) {
    data.busZeroPtSecondary = busZeroPtSecondary;
  }
  let linePtPrimary = formatPrimarySystemNumber(source.PT_Line_Primary, 1);
  if (linePtPrimary.length > 0) {
    data.linePtPrimary = linePtPrimary;
  }
  let linePtSecondary = formatPrimarySystemNumber(source.PT_Line_Secondary);
  if (linePtSecondary.length > 0) {
    data.linePtSecondary = linePtSecondary;
  }
  let protectCtPrimary = formatPrimarySystemNumber(source.CTp_Protection_Primary);
  if (protectCtPrimary.length > 0) {
    data.protectCtPrimary = protectCtPrimary;
  }
  let protectCtSecondary = formatPrimarySystemNumber(source.CTp_Protection_Secondary);
  if (protectCtSecondary.length > 0) {
    data.protectCtSecondary = protectCtSecondary;
  }
  let zeroCtPrimary = formatPrimarySystemNumber(source.CTo_Primary);
  if (zeroCtPrimary.length > 0) {
    data.zeroCtPrimary = zeroCtPrimary;
  }
  let zeroCtSecondary = formatPrimarySystemNumber(source.CTo_Secondary);
  if (zeroCtSecondary.length > 0) {
    data.zeroCtSecondary = zeroCtSecondary;
  }
  let measureCtPrimary = formatPrimarySystemNumber(source.CTp_Measure_Primary);
  if (measureCtPrimary.length > 0) {
    data.measureCtPrimary = measureCtPrimary;
  }
  let measureCtSecondary = formatPrimarySystemNumber(source.CTp_Measure_Secondary);
  if (measureCtSecondary.length > 0) {
    data.measureCtSecondary = measureCtSecondary;
  }
  let ratedPower = formatPrimarySystemNumber(source.RatedPower_Line);
  if (ratedPower.length > 0) {
    data.ratedPower = ratedPower;
  }
  let linePhaseText = normalizePrimarySystemLinePhase(source.PT_Line_Phase_Text);
  if (linePhaseText.length > 0) {
    data.linePhase = linePhaseText;
  }
  if (source.Mode_CTConnectioin_Text.length > 0) {
    data.ctConnectionMode = source.Mode_CTConnectioin_Text;
  }
  if (source.Mode_Iosample_Text.length > 0) {
    data.zeroCurrentMode = source.Mode_Iosample_Text;
  }
  return data;
}

export function serializeCommonSettingPrimarySystemData(data: CommonSettingPrimarySystemData): string {
  return JSON.stringify({
    busPtPrimary: data.busPtPrimary,
    busPtSecondary: data.busPtSecondary,
    busZeroPtPrimary: data.busZeroPtPrimary,
    busZeroPtSecondary: data.busZeroPtSecondary,
    linePtPrimary: data.linePtPrimary,
    linePtSecondary: data.linePtSecondary,
    protectCtPrimary: data.protectCtPrimary,
    protectCtSecondary: data.protectCtSecondary,
    zeroCtPrimary: data.zeroCtPrimary,
    zeroCtSecondary: data.zeroCtSecondary,
    measureCtPrimary: data.measureCtPrimary,
    measureCtSecondary: data.measureCtSecondary,
    ratedPower: data.ratedPower,
    linePhase: data.linePhase,
    ctConnectionMode: data.ctConnectionMode,
    zeroCurrentMode: data.zeroCurrentMode
  });
}

export function deserializeCommonSettingPrimarySystemData(raw: string): CommonSettingPrimarySystemData | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, string>;
    let data = createDefaultCommonSettingPrimarySystemData();
    if (!parsed || typeof parsed !== 'object') {
      return data;
    }

    data.busPtPrimary = typeof parsed.busPtPrimary === 'string' ? parsed.busPtPrimary : data.busPtPrimary;
    data.busPtSecondary = typeof parsed.busPtSecondary === 'string' ? parsed.busPtSecondary : data.busPtSecondary;
    data.busZeroPtPrimary = typeof parsed.busZeroPtPrimary === 'string' ? parsed.busZeroPtPrimary : data.busZeroPtPrimary;
    data.busZeroPtSecondary = typeof parsed.busZeroPtSecondary === 'string' ? parsed.busZeroPtSecondary : data.busZeroPtSecondary;
    data.linePtPrimary = typeof parsed.linePtPrimary === 'string' ? parsed.linePtPrimary : data.linePtPrimary;
    data.linePtSecondary = typeof parsed.linePtSecondary === 'string' ? parsed.linePtSecondary : data.linePtSecondary;
    data.protectCtPrimary = typeof parsed.protectCtPrimary === 'string' ? parsed.protectCtPrimary : data.protectCtPrimary;
    data.protectCtSecondary = typeof parsed.protectCtSecondary === 'string' ? parsed.protectCtSecondary : data.protectCtSecondary;
    data.zeroCtPrimary = typeof parsed.zeroCtPrimary === 'string' ? parsed.zeroCtPrimary : data.zeroCtPrimary;
    data.zeroCtSecondary = typeof parsed.zeroCtSecondary === 'string' ? parsed.zeroCtSecondary : data.zeroCtSecondary;
    data.measureCtPrimary = typeof parsed.measureCtPrimary === 'string' ? parsed.measureCtPrimary : data.measureCtPrimary;
    data.measureCtSecondary = typeof parsed.measureCtSecondary === 'string' ? parsed.measureCtSecondary : data.measureCtSecondary;
    data.ratedPower = typeof parsed.ratedPower === 'string' ? parsed.ratedPower : data.ratedPower;
    data.linePhase = typeof parsed.linePhase === 'string' ? parsed.linePhase : data.linePhase;
    data.ctConnectionMode = typeof parsed.ctConnectionMode === 'string' ? parsed.ctConnectionMode : data.ctConnectionMode;
    data.zeroCurrentMode = typeof parsed.zeroCurrentMode === 'string' ? parsed.zeroCurrentMode : data.zeroCurrentMode;
    return data;
  } catch (error) {
    return undefined;
  }
}
