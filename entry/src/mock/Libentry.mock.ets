export const startTcpClient = (_host: string, _port: number): boolean => {
  return true;
};

export const stopTcpClient = (): void => {
};

export const isTcpClientRunning = (): boolean => {
  return false;
};

export const getBaseFreqDisplayData = () => {
  return {
    ready: false,
    Ua_Rms: 0,
    Ua_Phase: 0,
    Ub_Rms: 0,
    Ub_Phase: 0,
    Uc_Rms: 0,
    Uc_Phase: 0,
    Uo_Rms: 0,
    Uo_Phase: 0,
    Ux_Rms: 0,
    Ux_Phase: 0,
    IA_Rms: 0,
    IA_Phase: 0,
    IB_Rms: 0,
    IB_Phase: 0,
    IC_Rms: 0,
    IC_Phase: 0,
    Io_Rms: 0,
    Io_Phase: 0,
    Ia_Rms: 0,
    Ia_Phase: 0,
    Ib_Rms: 0,
    Ib_Phase: 0,
    Ic_Rms: 0,
    Ic_Phase: 0
  };
};

export const requestHarmonicDisplayData = (): boolean => {
  return true;
};

const defaultHarmonicCurrentValues = () => {
  return new Array<number>(30).fill(0);
};

export const getHarmonicVoltageDisplayData = () => {
  return {
    ready: false,
    Ua: defaultHarmonicCurrentValues(),
    Ub: defaultHarmonicCurrentValues(),
    Uc: defaultHarmonicCurrentValues()
  };
};

export const getHarmonicCurrentDisplayData = () => {
  return {
    ready: false,
    Ia: defaultHarmonicCurrentValues(),
    Ib: defaultHarmonicCurrentValues(),
    Ic: defaultHarmonicCurrentValues()
  };
};

export const getPrimarySystemSetting = () => {
  return {
    ready: false,
    SystemGroundingMode: 0,
    PTp_Bus_Primary: 0,
    PTp_Bus_Secondary: 0,
    PTo_Bus_Primary: 0,
    PTo_Bus_Secondary: 0,
    PT_Line_Primary: 0,
    PT_Line_Secondary: 0,
    PT_Line_Phase: 0,
    PT_Line_Phase_Text: '',
    CTp_Protection_Primary: 0,
    CTp_Protection_Secondary: 0,
    CTo_Primary: 0,
    CTo_Secondary: 0,
    CTp_Measure_Primary: 0,
    CTp_Measure_Secondary: 0,
    Mode_CTConnectioin: 0,
    Mode_CTConnectioin_Text: '',
    Mode_Iosample: 0,
    Mode_Iosample_Text: '',
    RatedPower_Line: 0,
    CRC: 0
  };
};

export const updatePrimarySystemSetting = (_value: any): boolean => {
  return true;
};

const defaultAnalogParameter = () => {
  return {
    Ua: 100.00,
    Ub: 100.00,
    Uc: 100.00,
    Uo: 100.00,
    IA: 5.00,
    IB: 5.00,
    IC: 5.00,
    Io: 5.00,
    Ia: 5.00,
    Ib: 5.00,
    Ic: 5.00,
    Is: 5.00,
    Ux: 100.00,
    Iby1: 5.00,
    Iby2: 5.00,
    Iby3: 5.00
  };
};

export const getAnalogQuantitySetting = () => {
  return {
    ready: false,
    Reference: defaultAnalogParameter(),
    Correction: defaultAnalogParameter(),
    ZeroDrift: defaultAnalogParameter(),
    CRC: 0
  };
};

export const updateAnalogQuantitySetting = (_value: any): boolean => {
  return true;
};

export const getTeleMeasuringSetting = () => {
  return {
    ready: false,
    Cycle_Detection: 0,
    DeadBand_Frequency: 0,
    DeadBand_ACvoltage: 0,
    DeadBand_DCvoltage: 0,
    DeadBand_ACcurrent: 0,
    DeadBand_Power: 0,
    DeadBand_PowerFactor: 0,
    Enable_PrimaryEnergy: 0,
    CRC: 0
  };
};

export const updateTeleMeasuringSetting = (_value: any): boolean => {
  return true;
};

export const getTeleSignalingSetting = () => {
  return {
    ready: false,
    YX01_Time: 0,
    YX02_Time: 0,
    YX03_Time: 0,
    YX04_Time: 0,
    YX05_Time: 0,
    YX06_Time: 0,
    YX07_Time: 0,
    YX08_Time: 0,
    Enable_Logic: 0,
    CRC: 0
  };
};

export const updateTeleSignalingSetting = (_value: any): boolean => {
  return true;
};

export const getTeleControllingSetting = () => {
  return {
    ready: false,
    HoldingTime_YK1_XZ: 0,
    HoldingTime_YK1_TZ: 0,
    HoldingTime_YK1_HZ: 0,
    HoldingTime_YK2_XZ: 0,
    HoldingTime_YK2_TZ: 0,
    HoldingTime_YK2_HZ: 0,
    Sync_NoVoltage: 0,
    Sync_ThereVoltage: 0,
    Sync_Volue_VoltageDifferenceBlock: 0,
    Sync_Volue_AngleDifferenceBlock: 0,
    Sync_Volue_FrequencyDifferenceBlock: 0,
    Sync_DelayTime: 0,
    Sync_BreakerCloseTime: 0,
    Sync_Enable_CloseMode_YK: 0,
    CRC: 0
  };
};

export const updateTeleControllingSetting = (_value: any): boolean => {
  return true;
};

export const getExceedingLimitSetting = () => {
  return {
    ready: false,
    Enable_LineVoltageExceedingUpperLimit: 0,
    Value_LineVoltageExceedingUpperLimit: 0,
    Enable_LineVoltageExceedingLowerLimit: 0,
    Value_LineVoltageExceedingLowerLimit: 0,
    Enable_ZeroSequenceVoltageExceedingUpperLimit: 0,
    Value_ZeroSequenceVoltageExceedingUpperLimit: 0,
    Enable_VoltageImbalanceRateExceedingUpperLimit: 0,
    Value_VoltageImbalanceRateExceedingUpperLimit: 0,
    Enable_PhaseCurrentExceedingUpperLimit: 0,
    Value_PhaseCurrentExceedingUpperLimit: 0,
    Enable_ZeroSequenceCurrentExceedingUpperLimit: 0,
    Value_ZeroSequenceCurrentExceedingUpperLimit: 0,
    Enable_CurrentImbalanceRateExceedingUpperLimit: 0,
    Value_CurrentImbalanceRateExceedingUpperLimit: 0,
    Enable_PhaseDifferentialCurrentExceedingUpperLimit: 0,
    Value_PhaseDifferentialCurrentExceedingUpperLimit: 0,
    Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit: 0,
    Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit: 0,
    Enable_LoadRateExceedingUpperLimit: 0,
    Value_LoadRateRateExceedingUpperLimit: 0,
    Time_Delay: 0,
    CRC: 0
  };
};

export const updateExceedingLimitSetting = (_value: any): boolean => {
  return true;
};

export const getPowerQualitySetting = () => {
  return {
    ready: false,
    Enable_FrequencyDeviation: 0,
    Value_FrequencyDeviation: 0,
    Enable_VoltageDeviation: 0,
    Value_VoltageDeviation: 0,
    Enable_VoltageUnbalance: 0,
    Value_VoltageUnbalance: 0,
    Enable_VoltageFluct: 0,
    Value_VoltageFluct: 0,
    Enable_VoltageFlicke: 0,
    Value_VoltageFlicke: 0,
    Enable_VoltageSeg: 0,
    Value_VoltageSeg: 0,
    Enable_VoltageTHD: 0,
    Value_VoltageTHD: 0,
    Enable_VoltageHAR: 0,
    Value_VoltageHAR: 0,
    Enable_CurrentUnbalance: 0,
    Value_CurrentUnbalance: 0,
    Enable_CurrentTHD: 0,
    Value_CurrentTHD: 0,
    Enable_CurrentHAR: 0,
    Value_CurrentHAR: 0,
    CRC: 0
  };
};

export const updatePowerQualitySetting = (_value: any): boolean => {
  return true;
};

export const getStatisticsSetting = () => {
  return {
    ready: false,
    Enable_Bus: 0,
    Enable_Line: 0,
    Enable_VoltageMaxValue: 0,
    PeriodType_VoltageMaxValue: 0,
    PeriodLength_VoltageMaxValue: 0,
    Enable_VoltageMinValue: 0,
    PeriodType_VoltageMinValue: 0,
    PeriodLength_VoltageMinValue: 0,
    Enable_VoltageOnTimeValue: 0,
    PeriodType_VoltageOnTimeValue: 0,
    PeriodLength_VoltageOnTimeValue: 0,
    Enable_VoltageImbalanceMaxValue: 0,
    PeriodType_VoltageImbalanceMaxValue: 0,
    PeriodLength_VoltageImbalanceMaxValue: 0,
    Enable_VoltageQualifiedRateOnTimeValue: 0,
    PeriodType_VoltageQualifiedRateOnTimeValue: 0,
    PeriodLength_VoltageQualifiedRateOnTimeValue: 0,
    Enable_CurrentMaxValue: 0,
    PeriodType_CurrentMaxValue: 0,
    PeriodLength_CurrentMaxValue: 0,
    Enable_CurrentMinValue: 0,
    PeriodType_CurrentMinValue: 0,
    PeriodLength_CurrentMinValue: 0,
    Enable_CurrentOnTimeValue: 0,
    PeriodType_CurrentOnTimeValue: 0,
    PeriodLength_CurrentOnTimeValue: 0,
    Enable_CurrentImbalanceMaxValue: 0,
    PeriodType_CurrentImbalanceMaxValue: 0,
    PeriodLength_CurrentImbalanceMaxValue: 0,
    Enable_PowerMaxValue: 0,
    PeriodType_PowerMaxValue: 0,
    PeriodLength_PowerMaxValue: 0,
    Enable_PowerOnTimeValue: 0,
    PeriodType_PowerOnTimeValue: 0,
    PeriodLength_PowerOnTimeValue: 0,
    Enable_PowerFactorMaxValue: 0,
    PeriodType_PowerFactorMaxValue: 0,
    PeriodLength_PowerFactorMaxValue: 0,
    Enable_PowerFactorOnTimeValue: 0,
    PeriodType_PowerFactorrOnTimeValue: 0,
    PeriodLength_PowerFactorOnTimeValue: 0,
    Enable_LoadRateOnTimeValue: 0,
    PeriodType_LoadRateOnTimeValue: 0,
    PeriodLength_LoadRateOnTimeValue: 0,
    Enable_PositiveActivePowerOnTimeValue: 0,
    PeriodType_PositiveActivePowerOnTimeValue: 0,
    PeriodLength_PositiveActivePowerOnTimeValue: 0,
    Enable_PositiveReactivePowerOnTimeValue: 0,
    PeriodType_PositiveReactivePowerOnTimeValue: 0,
    PeriodLength_PositiveReactivePowerOnTimeValue: 0,
    Enable_ReverseActivePowerOnTimeValue: 0,
    PeriodType_ReverseActivePowerOnTimeValue: 0,
    PeriodLength_ReverseActivePowerOnTimeValue: 0,
    Enable_ReverseReactivePowerOnTimeValue: 0,
    PeriodType_ReverseReactivePowerOnTimeValue: 0,
    PeriodLength_ReverseReactivePowerOnTimeValue: 0,
    CRC: 0
  };
};

export const updateStatisticsSetting = (_value: any): boolean => {
  return true;
};

export const getRelaySettingByZone = (_zoneCode: number) => {
  return {
    ready: false,
    zoneCode: 1,
    fields: []
  };
};

export const requestRelaySettingByZone = (_zoneCode: number): boolean => {
  return true;
};

export const updateRelaySettingByZone = (_value: any): boolean => {
  return true;
};

export const add = (a: number, b: number): number => {
  return a + b;
};
