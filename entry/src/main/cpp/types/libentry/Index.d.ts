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

export interface CommonSettingPrimarySystemWriteValue {
  SystemGroundingMode: number;
  PTp_Bus_Primary: number;
  PTp_Bus_Secondary: number;
  PTo_Bus_Primary: number;
  PTo_Bus_Secondary: number;
  PT_Line_Primary: number;
  PT_Line_Secondary: number;
  PT_Line_Phase: number;
  CTp_Protection_Primary: number;
  CTp_Protection_Secondary: number;
  CTo_Primary: number;
  CTo_Secondary: number;
  CTp_Measure_Primary: number;
  CTp_Measure_Secondary: number;
  Mode_CTConnectioin: number;
  Mode_Iosample: number;
  RatedPower_Line: number;
}

export interface BaseFreqDisplayValue {
  ready: boolean;
  Ua_Rms: number;
  Ua_Phase: number;
  Ub_Rms: number;
  Ub_Phase: number;
  Uc_Rms: number;
  Uc_Phase: number;
  Uo_Rms: number;
  Uo_Phase: number;
  Ux_Rms: number;
  Ux_Phase: number;
  IA_Rms: number;
  IA_Phase: number;
  IB_Rms: number;
  IB_Phase: number;
  IC_Rms: number;
  IC_Phase: number;
  Io_Rms: number;
  Io_Phase: number;
  Ia_Rms: number;
  Ia_Phase: number;
  Ib_Rms: number;
  Ib_Phase: number;
  Ic_Rms: number;
  Ic_Phase: number;
}

export interface HarmonicCurrentDisplayValue {
  ready: boolean;
  Ia: number[];
  Ib: number[];
  Ic: number[];
}

export interface HarmonicVoltageDisplayValue {
  ready: boolean;
  Ua: number[];
  Ub: number[];
  Uc: number[];
}

export interface CommonSettingAnalogQuantityParameterStructValue {
  Ua: number;
  Ub: number;
  Uc: number;
  Uo: number;
  IA: number;
  IB: number;
  IC: number;
  Io: number;
  Ia: number;
  Ib: number;
  Ic: number;
  Is: number;
  Ux: number;
  Iby1: number;
  Iby2: number;
  Iby3: number;
}

export interface CommonSettingAnalogQuantityStructValue {
  ready: boolean;
  Reference: CommonSettingAnalogQuantityParameterStructValue;
  Correction: CommonSettingAnalogQuantityParameterStructValue;
  ZeroDrift: CommonSettingAnalogQuantityParameterStructValue;
  CRC: number;
}

export interface CommonSettingAnalogQuantityWriteParameterValue {
  Ua: number;
  Ub: number;
  Uc: number;
  Uo: number;
  IA: number;
  IB: number;
  IC: number;
  Io: number;
  Ia: number;
  Ib: number;
  Ic: number;
  Is: number;
  Ux: number;
  Iby1: number;
  Iby2: number;
  Iby3: number;
}

export interface CommonSettingAnalogQuantityWriteValue {
  Reference: CommonSettingAnalogQuantityWriteParameterValue;
  Correction: CommonSettingAnalogQuantityWriteParameterValue;
  ZeroDrift: CommonSettingAnalogQuantityWriteParameterValue;
}

export interface CommonSettingTeleMeasuringStructValue {
  ready: boolean;
  Cycle_Detection: number;
  DeadBand_Frequency: number;
  DeadBand_ACvoltage: number;
  DeadBand_DCvoltage: number;
  DeadBand_ACcurrent: number;
  DeadBand_Power: number;
  DeadBand_PowerFactor: number;
  Enable_PrimaryEnergy: number;
  CRC: number;
}

export interface CommonSettingTeleMeasuringWriteValue {
  Cycle_Detection: number;
  DeadBand_Frequency: number;
  DeadBand_ACvoltage: number;
  DeadBand_DCvoltage: number;
  DeadBand_ACcurrent: number;
  DeadBand_Power: number;
  DeadBand_PowerFactor: number;
  Enable_PrimaryEnergy: number;
}

export interface CommonSettingTeleSignalingStructValue {
  ready: boolean;
  YX01_Time: number;
  YX02_Time: number;
  YX03_Time: number;
  YX04_Time: number;
  YX05_Time: number;
  YX06_Time: number;
  YX07_Time: number;
  YX08_Time: number;
  Enable_Logic: number;
  CRC: number;
}

export interface CommonSettingTeleSignalingWriteValue {
  YX01_Time: number;
  YX02_Time: number;
  YX03_Time: number;
  YX04_Time: number;
  YX05_Time: number;
  YX06_Time: number;
  YX07_Time: number;
  YX08_Time: number;
  Enable_Logic: number;
}

export interface CommonSettingTeleControllingStructValue {
  ready: boolean;
  HoldingTime_YK1_XZ: number;
  HoldingTime_YK1_TZ: number;
  HoldingTime_YK1_HZ: number;
  HoldingTime_YK2_XZ: number;
  HoldingTime_YK2_TZ: number;
  HoldingTime_YK2_HZ: number;
  Sync_NoVoltage: number;
  Sync_ThereVoltage: number;
  Sync_Volue_VoltageDifferenceBlock: number;
  Sync_Volue_AngleDifferenceBlock: number;
  Sync_Volue_FrequencyDifferenceBlock: number;
  Sync_DelayTime: number;
  Sync_BreakerCloseTime: number;
  Sync_Enable_CloseMode_YK: number;
  CRC: number;
}

export interface CommonSettingTeleControllingWriteValue {
  HoldingTime_YK1_XZ: number;
  HoldingTime_YK1_TZ: number;
  HoldingTime_YK1_HZ: number;
  HoldingTime_YK2_XZ: number;
  HoldingTime_YK2_TZ: number;
  HoldingTime_YK2_HZ: number;
  Sync_NoVoltage: number;
  Sync_ThereVoltage: number;
  Sync_Volue_VoltageDifferenceBlock: number;
  Sync_Volue_AngleDifferenceBlock: number;
  Sync_Volue_FrequencyDifferenceBlock: number;
  Sync_DelayTime: number;
  Sync_BreakerCloseTime: number;
  Sync_Enable_CloseMode_YK: number;
}

export interface CommonSettingExceedingLimitStructValue {
  ready: boolean;
  Enable_LineVoltageExceedingUpperLimit: number;
  Value_LineVoltageExceedingUpperLimit: number;
  Enable_LineVoltageExceedingLowerLimit: number;
  Value_LineVoltageExceedingLowerLimit: number;
  Enable_ZeroSequenceVoltageExceedingUpperLimit: number;
  Value_ZeroSequenceVoltageExceedingUpperLimit: number;
  Enable_VoltageImbalanceRateExceedingUpperLimit: number;
  Value_VoltageImbalanceRateExceedingUpperLimit: number;
  Enable_PhaseCurrentExceedingUpperLimit: number;
  Value_PhaseCurrentExceedingUpperLimit: number;
  Enable_ZeroSequenceCurrentExceedingUpperLimit: number;
  Value_ZeroSequenceCurrentExceedingUpperLimit: number;
  Enable_CurrentImbalanceRateExceedingUpperLimit: number;
  Value_CurrentImbalanceRateExceedingUpperLimit: number;
  Enable_PhaseDifferentialCurrentExceedingUpperLimit: number;
  Value_PhaseDifferentialCurrentExceedingUpperLimit: number;
  Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit: number;
  Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit: number;
  Enable_LoadRateExceedingUpperLimit: number;
  Value_LoadRateRateExceedingUpperLimit: number;
  Time_Delay: number;
  CRC: number;
}

export interface CommonSettingExceedingLimitWriteValue {
  Enable_LineVoltageExceedingUpperLimit: number;
  Value_LineVoltageExceedingUpperLimit: number;
  Enable_LineVoltageExceedingLowerLimit: number;
  Value_LineVoltageExceedingLowerLimit: number;
  Enable_ZeroSequenceVoltageExceedingUpperLimit: number;
  Value_ZeroSequenceVoltageExceedingUpperLimit: number;
  Enable_VoltageImbalanceRateExceedingUpperLimit: number;
  Value_VoltageImbalanceRateExceedingUpperLimit: number;
  Enable_PhaseCurrentExceedingUpperLimit: number;
  Value_PhaseCurrentExceedingUpperLimit: number;
  Enable_ZeroSequenceCurrentExceedingUpperLimit: number;
  Value_ZeroSequenceCurrentExceedingUpperLimit: number;
  Enable_CurrentImbalanceRateExceedingUpperLimit: number;
  Value_CurrentImbalanceRateExceedingUpperLimit: number;
  Enable_PhaseDifferentialCurrentExceedingUpperLimit: number;
  Value_PhaseDifferentialCurrentExceedingUpperLimit: number;
  Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit: number;
  Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit: number;
  Enable_LoadRateExceedingUpperLimit: number;
  Value_LoadRateRateExceedingUpperLimit: number;
  Time_Delay: number;
}

export interface CommonSettingPowerQualityStructValue {
  ready: boolean;
  Enable_FrequencyDeviation: number;
  Value_FrequencyDeviation: number;
  Enable_VoltageDeviation: number;
  Value_VoltageDeviation: number;
  Enable_VoltageUnbalance: number;
  Value_VoltageUnbalance: number;
  Enable_VoltageFluct: number;
  Value_VoltageFluct: number;
  Enable_VoltageFlicke: number;
  Value_VoltageFlicke: number;
  Enable_VoltageSeg: number;
  Value_VoltageSeg: number;
  Enable_VoltageTHD: number;
  Value_VoltageTHD: number;
  Enable_VoltageHAR: number;
  Value_VoltageHAR: number;
  Enable_CurrentUnbalance: number;
  Value_CurrentUnbalance: number;
  Enable_CurrentTHD: number;
  Value_CurrentTHD: number;
  Enable_CurrentHAR: number;
  Value_CurrentHAR: number;
  CRC: number;
}

export interface CommonSettingPowerQualityWriteValue {
  Enable_FrequencyDeviation: number;
  Value_FrequencyDeviation: number;
  Enable_VoltageDeviation: number;
  Value_VoltageDeviation: number;
  Enable_VoltageUnbalance: number;
  Value_VoltageUnbalance: number;
  Enable_VoltageFluct: number;
  Value_VoltageFluct: number;
  Enable_VoltageFlicke: number;
  Value_VoltageFlicke: number;
  Enable_VoltageSeg: number;
  Value_VoltageSeg: number;
  Enable_VoltageTHD: number;
  Value_VoltageTHD: number;
  Enable_VoltageHAR: number;
  Value_VoltageHAR: number;
  Enable_CurrentUnbalance: number;
  Value_CurrentUnbalance: number;
  Enable_CurrentTHD: number;
  Value_CurrentTHD: number;
  Enable_CurrentHAR: number;
  Value_CurrentHAR: number;
}

export interface CommonSettingStatisticsStructValue {
  ready: boolean;
  Enable_Bus: number;
  Enable_Line: number;
  Enable_VoltageMaxValue: number;
  PeriodType_VoltageMaxValue: number;
  PeriodLength_VoltageMaxValue: number;
  Enable_VoltageMinValue: number;
  PeriodType_VoltageMinValue: number;
  PeriodLength_VoltageMinValue: number;
  Enable_VoltageOnTimeValue: number;
  PeriodType_VoltageOnTimeValue: number;
  PeriodLength_VoltageOnTimeValue: number;
  Enable_VoltageImbalanceMaxValue: number;
  PeriodType_VoltageImbalanceMaxValue: number;
  PeriodLength_VoltageImbalanceMaxValue: number;
  Enable_VoltageQualifiedRateOnTimeValue: number;
  PeriodType_VoltageQualifiedRateOnTimeValue: number;
  PeriodLength_VoltageQualifiedRateOnTimeValue: number;
  Enable_CurrentMaxValue: number;
  PeriodType_CurrentMaxValue: number;
  PeriodLength_CurrentMaxValue: number;
  Enable_CurrentMinValue: number;
  PeriodType_CurrentMinValue: number;
  PeriodLength_CurrentMinValue: number;
  Enable_CurrentOnTimeValue: number;
  PeriodType_CurrentOnTimeValue: number;
  PeriodLength_CurrentOnTimeValue: number;
  Enable_CurrentImbalanceMaxValue: number;
  PeriodType_CurrentImbalanceMaxValue: number;
  PeriodLength_CurrentImbalanceMaxValue: number;
  Enable_PowerMaxValue: number;
  PeriodType_PowerMaxValue: number;
  PeriodLength_PowerMaxValue: number;
  Enable_PowerOnTimeValue: number;
  PeriodType_PowerOnTimeValue: number;
  PeriodLength_PowerOnTimeValue: number;
  Enable_PowerFactorMaxValue: number;
  PeriodType_PowerFactorMaxValue: number;
  PeriodLength_PowerFactorMaxValue: number;
  Enable_PowerFactorOnTimeValue: number;
  PeriodType_PowerFactorrOnTimeValue: number;
  PeriodLength_PowerFactorOnTimeValue: number;
  Enable_LoadRateOnTimeValue: number;
  PeriodType_LoadRateOnTimeValue: number;
  PeriodLength_LoadRateOnTimeValue: number;
  Enable_PositiveActivePowerOnTimeValue: number;
  PeriodType_PositiveActivePowerOnTimeValue: number;
  PeriodLength_PositiveActivePowerOnTimeValue: number;
  Enable_PositiveReactivePowerOnTimeValue: number;
  PeriodType_PositiveReactivePowerOnTimeValue: number;
  PeriodLength_PositiveReactivePowerOnTimeValue: number;
  Enable_ReverseActivePowerOnTimeValue: number;
  PeriodType_ReverseActivePowerOnTimeValue: number;
  PeriodLength_ReverseActivePowerOnTimeValue: number;
  Enable_ReverseReactivePowerOnTimeValue: number;
  PeriodType_ReverseReactivePowerOnTimeValue: number;
  PeriodLength_ReverseReactivePowerOnTimeValue: number;
  CRC: number;
}

export interface CommonSettingStatisticsWriteValue {
  Enable_Bus: number;
  Enable_Line: number;
  Enable_VoltageMaxValue: number;
  PeriodType_VoltageMaxValue: number;
  PeriodLength_VoltageMaxValue: number;
  Enable_VoltageMinValue: number;
  PeriodType_VoltageMinValue: number;
  PeriodLength_VoltageMinValue: number;
  Enable_VoltageOnTimeValue: number;
  PeriodType_VoltageOnTimeValue: number;
  PeriodLength_VoltageOnTimeValue: number;
  Enable_VoltageImbalanceMaxValue: number;
  PeriodType_VoltageImbalanceMaxValue: number;
  PeriodLength_VoltageImbalanceMaxValue: number;
  Enable_VoltageQualifiedRateOnTimeValue: number;
  PeriodType_VoltageQualifiedRateOnTimeValue: number;
  PeriodLength_VoltageQualifiedRateOnTimeValue: number;
  Enable_CurrentMaxValue: number;
  PeriodType_CurrentMaxValue: number;
  PeriodLength_CurrentMaxValue: number;
  Enable_CurrentMinValue: number;
  PeriodType_CurrentMinValue: number;
  PeriodLength_CurrentMinValue: number;
  Enable_CurrentOnTimeValue: number;
  PeriodType_CurrentOnTimeValue: number;
  PeriodLength_CurrentOnTimeValue: number;
  Enable_CurrentImbalanceMaxValue: number;
  PeriodType_CurrentImbalanceMaxValue: number;
  PeriodLength_CurrentImbalanceMaxValue: number;
  Enable_PowerMaxValue: number;
  PeriodType_PowerMaxValue: number;
  PeriodLength_PowerMaxValue: number;
  Enable_PowerOnTimeValue: number;
  PeriodType_PowerOnTimeValue: number;
  PeriodLength_PowerOnTimeValue: number;
  Enable_PowerFactorMaxValue: number;
  PeriodType_PowerFactorMaxValue: number;
  PeriodLength_PowerFactorMaxValue: number;
  Enable_PowerFactorOnTimeValue: number;
  PeriodType_PowerFactorrOnTimeValue: number;
  PeriodLength_PowerFactorOnTimeValue: number;
  Enable_LoadRateOnTimeValue: number;
  PeriodType_LoadRateOnTimeValue: number;
  PeriodLength_LoadRateOnTimeValue: number;
  Enable_PositiveActivePowerOnTimeValue: number;
  PeriodType_PositiveActivePowerOnTimeValue: number;
  PeriodLength_PositiveActivePowerOnTimeValue: number;
  Enable_PositiveReactivePowerOnTimeValue: number;
  PeriodType_PositiveReactivePowerOnTimeValue: number;
  PeriodLength_PositiveReactivePowerOnTimeValue: number;
  Enable_ReverseActivePowerOnTimeValue: number;
  PeriodType_ReverseActivePowerOnTimeValue: number;
  PeriodLength_ReverseActivePowerOnTimeValue: number;
  Enable_ReverseReactivePowerOnTimeValue: number;
  PeriodType_ReverseReactivePowerOnTimeValue: number;
  PeriodLength_ReverseReactivePowerOnTimeValue: number;
}

export interface RelaySettingFieldEntryValue {
  id: string;
  value: string;
}

export interface RelaySettingZoneValue {
  ready: boolean;
  zoneCode: number;
  fields: RelaySettingFieldEntryValue[];
}

export interface RelaySettingWriteFieldEntryValue {
  id: string;
  textValue: string;
  numberValue: number;
  enumValue: number;
}

export interface RelaySettingWriteZoneValue {
  zoneCode: number;
  fields: RelaySettingWriteFieldEntryValue[];
}

export const startTcpClient: (host: string, port: number) => boolean;
export const stopTcpClient: () => void;
export const isTcpClientRunning: () => boolean;
export const getBaseFreqDisplayData: () => BaseFreqDisplayValue;
export const requestHarmonicDisplayData: () => boolean;
export const getHarmonicVoltageDisplayData: () => HarmonicVoltageDisplayValue;
export const getHarmonicCurrentDisplayData: () => HarmonicCurrentDisplayValue;
export const getPrimarySystemSetting: () => CommonSettingPrimarySystemStructValue;
export const updatePrimarySystemSetting: (value: CommonSettingPrimarySystemWriteValue) => boolean;
export const getAnalogQuantitySetting: () => CommonSettingAnalogQuantityStructValue;
export const updateAnalogQuantitySetting: (value: CommonSettingAnalogQuantityWriteValue) => boolean;
export const getTeleMeasuringSetting: () => CommonSettingTeleMeasuringStructValue;
export const updateTeleMeasuringSetting: (value: CommonSettingTeleMeasuringWriteValue) => boolean;
export const getTeleSignalingSetting: () => CommonSettingTeleSignalingStructValue;
export const updateTeleSignalingSetting: (value: CommonSettingTeleSignalingWriteValue) => boolean;
export const getTeleControllingSetting: () => CommonSettingTeleControllingStructValue;
export const updateTeleControllingSetting: (value: CommonSettingTeleControllingWriteValue) => boolean;
export const getExceedingLimitSetting: () => CommonSettingExceedingLimitStructValue;
export const updateExceedingLimitSetting: (value: CommonSettingExceedingLimitWriteValue) => boolean;
export const getPowerQualitySetting: () => CommonSettingPowerQualityStructValue;
export const updatePowerQualitySetting: (value: CommonSettingPowerQualityWriteValue) => boolean;
export const getStatisticsSetting: () => CommonSettingStatisticsStructValue;
export const updateStatisticsSetting: (value: CommonSettingStatisticsWriteValue) => boolean;
export const getRelaySettingByZone: (zoneCode: number) => RelaySettingZoneValue;
export const updateRelaySettingByZone: (value: RelaySettingWriteZoneValue) => boolean;
export const add: (a: number, b: number) => number;
