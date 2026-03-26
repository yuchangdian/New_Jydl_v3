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

export const add = (a: number, b: number): number => {
  return a + b;
};
