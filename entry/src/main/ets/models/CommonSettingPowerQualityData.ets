@Observed
export class CommonSettingPowerQualityData {
  frequencyDeviationEnabled: string = '投入';
  frequencyDeviationValue: string = '5.00';
  voltageDeviationEnabled: string = '投入';
  voltageDeviationValue: string = '50.00';
  voltageUnbalanceEnabled: string = '投入';
  voltageUnbalanceValue: string = '50.00';
  voltageFluctuationEnabled: string = '投入';
  voltageFluctuationValue: string = '50.00';
  voltageFlickerEnabled: string = '投入';
  voltageFlickerValue: string = '1.00';
  voltageSagEnabled: string = '投入';
  voltageSagValue: string = '50.00';
  voltageThdEnabled: string = '投入';
  voltageThdValue: string = '50.00';
  voltageHarEnabled: string = '投入';
  voltageHarValue: string = '50.00';
  currentUnbalanceEnabled: string = '投入';
  currentUnbalanceValue: string = '50.00';
  currentThdEnabled: string = '投入';
  currentThdValue: string = '50.00';
  currentHarEnabled: string = '投入';
  currentHarValue: string = '50.00';

  assignFrom(source: CommonSettingPowerQualityData): void {
    this.frequencyDeviationEnabled = source.frequencyDeviationEnabled;
    this.frequencyDeviationValue = source.frequencyDeviationValue;
    this.voltageDeviationEnabled = source.voltageDeviationEnabled;
    this.voltageDeviationValue = source.voltageDeviationValue;
    this.voltageUnbalanceEnabled = source.voltageUnbalanceEnabled;
    this.voltageUnbalanceValue = source.voltageUnbalanceValue;
    this.voltageFluctuationEnabled = source.voltageFluctuationEnabled;
    this.voltageFluctuationValue = source.voltageFluctuationValue;
    this.voltageFlickerEnabled = source.voltageFlickerEnabled;
    this.voltageFlickerValue = source.voltageFlickerValue;
    this.voltageSagEnabled = source.voltageSagEnabled;
    this.voltageSagValue = source.voltageSagValue;
    this.voltageThdEnabled = source.voltageThdEnabled;
    this.voltageThdValue = source.voltageThdValue;
    this.voltageHarEnabled = source.voltageHarEnabled;
    this.voltageHarValue = source.voltageHarValue;
    this.currentUnbalanceEnabled = source.currentUnbalanceEnabled;
    this.currentUnbalanceValue = source.currentUnbalanceValue;
    this.currentThdEnabled = source.currentThdEnabled;
    this.currentThdValue = source.currentThdValue;
    this.currentHarEnabled = source.currentHarEnabled;
    this.currentHarValue = source.currentHarValue;
  }
}

export const COMMON_SETTING_POWER_QUALITY_ENABLE_OPTIONS: string[] = ['投入', '退出'];

export function createDefaultCommonSettingPowerQualityData(): CommonSettingPowerQualityData {
  return new CommonSettingPowerQualityData();
}

export function serializeCommonSettingPowerQualityData(data: CommonSettingPowerQualityData): string {
  return JSON.stringify({
    frequencyDeviationEnabled: data.frequencyDeviationEnabled,
    frequencyDeviationValue: data.frequencyDeviationValue,
    voltageDeviationEnabled: data.voltageDeviationEnabled,
    voltageDeviationValue: data.voltageDeviationValue,
    voltageUnbalanceEnabled: data.voltageUnbalanceEnabled,
    voltageUnbalanceValue: data.voltageUnbalanceValue,
    voltageFluctuationEnabled: data.voltageFluctuationEnabled,
    voltageFluctuationValue: data.voltageFluctuationValue,
    voltageFlickerEnabled: data.voltageFlickerEnabled,
    voltageFlickerValue: data.voltageFlickerValue,
    voltageSagEnabled: data.voltageSagEnabled,
    voltageSagValue: data.voltageSagValue,
    voltageThdEnabled: data.voltageThdEnabled,
    voltageThdValue: data.voltageThdValue,
    voltageHarEnabled: data.voltageHarEnabled,
    voltageHarValue: data.voltageHarValue,
    currentUnbalanceEnabled: data.currentUnbalanceEnabled,
    currentUnbalanceValue: data.currentUnbalanceValue,
    currentThdEnabled: data.currentThdEnabled,
    currentThdValue: data.currentThdValue,
    currentHarEnabled: data.currentHarEnabled,
    currentHarValue: data.currentHarValue
  });
}

export function deserializeCommonSettingPowerQualityData(raw: string): CommonSettingPowerQualityData | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, string>;
    let data = createDefaultCommonSettingPowerQualityData();
    if (!parsed || typeof parsed !== 'object') {
      return data;
    }

    data.frequencyDeviationEnabled = typeof parsed.frequencyDeviationEnabled === 'string'
      ? parsed.frequencyDeviationEnabled
      : data.frequencyDeviationEnabled;
    data.frequencyDeviationValue = typeof parsed.frequencyDeviationValue === 'string'
      ? parsed.frequencyDeviationValue
      : data.frequencyDeviationValue;
    data.voltageDeviationEnabled = typeof parsed.voltageDeviationEnabled === 'string'
      ? parsed.voltageDeviationEnabled
      : data.voltageDeviationEnabled;
    data.voltageDeviationValue = typeof parsed.voltageDeviationValue === 'string'
      ? parsed.voltageDeviationValue
      : data.voltageDeviationValue;
    data.voltageUnbalanceEnabled = typeof parsed.voltageUnbalanceEnabled === 'string'
      ? parsed.voltageUnbalanceEnabled
      : data.voltageUnbalanceEnabled;
    data.voltageUnbalanceValue = typeof parsed.voltageUnbalanceValue === 'string'
      ? parsed.voltageUnbalanceValue
      : data.voltageUnbalanceValue;
    data.voltageFluctuationEnabled = typeof parsed.voltageFluctuationEnabled === 'string'
      ? parsed.voltageFluctuationEnabled
      : data.voltageFluctuationEnabled;
    data.voltageFluctuationValue = typeof parsed.voltageFluctuationValue === 'string'
      ? parsed.voltageFluctuationValue
      : data.voltageFluctuationValue;
    data.voltageFlickerEnabled = typeof parsed.voltageFlickerEnabled === 'string'
      ? parsed.voltageFlickerEnabled
      : data.voltageFlickerEnabled;
    data.voltageFlickerValue = typeof parsed.voltageFlickerValue === 'string'
      ? parsed.voltageFlickerValue
      : data.voltageFlickerValue;
    data.voltageSagEnabled = typeof parsed.voltageSagEnabled === 'string'
      ? parsed.voltageSagEnabled
      : data.voltageSagEnabled;
    data.voltageSagValue = typeof parsed.voltageSagValue === 'string'
      ? parsed.voltageSagValue
      : data.voltageSagValue;
    data.voltageThdEnabled = typeof parsed.voltageThdEnabled === 'string'
      ? parsed.voltageThdEnabled
      : data.voltageThdEnabled;
    data.voltageThdValue = typeof parsed.voltageThdValue === 'string'
      ? parsed.voltageThdValue
      : data.voltageThdValue;
    data.voltageHarEnabled = typeof parsed.voltageHarEnabled === 'string'
      ? parsed.voltageHarEnabled
      : data.voltageHarEnabled;
    data.voltageHarValue = typeof parsed.voltageHarValue === 'string'
      ? parsed.voltageHarValue
      : data.voltageHarValue;
    data.currentUnbalanceEnabled = typeof parsed.currentUnbalanceEnabled === 'string'
      ? parsed.currentUnbalanceEnabled
      : data.currentUnbalanceEnabled;
    data.currentUnbalanceValue = typeof parsed.currentUnbalanceValue === 'string'
      ? parsed.currentUnbalanceValue
      : data.currentUnbalanceValue;
    data.currentThdEnabled = typeof parsed.currentThdEnabled === 'string'
      ? parsed.currentThdEnabled
      : data.currentThdEnabled;
    data.currentThdValue = typeof parsed.currentThdValue === 'string'
      ? parsed.currentThdValue
      : data.currentThdValue;
    data.currentHarEnabled = typeof parsed.currentHarEnabled === 'string'
      ? parsed.currentHarEnabled
      : data.currentHarEnabled;
    data.currentHarValue = typeof parsed.currentHarValue === 'string'
      ? parsed.currentHarValue
      : data.currentHarValue;
    return data;
  } catch (error) {
    return undefined;
  }
}
