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
