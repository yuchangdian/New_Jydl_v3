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
