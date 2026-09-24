import nativeProtocol, { Jybsmr131DigitalInputValue, Jybsmr131NumericField, Jybsmr131PacketValue } from 'libentry.so';

export enum Jybsmr131CommonAddress {
  RemoteMetry = 0x1311,
  RemoteControl = 0x1322,
  RemoteSignal = 0x1333,
  RemoteAdjust = 0x1344,
  Soe = 0x1355,
  Record = 0x1366,
  PowerQualityEvent = 0x1377
}

export enum Jybsmr131TelemetryAddress {
  BaseValue = 0x0011,
  HarmonicVoltage = 0x0033,
  HarmonicCurrent = 0x0044,
  PowerQuality = 0x0055,
  HarmonicUa = 0x0081,
  HarmonicUb = 0x0082,
  HarmonicUc = 0x0083,
  HarmonicIa = 0x0084,
  HarmonicIb = 0x0085,
  HarmonicIc = 0x0086,
  InterharmonicUa = 0x0091,
  InterharmonicUb = 0x0092,
  InterharmonicUc = 0x0093,
  InterharmonicIa = 0x0094,
  InterharmonicIb = 0x0095,
  InterharmonicIc = 0x0096,
  Location = 0x00AA,
  WaveformUa = 0x00B1,
  WaveformUb = 0x00B2,
  WaveformUc = 0x00B3,
  WaveformIa = 0x00B4,
  WaveformIb = 0x00B5,
  WaveformIc = 0x00B6
}

export enum Jybsmr131SettingAddress {
  System = 0x0011,
  Analog = 0x0022,
  PowerQuality = 0x0033,
  FaultRecord = 0x0044,
  BroadbandPhasor = 0x0055
}

export enum Jybsmr131SignalAddress {
  All = 0x0011,
  GLKGW = 0x0101,
  JDKGW = 0x0102,
  KHBJ = 0x0103,
  WCN = 0x0104,
  YFJD = 0x0105,
  HW = 0x0106,
  TW = 0x0107,
  Run = 0x0108,
  Alarm = 0x0109,
  SyncErr = 0x010A,
  SwitchState = 0x010B
}

export enum Jybsmr131SwitchState {
  Uncertain = 0x00,
  Open = 0x01,
  Closed = 0x02,
  ControlCircuitOpen = 0x11
}

// native TCP 连接由 EntryAbility 管理。未收到有效报文时 ready 为 false。
export class Jybsmr131Protocol {
  // ready 表示收到至少一个通道，complete 表示 11 个通道均已收到。
  // 未收到的通道为 undefined；BreakerState_Now 仅由 SwitchState 更新。
  static digitalInputs(): Jybsmr131DigitalInputValue {
    return nativeProtocol.getJybsmr131DigitalInputs();
  }

  static signal(address: Jybsmr131SignalAddress): Jybsmr131PacketValue {
    return nativeProtocol.getJybsmr131Packet(Jybsmr131CommonAddress.RemoteSignal, address);
  }

  // 整组遥信沿用 data.h 的 19 个字段，与 11 路开入快照分别读取。
  static requestAllSignals(): boolean {
    return nativeProtocol.requestJybsmr131Packet(Jybsmr131CommonAddress.RemoteSignal, Jybsmr131SignalAddress.All);
  }
  static requestTelemetry(address: Jybsmr131TelemetryAddress): boolean {
    return nativeProtocol.requestJybsmr131Packet(Jybsmr131CommonAddress.RemoteMetry, address);
  }

  static telemetry(address: Jybsmr131TelemetryAddress): Jybsmr131PacketValue {
    return nativeProtocol.getJybsmr131Packet(Jybsmr131CommonAddress.RemoteMetry, address);
  }

  static requestSetting(address: Jybsmr131SettingAddress): boolean {
    return nativeProtocol.requestJybsmr131Packet(Jybsmr131CommonAddress.RemoteAdjust, address);
  }

  static setting(address: Jybsmr131SettingAddress): Jybsmr131PacketValue {
    return nativeProtocol.getJybsmr131Packet(Jybsmr131CommonAddress.RemoteAdjust, address);
  }

  // 只接受已收到有效回包的定值，字段名与 C++ 一致，例如 Correction.Ua。
  // CRC 由 native 计算。返回 true 仅代表发送成功，需以设备回包确认结果。
  static updateSetting(address: Jybsmr131SettingAddress, fields: Jybsmr131NumericField[]): boolean {
    return nativeProtocol.updateJybsmr131Setting(address, fields);
  }

  static values(packet: Jybsmr131PacketValue, name: string): number[] {
    if (!packet.ready) return [];
    const field = packet.fields.find((item: Jybsmr131NumericField) => item.name === name);
    return field ? field.values.slice() : [];
  }

  static value(packet: Jybsmr131PacketValue, name: string): number | undefined {
    const values = Jybsmr131Protocol.values(packet, name);
    return values.length === 1 ? values[0] : undefined;
  }
}
