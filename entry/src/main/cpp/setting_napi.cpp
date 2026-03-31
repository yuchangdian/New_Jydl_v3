#include "setting_napi.h"

#include <cmath>
#include <cstdint>
#include <iomanip>
#include <sstream>
#include <string>

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

napi_value CreateObject(napi_env env)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);
    return result;
}

void SetNamedProperty(napi_env env, napi_value object, const char *name, napi_value value)
{
    napi_set_named_property(env, object, name, value);
}

std::string FormatRelayNumber(double value)
{
    if (!std::isfinite(value)) {
        return "";
    }

    std::ostringstream builder;
    builder << std::fixed << std::setprecision(2) << value;
    return builder.str();
}

std::string FormatRelayInteger(std::uint32_t value)
{
    return FormatRelayNumber(static_cast<double>(value));
}

std::string FormatRelayTime(std::uint32_t value)
{
    // RelaySetting time values are stored as 0.5 ms ticks in native structs.
    return FormatRelayNumber(static_cast<double>(value) / 2000.0);
}

std::string FormatRelayIdCode(std::uint32_t value)
{
    return std::to_string(value);
}

std::string FormatRelayMacAddress(const std::uint32_t value[6])
{
    std::ostringstream builder;
    builder << std::uppercase << std::hex << std::setfill('0');
    for (int index = 0; index < 6; index++) {
        if (index > 0) {
            builder << ':';
        }
        builder << std::setw(2) << static_cast<unsigned int>(value[index] & 0xFFU);
    }
    return builder.str();
}

void SetRelayTextField(napi_env env, napi_value fields, const char *fieldId, const std::string &value)
{
    if (fieldId == nullptr || value.empty()) {
        return;
    }

    std::uint32_t fieldCount = 0;
    napi_get_array_length(env, fields, &fieldCount);

    napi_value entry = CreateObject(env);
    SetNamedProperty(env, entry, "id", CreateString(env, fieldId));
    SetNamedProperty(env, entry, "value", CreateString(env, value.c_str()));
    napi_set_element(env, fields, fieldCount, entry);
}

void SetRelayEnumField(napi_env env, napi_value fields, const char *fieldId, const char *label)
{
    if (label == nullptr || label[0] == '\0') {
        return;
    }
    SetRelayTextField(env, fields, fieldId, label);
}

void SetRelayNumberField(napi_env env, napi_value fields, const char *fieldId, double value)
{
    SetRelayTextField(env, fields, fieldId, FormatRelayNumber(value));
}

void SetRelayUintField(napi_env env, napi_value fields, const char *fieldId, std::uint32_t value)
{
    SetRelayTextField(env, fields, fieldId, FormatRelayTime(value));
}

void SetRelayIdField(napi_env env, napi_value fields, const char *fieldId, std::uint32_t value)
{
    SetRelayTextField(env, fields, fieldId, FormatRelayIdCode(value));
}

void SetRelayMacField(napi_env env, napi_value fields, const char *fieldId, const std::uint32_t value[6])
{
    SetRelayTextField(env, fields, fieldId, FormatRelayMacAddress(value));
}

const char *GetRelayEnableText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "投入";
        case 0:
            return "退出";
        default:
            return "";
    }
}

const char *GetRelayProtectionModeText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "跳闸";
        case 0:
            return "告警";
        default:
            return "";
    }
}

const char *GetRelayConvertText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "折算";
        case 0:
            return "不折算";
        default:
            return "";
    }
}

const char *GetRelayInverseCharacterText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "一般反时限";
        case 2:
            return "非常反时限";
        case 3:
            return "极端反时限";
        default:
            return "";
    }
}

const char *GetRelayReclosureModeText(std::uint32_t value)
{
    switch (value) {
        case ReclosureMode_DisableReclosure:
            return "闭锁";
        case ReclosureMode_General:
            return "普通";
        case ReclosureMode_Synchronism:
            return "检同期";
        case ReclosureMode_LineNV_and_BusEV:
            return "检线路无压且母有压";
        case ReclosureMode_LineEV_and_BusNV:
            return "检线路有压且母无压";
        case ReclosureMode_LineNV_and_BusNV:
            return "检线路无压且母无压";
        case ReclosureMode_LineNV_or_BusNV:
            return "检线路无压或母无压";
        default:
            return "";
    }
}

const char *GetRelayMisTripText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "重合";
        case 0:
            return "不重合";
        default:
            return "";
    }
}

const char *GetRelayTripModeText(std::uint32_t value)
{
    switch (value) {
        case 1:
            return "解列";
        case 0:
            return "减载";
        default:
            return "";
    }
}

void AppendRelayCommonFields(napi_env env, napi_value fields, const RelaySetting_Common_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-01-row-01-item-02-cell-01",
        GetRelayEnableText(setting.Enable_FaultIndicatorLightReset));
    SetRelayUintField(env, fields, "section-01-row-01-item-05-cell-01", setting.Time_FaultIndicatorLightReset);
    SetRelayUintField(env, fields, "section-01-row-01-item-09-cell-01", setting.Time_FaultTeleSignalingHolding);
    SetRelayNumberField(env, fields, "section-01-row-02-item-02-cell-01", setting.Value_NoVoltage);
    SetRelayNumberField(env, fields, "section-01-row-02-item-06-cell-01", setting.Value_NoCurrent);
    SetRelayNumberField(env, fields, "section-01-row-02-item-10-cell-01", setting.Value_ThereVoltage);
    SetRelayNumberField(env, fields, "section-01-row-03-item-02-cell-01", setting.Kre_OverRelay);
    SetRelayNumberField(env, fields, "section-01-row-03-item-05-cell-01", setting.Kre_UnderRelay);
    SetRelayEnumField(env, fields, "section-01-row-04-item-02-cell-01",
        GetRelayConvertText(setting.Enable_IoNeedConvert));
}

void AppendRelayCommunicationFields(napi_env env, napi_value fields, const RelaySetting_Communication_Struct &setting)
{
    SetRelayMacField(env, fields, "section-02-row-01-item-01-cell-02", setting.ChannelA_MAC_ETU);
    SetRelayMacField(env, fields, "section-02-row-01-item-03-cell-02", setting.ChannelB_MAC_ETU);
    SetRelayMacField(env, fields, "section-02-row-02-item-01-cell-02", setting.ChannelA_MAC_Onside);
    SetRelayMacField(env, fields, "section-02-row-02-item-03-cell-02", setting.ChannelB_MAC_Onside);
    SetRelayMacField(env, fields, "section-02-row-03-item-01-cell-02", setting.ChannelA_MAC_Offside);
    SetRelayMacField(env, fields, "section-02-row-03-item-03-cell-02", setting.ChannelB_MAC_Offside);
    SetRelayIdField(env, fields, "section-02-row-04-item-02-cell-01", setting.IDcode_ETU);
    SetRelayIdField(env, fields, "section-02-row-05-item-02-cell-01", setting.IDcode_Onside);
    SetRelayIdField(env, fields, "section-02-row-05-item-05-cell-01", setting.IDcode_Offside);
}

void AppendRelayPilotFields(napi_env env, napi_value fields, const RelaySetting_PilotRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-03-row-01-item-01-cell-02",
        GetRelayEnableText(setting.Common.Enable_CTBreakBlock));
    SetRelayEnumField(env, fields, "section-03-row-01-item-03-cell-02",
        GetRelayEnableText(setting.Common.Enable_CTSaturationBlock));
    SetRelayEnumField(env, fields, "section-03-row-02-item-01-cell-02",
        GetRelayEnableText(setting.Common.Enable_StartBlockEachOther));
    SetRelayEnumField(env, fields, "section-03-row-02-item-03-cell-02",
        GetRelayEnableText(setting.Common.Enable_RemoteTripWithStart));

    SetRelayEnumField(env, fields, "section-04-row-01-item-01-cell-02",
        GetRelayEnableText(setting.StartElement.Enable_I_MutationStart));
    SetRelayNumberField(env, fields, "section-04-row-01-item-03-cell-03", setting.StartElement.Value_I_Mutation);
    SetRelayEnumField(env, fields, "section-04-row-02-item-01-cell-02",
        GetRelayEnableText(setting.StartElement.Enable_I_RmsStart));
    SetRelayNumberField(env, fields, "section-04-row-02-item-03-cell-03", setting.StartElement.Value_I_Rms);
    SetRelayEnumField(env, fields, "section-04-row-03-item-01-cell-02",
        GetRelayEnableText(setting.StartElement.Enable_Io_MutationStart));
    SetRelayNumberField(env, fields, "section-04-row-03-item-03-cell-03", setting.StartElement.Value_Io_Mutation);
    SetRelayEnumField(env, fields, "section-04-row-04-item-01-cell-02",
        GetRelayEnableText(setting.StartElement.Enable_Io_RmsStart));
    SetRelayNumberField(env, fields, "section-04-row-04-item-03-cell-03", setting.StartElement.Value_Io_Rms);

    SetRelayEnumField(env, fields, "section-05-row-01-item-01-cell-02",
        GetRelayEnableText(setting.Current.Enable));
    SetRelayEnumField(env, fields, "section-05-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Current.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-05-row-01-item-05-cell-02", setting.Current.Value_Current);
    SetRelayNumberField(env, fields, "section-05-row-01-item-07-cell-02", setting.Current.Value_HighCurrent);

    SetRelayEnumField(env, fields, "section-06-row-01-item-01-cell-02",
        GetRelayEnableText(setting.Io.Enable));
    SetRelayEnumField(env, fields, "section-06-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Io.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-06-row-01-item-05-cell-02", setting.Io.Value_Current);
    SetRelayNumberField(env, fields, "section-06-row-01-item-07-cell-02", setting.Io.Value_HighCurrent);
    SetRelayNumberField(env, fields, "section-06-row-02-item-01-cell-02", setting.Io.Value_RatioCoeff);
}

void AppendRelayOverCurrentZoneFields(
    napi_env env,
    napi_value fields,
    const char *enableFieldId,
    const char *modeFieldId,
    const char *voltageBlockFieldId,
    const char *directionFieldId,
    const char *inrushFieldId,
    const char *currentFieldId,
    const char *delayFieldId,
    const RelaySetting_OverCurrentRelay_Zone_Struct &setting)
{
    SetRelayEnumField(env, fields, enableFieldId, GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, modeFieldId, GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayEnumField(env, fields, voltageBlockFieldId, GetRelayEnableText(setting.Enable_WithVoltageBlock));
    SetRelayEnumField(env, fields, directionFieldId, GetRelayEnableText(setting.Enable_WithDirection));
    SetRelayEnumField(env, fields, inrushFieldId, GetRelayEnableText(setting.Enable_WithInrushCurrentRestrain));
    SetRelayNumberField(env, fields, currentFieldId, setting.Value_Current);
    SetRelayUintField(env, fields, delayFieldId, setting.Time_Delay);
}

void AppendRelayOverCurrentFields(napi_env env, napi_value fields, const RelaySetting_OverCurrentRelay_Struct &setting)
{
    SetRelayNumberField(env, fields, "section-07-row-01-item-01-cell-03", setting.VoltageBlock.Value_LineVoltage);
    SetRelayNumberField(env, fields, "section-07-row-01-item-03-cell-03", setting.VoltageBlock.Value_NegativeVoltage);
    SetRelayNumberField(env, fields, "section-07-row-02-item-01-cell-03", setting.InrushCurrent.Value_Ratio);

    AppendRelayOverCurrentZoneFields(env, fields,
        "section-08-row-01-item-01-cell-02",
        "section-08-row-01-item-03-cell-02",
        "section-08-row-01-item-05-cell-02",
        "section-08-row-01-item-07-cell-02",
        "section-08-row-01-item-09-cell-02",
        "section-08-row-02-item-01-cell-02",
        "section-08-row-02-item-03-cell-02",
        setting.Z1);
    AppendRelayOverCurrentZoneFields(env, fields,
        "section-09-row-01-item-01-cell-02",
        "section-09-row-01-item-03-cell-02",
        "section-09-row-01-item-05-cell-02",
        "section-09-row-01-item-07-cell-02",
        "section-09-row-01-item-09-cell-02",
        "section-09-row-02-item-01-cell-02",
        "section-09-row-02-item-03-cell-02",
        setting.Z2);
    AppendRelayOverCurrentZoneFields(env, fields,
        "section-10-row-01-item-01-cell-02",
        "section-10-row-01-item-03-cell-02",
        "section-10-row-01-item-05-cell-02",
        "section-10-row-01-item-07-cell-02",
        "section-10-row-01-item-09-cell-02",
        "section-10-row-02-item-01-cell-02",
        "section-10-row-02-item-03-cell-02",
        setting.Z3);

    SetRelayEnumField(env, fields, "section-11-row-01-item-01-cell-02", GetRelayEnableText(setting.Inv.Enable));
    SetRelayEnumField(env, fields, "section-11-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Inv.Enable_ProtectionMode));
    SetRelayEnumField(env, fields, "section-11-row-01-item-05-cell-02",
        GetRelayEnableText(setting.Inv.Enable_WithVoltageBlock));
    SetRelayEnumField(env, fields, "section-11-row-01-item-07-cell-02",
        GetRelayEnableText(setting.Inv.Enable_WithDirection));
    SetRelayEnumField(env, fields, "section-11-row-01-item-09-cell-02",
        GetRelayEnableText(setting.Inv.Enable_WithInrushCurrentRestrain));
    SetRelayEnumField(env, fields, "section-11-row-02-item-01-cell-02",
        GetRelayInverseCharacterText(setting.Inv.Index));
    SetRelayNumberField(env, fields, "section-11-row-02-item-03-cell-02", setting.Inv.Value_Current);
    SetRelayUintField(env, fields, "section-11-row-02-item-05-cell-02", setting.Inv.Time_Delay);

    SetRelayEnumField(env, fields, "section-12-row-01-item-01-cell-02", GetRelayEnableText(setting.PTBreak.Enable));
    SetRelayEnumField(env, fields, "section-12-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.PTBreak.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-12-row-01-item-05-cell-02", setting.PTBreak.Value_Current);
    SetRelayUintField(env, fields, "section-12-row-01-item-07-cell-02", setting.PTBreak.Time_Delay);

    SetRelayEnumField(env, fields, "section-13-row-01-item-01-cell-02",
        GetRelayEnableText(setting.Acc.Enable_ManualCloseAcc));
    SetRelayUintField(env, fields, "section-13-row-01-item-03-cell-03", setting.Acc.Time_ManualCloseAccEnble);
    SetRelayEnumField(env, fields, "section-13-row-02-item-01-cell-02",
        GetRelayEnableText(setting.Acc.Enable_ReclosureAcc));
    SetRelayUintField(env, fields, "section-13-row-02-item-03-cell-03", setting.Acc.Time_ReclosureAccEnble);
    SetRelayEnumField(env, fields, "section-13-row-03-item-01-cell-02",
        GetRelayEnableText(setting.Acc.Enable_WithVoltageBlock));
    SetRelayNumberField(env, fields, "section-13-row-03-item-03-cell-02", setting.Acc.Value_Current);
    SetRelayUintField(env, fields, "section-13-row-03-item-05-cell-02", setting.Acc.Time_Delay);
}

void AppendRelayIoZoneFields(
    napi_env env,
    napi_value fields,
    const char *enableFieldId,
    const char *modeFieldId,
    const char *directionFieldId,
    const char *currentFieldId,
    const char *delayFieldId,
    const RelaySetting_IoRelay_Zone_Struct &setting)
{
    SetRelayEnumField(env, fields, enableFieldId, GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, modeFieldId, GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayEnumField(env, fields, directionFieldId, GetRelayEnableText(setting.Enable_WithDirection));
    SetRelayNumberField(env, fields, currentFieldId, setting.Value_Current);
    SetRelayUintField(env, fields, delayFieldId, setting.Time_Delay);
}

void AppendRelayIoFields(napi_env env, napi_value fields, const RelaySetting_IoRelay_Struct &setting)
{
    AppendRelayIoZoneFields(env, fields,
        "section-14-row-01-item-01-cell-02",
        "section-14-row-01-item-03-cell-02",
        "section-14-row-01-item-05-cell-02",
        "section-14-row-02-item-01-cell-02",
        "section-14-row-02-item-03-cell-02",
        setting.Z1);
    AppendRelayIoZoneFields(env, fields,
        "section-15-row-01-item-01-cell-02",
        "section-15-row-01-item-03-cell-02",
        "section-15-row-01-item-05-cell-02",
        "section-15-row-02-item-01-cell-02",
        "section-15-row-02-item-03-cell-02",
        setting.Z2);
    AppendRelayIoZoneFields(env, fields,
        "section-16-row-01-item-01-cell-02",
        "section-16-row-01-item-03-cell-02",
        "section-16-row-01-item-05-cell-02",
        "section-16-row-02-item-01-cell-02",
        "section-16-row-02-item-03-cell-02",
        setting.Z3);

    SetRelayEnumField(env, fields, "section-17-row-01-item-01-cell-02", GetRelayEnableText(setting.Inv.Enable));
    SetRelayEnumField(env, fields, "section-17-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Inv.Enable_ProtectionMode));
    SetRelayEnumField(env, fields, "section-17-row-01-item-05-cell-02",
        GetRelayEnableText(setting.Inv.Enable_WithDirection));
    SetRelayEnumField(env, fields, "section-17-row-02-item-01-cell-02",
        GetRelayInverseCharacterText(setting.Inv.Index));
    SetRelayNumberField(env, fields, "section-17-row-02-item-03-cell-02", setting.Inv.Value_Current);
    SetRelayUintField(env, fields, "section-17-row-02-item-05-cell-02", setting.Inv.Time_Delay);

    SetRelayEnumField(env, fields, "section-18-row-01-item-01-cell-02",
        GetRelayEnableText(setting.Acc.Enable_ManualCloseAcc));
    SetRelayUintField(env, fields, "section-18-row-01-item-03-cell-03", setting.Acc.Time_ManualCloseAccEnble);
    SetRelayEnumField(env, fields, "section-18-row-02-item-01-cell-02",
        GetRelayEnableText(setting.Acc.Enable_ReclosureAcc));
    SetRelayUintField(env, fields, "section-18-row-02-item-03-cell-03", setting.Acc.Time_ReclosureAccEnble);
    SetRelayNumberField(env, fields, "section-18-row-03-item-01-cell-02", setting.Acc.Value_Current);
    SetRelayUintField(env, fields, "section-18-row-03-item-03-cell-02", setting.Acc.Time_Delay);
}

void AppendRelayAdaptIoFields(napi_env env, napi_value fields, const RelaySetting_adaptIoRelay_Struct &setting)
{
    SetRelayNumberField(env, fields, "section-19-row-01-item-01-cell-02", setting.Value_MinCurrent);
    SetRelayNumberField(env, fields, "section-19-row-01-item-03-cell-02", setting.Value_Ko_Re);
    SetRelayNumberField(env, fields, "section-19-row-01-item-03-cell-04", setting.Value_Ko_Im);
    SetRelayNumberField(env, fields, "section-19-row-01-item-05-cell-02", setting.Value_Zs_Re);
    SetRelayNumberField(env, fields, "section-19-row-01-item-05-cell-04", setting.Value_Zs_Im);
    SetRelayEnumField(env, fields, "section-19-row-02-item-01-cell-02", GetRelayEnableText(setting.Enable_Z1));
    SetRelayEnumField(env, fields, "section-19-row-02-item-03-cell-02", GetRelayEnableText(setting.Enable_Z2));
    SetRelayEnumField(env, fields, "section-19-row-02-item-05-cell-02", GetRelayEnableText(setting.Enable_Z3));
    SetRelayEnumField(env, fields, "section-19-row-02-item-07-cell-02", GetRelayEnableText(setting.Enable_Inv));
    SetRelayEnumField(env, fields, "section-19-row-03-item-01-cell-02",
        GetRelayEnableText(setting.Enable_ManualCloseAcc));
    SetRelayEnumField(env, fields, "section-19-row-03-item-03-cell-02",
        GetRelayEnableText(setting.Enable_ReclosureAcc));
}

void AppendRelayReclosureFields(napi_env env, napi_value fields, const RelaySetting_ReclosureRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-20-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-20-row-01-item-03-cell-02",
        GetRelayReclosureModeText(setting.Enable_Mode));
    SetRelayUintField(env, fields, "section-20-row-01-item-05-cell-02", setting.Time_Charge);
    SetRelayEnumField(env, fields, "section-20-row-02-item-01-cell-02",
        GetRelayMisTripText(setting.Enable_MisTripStartReclosure));
    SetRelayEnumField(env, fields, "section-20-row-02-item-03-cell-02",
        GetRelayEnableText(setting.Enable_BigCurrentBlock));
    SetRelayNumberField(env, fields, "section-20-row-02-item-05-cell-02", setting.Value_BigCurrent);
    SetRelayNumberField(env, fields, "section-20-row-03-item-01-cell-02", setting.Value_Angle);
    SetRelayUintField(env, fields, "section-20-row-03-item-03-cell-02", setting.Time_OpenCheckSynchronism);
    SetRelayUintField(env, fields, "section-20-row-03-item-05-cell-02", setting.Time_OpenCheckNoVoltage);
    SetRelayUintField(env, fields, "section-20-row-04-item-01-cell-02", setting.Time_Delay);
}

void AppendRelayOverloadFields(napi_env env, napi_value fields, const RelaySetting_OverLoadRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-21-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-21-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-21-row-01-item-05-cell-02", setting.Value_Current);
    SetRelayUintField(env, fields, "section-21-row-02-item-01-cell-02", setting.Time_TripDelay);
    SetRelayUintField(env, fields, "section-21-row-02-item-03-cell-02", setting.Time_AlarmDelay);
}

void AppendRelayLowVoltageFields(napi_env env, napi_value fields, const RelaySetting_LowVoltageRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-22-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-22-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-22-row-01-item-05-cell-02", setting.Value_Voltage);
    SetRelayUintField(env, fields, "section-22-row-01-item-07-cell-02", setting.Time_Delay);
    SetRelayNumberField(env, fields, "section-22-row-02-item-01-cell-02", setting.Value_LowVoltageBlock);
    SetRelayEnumField(env, fields, "section-22-row-02-item-03-cell-02",
        GetRelayEnableText(setting.Enable_WithSlipBlock));
    SetRelayNumberField(env, fields, "section-22-row-02-item-05-cell-02", setting.Value_SlipBlock);
    SetRelayNumberField(env, fields, "section-22-row-03-item-01-cell-02", setting.Value_SlipClearBlock);
    SetRelayEnumField(env, fields, "section-22-row-03-item-03-cell-02",
        GetRelayEnableText(setting.Enable_WithNoCurrentBlock));
    SetRelayNumberField(env, fields, "section-22-row-03-item-05-cell-02", setting.Value_NoCurrent);
}

void AppendRelayOverVoltageFields(napi_env env, napi_value fields, const RelaySetting_OverVoltageRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-23-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-23-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-23-row-01-item-05-cell-02", setting.Value_Voltage);
    SetRelayUintField(env, fields, "section-23-row-01-item-07-cell-02", setting.Time_Delay);
}

void AppendRelayLowFrequencyFields(napi_env env, napi_value fields, const RelaySetting_LowFrequencyRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-24-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-24-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-24-row-01-item-05-cell-02", setting.Value_Frequency);
    SetRelayUintField(env, fields, "section-24-row-01-item-07-cell-02", setting.Time_Delay);
    SetRelayEnumField(env, fields, "section-24-row-02-item-01-cell-02",
        GetRelayTripModeText(setting.Enable_TripMode));
    SetRelayEnumField(env, fields, "section-24-row-02-item-03-cell-02",
        GetRelayEnableText(setting.Enable_WithSlipBlock));
    SetRelayNumberField(env, fields, "section-24-row-02-item-05-cell-02", setting.Value_SlipBlock);
    SetRelayEnumField(env, fields, "section-24-row-03-item-01-cell-02",
        GetRelayEnableText(setting.Enable_WithNoCurrentBlock));
    SetRelayNumberField(env, fields, "section-24-row-03-item-03-cell-02", setting.Value_NoCurrentBlock);
    SetRelayNumberField(env, fields, "section-24-row-03-item-05-cell-02", setting.Value_LowVoltageBlock);
}

void AppendRelayHighFrequencyFields(napi_env env, napi_value fields, const RelaySetting_HighFrequencyRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-25-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-25-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-25-row-01-item-05-cell-02", setting.Value_Frequency);
    SetRelayUintField(env, fields, "section-25-row-01-item-07-cell-02", setting.Time_Delay);
}

void AppendRelayInversePowerFields(napi_env env, napi_value fields, const RelaySetting_InversePowerRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-26-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-26-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-26-row-01-item-05-cell-02", setting.Value_Power);
    SetRelayUintField(env, fields, "section-26-row-01-item-07-cell-02", setting.Time_Delay);
}

void AppendRelayHarmonicCurrentFields(napi_env env, napi_value fields, const RelaySetting_HarmonicCurrentRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-27-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-27-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-27-row-01-item-05-cell-02", setting.Value_THDi);
    SetRelayUintField(env, fields, "section-27-row-01-item-07-cell-02", setting.Time_Delay);
}

void AppendRelayHarmonicVoltageFields(napi_env env, napi_value fields, const RelaySetting_HarmonicVoltageRelay_Struct &setting)
{
    SetRelayEnumField(env, fields, "section-28-row-01-item-01-cell-02", GetRelayEnableText(setting.Enable));
    SetRelayEnumField(env, fields, "section-28-row-01-item-03-cell-02",
        GetRelayProtectionModeText(setting.Enable_ProtectionMode));
    SetRelayNumberField(env, fields, "section-28-row-01-item-05-cell-02", setting.Value_THDu);
    SetRelayUintField(env, fields, "section-28-row-01-item-07-cell-02", setting.Time_Delay);
}

void AppendRelayAbnormalMonitoringFields(
    napi_env env,
    napi_value fields,
    const RelaySetting_AbnormalMonitoring_Struct &setting)
{
    SetRelayEnumField(env, fields, "bus-pt-enable", GetRelayEnableText(setting.BusPTBreak.Enable));
    SetRelayEnumField(env, fields, "bus-pt-block", GetRelayEnableText(setting.BusPTBreak.Enable_BlockProtection));
    SetRelayUintField(env, fields, "bus-pt-delay", setting.BusPTBreak.Time_Delay);

    SetRelayEnumField(env, fields, "line-pt-enable", GetRelayEnableText(setting.LinePTBreak.Enable));
    SetRelayEnumField(env, fields, "line-pt-block", GetRelayEnableText(setting.LinePTBreak.Enable_BlockProtection));
    SetRelayUintField(env, fields, "line-pt-delay", setting.LinePTBreak.Time_Delay);

    SetRelayEnumField(env, fields, "ct-enable", GetRelayEnableText(setting.CTBreak.Enable));
    SetRelayUintField(env, fields, "ct-delay", setting.CTBreak.Time_Delay);

    SetRelayEnumField(env, fields, "cb-enable", GetRelayEnableText(setting.CtrlCircuitBreak.Enable));
    SetRelayUintField(env, fields, "cb-delay", setting.CtrlCircuitBreak.Time_Delay);

    SetRelayEnumField(env, fields, "spring-enable", GetRelayEnableText(setting.SpringLessEnergy.Enable));
    SetRelayUintField(env, fields, "spring-delay", setting.SpringLessEnergy.Time_Delay);

    SetRelayEnumField(env, fields, "twj-enable", GetRelayEnableText(setting.TWJ.Enable));
    SetRelayUintField(env, fields, "twj-delay", setting.TWJ.Time_Delay);

    SetRelayEnumField(env, fields, "freq-enable", GetRelayEnableText(setting.Frequency.Enable));
    SetRelayUintField(env, fields, "freq-delay", setting.Frequency.Time_Delay);

    SetRelayEnumField(env, fields, "ground-enable", GetRelayEnableText(setting.Grounding.Enable));
    SetRelayUintField(env, fields, "ground-delay", setting.Grounding.Time_Delay);
}

napi_value CreateRelaySettingFieldsObject(napi_env env, const RelaySetting_Struct &setting)
{
    napi_value fields = nullptr;
    napi_create_array(env, &fields);

    AppendRelayCommonFields(env, fields, setting.Common);
    AppendRelayCommunicationFields(env, fields, setting.Communication);
    AppendRelayPilotFields(env, fields, setting.Pilot);
    AppendRelayOverCurrentFields(env, fields, setting.OverCurrent);
    AppendRelayIoFields(env, fields, setting.Io);
    AppendRelayAdaptIoFields(env, fields, setting.adaptIo);
    AppendRelayReclosureFields(env, fields, setting.Reclosure);
    AppendRelayOverloadFields(env, fields, setting.OverLoad);
    AppendRelayLowVoltageFields(env, fields, setting.LowVoltage);
    AppendRelayOverVoltageFields(env, fields, setting.OverVoltage);
    AppendRelayLowFrequencyFields(env, fields, setting.LowFrequency);
    AppendRelayHighFrequencyFields(env, fields, setting.HighFrequency);
    AppendRelayInversePowerFields(env, fields, setting.InversePower);
    AppendRelayHarmonicCurrentFields(env, fields, setting.HarmonicCurrent);
    AppendRelayHarmonicVoltageFields(env, fields, setting.HarmonicVoltage);
    AppendRelayAbnormalMonitoringFields(env, fields, setting.AbnormalMonitoring);

    return fields;
}

std::uint32_t GetRelayZoneCodeFromInfo(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = { nullptr };
    std::uint32_t zoneCode = SettingCode_Now;

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc >= 1 && args[0] != nullptr) {
        std::uint32_t parsedZoneCode = 0;
        if (napi_get_value_uint32(env, args[0], &parsedZoneCode) == napi_ok) {
            zoneCode = parsedZoneCode;
        }
    }

    if (zoneCode < 1 || zoneCode > 20) {
        return 1;
    }
    return zoneCode;
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

napi_value GetRelaySettingByZone(napi_env env, napi_callback_info info)
{
    std::uint32_t zoneCode = GetRelayZoneCodeFromInfo(env, info);
    std::uint32_t zoneIndex = zoneCode - 1;

    napi_value result = CreateObject(env);
    SetNamedProperty(env, result, "ready", CreateBoolean(env, RelaySettingReady[zoneIndex]));
    SetNamedProperty(env, result, "zoneCode", CreateUint32(env, zoneCode));

    napi_value fields = RelaySettingReady[zoneIndex]
        ? CreateRelaySettingFieldsObject(env, RelaySetting[zoneIndex])
        : CreateObject(env);
    SetNamedProperty(env, result, "fields", fields);

    return result;
}
