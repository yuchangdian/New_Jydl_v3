@Observed
export class CommonSettingExceedingLimitData {
  delayTime: string = '00.00';
  lineVoltageUpperEnabled: string = '投入';
  lineVoltageUpperValue: string = '00.00';
  lineVoltageLowerEnabled: string = '投入';
  lineVoltageLowerValue: string = '00.00';
  zeroSequenceVoltageUpperEnabled: string = '投入';
  zeroSequenceVoltageUpperValue: string = '00.00';
  voltageImbalanceRateUpperEnabled: string = '投入';
  voltageImbalanceRateUpperValue: string = '00.00';
  phaseCurrentUpperEnabled: string = '投入';
  phaseCurrentUpperValue: string = '00.00';
  zeroSequenceCurrentUpperEnabled: string = '投入';
  zeroSequenceCurrentUpperValue: string = '00.00';
  currentImbalanceRateUpperEnabled: string = '投入';
  currentImbalanceRateUpperValue: string = '00.00';
  phaseDifferentialCurrentUpperEnabled: string = '投入';
  phaseDifferentialCurrentUpperValue: string = '00.00';
  zeroSequenceDifferentialCurrentUpperEnabled: string = '投入';
  zeroSequenceDifferentialCurrentUpperValue: string = '00.00';
  loadRateUpperEnabled: string = '投入';
  loadRateUpperValue: string = '00.00';

  assignFrom(source: CommonSettingExceedingLimitData): void {
    this.delayTime = source.delayTime;
    this.lineVoltageUpperEnabled = source.lineVoltageUpperEnabled;
    this.lineVoltageUpperValue = source.lineVoltageUpperValue;
    this.lineVoltageLowerEnabled = source.lineVoltageLowerEnabled;
    this.lineVoltageLowerValue = source.lineVoltageLowerValue;
    this.zeroSequenceVoltageUpperEnabled = source.zeroSequenceVoltageUpperEnabled;
    this.zeroSequenceVoltageUpperValue = source.zeroSequenceVoltageUpperValue;
    this.voltageImbalanceRateUpperEnabled = source.voltageImbalanceRateUpperEnabled;
    this.voltageImbalanceRateUpperValue = source.voltageImbalanceRateUpperValue;
    this.phaseCurrentUpperEnabled = source.phaseCurrentUpperEnabled;
    this.phaseCurrentUpperValue = source.phaseCurrentUpperValue;
    this.zeroSequenceCurrentUpperEnabled = source.zeroSequenceCurrentUpperEnabled;
    this.zeroSequenceCurrentUpperValue = source.zeroSequenceCurrentUpperValue;
    this.currentImbalanceRateUpperEnabled = source.currentImbalanceRateUpperEnabled;
    this.currentImbalanceRateUpperValue = source.currentImbalanceRateUpperValue;
    this.phaseDifferentialCurrentUpperEnabled = source.phaseDifferentialCurrentUpperEnabled;
    this.phaseDifferentialCurrentUpperValue = source.phaseDifferentialCurrentUpperValue;
    this.zeroSequenceDifferentialCurrentUpperEnabled = source.zeroSequenceDifferentialCurrentUpperEnabled;
    this.zeroSequenceDifferentialCurrentUpperValue = source.zeroSequenceDifferentialCurrentUpperValue;
    this.loadRateUpperEnabled = source.loadRateUpperEnabled;
    this.loadRateUpperValue = source.loadRateUpperValue;
  }
}

export const COMMON_SETTING_EXCEEDING_LIMIT_ENABLE_OPTIONS: string[] = ['投入', '退出'];

export function createDefaultCommonSettingExceedingLimitData(): CommonSettingExceedingLimitData {
  return new CommonSettingExceedingLimitData();
}

export function serializeCommonSettingExceedingLimitData(data: CommonSettingExceedingLimitData): string {
  return JSON.stringify({
    delayTime: data.delayTime,
    lineVoltageUpperEnabled: data.lineVoltageUpperEnabled,
    lineVoltageUpperValue: data.lineVoltageUpperValue,
    lineVoltageLowerEnabled: data.lineVoltageLowerEnabled,
    lineVoltageLowerValue: data.lineVoltageLowerValue,
    zeroSequenceVoltageUpperEnabled: data.zeroSequenceVoltageUpperEnabled,
    zeroSequenceVoltageUpperValue: data.zeroSequenceVoltageUpperValue,
    voltageImbalanceRateUpperEnabled: data.voltageImbalanceRateUpperEnabled,
    voltageImbalanceRateUpperValue: data.voltageImbalanceRateUpperValue,
    phaseCurrentUpperEnabled: data.phaseCurrentUpperEnabled,
    phaseCurrentUpperValue: data.phaseCurrentUpperValue,
    zeroSequenceCurrentUpperEnabled: data.zeroSequenceCurrentUpperEnabled,
    zeroSequenceCurrentUpperValue: data.zeroSequenceCurrentUpperValue,
    currentImbalanceRateUpperEnabled: data.currentImbalanceRateUpperEnabled,
    currentImbalanceRateUpperValue: data.currentImbalanceRateUpperValue,
    phaseDifferentialCurrentUpperEnabled: data.phaseDifferentialCurrentUpperEnabled,
    phaseDifferentialCurrentUpperValue: data.phaseDifferentialCurrentUpperValue,
    zeroSequenceDifferentialCurrentUpperEnabled: data.zeroSequenceDifferentialCurrentUpperEnabled,
    zeroSequenceDifferentialCurrentUpperValue: data.zeroSequenceDifferentialCurrentUpperValue,
    loadRateUpperEnabled: data.loadRateUpperEnabled,
    loadRateUpperValue: data.loadRateUpperValue
  });
}

export function deserializeCommonSettingExceedingLimitData(
  raw: string
): CommonSettingExceedingLimitData | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, string>;
    let data = createDefaultCommonSettingExceedingLimitData();
    if (!parsed || typeof parsed !== 'object') {
      return data;
    }

    data.delayTime = typeof parsed.delayTime === 'string' ? parsed.delayTime : data.delayTime;
    data.lineVoltageUpperEnabled = typeof parsed.lineVoltageUpperEnabled === 'string'
      ? parsed.lineVoltageUpperEnabled
      : data.lineVoltageUpperEnabled;
    data.lineVoltageUpperValue = typeof parsed.lineVoltageUpperValue === 'string'
      ? parsed.lineVoltageUpperValue
      : data.lineVoltageUpperValue;
    data.lineVoltageLowerEnabled = typeof parsed.lineVoltageLowerEnabled === 'string'
      ? parsed.lineVoltageLowerEnabled
      : data.lineVoltageLowerEnabled;
    data.lineVoltageLowerValue = typeof parsed.lineVoltageLowerValue === 'string'
      ? parsed.lineVoltageLowerValue
      : data.lineVoltageLowerValue;
    data.zeroSequenceVoltageUpperEnabled = typeof parsed.zeroSequenceVoltageUpperEnabled === 'string'
      ? parsed.zeroSequenceVoltageUpperEnabled
      : data.zeroSequenceVoltageUpperEnabled;
    data.zeroSequenceVoltageUpperValue = typeof parsed.zeroSequenceVoltageUpperValue === 'string'
      ? parsed.zeroSequenceVoltageUpperValue
      : data.zeroSequenceVoltageUpperValue;
    data.voltageImbalanceRateUpperEnabled = typeof parsed.voltageImbalanceRateUpperEnabled === 'string'
      ? parsed.voltageImbalanceRateUpperEnabled
      : data.voltageImbalanceRateUpperEnabled;
    data.voltageImbalanceRateUpperValue = typeof parsed.voltageImbalanceRateUpperValue === 'string'
      ? parsed.voltageImbalanceRateUpperValue
      : data.voltageImbalanceRateUpperValue;
    data.phaseCurrentUpperEnabled = typeof parsed.phaseCurrentUpperEnabled === 'string'
      ? parsed.phaseCurrentUpperEnabled
      : data.phaseCurrentUpperEnabled;
    data.phaseCurrentUpperValue = typeof parsed.phaseCurrentUpperValue === 'string'
      ? parsed.phaseCurrentUpperValue
      : data.phaseCurrentUpperValue;
    data.zeroSequenceCurrentUpperEnabled = typeof parsed.zeroSequenceCurrentUpperEnabled === 'string'
      ? parsed.zeroSequenceCurrentUpperEnabled
      : data.zeroSequenceCurrentUpperEnabled;
    data.zeroSequenceCurrentUpperValue = typeof parsed.zeroSequenceCurrentUpperValue === 'string'
      ? parsed.zeroSequenceCurrentUpperValue
      : data.zeroSequenceCurrentUpperValue;
    data.currentImbalanceRateUpperEnabled = typeof parsed.currentImbalanceRateUpperEnabled === 'string'
      ? parsed.currentImbalanceRateUpperEnabled
      : data.currentImbalanceRateUpperEnabled;
    data.currentImbalanceRateUpperValue = typeof parsed.currentImbalanceRateUpperValue === 'string'
      ? parsed.currentImbalanceRateUpperValue
      : data.currentImbalanceRateUpperValue;
    data.phaseDifferentialCurrentUpperEnabled = typeof parsed.phaseDifferentialCurrentUpperEnabled === 'string'
      ? parsed.phaseDifferentialCurrentUpperEnabled
      : data.phaseDifferentialCurrentUpperEnabled;
    data.phaseDifferentialCurrentUpperValue = typeof parsed.phaseDifferentialCurrentUpperValue === 'string'
      ? parsed.phaseDifferentialCurrentUpperValue
      : data.phaseDifferentialCurrentUpperValue;
    data.zeroSequenceDifferentialCurrentUpperEnabled = typeof parsed.zeroSequenceDifferentialCurrentUpperEnabled === 'string'
      ? parsed.zeroSequenceDifferentialCurrentUpperEnabled
      : data.zeroSequenceDifferentialCurrentUpperEnabled;
    data.zeroSequenceDifferentialCurrentUpperValue = typeof parsed.zeroSequenceDifferentialCurrentUpperValue === 'string'
      ? parsed.zeroSequenceDifferentialCurrentUpperValue
      : data.zeroSequenceDifferentialCurrentUpperValue;
    data.loadRateUpperEnabled = typeof parsed.loadRateUpperEnabled === 'string'
      ? parsed.loadRateUpperEnabled
      : data.loadRateUpperEnabled;
    data.loadRateUpperValue = typeof parsed.loadRateUpperValue === 'string'
      ? parsed.loadRateUpperValue
      : data.loadRateUpperValue;
    return data;
  } catch (error) {
    return undefined;
  }
}
