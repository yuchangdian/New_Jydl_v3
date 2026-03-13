@Observed
export class CommonSettingStatisticsField {
  key: string = '';
  value: string = '';
}

interface CommonSettingStatisticsDefaultItem {
  key: string;
  value: string;
}

function createCommonSettingStatisticsField(key: string, value: string): CommonSettingStatisticsField {
  let field = new CommonSettingStatisticsField();
  field.key = key;
  field.value = value;
  return field;
}

const COMMON_SETTING_STATISTICS_DEFAULT_ITEMS: CommonSettingStatisticsDefaultItem[] = [
  { key: 'C_Box_Stats_En_Bus', value: '投入' },
  { key: 'C_Box_Stats_En_Line', value: '投入' },
  { key: 'C_Box_Stats_En_VoltageMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_VoltageMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_VoltageMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_VoltageMinValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_VoltageMinValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_VoltageMinValue', value: '00.00' },
  { key: 'C_Box_Stats_En_VoltageOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_VoltageOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_VoltageOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_VoltageImbalanceMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_VoltageImbalanceMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_VoltageImbalanceMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_VoltageQualifiedRateOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_VoltageQualifiedRateOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_VoltageQualifiedRateOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_CurrentMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_CurrentMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_CurrentMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_CurrentMinValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_CurrentMinValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_CurrentMinValue', value: '00.00' },
  { key: 'C_Box_Stats_En_CurrentOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_CurrentOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_CurrentOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_CurrentImbalanceMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_CurrentImbalanceMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_CurrentImbalanceMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PowerMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PowerMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PowerMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PowerOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PowerOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PowerOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PowerFactorMaxValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PowerFactorMaxValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PowerFactorMaxValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PowerFactorOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PowerFactorOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PowerFactorOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_LoadRateOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_LoadRateOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_LoadRateOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PositiveActivePowerOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PositiveActivePowerOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PositiveActivePowerOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_PositiveReactivePowerOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_PositiveReactivePowerOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_PositiveReactivePowerOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_ReverseActivePowerOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_ReverseActivePowerOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_ReverseActivePowerOnTimeValue', value: '00.00' },
  { key: 'C_Box_Stats_En_ReverseReactivePowerOnTimeValue', value: '投入' },
  { key: 'C_Box_Stats_PDType_ReverseReactivePowerOnTimeValue', value: '小时级' },
  { key: 'Edit_Stats_PDLen_ReverseReactivePowerOnTimeValue', value: '00.00' }
];

export const COMMON_SETTING_STATISTICS_ENABLE_OPTIONS: string[] = [
  '投入',
  '退出'
];

export const COMMON_SETTING_STATISTICS_PERIOD_TYPE_OPTIONS: string[] = [
  '小时级',
  '分钟级',
  '日级'
];

export function createDefaultCommonSettingStatisticsFields(): CommonSettingStatisticsField[] {
  return COMMON_SETTING_STATISTICS_DEFAULT_ITEMS.map((item: CommonSettingStatisticsDefaultItem) => {
    return createCommonSettingStatisticsField(item.key, item.value);
  });
}

export function serializeCommonSettingStatisticsFields(fields: CommonSettingStatisticsField[]): string {
  let data: Record<string, string> = {};
  fields.forEach((field: CommonSettingStatisticsField) => {
    data[field.key] = field.value;
  });
  return JSON.stringify(data);
}

export function deserializeCommonSettingStatisticsFields(raw: string): CommonSettingStatisticsField[] | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, string>;
    let fields = createDefaultCommonSettingStatisticsFields();
    if (!parsed || typeof parsed !== 'object') {
      return fields;
    }

    fields.forEach((field: CommonSettingStatisticsField) => {
      let value = parsed[field.key];
      if (typeof value === 'string') {
        field.value = value;
      }
    });
    return fields;
  } catch (error) {
    return undefined;
  }
}
