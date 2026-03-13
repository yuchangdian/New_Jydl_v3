@Observed
export class CommonSettingTeleControllingData {
  yk1SelectHoldingTime: string = '00.00';
  yk2SelectHoldingTime: string = '00.00';
  yk1TripHoldingTime: string = '00.00';
  yk2TripHoldingTime: string = '00.00';
  yk1CloseHoldingTime: string = '00.00';
  yk2CloseHoldingTime: string = '00.00';
  syncNoVoltage: string = '00.00';
  syncThereVoltage: string = '00.00';
  syncVoltageDifferenceBlock: string = '00.00';
  syncAngleDifferenceBlock: string = '00.00';
  syncFrequencyDifferenceBlock: string = '00.00';
  syncDelayTime: string = '00.00';
  syncBreakerCloseTime: string = '00.00';
  remoteCloseMode: string = '\u68c0\u540c\u671f';

  assignFrom(source: CommonSettingTeleControllingData): void {
    this.yk1SelectHoldingTime = source.yk1SelectHoldingTime;
    this.yk2SelectHoldingTime = source.yk2SelectHoldingTime;
    this.yk1TripHoldingTime = source.yk1TripHoldingTime;
    this.yk2TripHoldingTime = source.yk2TripHoldingTime;
    this.yk1CloseHoldingTime = source.yk1CloseHoldingTime;
    this.yk2CloseHoldingTime = source.yk2CloseHoldingTime;
    this.syncNoVoltage = source.syncNoVoltage;
    this.syncThereVoltage = source.syncThereVoltage;
    this.syncVoltageDifferenceBlock = source.syncVoltageDifferenceBlock;
    this.syncAngleDifferenceBlock = source.syncAngleDifferenceBlock;
    this.syncFrequencyDifferenceBlock = source.syncFrequencyDifferenceBlock;
    this.syncDelayTime = source.syncDelayTime;
    this.syncBreakerCloseTime = source.syncBreakerCloseTime;
    this.remoteCloseMode = source.remoteCloseMode;
  }
}

export const COMMON_SETTING_TELE_CONTROLLING_CLOSE_MODE_OPTIONS: string[] = [
  '\u68c0\u540c\u671f',
  '\u95ed\u9501',
  '\u666e\u901a',
  '\u68c0\u7ebf\u65e0\u538b\u4e14\u6bcd\u6709\u538b',
  '\u68c0\u7ebf\u6709\u538b\u4e14\u6bcd\u65e0\u538b',
  '\u68c0\u7ebf\u65e0\u538b\u4e14\u6bcd\u65e0\u538b',
  '\u68c0\u7ebf\u65e0\u538b\u6216\u6bcd\u65e0\u538b'
];

export function createDefaultCommonSettingTeleControllingData(): CommonSettingTeleControllingData {
  return new CommonSettingTeleControllingData();
}

export function serializeCommonSettingTeleControllingData(data: CommonSettingTeleControllingData): string {
  return JSON.stringify({
    yk1SelectHoldingTime: data.yk1SelectHoldingTime,
    yk2SelectHoldingTime: data.yk2SelectHoldingTime,
    yk1TripHoldingTime: data.yk1TripHoldingTime,
    yk2TripHoldingTime: data.yk2TripHoldingTime,
    yk1CloseHoldingTime: data.yk1CloseHoldingTime,
    yk2CloseHoldingTime: data.yk2CloseHoldingTime,
    syncNoVoltage: data.syncNoVoltage,
    syncThereVoltage: data.syncThereVoltage,
    syncVoltageDifferenceBlock: data.syncVoltageDifferenceBlock,
    syncAngleDifferenceBlock: data.syncAngleDifferenceBlock,
    syncFrequencyDifferenceBlock: data.syncFrequencyDifferenceBlock,
    syncDelayTime: data.syncDelayTime,
    syncBreakerCloseTime: data.syncBreakerCloseTime,
    remoteCloseMode: data.remoteCloseMode
  });
}

export function deserializeCommonSettingTeleControllingData(raw: string): CommonSettingTeleControllingData | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, string>;
    let data = createDefaultCommonSettingTeleControllingData();
    if (!parsed || typeof parsed !== 'object') {
      return data;
    }

    data.yk1SelectHoldingTime = typeof parsed.yk1SelectHoldingTime === 'string'
      ? parsed.yk1SelectHoldingTime
      : data.yk1SelectHoldingTime;
    data.yk2SelectHoldingTime = typeof parsed.yk2SelectHoldingTime === 'string'
      ? parsed.yk2SelectHoldingTime
      : data.yk2SelectHoldingTime;
    data.yk1TripHoldingTime = typeof parsed.yk1TripHoldingTime === 'string'
      ? parsed.yk1TripHoldingTime
      : data.yk1TripHoldingTime;
    data.yk2TripHoldingTime = typeof parsed.yk2TripHoldingTime === 'string'
      ? parsed.yk2TripHoldingTime
      : data.yk2TripHoldingTime;
    data.yk1CloseHoldingTime = typeof parsed.yk1CloseHoldingTime === 'string'
      ? parsed.yk1CloseHoldingTime
      : data.yk1CloseHoldingTime;
    data.yk2CloseHoldingTime = typeof parsed.yk2CloseHoldingTime === 'string'
      ? parsed.yk2CloseHoldingTime
      : data.yk2CloseHoldingTime;
    data.syncNoVoltage = typeof parsed.syncNoVoltage === 'string' ? parsed.syncNoVoltage : data.syncNoVoltage;
    data.syncThereVoltage = typeof parsed.syncThereVoltage === 'string'
      ? parsed.syncThereVoltage
      : data.syncThereVoltage;
    data.syncVoltageDifferenceBlock = typeof parsed.syncVoltageDifferenceBlock === 'string'
      ? parsed.syncVoltageDifferenceBlock
      : data.syncVoltageDifferenceBlock;
    data.syncAngleDifferenceBlock = typeof parsed.syncAngleDifferenceBlock === 'string'
      ? parsed.syncAngleDifferenceBlock
      : data.syncAngleDifferenceBlock;
    data.syncFrequencyDifferenceBlock = typeof parsed.syncFrequencyDifferenceBlock === 'string'
      ? parsed.syncFrequencyDifferenceBlock
      : data.syncFrequencyDifferenceBlock;
    data.syncDelayTime = typeof parsed.syncDelayTime === 'string' ? parsed.syncDelayTime : data.syncDelayTime;
    data.syncBreakerCloseTime = typeof parsed.syncBreakerCloseTime === 'string'
      ? parsed.syncBreakerCloseTime
      : data.syncBreakerCloseTime;
    data.remoteCloseMode = typeof parsed.remoteCloseMode === 'string'
      ? parsed.remoteCloseMode
      : data.remoteCloseMode;
    return data;
  } catch (error) {
    return undefined;
  }
}