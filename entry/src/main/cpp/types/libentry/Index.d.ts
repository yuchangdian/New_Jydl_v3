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

export const startTcpClient: (host: string, port: number) => boolean;
export const stopTcpClient: () => void;
export const isTcpClientRunning: () => boolean;
export const getBaseFreqDisplayData: () => BaseFreqDisplayValue;
export const getPrimarySystemSetting: () => CommonSettingPrimarySystemStructValue;
export const getAnalogQuantitySetting: () => CommonSettingAnalogQuantityStructValue;
export const add: (a: number, b: number) => number;
