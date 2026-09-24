import { Jybsmr131NumericField, Jybsmr131PacketValue } from 'libentry.so';

@Observed
export class PowerQualityAlarmRow {
  key: string;
  title: string;
  label: string;
  unit: string;
  maximum: number;
  hasMaximum: boolean;
  enabled: string = '退出';
  value: string = '0';

  constructor(key: string, title: string, unit: string, maximum: number, hasMaximum: boolean) {
    this.key = key;
    this.title = title;
    this.label = title.replace('越限告警定值', '').replace('告警定值', '');
    this.unit = unit;
    this.maximum = maximum;
    this.hasMaximum = hasMaximum;
  }
}

export function createPowerQualityAlarmRows(): PowerQualityAlarmRow[] {
  return [
    new PowerQualityAlarmRow('VoltageUnbalance', '电压不平衡越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageDeviation', '电压偏差越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('FreqDeviation', '频率偏差越限告警定值', 'Hz', 50, true),
    new PowerQualityAlarmRow('VoltageShortFlicke', '电压短闪变越限告警定值', '', 0, false),
    new PowerQualityAlarmRow('VoltageLongFlicke', '电压长闪变越限告警定值', '', 0, false),
    new PowerQualityAlarmRow('VoltageFluct', '电压波动越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageSeg', '电压暂降告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageSwell', '电压暂升告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageTHD', '电压总谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageOddTHD', '电压总奇次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageEvenTHD', '电压总偶次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageOddHAR', '电压单一奇次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageEvenHAR', '电压单一偶次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageInterTHD', '电压总间谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('VoltageInterHAR', '电压单一间谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentUnbalance', '电流不平衡越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentTHD', '电流总谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentOddTHD', '电流总奇次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentEvenTHD', '电流总偶次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentOddHAR', '电流单一奇次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentEvenHAR', '电流单一偶次谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentInterTHD', '电流总间谐波含量越限告警定值', '%', 100, true),
    new PowerQualityAlarmRow('CurrentInterHAR', '电流单一间谐波含量越限告警定值', '%', 100, true)
  ];
}

export function validatePowerQualitySetting(normalText: string, violationText: string,
  rows: PowerQualityAlarmRow[]): string[] {
  const errors: string[] = [];
  const normal = Number(normalText);
  const violation = Number(violationText);
  if (normalText.trim().length === 0 || !Number.isFinite(normal) || normal < 0 || normal > 600) {
    errors.push('【正常状态录波长度】应在 0～600 ms 范围内');
  }
  if (violationText.trim().length === 0 || !Number.isFinite(violation) || violation < 0 || violation > 600) {
    errors.push('【越限状态录波长度】应在 0～600 ms 范围内');
  }
  rows.forEach((row: PowerQualityAlarmRow) => {
    const value = Number(row.value);
    if (row.value.trim().length === 0 || !Number.isFinite(value)) {
      errors.push(`【${row.title}】请输入有效数字`);
    } else if (value < 0 || (row.hasMaximum && value > row.maximum)) {
      const range = row.hasMaximum ? `0～${row.maximum}` : '不小于 0';
      errors.push(`【${row.title}】应在 ${range} ${row.unit} 范围内`);
    }
  });
  return errors;
}

export function buildPowerQualitySettingFields(reference: number, normalText: string, violationText: string,
  rows: PowerQualityAlarmRow[]): Jybsmr131NumericField[] {
  const fields: Jybsmr131NumericField[] = [
    { name: 'VoltageRef_SegSwell', values: [reference] },
    { name: 'RecoedSize_Normal', values: [Math.trunc(Number(normalText))] },
    { name: 'RecoedSize_Violation', values: [Math.trunc(Number(violationText))] }
  ];
  rows.forEach((row: PowerQualityAlarmRow) => {
    fields.push({ name: `${row.key}.Enable`, values: [row.enabled === '投入' ? 1 : 0] });
    fields.push({ name: `${row.key}.ActValue`, values: [Number(row.value)] });
  });
  return fields;
}

export function readPacketValue(packet: Jybsmr131PacketValue, name: string): number | undefined {
  const field = packet.fields.find((item: Jybsmr131NumericField) => item.name === name);
  return field && field.values.length === 1 ? field.values[0] : undefined;
}

export function packetMatchesFields(packet: Jybsmr131PacketValue, fields: Jybsmr131NumericField[]): boolean {
  if (!packet.ready) return false;
  for (let index = 0; index < fields.length; index++) {
    const actual = readPacketValue(packet, fields[index].name);
    const expected = fields[index].values[0];
    if (actual === undefined || !Number.isFinite(actual) || !Number.isFinite(expected) ||
      Math.abs(actual - expected) > 0.0001) return false;
  }
  return true;
}
