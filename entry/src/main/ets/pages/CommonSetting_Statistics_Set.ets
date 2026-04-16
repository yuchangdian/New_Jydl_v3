import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import * as statisticsNativeModule from 'libentry.so';
import {
  CommonSettingStatisticsField,
  COMMON_SETTING_STATISTICS_ENABLE_OPTIONS,
  COMMON_SETTING_STATISTICS_PERIOD_TYPE_OPTIONS,
  createDefaultCommonSettingStatisticsFields,
  deserializeCommonSettingStatisticsFields,
  serializeCommonSettingStatisticsFields
} from '../models/CommonSettingStatisticsData';

interface AbilityFileContext {
  filesDir: string;
}

interface CommonSettingStatisticsStructValue {
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

interface CommonSettingStatisticsWriteValue {
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

interface StatisticsNativeModule {
  getStatisticsSetting?: () => CommonSettingStatisticsStructValue | undefined;
  updateStatisticsSetting?: (value: CommonSettingStatisticsWriteValue) => boolean;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): StatisticsNativeModule | undefined;

function isValidStatisticsInteger(value: number): boolean {
  return typeof value === 'number' && isFinite(value) && value >= 0;
}

function getStatisticsEnableText(value: number): string {
  if (value === 1) {
    return '投入';
  }
  if (value === 0) {
    return '退出';
  }
  return '';
}

function getStatisticsEnableCode(value: string, fallbackValue: number): number {
  if (value === '投入') {
    return 1;
  }
  if (value === '退出') {
    return 0;
  }
  if (fallbackValue === 0 || fallbackValue === 1) {
    return fallbackValue;
  }
  return 1;
}

function getStatisticsPeriodTypeText(value: number): string {
  if (value === 1) {
    return '分钟级';
  }
  if (value === 2) {
    return '小时级';
  }
  if (value === 3) {
    return '日级';
  }
  return '';
}

function getStatisticsPeriodTypeCode(value: string, fallbackValue: number): number {
  if (value === '分钟级') {
    return 1;
  }
  if (value === '小时级') {
    return 2;
  }
  if (value === '日级') {
    return 3;
  }
  if (fallbackValue === 1 || fallbackValue === 2 || fallbackValue === 3) {
    return fallbackValue;
  }
  return 2;
}

function formatStatisticsPeriodLength(value: number): string {
  if (!isValidStatisticsInteger(value)) {
    return '';
  }
  return value.toString();
}

function isStatisticsEnableValue(value: number): boolean {
  return value === 0 || value === 1;
}

function isStatisticsPeriodTypeValue(value: number): boolean {
  return value === 1 || value === 2 || value === 3;
}

function setStatisticsFieldValue(fields: CommonSettingStatisticsField[], fieldKey: string, value: string): void {
  let field = fields.find((item: CommonSettingStatisticsField) => item.key === fieldKey);
  if (field) {
    field.value = value;
  }
}

interface StatisticsToggleConfig {
  title: string;
  titleWidth: number;
  fieldKey: string;
}

interface StatisticsPeriodConfig {
  title: string;
  titleWidth: number;
  enableKey: string;
  periodTypeKey: string;
  periodLengthKey: string;
}

const COMMON_SETTING_STATISTICS_TOP_SECTIONS: StatisticsToggleConfig[] = [
  {
    title: '【母线统计】',
    titleWidth: 140,
    fieldKey: 'C_Box_Stats_En_Bus'
  },
  {
    title: '【线路统计】',
    titleWidth: 140,
    fieldKey: 'C_Box_Stats_En_Line'
  }
];

const COMMON_SETTING_STATISTICS_PERIOD_SECTIONS: StatisticsPeriodConfig[] = [
  {
    title: '【电压极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageMaxValue'
  },
  {
    title: '【电压极小值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageMinValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageMinValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageMinValue'
  },
  {
    title: '【电压整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageOnTimeValue'
  },
  {
    title: '【电压不平衡极大值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_VoltageImbalanceMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageImbalanceMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageImbalanceMaxValue'
  },
  {
    title: '【电压合格率整点值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_VoltageQualifiedRateOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageQualifiedRateOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageQualifiedRateOnTimeValue'
  },
  {
    title: '【电流极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentMaxValue'
  },
  {
    title: '【电流极小值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentMinValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentMinValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentMinValue'
  },
  {
    title: '【电流整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentOnTimeValue'
  },
  {
    title: '【电流不平衡极大值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_CurrentImbalanceMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentImbalanceMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentImbalanceMaxValue'
  },
  {
    title: '【功率极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_PowerMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerMaxValue'
  },
  {
    title: '【功率整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_PowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerOnTimeValue'
  },
  {
    title: '【功率因数极大值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PowerFactorMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerFactorMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerFactorMaxValue'
  },
  {
    title: '【功率因数整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PowerFactorOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerFactorOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerFactorOnTimeValue'
  },
  {
    title: '【负载率整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_LoadRateOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_LoadRateOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_LoadRateOnTimeValue'
  },
  {
    title: '【正向有功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PositiveActivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PositiveActivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PositiveActivePowerOnTimeValue'
  },
  {
    title: '【正向无功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PositiveReactivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PositiveReactivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PositiveReactivePowerOnTimeValue'
  },
  {
    title: '【反向有功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_ReverseActivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_ReverseActivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_ReverseActivePowerOnTimeValue'
  },
  {
    title: '【反向无功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_ReverseReactivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_ReverseReactivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_ReverseReactivePowerOnTimeValue'
  }
];

function isUsableCommonSettingStatisticsStructValue(
  value: CommonSettingStatisticsStructValue | undefined
): boolean {
  if (!value || !value.ready) {
    return false;
  }

  return isStatisticsEnableValue(value.Enable_Bus) &&
    isStatisticsEnableValue(value.Enable_Line) &&
    isStatisticsEnableValue(value.Enable_VoltageMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_VoltageMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_VoltageMaxValue) &&
    isStatisticsEnableValue(value.Enable_VoltageMinValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_VoltageMinValue) &&
    isValidStatisticsInteger(value.PeriodLength_VoltageMinValue) &&
    isStatisticsEnableValue(value.Enable_VoltageOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_VoltageOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_VoltageOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_VoltageImbalanceMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_VoltageImbalanceMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_VoltageImbalanceMaxValue) &&
    isStatisticsEnableValue(value.Enable_VoltageQualifiedRateOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_VoltageQualifiedRateOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_VoltageQualifiedRateOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_CurrentMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_CurrentMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_CurrentMaxValue) &&
    isStatisticsEnableValue(value.Enable_CurrentMinValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_CurrentMinValue) &&
    isValidStatisticsInteger(value.PeriodLength_CurrentMinValue) &&
    isStatisticsEnableValue(value.Enable_CurrentOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_CurrentOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_CurrentOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_CurrentImbalanceMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_CurrentImbalanceMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_CurrentImbalanceMaxValue) &&
    isStatisticsEnableValue(value.Enable_PowerMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PowerMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_PowerMaxValue) &&
    isStatisticsEnableValue(value.Enable_PowerOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PowerOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_PowerOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_PowerFactorMaxValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PowerFactorMaxValue) &&
    isValidStatisticsInteger(value.PeriodLength_PowerFactorMaxValue) &&
    isStatisticsEnableValue(value.Enable_PowerFactorOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PowerFactorrOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_PowerFactorOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_LoadRateOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_LoadRateOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_LoadRateOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_PositiveActivePowerOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PositiveActivePowerOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_PositiveActivePowerOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_PositiveReactivePowerOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_PositiveReactivePowerOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_PositiveReactivePowerOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_ReverseActivePowerOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_ReverseActivePowerOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_ReverseActivePowerOnTimeValue) &&
    isStatisticsEnableValue(value.Enable_ReverseReactivePowerOnTimeValue) &&
    isStatisticsPeriodTypeValue(value.PeriodType_ReverseReactivePowerOnTimeValue) &&
    isValidStatisticsInteger(value.PeriodLength_ReverseReactivePowerOnTimeValue);
}

function createCommonSettingStatisticsFieldsFromStruct(
  source: CommonSettingStatisticsStructValue
): CommonSettingStatisticsField[] {
  let fields = createDefaultCommonSettingStatisticsFields();

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_Bus', getStatisticsEnableText(source.Enable_Bus));
  setStatisticsFieldValue(fields, 'C_Box_Stats_En_Line', getStatisticsEnableText(source.Enable_Line));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_VoltageMaxValue', getStatisticsEnableText(source.Enable_VoltageMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_VoltageMaxValue', getStatisticsPeriodTypeText(source.PeriodType_VoltageMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_VoltageMaxValue', formatStatisticsPeriodLength(source.PeriodLength_VoltageMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_VoltageMinValue', getStatisticsEnableText(source.Enable_VoltageMinValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_VoltageMinValue', getStatisticsPeriodTypeText(source.PeriodType_VoltageMinValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_VoltageMinValue', formatStatisticsPeriodLength(source.PeriodLength_VoltageMinValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_VoltageOnTimeValue', getStatisticsEnableText(source.Enable_VoltageOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_VoltageOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_VoltageOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_VoltageOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_VoltageOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_VoltageImbalanceMaxValue', getStatisticsEnableText(source.Enable_VoltageImbalanceMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_VoltageImbalanceMaxValue', getStatisticsPeriodTypeText(source.PeriodType_VoltageImbalanceMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_VoltageImbalanceMaxValue', formatStatisticsPeriodLength(source.PeriodLength_VoltageImbalanceMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_VoltageQualifiedRateOnTimeValue', getStatisticsEnableText(source.Enable_VoltageQualifiedRateOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_VoltageQualifiedRateOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_VoltageQualifiedRateOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_VoltageQualifiedRateOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_VoltageQualifiedRateOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_CurrentMaxValue', getStatisticsEnableText(source.Enable_CurrentMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_CurrentMaxValue', getStatisticsPeriodTypeText(source.PeriodType_CurrentMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_CurrentMaxValue', formatStatisticsPeriodLength(source.PeriodLength_CurrentMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_CurrentMinValue', getStatisticsEnableText(source.Enable_CurrentMinValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_CurrentMinValue', getStatisticsPeriodTypeText(source.PeriodType_CurrentMinValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_CurrentMinValue', formatStatisticsPeriodLength(source.PeriodLength_CurrentMinValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_CurrentOnTimeValue', getStatisticsEnableText(source.Enable_CurrentOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_CurrentOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_CurrentOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_CurrentOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_CurrentOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_CurrentImbalanceMaxValue', getStatisticsEnableText(source.Enable_CurrentImbalanceMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_CurrentImbalanceMaxValue', getStatisticsPeriodTypeText(source.PeriodType_CurrentImbalanceMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_CurrentImbalanceMaxValue', formatStatisticsPeriodLength(source.PeriodLength_CurrentImbalanceMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PowerMaxValue', getStatisticsEnableText(source.Enable_PowerMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PowerMaxValue', getStatisticsPeriodTypeText(source.PeriodType_PowerMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PowerMaxValue', formatStatisticsPeriodLength(source.PeriodLength_PowerMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PowerOnTimeValue', getStatisticsEnableText(source.Enable_PowerOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PowerOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_PowerOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PowerOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_PowerOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PowerFactorMaxValue', getStatisticsEnableText(source.Enable_PowerFactorMaxValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PowerFactorMaxValue', getStatisticsPeriodTypeText(source.PeriodType_PowerFactorMaxValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PowerFactorMaxValue', formatStatisticsPeriodLength(source.PeriodLength_PowerFactorMaxValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PowerFactorOnTimeValue', getStatisticsEnableText(source.Enable_PowerFactorOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PowerFactorOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_PowerFactorrOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PowerFactorOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_PowerFactorOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_LoadRateOnTimeValue', getStatisticsEnableText(source.Enable_LoadRateOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_LoadRateOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_LoadRateOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_LoadRateOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_LoadRateOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PositiveActivePowerOnTimeValue', getStatisticsEnableText(source.Enable_PositiveActivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PositiveActivePowerOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_PositiveActivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PositiveActivePowerOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_PositiveActivePowerOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_PositiveReactivePowerOnTimeValue', getStatisticsEnableText(source.Enable_PositiveReactivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_PositiveReactivePowerOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_PositiveReactivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_PositiveReactivePowerOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_PositiveReactivePowerOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_ReverseActivePowerOnTimeValue', getStatisticsEnableText(source.Enable_ReverseActivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_ReverseActivePowerOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_ReverseActivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_ReverseActivePowerOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_ReverseActivePowerOnTimeValue));

  setStatisticsFieldValue(fields, 'C_Box_Stats_En_ReverseReactivePowerOnTimeValue', getStatisticsEnableText(source.Enable_ReverseReactivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'C_Box_Stats_PDType_ReverseReactivePowerOnTimeValue', getStatisticsPeriodTypeText(source.PeriodType_ReverseReactivePowerOnTimeValue));
  setStatisticsFieldValue(fields, 'Edit_Stats_PDLen_ReverseReactivePowerOnTimeValue', formatStatisticsPeriodLength(source.PeriodLength_ReverseReactivePowerOnTimeValue));

  return fields;
}

@Observed
class BottomActionState {
  defaultText: string = '默认值';
  submitText: string = '提交';
  closeText: string = '关闭';
  backText: string = '返回';
}

@Observed
class CommonSettingStatisticsVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定统计参数';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingStatisticsFontSize {
  notice: number = 16;
  title: number = 20;
  sectionTitle: number = 18;
  fieldLabel: number = 18;
  inputValue: number = 18;
  button: number = 18;
  timeText: number = 17;
  dialogTitle: number = 18;
  dialogBody: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  arrow: number = 12;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct CommonSetting_Statistics_Set {
  @State vm: CommonSettingStatisticsVM = new CommonSettingStatisticsVM();
  @State formData: CommonSettingStatisticsField[] = createDefaultCommonSettingStatisticsFields();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '';
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayValue: string = '';
  @State selectOverlayOptions: string[] = [];
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';
  @State submitWaitingDialogVisible: boolean = false;
  @State submitWaitingMessage: string = '';

  private readonly fontSize: CommonSettingStatisticsFontSize = new CommonSettingStatisticsFontSize();
  private readonly enableOptions: string[] = COMMON_SETTING_STATISTICS_ENABLE_OPTIONS;
  private readonly periodTypeOptions: string[] = COMMON_SETTING_STATISTICS_PERIOD_TYPE_OPTIONS;
  private cachedStatisticsNativeModule?: StatisticsNativeModule;

  private readonly pageMaxWidth: number = 1024;
  private readonly pageBaseWidth: number = 1280;
  private readonly pageBaseHeight: number = 720;
  private readonly layoutZoom: number = 1.2;
  private readonly headerHeight: number = 80;
  private readonly footerHeight: number = 80;
  private readonly contentMinHeight: number = 1140;
  private readonly contentBottomPadding: number = 200;
  private readonly contentWidth: number = 1000;
  private readonly rowHeight: number = 60;
  private readonly rowContentHeight: number = 40;
  private readonly rowContentTopMargin: number = 5;
  private readonly separatorHeight: number = 20;
  private readonly separatorStroke: number = 2;
  private readonly toggleLabelWidth: number = 80;
  private readonly periodTypeLabelWidth: number = 160;
  private readonly periodLengthLabelWidth: number = 160;
  private readonly toggleFieldWidth: number = 80;
  private readonly periodTypeFieldWidth: number = 100;
  private readonly periodLengthFieldWidth: number = 80;
  private readonly fieldHeight: number = 40;
  private readonly gapWidth: number = 20;
  private readonly bottomButtonWidth: number = 110;
  private readonly bottomButtonHeight: number = 60;
  private readonly bottomButtonRadius: number = 24;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly separatorColor: string = '#A9A9A9';
  private readonly overlayCardWidth: number = 320;
  private readonly overlayCardRadius: number = 10;
  private readonly dataFileName: string = 'common_setting_statistics.json';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let scaleX = d.width / this.pageBaseWidth;
      let scaleY = d.height / this.pageBaseHeight;
      let scale = Math.min(scaleX, scaleY);
      this.uiScale = (scale > 0 ? scale : 1) * this.layoutZoom;
    } catch (error) {
      this.uiScale = this.layoutZoom;
    }
    if (!this.loadNativeStatisticsData()) {
      this.loadPersistedData();
    }
  }

  private getDataFilePath(): string {
    let context = getContext(this) as AbilityFileContext;
    return `${context.filesDir}/${this.dataFileName}`;
  }

  private loadPersistedData(): void {
    try {
      let dataFilePath = this.getDataFilePath();
      if (!fs.accessSync(dataFilePath)) {
        return;
      }
      let raw = fs.readTextSync(dataFilePath);
      let restored = deserializeCommonSettingStatisticsFields(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load statistics data failed: ${JSON.stringify(error)}`);
    }
  }

  private isValidStatisticsNativeModule(module: StatisticsNativeModule | undefined): boolean {
    return !!module && typeof module.getStatisticsSetting === 'function';
  }

  private loadStatisticsNativeModule(): StatisticsNativeModule | undefined {
    if (this.isValidStatisticsNativeModule(this.cachedStatisticsNativeModule)) {
      return this.cachedStatisticsNativeModule;
    }
    if (this.isValidStatisticsNativeModule(statisticsNativeModule)) {
      this.cachedStatisticsNativeModule = statisticsNativeModule;
      return this.cachedStatisticsNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidStatisticsNativeModule(napiModuleWithPath)) {
      this.cachedStatisticsNativeModule = napiModuleWithPath;
      return this.cachedStatisticsNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidStatisticsNativeModule(napiModuleWithApp)) {
      this.cachedStatisticsNativeModule = napiModuleWithApp;
      return this.cachedStatisticsNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidStatisticsNativeModule(napiModule)) {
      this.cachedStatisticsNativeModule = napiModule;
      return this.cachedStatisticsNativeModule;
    }

    return undefined;
  }

  private loadNativeStatisticsData(): boolean {
    try {
      let nativeModule = this.loadStatisticsNativeModule();
      if (!nativeModule || typeof nativeModule.getStatisticsSetting !== 'function') {
        return false;
      }

      let structValue = nativeModule.getStatisticsSetting();
      if (!isUsableCommonSettingStatisticsStructValue(structValue)) {
        return false;
      }

      this.formData = createCommonSettingStatisticsFieldsFromStruct(
        structValue as CommonSettingStatisticsStructValue
      );
      return true;
    } catch (error) {
      console.error(`load native statistics data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingStatisticsFields(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save statistics data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private findField(fieldKey: string): CommonSettingStatisticsField | undefined {
    return this.formData.find((field: CommonSettingStatisticsField) => field.key === fieldKey);
  }

  private getFieldValue(fieldKey: string): string {
    let field = this.findField(fieldKey);
    return field ? field.value : '';
  }

  private setFieldValue(fieldKey: string, value: string): void {
    let field = this.findField(fieldKey);
    if (field) {
      field.value = value;
    }
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingStatisticsFields();
  }

  private showFeedback(message: string): void {
    this.feedbackMessage = message;
    this.feedbackDialogVisible = true;
  }

  private showSubmitWaiting(message: string): void {
    this.submitWaitingMessage = message;
    this.submitWaitingDialogVisible = true;
  }

  private closeSubmitWaiting(): void {
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
  }

  private parseStatisticsFieldUint(value: string, fallbackValue: number): number {
    let parsed = Number.parseFloat(value);
    if (!Number.isFinite(parsed) || parsed < 0) {
      return fallbackValue;
    }
    return Math.max(0, Math.round(parsed));
  }

  private createStatisticsWriteValue(
    fallbackSource?: CommonSettingStatisticsStructValue
  ): CommonSettingStatisticsWriteValue {
    return {
      Enable_Bus: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_Bus'),
        fallbackSource?.Enable_Bus ?? 1
      ),
      Enable_Line: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_Line'),
        fallbackSource?.Enable_Line ?? 1
      ),
      Enable_VoltageMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_VoltageMaxValue'),
        fallbackSource?.Enable_VoltageMaxValue ?? 1
      ),
      PeriodType_VoltageMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_VoltageMaxValue'),
        fallbackSource?.PeriodType_VoltageMaxValue ?? 2
      ),
      PeriodLength_VoltageMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_VoltageMaxValue'),
        fallbackSource?.PeriodLength_VoltageMaxValue ?? 0
      ),
      Enable_VoltageMinValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_VoltageMinValue'),
        fallbackSource?.Enable_VoltageMinValue ?? 1
      ),
      PeriodType_VoltageMinValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_VoltageMinValue'),
        fallbackSource?.PeriodType_VoltageMinValue ?? 2
      ),
      PeriodLength_VoltageMinValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_VoltageMinValue'),
        fallbackSource?.PeriodLength_VoltageMinValue ?? 0
      ),
      Enable_VoltageOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_VoltageOnTimeValue'),
        fallbackSource?.Enable_VoltageOnTimeValue ?? 1
      ),
      PeriodType_VoltageOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_VoltageOnTimeValue'),
        fallbackSource?.PeriodType_VoltageOnTimeValue ?? 2
      ),
      PeriodLength_VoltageOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_VoltageOnTimeValue'),
        fallbackSource?.PeriodLength_VoltageOnTimeValue ?? 0
      ),
      Enable_VoltageImbalanceMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_VoltageImbalanceMaxValue'),
        fallbackSource?.Enable_VoltageImbalanceMaxValue ?? 1
      ),
      PeriodType_VoltageImbalanceMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_VoltageImbalanceMaxValue'),
        fallbackSource?.PeriodType_VoltageImbalanceMaxValue ?? 2
      ),
      PeriodLength_VoltageImbalanceMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_VoltageImbalanceMaxValue'),
        fallbackSource?.PeriodLength_VoltageImbalanceMaxValue ?? 0
      ),
      Enable_VoltageQualifiedRateOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_VoltageQualifiedRateOnTimeValue'),
        fallbackSource?.Enable_VoltageQualifiedRateOnTimeValue ?? 1
      ),
      PeriodType_VoltageQualifiedRateOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_VoltageQualifiedRateOnTimeValue'),
        fallbackSource?.PeriodType_VoltageQualifiedRateOnTimeValue ?? 2
      ),
      PeriodLength_VoltageQualifiedRateOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_VoltageQualifiedRateOnTimeValue'),
        fallbackSource?.PeriodLength_VoltageQualifiedRateOnTimeValue ?? 0
      ),
      Enable_CurrentMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_CurrentMaxValue'),
        fallbackSource?.Enable_CurrentMaxValue ?? 1
      ),
      PeriodType_CurrentMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_CurrentMaxValue'),
        fallbackSource?.PeriodType_CurrentMaxValue ?? 2
      ),
      PeriodLength_CurrentMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_CurrentMaxValue'),
        fallbackSource?.PeriodLength_CurrentMaxValue ?? 0
      ),
      Enable_CurrentMinValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_CurrentMinValue'),
        fallbackSource?.Enable_CurrentMinValue ?? 1
      ),
      PeriodType_CurrentMinValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_CurrentMinValue'),
        fallbackSource?.PeriodType_CurrentMinValue ?? 2
      ),
      PeriodLength_CurrentMinValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_CurrentMinValue'),
        fallbackSource?.PeriodLength_CurrentMinValue ?? 0
      ),
      Enable_CurrentOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_CurrentOnTimeValue'),
        fallbackSource?.Enable_CurrentOnTimeValue ?? 1
      ),
      PeriodType_CurrentOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_CurrentOnTimeValue'),
        fallbackSource?.PeriodType_CurrentOnTimeValue ?? 2
      ),
      PeriodLength_CurrentOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_CurrentOnTimeValue'),
        fallbackSource?.PeriodLength_CurrentOnTimeValue ?? 0
      ),
      Enable_CurrentImbalanceMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_CurrentImbalanceMaxValue'),
        fallbackSource?.Enable_CurrentImbalanceMaxValue ?? 1
      ),
      PeriodType_CurrentImbalanceMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_CurrentImbalanceMaxValue'),
        fallbackSource?.PeriodType_CurrentImbalanceMaxValue ?? 2
      ),
      PeriodLength_CurrentImbalanceMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_CurrentImbalanceMaxValue'),
        fallbackSource?.PeriodLength_CurrentImbalanceMaxValue ?? 0
      ),
      Enable_PowerMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PowerMaxValue'),
        fallbackSource?.Enable_PowerMaxValue ?? 1
      ),
      PeriodType_PowerMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PowerMaxValue'),
        fallbackSource?.PeriodType_PowerMaxValue ?? 2
      ),
      PeriodLength_PowerMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PowerMaxValue'),
        fallbackSource?.PeriodLength_PowerMaxValue ?? 0
      ),
      Enable_PowerOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PowerOnTimeValue'),
        fallbackSource?.Enable_PowerOnTimeValue ?? 1
      ),
      PeriodType_PowerOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PowerOnTimeValue'),
        fallbackSource?.PeriodType_PowerOnTimeValue ?? 2
      ),
      PeriodLength_PowerOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PowerOnTimeValue'),
        fallbackSource?.PeriodLength_PowerOnTimeValue ?? 0
      ),
      Enable_PowerFactorMaxValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PowerFactorMaxValue'),
        fallbackSource?.Enable_PowerFactorMaxValue ?? 1
      ),
      PeriodType_PowerFactorMaxValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PowerFactorMaxValue'),
        fallbackSource?.PeriodType_PowerFactorMaxValue ?? 2
      ),
      PeriodLength_PowerFactorMaxValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PowerFactorMaxValue'),
        fallbackSource?.PeriodLength_PowerFactorMaxValue ?? 0
      ),
      Enable_PowerFactorOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PowerFactorOnTimeValue'),
        fallbackSource?.Enable_PowerFactorOnTimeValue ?? 1
      ),
      PeriodType_PowerFactorrOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PowerFactorOnTimeValue'),
        fallbackSource?.PeriodType_PowerFactorrOnTimeValue ?? 2
      ),
      PeriodLength_PowerFactorOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PowerFactorOnTimeValue'),
        fallbackSource?.PeriodLength_PowerFactorOnTimeValue ?? 0
      ),
      Enable_LoadRateOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_LoadRateOnTimeValue'),
        fallbackSource?.Enable_LoadRateOnTimeValue ?? 1
      ),
      PeriodType_LoadRateOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_LoadRateOnTimeValue'),
        fallbackSource?.PeriodType_LoadRateOnTimeValue ?? 2
      ),
      PeriodLength_LoadRateOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_LoadRateOnTimeValue'),
        fallbackSource?.PeriodLength_LoadRateOnTimeValue ?? 0
      ),
      Enable_PositiveActivePowerOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PositiveActivePowerOnTimeValue'),
        fallbackSource?.Enable_PositiveActivePowerOnTimeValue ?? 1
      ),
      PeriodType_PositiveActivePowerOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PositiveActivePowerOnTimeValue'),
        fallbackSource?.PeriodType_PositiveActivePowerOnTimeValue ?? 2
      ),
      PeriodLength_PositiveActivePowerOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PositiveActivePowerOnTimeValue'),
        fallbackSource?.PeriodLength_PositiveActivePowerOnTimeValue ?? 0
      ),
      Enable_PositiveReactivePowerOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_PositiveReactivePowerOnTimeValue'),
        fallbackSource?.Enable_PositiveReactivePowerOnTimeValue ?? 1
      ),
      PeriodType_PositiveReactivePowerOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_PositiveReactivePowerOnTimeValue'),
        fallbackSource?.PeriodType_PositiveReactivePowerOnTimeValue ?? 2
      ),
      PeriodLength_PositiveReactivePowerOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_PositiveReactivePowerOnTimeValue'),
        fallbackSource?.PeriodLength_PositiveReactivePowerOnTimeValue ?? 0
      ),
      Enable_ReverseActivePowerOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_ReverseActivePowerOnTimeValue'),
        fallbackSource?.Enable_ReverseActivePowerOnTimeValue ?? 1
      ),
      PeriodType_ReverseActivePowerOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_ReverseActivePowerOnTimeValue'),
        fallbackSource?.PeriodType_ReverseActivePowerOnTimeValue ?? 2
      ),
      PeriodLength_ReverseActivePowerOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_ReverseActivePowerOnTimeValue'),
        fallbackSource?.PeriodLength_ReverseActivePowerOnTimeValue ?? 0
      ),
      Enable_ReverseReactivePowerOnTimeValue: getStatisticsEnableCode(
        this.getFieldValue('C_Box_Stats_En_ReverseReactivePowerOnTimeValue'),
        fallbackSource?.Enable_ReverseReactivePowerOnTimeValue ?? 1
      ),
      PeriodType_ReverseReactivePowerOnTimeValue: getStatisticsPeriodTypeCode(
        this.getFieldValue('C_Box_Stats_PDType_ReverseReactivePowerOnTimeValue'),
        fallbackSource?.PeriodType_ReverseReactivePowerOnTimeValue ?? 2
      ),
      PeriodLength_ReverseReactivePowerOnTimeValue: this.parseStatisticsFieldUint(
        this.getFieldValue('Edit_Stats_PDLen_ReverseReactivePowerOnTimeValue'),
        fallbackSource?.PeriodLength_ReverseReactivePowerOnTimeValue ?? 0
      )
    };
  }

  private writeNativeStatisticsData(): boolean {
    try {
      let nativeModule = this.loadStatisticsNativeModule();
      if (!nativeModule || typeof nativeModule.updateStatisticsSetting !== 'function') {
        return false;
      }

      let currentStructValue: CommonSettingStatisticsStructValue | undefined = undefined;
      if (typeof nativeModule.getStatisticsSetting === 'function') {
        currentStructValue = nativeModule.getStatisticsSetting();
      }

      let writeValue = this.createStatisticsWriteValue(currentStructValue);
      let writeSuccess = nativeModule.updateStatisticsSetting(writeValue);
      if (writeSuccess) {
        this.loadNativeStatisticsData();
      }
      return writeSuccess;
    } catch (error) {
      console.error(`write native statistics data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    if (!saveSuccess) {
      this.showFeedback('提交失败');
      return;
    }

    let writeSuccess = this.writeNativeStatisticsData();
    if (!writeSuccess) {
      this.showFeedback('提交失败，请检查统计参数结构体写入。');
      return;
    }

    this.showSubmitWaiting('界面参数已写入统计参数结构体，等待装置回应...');
  }

  private closeFeedback(): void {
    this.feedbackDialogVisible = false;
    this.feedbackMessage = '';
  }

  private cleanSectionTitle(title: string): string {
    return title.replace('【', '').replace('】', '');
  }

  private openSelectOverlay(fieldKey: string, title: string, options: string[]): void {
    this.selectOverlayFieldKey = fieldKey;
    this.selectOverlayTitle = title;
    this.selectOverlayValue = this.getFieldValue(fieldKey);
    this.selectOverlayOptions = options.slice();
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
    this.selectOverlayFieldKey = '';
    this.selectOverlayTitle = '';
  }

  private applySelectOverlayValue(value: string): void {
    if (this.selectOverlayFieldKey.length > 0) {
      this.setFieldValue(this.selectOverlayFieldKey, value);
    }
    this.closeSelectOverlay();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Column() {
          this.HeaderBar();

          Scroll() {
            Column() {
              this.TopToggleRow();

              ForEach(COMMON_SETTING_STATISTICS_PERIOD_SECTIONS, (section: StatisticsPeriodConfig) => {
                this.PeriodSectionRow(section);
              }, (section: StatisticsPeriodConfig) => section.enableKey);

              Blank()
                .height(this.s(this.contentBottomPadding));
            }
            .width(this.s(this.contentWidth))
            .constraintSize({ minHeight: this.s(this.contentMinHeight) })
            .padding({ left: this.s(5), right: this.s(5) });
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor('#FFFFFF');

          this.BottomBar();
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
        .backgroundColor('#FFFFFF');
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF');

      if (this.selectOverlayVisible) {
        this.SelectOverlay();
      }

      if (this.submitWaitingDialogVisible) {
        this.SubmitWaitingOverlay();
      }

      if (this.feedbackDialogVisible) {
        this.FeedbackOverlay();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.noticeMin))
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .maxLines(1)
        .textAlign(TextAlign.Start)
        .padding({ left: this.s(10) });

      Text(this.vm.titleLeft)
        .layoutWeight(3)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(37))
          .height(this.s(40));
      }
      .layoutWeight(2)
      .height(this.s(60))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(32))
          .height(this.s(40));
      }
      .layoutWeight(2)
      .height(this.s(60))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .alignItems(VerticalAlign.Center)
    .padding({ left: this.s(10), right: this.s(10), top: this.s(10), bottom: this.s(10) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  TopToggleRow() {
    Column() {
      Row() {
        this.SectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].title, COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].title)}投/退`,
          COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].fieldKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().width(this.s(200));
        this.SectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].title, COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].title)}投/退`,
          COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].fieldKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().layoutWeight(1);
      }
      .width('100%')
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowContentTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.SeparatorRow();
    }
    .width('100%')
    .height(this.s(this.rowHeight));
  }

  @Builder
  PeriodSectionRow(section: StatisticsPeriodConfig) {
    Column() {
      Row() {
        this.SectionTitle(section.title, section.titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(section.title)}投/退`,
          section.enableKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('统计周期类型:', this.periodTypeLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(section.title)}统计周期类型`,
          section.periodTypeKey,
          this.periodTypeFieldWidth,
          this.periodTypeOptions
        );
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('统计周期长度:', this.periodLengthLabelWidth);
        this.InputField(section.periodLengthKey, this.periodLengthFieldWidth);
        Blank().layoutWeight(1);
      }
      .width('100%')
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowContentTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.SeparatorRow();
    }
    .width('100%')
    .height(this.s(this.rowHeight));
  }

  @Builder
  SectionTitle(title: string, width: number) {
    Text(title)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.sectionTitle))
      .fontColor('#000000')
      .fontFamily('sans-serif')
      .maxLines(1)
      .textAlign(TextAlign.Start);
  }

  @Builder
  FieldLabel(label: string, width: number) {
    Text(label)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.fieldLabel))
      .fontColor('#000000')
      .fontFamily('sans-serif')
      .maxLines(1)
      .textAlign(TextAlign.Start);
  }

  @Builder
  InputField(fieldKey: string, width: number) {
    Row() {
      TextInput({ text: this.getFieldValue(fieldKey), placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .backgroundColor(this.fieldBackgroundColor)
        .border({ width: 0 })
        .padding({ left: this.s(8), right: this.s(8), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setFieldValue(fieldKey, value);
        });
    }
    .width(this.s(width))
    .height(this.s(this.fieldHeight))
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ComboField(title: string, fieldKey: string, width: number, options: string[]) {
    Row() {
      Text(this.getFieldValue(fieldKey))
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);

      Text('▼')
        .width(this.s(14))
        .fontSize(this.s(this.fontSize.arrow))
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(4) });
    }
    .width(this.s(width))
    .height(this.s(this.fieldHeight))
    .padding({ left: this.s(8), right: this.s(6) })
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openSelectOverlay(fieldKey, title, options);
    });
  }

  @Builder
  SeparatorRow() {
    Row() {
      Divider()
        .strokeWidth(this.s(this.separatorStroke))
        .color(this.separatorColor)
        .width('100%');
    }
    .width('100%')
    .height(this.s(this.separatorHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SelectOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeSelectOverlay();
      });

      Column() {
        Text(this.selectOverlayTitle)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        ForEach(this.selectOverlayOptions, (option: string) => {
          Button() {
            Text(option)
              .fontSize(this.s(this.fontSize.dialogBody))
              .fontColor('#000000')
              .fontFamily('STKaiti');
          }
          .width('100%')
          .height(this.s(42))
          .margin({ bottom: this.s(6) })
          .backgroundColor(option === this.selectOverlayValue ? '#D9E9F8' : '#FFFFFF')
          .border({ width: 1, color: option === this.selectOverlayValue ? '#7A9CC0' : '#BEBEBE' })
          .borderRadius(this.s(6))
          .onClick(() => {
            this.applySelectOverlayValue(option);
          });
        }, (option: string) => option);

        Button('取消')
          .width('100%')
          .height(this.s(40))
          .margin({ top: this.s(4) })
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(6))
          .onClick(() => {
            this.closeSelectOverlay();
          });
      }
      .width(this.s(this.overlayCardWidth))
      .padding({ left: this.s(14), right: this.s(14), top: this.s(14), bottom: this.s(14) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  FeedbackOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeFeedback();
      });

      Column() {
        Text('提示')
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.feedbackMessage)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('确定')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeFeedback();
          });
      }
      .width(this.s(280))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  SubmitWaitingOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeSubmitWaiting();
      });

      Column() {
        Text('等待回应')
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.submitWaitingMessage)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('关闭')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeSubmitWaiting();
          });
      }
      .width(this.s(280))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().width(this.s(40));

      Button(this.vm.actions.defaultText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          this.resetDefaults();
        });

      Blank().width(this.s(117));

      Button(this.vm.actions.submitText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          this.submitCurrentData();
        });

      Blank().width(this.s(78));

      Button(this.vm.actions.closeText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().width(this.s(78));

      Button(this.vm.actions.backText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().width(this.s(97));

      Text(this.vm.timeText)
        .width(this.s(160))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.footerHeight))
    .alignItems(VerticalAlign.Center)
    .padding({ top: this.s(10), bottom: this.s(10) })
    .backgroundColor('#D3D3D3');
  }
}
