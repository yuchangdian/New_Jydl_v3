#include "setting_napi.h"

#include <cstdint>

#include "setting.h"

namespace {

napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

napi_value CreateDouble(napi_env env, double value)
{
    napi_value result = nullptr;
    napi_create_double(env, value, &result);
    return result;
}

napi_value CreateUint32(napi_env env, std::uint32_t value)
{
    napi_value result = nullptr;
    napi_create_uint32(env, value, &result);
    return result;
}

napi_value CreateString(napi_env env, const char *value)
{
    napi_value result = nullptr;
    napi_create_string_utf8(env, value == nullptr ? "" : value, NAPI_AUTO_LENGTH, &result);
    return result;
}

const char *GetPrimarySystemPhaseText(std::uint32_t phase)
{
    switch (phase) {
        case Phase_A:
            return "A相";
        case Phase_B:
            return "B相";
        case Phase_C:
            return "C相";
        case Phase_AB:
            return "AB相";
        case Phase_BC:
            return "BC相";
        case Phase_CA:
            return "CA相";
        case Phase_ABC:
            return "三相";
        default:
            return "";
    }
}

const char *GetPrimarySystemCtConnectionText(std::uint32_t mode)
{
    switch (mode) {
        case Mode_CTConnectioin_3P:
            return "三相式";
        case Mode_CTConnectioin_2P:
            return "两相式";
        default:
            return "";
    }
}

const char *GetPrimarySystemZeroCurrentModeText(std::uint32_t mode)
{
    switch (mode) {
        case Mode_Iosample_Exteral:
            return "外部";
        case Mode_Iosample_SelfGenerate:
            return "自产";
        default:
            return "";
    }
}

napi_value CreateAnalogQuantityParameterObject(
    napi_env env,
    const CommonSetting_AnalogQuantity_Parameter_Struct &parameter)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "Ua", CreateDouble(env, parameter.Ua));
    napi_set_named_property(env, result, "Ub", CreateDouble(env, parameter.Ub));
    napi_set_named_property(env, result, "Uc", CreateDouble(env, parameter.Uc));
    napi_set_named_property(env, result, "Uo", CreateDouble(env, parameter.Uo));
    napi_set_named_property(env, result, "IA", CreateDouble(env, parameter.IA));
    napi_set_named_property(env, result, "IB", CreateDouble(env, parameter.IB));
    napi_set_named_property(env, result, "IC", CreateDouble(env, parameter.IC));
    napi_set_named_property(env, result, "Io", CreateDouble(env, parameter.Io));
    napi_set_named_property(env, result, "Ia", CreateDouble(env, parameter.Ia));
    napi_set_named_property(env, result, "Ib", CreateDouble(env, parameter.Ib));
    napi_set_named_property(env, result, "Ic", CreateDouble(env, parameter.Ic));
    napi_set_named_property(env, result, "Is", CreateDouble(env, parameter.Is));
    napi_set_named_property(env, result, "Ux", CreateDouble(env, parameter.Ux));
    napi_set_named_property(env, result, "Iby1", CreateDouble(env, parameter.Iby1));
    napi_set_named_property(env, result, "Iby2", CreateDouble(env, parameter.Iby2));
    napi_set_named_property(env, result, "Iby3", CreateDouble(env, parameter.Iby3));

    return result;
}

} // namespace

napi_value GetPrimarySystemSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, PrimarySystemSettingReady));
    napi_set_named_property(env, result, "SystemGroundingMode", CreateUint32(env, PrimarySystemSetting.SystemGroundingMode));
    napi_set_named_property(env, result, "PTp_Bus_Primary", CreateDouble(env, PrimarySystemSetting.PTp_Bus_Primary));
    napi_set_named_property(env, result, "PTp_Bus_Secondary", CreateDouble(env, PrimarySystemSetting.PTp_Bus_Secondary));
    napi_set_named_property(env, result, "PTo_Bus_Primary", CreateDouble(env, PrimarySystemSetting.PTo_Bus_Primary));
    napi_set_named_property(env, result, "PTo_Bus_Secondary", CreateDouble(env, PrimarySystemSetting.PTo_Bus_Secondary));
    napi_set_named_property(env, result, "PT_Line_Primary", CreateDouble(env, PrimarySystemSetting.PT_Line_Primary));
    napi_set_named_property(env, result, "PT_Line_Secondary", CreateDouble(env, PrimarySystemSetting.PT_Line_Secondary));
    napi_set_named_property(env, result, "PT_Line_Phase", CreateUint32(env, PrimarySystemSetting.PT_Line_Phase));
    napi_set_named_property(env, result, "PT_Line_Phase_Text",
        CreateString(env, GetPrimarySystemPhaseText(PrimarySystemSetting.PT_Line_Phase)));
    napi_set_named_property(env, result, "CTp_Protection_Primary",
        CreateDouble(env, PrimarySystemSetting.CTp_Protection_Primary));
    napi_set_named_property(env, result, "CTp_Protection_Secondary",
        CreateDouble(env, PrimarySystemSetting.CTp_Protection_Secondary));
    napi_set_named_property(env, result, "CTo_Primary", CreateDouble(env, PrimarySystemSetting.CTo_Primary));
    napi_set_named_property(env, result, "CTo_Secondary", CreateDouble(env, PrimarySystemSetting.CTo_Secondary));
    napi_set_named_property(env, result, "CTp_Measure_Primary",
        CreateDouble(env, PrimarySystemSetting.CTp_Measure_Primary));
    napi_set_named_property(env, result, "CTp_Measure_Secondary",
        CreateDouble(env, PrimarySystemSetting.CTp_Measure_Secondary));
    napi_set_named_property(env, result, "Mode_CTConnectioin", CreateUint32(env, PrimarySystemSetting.Mode_CTConnectioin));
    napi_set_named_property(env, result, "Mode_CTConnectioin_Text",
        CreateString(env, GetPrimarySystemCtConnectionText(PrimarySystemSetting.Mode_CTConnectioin)));
    napi_set_named_property(env, result, "Mode_Iosample", CreateUint32(env, PrimarySystemSetting.Mode_Iosample));
    napi_set_named_property(env, result, "Mode_Iosample_Text",
        CreateString(env, GetPrimarySystemZeroCurrentModeText(PrimarySystemSetting.Mode_Iosample)));
    napi_set_named_property(env, result, "RatedPower_Line", CreateDouble(env, PrimarySystemSetting.RatedPower_Line));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, PrimarySystemSetting.CRC));

    return result;
}

napi_value GetAnalogQuantitySetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, AnalogQuantitySettingReady));
    napi_set_named_property(env, result, "Reference",
        CreateAnalogQuantityParameterObject(env, AnalogQuantitySetting.Reference));
    napi_set_named_property(env, result, "Correction",
        CreateAnalogQuantityParameterObject(env, AnalogQuantitySetting.Correction));
    napi_set_named_property(env, result, "ZeroDrift",
        CreateAnalogQuantityParameterObject(env, AnalogQuantitySetting.ZeroDrift));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, AnalogQuantitySetting.CRC));

    return result;
}

napi_value GetTeleMeasuringSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, TeleMeasuringSettingReady));
    napi_set_named_property(env, result, "Cycle_Detection", CreateDouble(env, TeleMeasuringSetting.Cycle_Detection));
    napi_set_named_property(env, result, "DeadBand_Frequency", CreateDouble(env, TeleMeasuringSetting.DeadBand_Frequency));
    napi_set_named_property(env, result, "DeadBand_ACvoltage", CreateDouble(env, TeleMeasuringSetting.DeadBand_ACvoltage));
    napi_set_named_property(env, result, "DeadBand_DCvoltage", CreateDouble(env, TeleMeasuringSetting.DeadBand_DCvoltage));
    napi_set_named_property(env, result, "DeadBand_ACcurrent", CreateDouble(env, TeleMeasuringSetting.DeadBand_ACcurrent));
    napi_set_named_property(env, result, "DeadBand_Power", CreateDouble(env, TeleMeasuringSetting.DeadBand_Power));
    napi_set_named_property(env, result, "DeadBand_PowerFactor", CreateDouble(env, TeleMeasuringSetting.DeadBand_PowerFactor));
    napi_set_named_property(env, result, "Enable_PrimaryEnergy", CreateUint32(env, TeleMeasuringSetting.Enable_PrimaryEnergy));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, TeleMeasuringSetting.CRC));

    return result;
}

napi_value GetTeleSignalingSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, TeleSignalingSettingReady));
    napi_set_named_property(env, result, "YX01_Time", CreateUint32(env, TeleSignalingSetting.YX01_Time));
    napi_set_named_property(env, result, "YX02_Time", CreateUint32(env, TeleSignalingSetting.YX02_Time));
    napi_set_named_property(env, result, "YX03_Time", CreateUint32(env, TeleSignalingSetting.YX03_Time));
    napi_set_named_property(env, result, "YX04_Time", CreateUint32(env, TeleSignalingSetting.YX04_Time));
    napi_set_named_property(env, result, "YX05_Time", CreateUint32(env, TeleSignalingSetting.YX05_Time));
    napi_set_named_property(env, result, "YX06_Time", CreateUint32(env, TeleSignalingSetting.YX06_Time));
    napi_set_named_property(env, result, "YX07_Time", CreateUint32(env, TeleSignalingSetting.YX07_Time));
    napi_set_named_property(env, result, "YX08_Time", CreateUint32(env, TeleSignalingSetting.YX08_Time));
    napi_set_named_property(env, result, "Enable_Logic", CreateUint32(env, TeleSignalingSetting.Enable_Logic));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, TeleSignalingSetting.CRC));

    return result;
}

napi_value GetTeleControllingSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, TeleControllingSettingReady));
    napi_set_named_property(env, result, "HoldingTime_YK1_XZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK1_XZ));
    napi_set_named_property(env, result, "HoldingTime_YK1_TZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK1_TZ));
    napi_set_named_property(env, result, "HoldingTime_YK1_HZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK1_HZ));
    napi_set_named_property(env, result, "HoldingTime_YK2_XZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK2_XZ));
    napi_set_named_property(env, result, "HoldingTime_YK2_TZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK2_TZ));
    napi_set_named_property(env, result, "HoldingTime_YK2_HZ", CreateUint32(env, TeleControllingSetting.HoldingTime_YK2_HZ));
    napi_set_named_property(env, result, "Sync_NoVoltage", CreateDouble(env, TeleControllingSetting.Sync_NoVoltage));
    napi_set_named_property(env, result, "Sync_ThereVoltage", CreateDouble(env, TeleControllingSetting.Sync_ThereVoltage));
    napi_set_named_property(env, result, "Sync_Volue_VoltageDifferenceBlock",
        CreateDouble(env, TeleControllingSetting.Sync_Volue_VoltageDifferenceBlock));
    napi_set_named_property(env, result, "Sync_Volue_AngleDifferenceBlock",
        CreateDouble(env, TeleControllingSetting.Sync_Volue_AngleDifferenceBlock));
    napi_set_named_property(env, result, "Sync_Volue_FrequencyDifferenceBlock",
        CreateDouble(env, TeleControllingSetting.Sync_Volue_FrequencyDifferenceBlock));
    napi_set_named_property(env, result, "Sync_DelayTime", CreateUint32(env, TeleControllingSetting.Sync_DelayTime));
    napi_set_named_property(env, result, "Sync_BreakerCloseTime", CreateUint32(env, TeleControllingSetting.Sync_BreakerCloseTime));
    napi_set_named_property(env, result, "Sync_Enable_CloseMode_YK",
        CreateUint32(env, TeleControllingSetting.Sync_Enable_CloseMode_YK));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, TeleControllingSetting.CRC));

    return result;
}

napi_value GetExceedingLimitSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, ExceedingLimitSettingReady));
    napi_set_named_property(env, result, "Enable_LineVoltageExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_LineVoltageExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_LineVoltageExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_LineVoltageExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_LineVoltageExceedingLowerLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_LineVoltageExceedingLowerLimit));
    napi_set_named_property(env, result, "Value_LineVoltageExceedingLowerLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_LineVoltageExceedingLowerLimit));
    napi_set_named_property(env, result, "Enable_ZeroSequenceVoltageExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_ZeroSequenceVoltageExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_ZeroSequenceVoltageExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_ZeroSequenceVoltageExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_VoltageImbalanceRateExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_VoltageImbalanceRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_VoltageImbalanceRateExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_VoltageImbalanceRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_PhaseCurrentExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_PhaseCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_PhaseCurrentExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_PhaseCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_ZeroSequenceCurrentExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_ZeroSequenceCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_ZeroSequenceCurrentExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_ZeroSequenceCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_CurrentImbalanceRateExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_CurrentImbalanceRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_CurrentImbalanceRateExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_CurrentImbalanceRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_PhaseDifferentialCurrentExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_PhaseDifferentialCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_PhaseDifferentialCurrentExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_PhaseDifferentialCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit));
    napi_set_named_property(env, result, "Enable_LoadRateExceedingUpperLimit",
        CreateUint32(env, ExceedingLimitSetting.Enable_LoadRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Value_LoadRateRateExceedingUpperLimit",
        CreateDouble(env, ExceedingLimitSetting.Value_LoadRateRateExceedingUpperLimit));
    napi_set_named_property(env, result, "Time_Delay", CreateUint32(env, ExceedingLimitSetting.Time_Delay));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, ExceedingLimitSetting.CRC));

    return result;
}

napi_value GetStatisticsSetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, StatisticsSettingReady));
    napi_set_named_property(env, result, "Enable_Bus", CreateUint32(env, StatisticsSetting.Enable_Bus));
    napi_set_named_property(env, result, "Enable_Line", CreateUint32(env, StatisticsSetting.Enable_Line));

    napi_set_named_property(env, result, "Enable_VoltageMaxValue", CreateUint32(env, StatisticsSetting.Enable_VoltageMaxValue));
    napi_set_named_property(env, result, "PeriodType_VoltageMaxValue", CreateUint32(env, StatisticsSetting.PeriodType_VoltageMaxValue));
    napi_set_named_property(env, result, "PeriodLength_VoltageMaxValue", CreateUint32(env, StatisticsSetting.PeriodLength_VoltageMaxValue));

    napi_set_named_property(env, result, "Enable_VoltageMinValue", CreateUint32(env, StatisticsSetting.Enable_VoltageMinValue));
    napi_set_named_property(env, result, "PeriodType_VoltageMinValue", CreateUint32(env, StatisticsSetting.PeriodType_VoltageMinValue));
    napi_set_named_property(env, result, "PeriodLength_VoltageMinValue", CreateUint32(env, StatisticsSetting.PeriodLength_VoltageMinValue));

    napi_set_named_property(env, result, "Enable_VoltageOnTimeValue", CreateUint32(env, StatisticsSetting.Enable_VoltageOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_VoltageOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodType_VoltageOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_VoltageOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodLength_VoltageOnTimeValue));

    napi_set_named_property(env, result, "Enable_VoltageImbalanceMaxValue", CreateUint32(env, StatisticsSetting.Enable_VoltageImbalanceMaxValue));
    napi_set_named_property(env, result, "PeriodType_VoltageImbalanceMaxValue", CreateUint32(env, StatisticsSetting.PeriodType_VoltageImbalanceMaxValue));
    napi_set_named_property(env, result, "PeriodLength_VoltageImbalanceMaxValue", CreateUint32(env, StatisticsSetting.PeriodLength_VoltageImbalanceMaxValue));

    napi_set_named_property(env, result, "Enable_VoltageQualifiedRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_VoltageQualifiedRateOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_VoltageQualifiedRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_VoltageQualifiedRateOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_VoltageQualifiedRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_VoltageQualifiedRateOnTimeValue));

    napi_set_named_property(env, result, "Enable_CurrentMaxValue", CreateUint32(env, StatisticsSetting.Enable_CurrentMaxValue));
    napi_set_named_property(env, result, "PeriodType_CurrentMaxValue", CreateUint32(env, StatisticsSetting.PeriodType_CurrentMaxValue));
    napi_set_named_property(env, result, "PeriodLength_CurrentMaxValue", CreateUint32(env, StatisticsSetting.PeriodLength_CurrentMaxValue));

    napi_set_named_property(env, result, "Enable_CurrentMinValue", CreateUint32(env, StatisticsSetting.Enable_CurrentMinValue));
    napi_set_named_property(env, result, "PeriodType_CurrentMinValue", CreateUint32(env, StatisticsSetting.PeriodType_CurrentMinValue));
    napi_set_named_property(env, result, "PeriodLength_CurrentMinValue", CreateUint32(env, StatisticsSetting.PeriodLength_CurrentMinValue));

    napi_set_named_property(env, result, "Enable_CurrentOnTimeValue", CreateUint32(env, StatisticsSetting.Enable_CurrentOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_CurrentOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodType_CurrentOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_CurrentOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodLength_CurrentOnTimeValue));

    napi_set_named_property(env, result, "Enable_CurrentImbalanceMaxValue",
        CreateUint32(env, StatisticsSetting.Enable_CurrentImbalanceMaxValue));
    napi_set_named_property(env, result, "PeriodType_CurrentImbalanceMaxValue",
        CreateUint32(env, StatisticsSetting.PeriodType_CurrentImbalanceMaxValue));
    napi_set_named_property(env, result, "PeriodLength_CurrentImbalanceMaxValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_CurrentImbalanceMaxValue));

    napi_set_named_property(env, result, "Enable_PowerMaxValue", CreateUint32(env, StatisticsSetting.Enable_PowerMaxValue));
    napi_set_named_property(env, result, "PeriodType_PowerMaxValue", CreateUint32(env, StatisticsSetting.PeriodType_PowerMaxValue));
    napi_set_named_property(env, result, "PeriodLength_PowerMaxValue", CreateUint32(env, StatisticsSetting.PeriodLength_PowerMaxValue));

    napi_set_named_property(env, result, "Enable_PowerOnTimeValue", CreateUint32(env, StatisticsSetting.Enable_PowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_PowerOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodType_PowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_PowerOnTimeValue", CreateUint32(env, StatisticsSetting.PeriodLength_PowerOnTimeValue));

    napi_set_named_property(env, result, "Enable_PowerFactorMaxValue",
        CreateUint32(env, StatisticsSetting.Enable_PowerFactorMaxValue));
    napi_set_named_property(env, result, "PeriodType_PowerFactorMaxValue",
        CreateUint32(env, StatisticsSetting.PeriodType_PowerFactorMaxValue));
    napi_set_named_property(env, result, "PeriodLength_PowerFactorMaxValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_PowerFactorMaxValue));

    napi_set_named_property(env, result, "Enable_PowerFactorOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_PowerFactorOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_PowerFactorrOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_PowerFactorrOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_PowerFactorOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_PowerFactorOnTimeValue));

    napi_set_named_property(env, result, "Enable_LoadRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_LoadRateOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_LoadRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_LoadRateOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_LoadRateOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_LoadRateOnTimeValue));

    napi_set_named_property(env, result, "Enable_PositiveActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_PositiveActivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_PositiveActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_PositiveActivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_PositiveActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_PositiveActivePowerOnTimeValue));

    napi_set_named_property(env, result, "Enable_PositiveReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_PositiveReactivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_PositiveReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_PositiveReactivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_PositiveReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_PositiveReactivePowerOnTimeValue));

    napi_set_named_property(env, result, "Enable_ReverseActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_ReverseActivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_ReverseActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_ReverseActivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_ReverseActivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_ReverseActivePowerOnTimeValue));

    napi_set_named_property(env, result, "Enable_ReverseReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.Enable_ReverseReactivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodType_ReverseReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodType_ReverseReactivePowerOnTimeValue));
    napi_set_named_property(env, result, "PeriodLength_ReverseReactivePowerOnTimeValue",
        CreateUint32(env, StatisticsSetting.PeriodLength_ReverseReactivePowerOnTimeValue));

    napi_set_named_property(env, result, "CRC", CreateUint32(env, StatisticsSetting.CRC));

    return result;
}
