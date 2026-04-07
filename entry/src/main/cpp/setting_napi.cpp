#include "setting_napi.h"

#include <cmath>
#include <cctype>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#include "setting.h"
#include <string.h>
#include "tcp_client.h"


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

bool GetRequiredNamedValue(napi_env env, napi_value object, const char *name, napi_value *result)
{
    bool hasProperty = false;
    if (napi_has_named_property(env, object, name, &hasProperty) != napi_ok || !hasProperty) {
        std::string message = std::string("primary system value missing field: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }

    if (napi_get_named_property(env, object, name, result) != napi_ok) {
        std::string message = std::string("failed to read primary system field: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }
    return true;
}

bool GetRequiredNamedDouble(napi_env env, napi_value object, const char *name, double *result)
{
    napi_value property = nullptr;
    if (!GetRequiredNamedValue(env, object, name, &property)) {
        return false;
    }

    if (napi_get_value_double(env, property, result) != napi_ok || !std::isfinite(*result)) {
        std::string message = std::string("primary system field must be a valid number: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }
    return true;
}

bool GetRequiredNamedUint32(napi_env env, napi_value object, const char *name, std::uint32_t *result)
{
    napi_value property = nullptr;
    if (!GetRequiredNamedValue(env, object, name, &property)) {
        return false;
    }

    if (napi_get_value_uint32(env, property, result) != napi_ok) {
        std::string message = std::string("primary system field must be an unsigned integer: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }
    return true;
}

bool GetRequiredNamedObject(napi_env env, napi_value object, const char *name, napi_value *result)
{
    if (!GetRequiredNamedValue(env, object, name, result)) {
        return false;
    }

    napi_valuetype valueType = napi_undefined;
    if (napi_typeof(env, *result, &valueType) != napi_ok || valueType != napi_object) {
        std::string message = std::string("field must be an object: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }
    return true;
}

bool FillAnalogQuantityParameterFromObject(
    napi_env env,
    napi_value object,
    CommonSetting_AnalogQuantity_Parameter_Struct *parameter)
{
    if (parameter == nullptr) {
        napi_throw_type_error(env, nullptr, "analog quantity parameter target is null");
        return false;
    }

    double numberValue = 0;
    if (!GetRequiredNamedDouble(env, object, "Ua", &numberValue)) {
        return false;
    }
    parameter->Ua = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Ub", &numberValue)) {
        return false;
    }
    parameter->Ub = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Uc", &numberValue)) {
        return false;
    }
    parameter->Uc = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Uo", &numberValue)) {
        return false;
    }
    parameter->Uo = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "IA", &numberValue)) {
        return false;
    }
    parameter->IA = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "IB", &numberValue)) {
        return false;
    }
    parameter->IB = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "IC", &numberValue)) {
        return false;
    }
    parameter->IC = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Io", &numberValue)) {
        return false;
    }
    parameter->Io = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Ia", &numberValue)) {
        return false;
    }
    parameter->Ia = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Ib", &numberValue)) {
        return false;
    }
    parameter->Ib = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Ic", &numberValue)) {
        return false;
    }
    parameter->Ic = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Is", &numberValue)) {
        return false;
    }
    parameter->Is = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Ux", &numberValue)) {
        return false;
    }
    parameter->Ux = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Iby1", &numberValue)) {
        return false;
    }
    parameter->Iby1 = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Iby2", &numberValue)) {
        return false;
    }
    parameter->Iby2 = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, object, "Iby3", &numberValue)) {
        return false;
    }
    parameter->Iby3 = static_cast<float>(numberValue);
    return true;
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

struct RelaySettingWriteFieldValue
{
    std::string textValue;
    double numberValue;
    std::uint32_t enumValue;
    bool hasText;
    bool hasNumber;
    bool hasEnum;

    RelaySettingWriteFieldValue()
        : textValue(""), numberValue(0), enumValue(0), hasText(false), hasNumber(false), hasEnum(false)
    {
    }
};

using RelaySettingWriteFieldMap = std::unordered_map<std::string, RelaySettingWriteFieldValue>;

bool GetRequiredNamedArray(napi_env env, napi_value object, const char *name, napi_value *result)
{
    if (!GetRequiredNamedValue(env, object, name, result)) {
        return false;
    }

    bool isArray = false;
    if (napi_is_array(env, *result, &isArray) != napi_ok || !isArray) {
        std::string message = std::string("field must be an array: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }
    return true;
}

bool GetOptionalNamedValue(napi_env env, napi_value object, const char *name, napi_value *result)
{
    bool hasProperty = false;
    if (napi_has_named_property(env, object, name, &hasProperty) != napi_ok || !hasProperty) {
        return false;
    }
    return napi_get_named_property(env, object, name, result) == napi_ok;
}

bool GetRequiredNamedString(napi_env env, napi_value object, const char *name, std::string *result)
{
    napi_value property = nullptr;
    if (!GetRequiredNamedValue(env, object, name, &property)) {
        return false;
    }

    size_t length = 0;
    if (napi_get_value_string_utf8(env, property, nullptr, 0, &length) != napi_ok) {
        std::string message = std::string("field must be a string: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }

    std::vector<char> buffer(length + 1, '\0');
    size_t written = 0;
    if (napi_get_value_string_utf8(env, property, buffer.data(), buffer.size(), &written) != napi_ok) {
        std::string message = std::string("failed to read string field: ") + name;
        napi_throw_type_error(env, nullptr, message.c_str());
        return false;
    }

    result->assign(buffer.data(), written);
    return true;
}

bool GetOptionalNamedString(napi_env env, napi_value object, const char *name, std::string *result)
{
    napi_value property = nullptr;
    if (!GetOptionalNamedValue(env, object, name, &property)) {
        return false;
    }

    napi_valuetype valueType = napi_undefined;
    if (napi_typeof(env, property, &valueType) != napi_ok || valueType != napi_string) {
        return false;
    }

    size_t length = 0;
    if (napi_get_value_string_utf8(env, property, nullptr, 0, &length) != napi_ok) {
        return false;
    }

    std::vector<char> buffer(length + 1, '\0');
    size_t written = 0;
    if (napi_get_value_string_utf8(env, property, buffer.data(), buffer.size(), &written) != napi_ok) {
        return false;
    }

    result->assign(buffer.data(), written);
    return true;
}

bool GetOptionalNamedDouble(napi_env env, napi_value object, const char *name, double *result)
{
    napi_value property = nullptr;
    if (!GetOptionalNamedValue(env, object, name, &property)) {
        return false;
    }
    return napi_get_value_double(env, property, result) == napi_ok && std::isfinite(*result);
}

bool GetOptionalNamedUint32(napi_env env, napi_value object, const char *name, std::uint32_t *result)
{
    napi_value property = nullptr;
    if (!GetOptionalNamedValue(env, object, name, &property)) {
        return false;
    }
    return napi_get_value_uint32(env, property, result) == napi_ok;
}

std::string TrimRelayText(const std::string &value)
{
    std::size_t start = 0;
    while (start < value.size() && std::isspace(static_cast<unsigned char>(value[start]))) {
        ++start;
    }

    std::size_t end = value.size();
    while (end > start && std::isspace(static_cast<unsigned char>(value[end - 1]))) {
        --end;
    }

    return value.substr(start, end - start);
}

bool BuildRelaySettingWriteFieldMap(
    napi_env env,
    napi_value fieldsArray,
    RelaySettingWriteFieldMap *fieldMap,
    std::uint32_t *fieldCount)
{
    if (fieldMap == nullptr) {
        napi_throw_type_error(env, nullptr, "relay setting field map target is null");
        return false;
    }

    fieldMap->clear();
    if (fieldCount != nullptr) {
        *fieldCount = 0;
    }

    std::uint32_t length = 0;
    napi_get_array_length(env, fieldsArray, &length);
    if (fieldCount != nullptr) {
        *fieldCount = length;
    }

    for (std::uint32_t index = 0; index < length; ++index) {
        napi_value fieldObject = nullptr;
        if (napi_get_element(env, fieldsArray, index, &fieldObject) != napi_ok) {
            continue;
        }

        napi_valuetype valueType = napi_undefined;
        if (napi_typeof(env, fieldObject, &valueType) != napi_ok || valueType != napi_object) {
            continue;
        }

        std::string fieldId;
        if (!GetRequiredNamedString(env, fieldObject, "id", &fieldId)) {
            return false;
        }
        if (fieldId.empty()) {
            continue;
        }

        RelaySettingWriteFieldValue fieldValue;
        fieldValue.hasText = GetOptionalNamedString(env, fieldObject, "textValue", &fieldValue.textValue);
        fieldValue.hasNumber = GetOptionalNamedDouble(env, fieldObject, "numberValue", &fieldValue.numberValue);
        fieldValue.hasEnum = GetOptionalNamedUint32(env, fieldObject, "enumValue", &fieldValue.enumValue);
        (*fieldMap)[fieldId] = fieldValue;
    }

    return true;
}

const RelaySettingWriteFieldValue *FindRelaySettingWriteField(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *fieldId)
{
    if (fieldId == nullptr) {
        return nullptr;
    }

    auto iterator = fieldMap.find(fieldId);
    if (iterator == fieldMap.end()) {
        return nullptr;
    }
    return &iterator->second;
}

std::uint32_t ParseRelayEnableLikeText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "投入") {
            return 1;
        }
        if (textValue == "退出") {
            return 0;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayProtectionModeText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "跳闸") {
            return 1;
        }
        if (textValue == "告警") {
            return 0;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayConvertText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "折算") {
            return 1;
        }
        if (textValue == "不折算") {
            return 0;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayInverseCharacterText(
    const RelaySettingWriteFieldValue *fieldValue,
    std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "一般反时限") {
            return 1;
        }
        if (textValue == "非常反时限") {
            return 2;
        }
        if (textValue == "极端反时限") {
            return 3;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayReclosureModeText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "闭锁") {
            return ReclosureMode_DisableReclosure;
        }
        if (textValue == "普通") {
            return ReclosureMode_General;
        }
        if (textValue == "检同期") {
            return ReclosureMode_Synchronism;
        }
        if (textValue == "检线路无压且母有压") {
            return ReclosureMode_LineNV_and_BusEV;
        }
        if (textValue == "检线路有压且母无压") {
            return ReclosureMode_LineEV_and_BusNV;
        }
        if (textValue == "检线路无压且母无压") {
            return ReclosureMode_LineNV_and_BusNV;
        }
        if (textValue == "检线路无压或母无压") {
            return ReclosureMode_LineNV_or_BusNV;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayMisTripText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "重合") {
            return 1;
        }
        if (textValue == "不重合") {
            return 0;
        }
    }

    if (fieldValue->hasEnum) {
        return fieldValue->enumValue;
    }
    return fallbackValue;
}

std::uint32_t ParseRelayTripModeText(const RelaySettingWriteFieldValue *fieldValue, std::uint32_t fallbackValue)
{
    if (fieldValue == nullptr) {
        return fallbackValue;
    }

    if (fieldValue->hasText) {
        std::string textValue = TrimRelayText(fieldValue->textValue);
        if (textValue == "解列") {
            return 1;
        }
        if (textValue == "减载") {
            return 0;
        }
    }

    return fallbackValue;
}

bool ParseRelayMacAddressText(const std::string &textValue, std::uint32_t output[6])
{
    if (output == nullptr) {
        return false;
    }

    std::stringstream stream(TrimRelayText(textValue));
    std::string segment;
    int index = 0;
    while (std::getline(stream, segment, ':')) {
        if (index >= 6) {
            return false;
        }

        std::string trimmedSegment = TrimRelayText(segment);
        if (trimmedSegment.empty()) {
            return false;
        }

        char *endPointer = nullptr;
        unsigned long parsedValue = std::strtoul(trimmedSegment.c_str(), &endPointer, 16);
        if (endPointer == trimmedSegment.c_str() || *endPointer != '\0' || parsedValue > 0xFFUL) {
            return false;
        }

        output[index] = static_cast<std::uint32_t>(parsedValue);
        ++index;
    }

    return index == 6;
}

std::uint32_t ParseRelayTextUint(const std::string &textValue, std::uint32_t fallbackValue)
{
    std::string trimmedText = TrimRelayText(textValue);
    if (trimmedText.empty()) {
        return fallbackValue;
    }

    char *endPointer = nullptr;
    unsigned long parsedValue = std::strtoul(trimmedText.c_str(), &endPointer, 0);
    if (endPointer == trimmedText.c_str() || *endPointer != '\0') {
        return fallbackValue;
    }

    return static_cast<std::uint32_t>(parsedValue);
}

void ApplyRelayNumberField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, float *target)
{
    const RelaySettingWriteFieldValue *fieldValue = FindRelaySettingWriteField(fieldMap, fieldId);
    if (fieldValue == nullptr || target == nullptr || !fieldValue->hasNumber || !std::isfinite(fieldValue->numberValue)) {
        return;
    }
    *target = static_cast<float>(fieldValue->numberValue);
}

void ApplyRelayTimeField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    const RelaySettingWriteFieldValue *fieldValue = FindRelaySettingWriteField(fieldMap, fieldId);
    if (fieldValue == nullptr || target == nullptr || !fieldValue->hasNumber || !std::isfinite(fieldValue->numberValue)) {
        return;
    }

    double tickValue = fieldValue->numberValue * 2000.0;
    if (tickValue < 0) {
        tickValue = 0;
    }
    *target = static_cast<std::uint32_t>(std::llround(tickValue));
}

void ApplyRelayEnableField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayEnableLikeText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayProtectionModeField(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *fieldId,
    std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayProtectionModeText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayConvertField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayConvertText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayInverseCharacterField(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *fieldId,
    std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayInverseCharacterText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayReclosureModeField(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *fieldId,
    std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayReclosureModeText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayMisTripField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayMisTripText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayTripModeField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    if (target == nullptr) {
        return;
    }
    *target = ParseRelayTripModeText(FindRelaySettingWriteField(fieldMap, fieldId), *target);
}

void ApplyRelayIdField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t *target)
{
    const RelaySettingWriteFieldValue *fieldValue = FindRelaySettingWriteField(fieldMap, fieldId);
    if (fieldValue == nullptr || target == nullptr || !fieldValue->hasText) {
        return;
    }
    *target = ParseRelayTextUint(fieldValue->textValue, *target);
}

void ApplyRelayMacField(const RelaySettingWriteFieldMap &fieldMap, const char *fieldId, std::uint32_t target[6])
{
    const RelaySettingWriteFieldValue *fieldValue = FindRelaySettingWriteField(fieldMap, fieldId);
    if (fieldValue == nullptr || target == nullptr || !fieldValue->hasText) {
        return;
    }

    std::uint32_t parsedValue[6] = {0};
    if (!ParseRelayMacAddressText(fieldValue->textValue, parsedValue)) {
        return;
    }

    for (int index = 0; index < 6; ++index) {
        target[index] = parsedValue[index];
    }
}

void ApplyRelayCommonWriteFields(const RelaySettingWriteFieldMap &fieldMap, RelaySetting_Common_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-01-row-01-item-02-cell-01", &setting->Enable_FaultIndicatorLightReset);
    ApplyRelayTimeField(fieldMap, "section-01-row-01-item-05-cell-01", &setting->Time_FaultIndicatorLightReset);
    ApplyRelayTimeField(fieldMap, "section-01-row-01-item-09-cell-01", &setting->Time_FaultTeleSignalingHolding);
    ApplyRelayNumberField(fieldMap, "section-01-row-02-item-02-cell-01", &setting->Value_NoVoltage);
    ApplyRelayNumberField(fieldMap, "section-01-row-02-item-06-cell-01", &setting->Value_NoCurrent);
    ApplyRelayNumberField(fieldMap, "section-01-row-02-item-10-cell-01", &setting->Value_ThereVoltage);
    ApplyRelayNumberField(fieldMap, "section-01-row-03-item-02-cell-01", &setting->Kre_OverRelay);
    ApplyRelayNumberField(fieldMap, "section-01-row-03-item-05-cell-01", &setting->Kre_UnderRelay);
    ApplyRelayConvertField(fieldMap, "section-01-row-04-item-02-cell-01", &setting->Enable_IoNeedConvert);
}

void ApplyRelayCommunicationWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_Communication_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayMacField(fieldMap, "section-02-row-01-item-01-cell-02", setting->ChannelA_MAC_ETU);
    ApplyRelayMacField(fieldMap, "section-02-row-01-item-03-cell-02", setting->ChannelB_MAC_ETU);
    ApplyRelayMacField(fieldMap, "section-02-row-02-item-01-cell-02", setting->ChannelA_MAC_Onside);
    ApplyRelayMacField(fieldMap, "section-02-row-02-item-03-cell-02", setting->ChannelB_MAC_Onside);
    ApplyRelayMacField(fieldMap, "section-02-row-03-item-01-cell-02", setting->ChannelA_MAC_Offside);
    ApplyRelayMacField(fieldMap, "section-02-row-03-item-03-cell-02", setting->ChannelB_MAC_Offside);
    ApplyRelayIdField(fieldMap, "section-02-row-04-item-02-cell-01", &setting->IDcode_ETU);
    ApplyRelayIdField(fieldMap, "section-02-row-05-item-02-cell-01", &setting->IDcode_Onside);
    ApplyRelayIdField(fieldMap, "section-02-row-05-item-05-cell-01", &setting->IDcode_Offside);
}

void ApplyRelayPilotWriteFields(const RelaySettingWriteFieldMap &fieldMap, RelaySetting_PilotRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-03-row-01-item-01-cell-02", &setting->Common.Enable_CTBreakBlock);
    ApplyRelayEnableField(fieldMap, "section-03-row-01-item-03-cell-02", &setting->Common.Enable_CTSaturationBlock);
    ApplyRelayEnableField(fieldMap, "section-03-row-02-item-01-cell-02", &setting->Common.Enable_StartBlockEachOther);
    ApplyRelayEnableField(fieldMap, "section-03-row-02-item-03-cell-02", &setting->Common.Enable_RemoteTripWithStart);

    ApplyRelayEnableField(fieldMap, "section-04-row-01-item-01-cell-02", &setting->StartElement.Enable_I_MutationStart);
    ApplyRelayNumberField(fieldMap, "section-04-row-01-item-03-cell-03", &setting->StartElement.Value_I_Mutation);
    ApplyRelayEnableField(fieldMap, "section-04-row-02-item-01-cell-02", &setting->StartElement.Enable_I_RmsStart);
    ApplyRelayNumberField(fieldMap, "section-04-row-02-item-03-cell-03", &setting->StartElement.Value_I_Rms);
    ApplyRelayEnableField(fieldMap, "section-04-row-03-item-01-cell-02", &setting->StartElement.Enable_Io_MutationStart);
    ApplyRelayNumberField(fieldMap, "section-04-row-03-item-03-cell-03", &setting->StartElement.Value_Io_Mutation);
    ApplyRelayEnableField(fieldMap, "section-04-row-04-item-01-cell-02", &setting->StartElement.Enable_Io_RmsStart);
    ApplyRelayNumberField(fieldMap, "section-04-row-04-item-03-cell-03", &setting->StartElement.Value_Io_Rms);

    ApplyRelayEnableField(fieldMap, "section-05-row-01-item-01-cell-02", &setting->Current.Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-05-row-01-item-03-cell-02", &setting->Current.Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-05-row-01-item-05-cell-02", &setting->Current.Value_Current);
    ApplyRelayNumberField(fieldMap, "section-05-row-01-item-07-cell-02", &setting->Current.Value_HighCurrent);

    ApplyRelayEnableField(fieldMap, "section-06-row-01-item-01-cell-02", &setting->Io.Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-06-row-01-item-03-cell-02", &setting->Io.Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-06-row-01-item-05-cell-02", &setting->Io.Value_Current);
    ApplyRelayNumberField(fieldMap, "section-06-row-01-item-07-cell-02", &setting->Io.Value_HighCurrent);
    ApplyRelayNumberField(fieldMap, "section-06-row-02-item-01-cell-02", &setting->Io.Value_RatioCoeff);
}

void ApplyRelayOverCurrentZoneWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *enableFieldId,
    const char *modeFieldId,
    const char *voltageBlockFieldId,
    const char *directionFieldId,
    const char *inrushFieldId,
    const char *currentFieldId,
    const char *delayFieldId,
    RelaySetting_OverCurrentRelay_Zone_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, enableFieldId, &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, modeFieldId, &setting->Enable_ProtectionMode);
    ApplyRelayEnableField(fieldMap, voltageBlockFieldId, &setting->Enable_WithVoltageBlock);
    ApplyRelayEnableField(fieldMap, directionFieldId, &setting->Enable_WithDirection);
    ApplyRelayEnableField(fieldMap, inrushFieldId, &setting->Enable_WithInrushCurrentRestrain);
    ApplyRelayNumberField(fieldMap, currentFieldId, &setting->Value_Current);
    ApplyRelayTimeField(fieldMap, delayFieldId, &setting->Time_Delay);
}

void ApplyRelayOverCurrentWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_OverCurrentRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayNumberField(fieldMap, "section-07-row-01-item-01-cell-03", &setting->VoltageBlock.Value_LineVoltage);
    ApplyRelayNumberField(fieldMap, "section-07-row-01-item-03-cell-03", &setting->VoltageBlock.Value_NegativeVoltage);
    ApplyRelayNumberField(fieldMap, "section-07-row-02-item-01-cell-03", &setting->InrushCurrent.Value_Ratio);

    ApplyRelayOverCurrentZoneWriteFields(fieldMap,
        "section-08-row-01-item-01-cell-02",
        "section-08-row-01-item-03-cell-02",
        "section-08-row-01-item-05-cell-02",
        "section-08-row-01-item-07-cell-02",
        "section-08-row-01-item-09-cell-02",
        "section-08-row-02-item-01-cell-02",
        "section-08-row-02-item-03-cell-02",
        &setting->Z1);
    ApplyRelayOverCurrentZoneWriteFields(fieldMap,
        "section-09-row-01-item-01-cell-02",
        "section-09-row-01-item-03-cell-02",
        "section-09-row-01-item-05-cell-02",
        "section-09-row-01-item-07-cell-02",
        "section-09-row-01-item-09-cell-02",
        "section-09-row-02-item-01-cell-02",
        "section-09-row-02-item-03-cell-02",
        &setting->Z2);
    ApplyRelayOverCurrentZoneWriteFields(fieldMap,
        "section-10-row-01-item-01-cell-02",
        "section-10-row-01-item-03-cell-02",
        "section-10-row-01-item-05-cell-02",
        "section-10-row-01-item-07-cell-02",
        "section-10-row-01-item-09-cell-02",
        "section-10-row-02-item-01-cell-02",
        "section-10-row-02-item-03-cell-02",
        &setting->Z3);

    ApplyRelayEnableField(fieldMap, "section-11-row-01-item-01-cell-02", &setting->Inv.Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-11-row-01-item-03-cell-02", &setting->Inv.Enable_ProtectionMode);
    ApplyRelayEnableField(fieldMap, "section-11-row-01-item-05-cell-02", &setting->Inv.Enable_WithVoltageBlock);
    ApplyRelayEnableField(fieldMap, "section-11-row-01-item-07-cell-02", &setting->Inv.Enable_WithDirection);
    ApplyRelayEnableField(fieldMap, "section-11-row-01-item-09-cell-02", &setting->Inv.Enable_WithInrushCurrentRestrain);
    ApplyRelayInverseCharacterField(fieldMap, "section-11-row-02-item-01-cell-02", &setting->Inv.Index);
    ApplyRelayNumberField(fieldMap, "section-11-row-02-item-03-cell-02", &setting->Inv.Value_Current);
    ApplyRelayTimeField(fieldMap, "section-11-row-02-item-05-cell-02", &setting->Inv.Time_Delay);

    ApplyRelayEnableField(fieldMap, "section-12-row-01-item-01-cell-02", &setting->PTBreak.Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-12-row-01-item-03-cell-02", &setting->PTBreak.Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-12-row-01-item-05-cell-02", &setting->PTBreak.Value_Current);
    ApplyRelayTimeField(fieldMap, "section-12-row-01-item-07-cell-02", &setting->PTBreak.Time_Delay);

    ApplyRelayEnableField(fieldMap, "section-13-row-01-item-01-cell-02", &setting->Acc.Enable_ManualCloseAcc);
    ApplyRelayTimeField(fieldMap, "section-13-row-01-item-03-cell-03", &setting->Acc.Time_ManualCloseAccEnble);
    ApplyRelayEnableField(fieldMap, "section-13-row-02-item-01-cell-02", &setting->Acc.Enable_ReclosureAcc);
    ApplyRelayTimeField(fieldMap, "section-13-row-02-item-03-cell-03", &setting->Acc.Time_ReclosureAccEnble);
    ApplyRelayEnableField(fieldMap, "section-13-row-03-item-01-cell-02", &setting->Acc.Enable_WithVoltageBlock);
    ApplyRelayNumberField(fieldMap, "section-13-row-03-item-03-cell-02", &setting->Acc.Value_Current);
    ApplyRelayTimeField(fieldMap, "section-13-row-03-item-05-cell-02", &setting->Acc.Time_Delay);
}

void ApplyRelayIoZoneWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    const char *enableFieldId,
    const char *modeFieldId,
    const char *directionFieldId,
    const char *currentFieldId,
    const char *delayFieldId,
    RelaySetting_IoRelay_Zone_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, enableFieldId, &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, modeFieldId, &setting->Enable_ProtectionMode);
    ApplyRelayEnableField(fieldMap, directionFieldId, &setting->Enable_WithDirection);
    ApplyRelayNumberField(fieldMap, currentFieldId, &setting->Value_Current);
    ApplyRelayTimeField(fieldMap, delayFieldId, &setting->Time_Delay);
}

void ApplyRelayIoWriteFields(const RelaySettingWriteFieldMap &fieldMap, RelaySetting_IoRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayIoZoneWriteFields(fieldMap,
        "section-14-row-01-item-01-cell-02",
        "section-14-row-01-item-03-cell-02",
        "section-14-row-01-item-05-cell-02",
        "section-14-row-02-item-01-cell-02",
        "section-14-row-02-item-03-cell-02",
        &setting->Z1);
    ApplyRelayIoZoneWriteFields(fieldMap,
        "section-15-row-01-item-01-cell-02",
        "section-15-row-01-item-03-cell-02",
        "section-15-row-01-item-05-cell-02",
        "section-15-row-02-item-01-cell-02",
        "section-15-row-02-item-03-cell-02",
        &setting->Z2);
    ApplyRelayIoZoneWriteFields(fieldMap,
        "section-16-row-01-item-01-cell-02",
        "section-16-row-01-item-03-cell-02",
        "section-16-row-01-item-05-cell-02",
        "section-16-row-02-item-01-cell-02",
        "section-16-row-02-item-03-cell-02",
        &setting->Z3);

    ApplyRelayEnableField(fieldMap, "section-17-row-01-item-01-cell-02", &setting->Inv.Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-17-row-01-item-03-cell-02", &setting->Inv.Enable_ProtectionMode);
    ApplyRelayEnableField(fieldMap, "section-17-row-01-item-05-cell-02", &setting->Inv.Enable_WithDirection);
    ApplyRelayInverseCharacterField(fieldMap, "section-17-row-02-item-01-cell-02", &setting->Inv.Index);
    ApplyRelayNumberField(fieldMap, "section-17-row-02-item-03-cell-02", &setting->Inv.Value_Current);
    ApplyRelayTimeField(fieldMap, "section-17-row-02-item-05-cell-02", &setting->Inv.Time_Delay);

    ApplyRelayEnableField(fieldMap, "section-18-row-01-item-01-cell-02", &setting->Acc.Enable_ManualCloseAcc);
    ApplyRelayTimeField(fieldMap, "section-18-row-01-item-03-cell-03", &setting->Acc.Time_ManualCloseAccEnble);
    ApplyRelayEnableField(fieldMap, "section-18-row-02-item-01-cell-02", &setting->Acc.Enable_ReclosureAcc);
    ApplyRelayTimeField(fieldMap, "section-18-row-02-item-03-cell-03", &setting->Acc.Time_ReclosureAccEnble);
    ApplyRelayNumberField(fieldMap, "section-18-row-03-item-01-cell-02", &setting->Acc.Value_Current);
    ApplyRelayTimeField(fieldMap, "section-18-row-03-item-03-cell-02", &setting->Acc.Time_Delay);
}

void ApplyRelayAdaptIoWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_adaptIoRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayNumberField(fieldMap, "section-19-row-01-item-01-cell-02", &setting->Value_MinCurrent);
    ApplyRelayNumberField(fieldMap, "section-19-row-01-item-03-cell-02", &setting->Value_Ko_Re);
    ApplyRelayNumberField(fieldMap, "section-19-row-01-item-03-cell-04", &setting->Value_Ko_Im);
    ApplyRelayNumberField(fieldMap, "section-19-row-01-item-05-cell-02", &setting->Value_Zs_Re);
    ApplyRelayNumberField(fieldMap, "section-19-row-01-item-05-cell-04", &setting->Value_Zs_Im);
    ApplyRelayEnableField(fieldMap, "section-19-row-02-item-01-cell-02", &setting->Enable_Z1);
    ApplyRelayEnableField(fieldMap, "section-19-row-02-item-03-cell-02", &setting->Enable_Z2);
    ApplyRelayEnableField(fieldMap, "section-19-row-02-item-05-cell-02", &setting->Enable_Z3);
    ApplyRelayEnableField(fieldMap, "section-19-row-02-item-07-cell-02", &setting->Enable_Inv);
    ApplyRelayEnableField(fieldMap, "section-19-row-03-item-01-cell-02", &setting->Enable_ManualCloseAcc);
    ApplyRelayEnableField(fieldMap, "section-19-row-03-item-03-cell-02", &setting->Enable_ReclosureAcc);
}

void ApplyRelayReclosureWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_ReclosureRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-20-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayReclosureModeField(fieldMap, "section-20-row-01-item-03-cell-02", &setting->Enable_Mode);
    ApplyRelayTimeField(fieldMap, "section-20-row-01-item-05-cell-02", &setting->Time_Charge);
    ApplyRelayMisTripField(fieldMap, "section-20-row-02-item-01-cell-02", &setting->Enable_MisTripStartReclosure);
    ApplyRelayEnableField(fieldMap, "section-20-row-02-item-03-cell-02", &setting->Enable_BigCurrentBlock);
    ApplyRelayNumberField(fieldMap, "section-20-row-02-item-05-cell-02", &setting->Value_BigCurrent);
    ApplyRelayNumberField(fieldMap, "section-20-row-03-item-01-cell-02", &setting->Value_Angle);
    ApplyRelayTimeField(fieldMap, "section-20-row-03-item-03-cell-02", &setting->Time_OpenCheckSynchronism);
    ApplyRelayTimeField(fieldMap, "section-20-row-03-item-05-cell-02", &setting->Time_OpenCheckNoVoltage);
    ApplyRelayTimeField(fieldMap, "section-20-row-04-item-01-cell-02", &setting->Time_Delay);
}

void ApplyRelayOverloadWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_OverLoadRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-21-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-21-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-21-row-01-item-05-cell-02", &setting->Value_Current);
    ApplyRelayTimeField(fieldMap, "section-21-row-02-item-01-cell-02", &setting->Time_TripDelay);
    ApplyRelayTimeField(fieldMap, "section-21-row-02-item-03-cell-02", &setting->Time_AlarmDelay);
}

void ApplyRelayLowVoltageWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_LowVoltageRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-22-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-22-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-22-row-01-item-05-cell-02", &setting->Value_Voltage);
    ApplyRelayTimeField(fieldMap, "section-22-row-01-item-07-cell-02", &setting->Time_Delay);
    ApplyRelayNumberField(fieldMap, "section-22-row-02-item-01-cell-02", &setting->Value_LowVoltageBlock);
    ApplyRelayEnableField(fieldMap, "section-22-row-02-item-03-cell-02", &setting->Enable_WithSlipBlock);
    ApplyRelayNumberField(fieldMap, "section-22-row-02-item-05-cell-02", &setting->Value_SlipBlock);
    ApplyRelayNumberField(fieldMap, "section-22-row-03-item-01-cell-02", &setting->Value_SlipClearBlock);
    ApplyRelayEnableField(fieldMap, "section-22-row-03-item-03-cell-02", &setting->Enable_WithNoCurrentBlock);
    ApplyRelayNumberField(fieldMap, "section-22-row-03-item-05-cell-02", &setting->Value_NoCurrent);
}

void ApplyRelayOverVoltageWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_OverVoltageRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-23-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-23-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-23-row-01-item-05-cell-02", &setting->Value_Voltage);
    ApplyRelayTimeField(fieldMap, "section-23-row-01-item-07-cell-02", &setting->Time_Delay);
}

void ApplyRelayLowFrequencyWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_LowFrequencyRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-24-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-24-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-24-row-01-item-05-cell-02", &setting->Value_Frequency);
    ApplyRelayTimeField(fieldMap, "section-24-row-01-item-07-cell-02", &setting->Time_Delay);
    ApplyRelayTripModeField(fieldMap, "section-24-row-02-item-01-cell-02", &setting->Enable_TripMode);
    ApplyRelayEnableField(fieldMap, "section-24-row-02-item-03-cell-02", &setting->Enable_WithSlipBlock);
    ApplyRelayNumberField(fieldMap, "section-24-row-02-item-05-cell-02", &setting->Value_SlipBlock);
    ApplyRelayEnableField(fieldMap, "section-24-row-03-item-01-cell-02", &setting->Enable_WithNoCurrentBlock);
    ApplyRelayNumberField(fieldMap, "section-24-row-03-item-03-cell-02", &setting->Value_NoCurrentBlock);
    ApplyRelayNumberField(fieldMap, "section-24-row-03-item-05-cell-02", &setting->Value_LowVoltageBlock);
}

void ApplyRelayHighFrequencyWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_HighFrequencyRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-25-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-25-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-25-row-01-item-05-cell-02", &setting->Value_Frequency);
    ApplyRelayTimeField(fieldMap, "section-25-row-01-item-07-cell-02", &setting->Time_Delay);
}

void ApplyRelayInversePowerWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_InversePowerRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-26-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-26-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-26-row-01-item-05-cell-02", &setting->Value_Power);
    ApplyRelayTimeField(fieldMap, "section-26-row-01-item-07-cell-02", &setting->Time_Delay);
}

void ApplyRelayHarmonicCurrentWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_HarmonicCurrentRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-27-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-27-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-27-row-01-item-05-cell-02", &setting->Value_THDi);
    ApplyRelayTimeField(fieldMap, "section-27-row-01-item-07-cell-02", &setting->Time_Delay);
}

void ApplyRelayHarmonicVoltageWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_HarmonicVoltageRelay_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "section-28-row-01-item-01-cell-02", &setting->Enable);
    ApplyRelayProtectionModeField(fieldMap, "section-28-row-01-item-03-cell-02", &setting->Enable_ProtectionMode);
    ApplyRelayNumberField(fieldMap, "section-28-row-01-item-05-cell-02", &setting->Value_THDu);
    ApplyRelayTimeField(fieldMap, "section-28-row-01-item-07-cell-02", &setting->Time_Delay);
}

void ApplyRelayAbnormalMonitoringWriteFields(
    const RelaySettingWriteFieldMap &fieldMap,
    RelaySetting_AbnormalMonitoring_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayEnableField(fieldMap, "bus-pt-enable", &setting->BusPTBreak.Enable);
    ApplyRelayEnableField(fieldMap, "bus-pt-block", &setting->BusPTBreak.Enable_BlockProtection);
    ApplyRelayTimeField(fieldMap, "bus-pt-delay", &setting->BusPTBreak.Time_Delay);

    ApplyRelayEnableField(fieldMap, "line-pt-enable", &setting->LinePTBreak.Enable);
    ApplyRelayEnableField(fieldMap, "line-pt-block", &setting->LinePTBreak.Enable_BlockProtection);
    ApplyRelayTimeField(fieldMap, "line-pt-delay", &setting->LinePTBreak.Time_Delay);

    ApplyRelayEnableField(fieldMap, "ct-enable", &setting->CTBreak.Enable);
    ApplyRelayTimeField(fieldMap, "ct-delay", &setting->CTBreak.Time_Delay);

    ApplyRelayEnableField(fieldMap, "cb-enable", &setting->CtrlCircuitBreak.Enable);
    ApplyRelayTimeField(fieldMap, "cb-delay", &setting->CtrlCircuitBreak.Time_Delay);

    ApplyRelayEnableField(fieldMap, "spring-enable", &setting->SpringLessEnergy.Enable);
    ApplyRelayTimeField(fieldMap, "spring-delay", &setting->SpringLessEnergy.Time_Delay);

    ApplyRelayEnableField(fieldMap, "twj-enable", &setting->TWJ.Enable);
    ApplyRelayTimeField(fieldMap, "twj-delay", &setting->TWJ.Time_Delay);

    ApplyRelayEnableField(fieldMap, "freq-enable", &setting->Frequency.Enable);
    ApplyRelayTimeField(fieldMap, "freq-delay", &setting->Frequency.Time_Delay);

    ApplyRelayEnableField(fieldMap, "ground-enable", &setting->Grounding.Enable);
    ApplyRelayTimeField(fieldMap, "ground-delay", &setting->Grounding.Time_Delay);
}

void ApplyRelayWriteFieldsToSetting(const RelaySettingWriteFieldMap &fieldMap, RelaySetting_Struct *setting)
{
    if (setting == nullptr) {
        return;
    }

    ApplyRelayCommonWriteFields(fieldMap, &setting->Common);
    ApplyRelayCommunicationWriteFields(fieldMap, &setting->Communication);
    ApplyRelayPilotWriteFields(fieldMap, &setting->Pilot);
    ApplyRelayOverCurrentWriteFields(fieldMap, &setting->OverCurrent);
    ApplyRelayIoWriteFields(fieldMap, &setting->Io);
    ApplyRelayAdaptIoWriteFields(fieldMap, &setting->adaptIo);
    ApplyRelayReclosureWriteFields(fieldMap, &setting->Reclosure);
    ApplyRelayOverloadWriteFields(fieldMap, &setting->OverLoad);
    ApplyRelayLowVoltageWriteFields(fieldMap, &setting->LowVoltage);
    ApplyRelayOverVoltageWriteFields(fieldMap, &setting->OverVoltage);
    ApplyRelayLowFrequencyWriteFields(fieldMap, &setting->LowFrequency);
    ApplyRelayHighFrequencyWriteFields(fieldMap, &setting->HighFrequency);
    ApplyRelayInversePowerWriteFields(fieldMap, &setting->InversePower);
    ApplyRelayHarmonicCurrentWriteFields(fieldMap, &setting->HarmonicCurrent);
    ApplyRelayHarmonicVoltageWriteFields(fieldMap, &setting->HarmonicVoltage);
    ApplyRelayAbnormalMonitoringWriteFields(fieldMap, &setting->AbnormalMonitoring);
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

napi_value UpdatePrimarySystemSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updatePrimarySystemSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updatePrimarySystemSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_PrimarySystem_Struct nextSetting = PrimarySystemSetting;

    if (!GetRequiredNamedUint32(env, args[0], "SystemGroundingMode", &nextSetting.SystemGroundingMode)) {
        return nullptr;
    }

    double numberValue = 0;
    if (!GetRequiredNamedDouble(env, args[0], "PTp_Bus_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PTp_Bus_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "PTp_Bus_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PTp_Bus_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "PTo_Bus_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PTo_Bus_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "PTo_Bus_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PTo_Bus_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "PT_Line_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PT_Line_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "PT_Line_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.PT_Line_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedUint32(env, args[0], "PT_Line_Phase", &nextSetting.PT_Line_Phase)) {
        return nullptr;
    }
    if (!GetRequiredNamedDouble(env, args[0], "CTp_Protection_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTp_Protection_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "CTp_Protection_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTp_Protection_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "CTo_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTo_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "CTo_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTo_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "CTp_Measure_Primary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTp_Measure_Primary = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "CTp_Measure_Secondary", &numberValue)) {
        return nullptr;
    }
    nextSetting.CTp_Measure_Secondary = static_cast<float>(numberValue);
    if (!GetRequiredNamedUint32(env, args[0], "Mode_CTConnectioin", &nextSetting.Mode_CTConnectioin)) {
        return nullptr;
    }
    if (!GetRequiredNamedUint32(env, args[0], "Mode_Iosample", &nextSetting.Mode_Iosample)) {
        return nullptr;
    }
    if (!GetRequiredNamedDouble(env, args[0], "RatedPower_Line", &numberValue)) {
        return nullptr;
    }
    nextSetting.RatedPower_Line = static_cast<float>(numberValue);

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(reinterpret_cast<std::uint32_t *>(&nextSetting), CommonSetting_PrimarySystem_CRCLength_4Byte);
    PrimarySystemSetting = nextSetting;
    PrimarySystemSettingReady = true;
    
    RemoteAdjust_PrimarySystem_Struct  *PrimarySystem_Pkg = new RemoteAdjust_PrimarySystem_Struct();
    PrimarySystem_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    PrimarySystem_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_PrimarySystem;
    PrimarySystem_Pkg->Length = CommonSetting_PrimarySystem_Length_1Byte;
    memcpy(&PrimarySystem_Pkg->PrimarySystem, &PrimarySystemSetting, sizeof(CommonSetting_PrimarySystem_Struct));
    //PrimarySystem_Pkg->PrimarySystem = nextSetting;
    //emit slots_Send_CommonSetting_PrimarySystem(PrimarySystem_Pkg, sizeof(CommonSetting_PrimarySystem_Struct)+6);
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(PrimarySystem_Pkg), sizeof(CommonSetting_PrimarySystem_Struct) + 6);
    
    return CreateBoolean(env, true);
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

napi_value UpdateAnalogQuantitySetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateAnalogQuantitySetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateAnalogQuantitySetting argument must be an object");
        return nullptr;
    }

    CommonSetting_AnalogQuantity_Struct nextSetting = AnalogQuantitySetting;
    napi_value referenceValue = nullptr;
    napi_value correctionValue = nullptr;
    napi_value zeroDriftValue = nullptr;

    if (!GetRequiredNamedObject(env, args[0], "Reference", &referenceValue)) {
        return nullptr;
    }
    if (!GetRequiredNamedObject(env, args[0], "Correction", &correctionValue)) {
        return nullptr;
    }
    if (!GetRequiredNamedObject(env, args[0], "ZeroDrift", &zeroDriftValue)) {
        return nullptr;
    }

    if (!FillAnalogQuantityParameterFromObject(env, referenceValue, &nextSetting.Reference)) {
        return nullptr;
    }
    if (!FillAnalogQuantityParameterFromObject(env, correctionValue, &nextSetting.Correction)) {
        return nullptr;
    }
    if (!FillAnalogQuantityParameterFromObject(env, zeroDriftValue, &nextSetting.ZeroDrift)) {
        return nullptr;
    }

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_AnalogQuantity_CRCLength_4Byte);
    AnalogQuantitySetting = nextSetting;
    AnalogQuantitySettingReady = true;
    
    RemoteAdjust_AnalogQuantity_Struct  *AnalogQuantity_Pkg = new RemoteAdjust_AnalogQuantity_Struct();
    AnalogQuantity_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    AnalogQuantity_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_AnalogQuantity;
    AnalogQuantity_Pkg->Length = CommonSetting_AnalogQuantity_Length_1Byte;
    memcpy(&AnalogQuantity_Pkg->AnalogQuantity, &AnalogQuantitySetting, sizeof(CommonSetting_AnalogQuantity_Struct));
//    qDebug("11111111111");
    //emit slots_Send_CommonSetting_AnalogQuantity_Set(AnalogQuantity_Pkg, sizeof(CommonSetting_AnalogQuantity_Struct)+6);
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(AnalogQuantity_Pkg), sizeof(CommonSetting_AnalogQuantity_Struct) + 6);
    
    return CreateBoolean(env, true);
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

napi_value UpdateTeleMeasuringSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateTeleMeasuringSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateTeleMeasuringSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_TeleMeasuring_Struct nextSetting = TeleMeasuringSetting;
    double numberValue = 0;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedDouble(env, args[0], "Cycle_Detection", &numberValue)) {
        return nullptr;
    }
    nextSetting.Cycle_Detection = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_Frequency", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_Frequency = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_ACvoltage", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_ACvoltage = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_DCvoltage", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_DCvoltage = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_ACcurrent", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_ACcurrent = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_Power", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_Power = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "DeadBand_PowerFactor", &numberValue)) {
        return nullptr;
    }
    nextSetting.DeadBand_PowerFactor = static_cast<float>(numberValue);
    if (!GetRequiredNamedUint32(env, args[0], "Enable_PrimaryEnergy", &uintValue)) {
        return nullptr;
    }
    nextSetting.Enable_PrimaryEnergy = uintValue;

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_TeleMeasuring_CRCLength_4Byte);
    TeleMeasuringSetting = nextSetting;
    TeleMeasuringSettingReady = true;

    RemoteAdjust_TeleMeasuring_Struct *teleMeasuringPkg = new RemoteAdjust_TeleMeasuring_Struct();
    teleMeasuringPkg->Common_addr = Common_Addr_RemoteAdjust;
    teleMeasuringPkg->Object_addr = YT_ObjectAddr_CommonSetting_TeleMeasuring;
    teleMeasuringPkg->Length = CommonSetting_TeleMeasuring_Length_1Byte;
    memcpy(&teleMeasuringPkg->TeleMeasuring, &TeleMeasuringSetting, sizeof(CommonSetting_TeleMeasuring_Struct));

    TcpClient::GetInstance().Send(reinterpret_cast<char *>(teleMeasuringPkg), sizeof(CommonSetting_TeleMeasuring_Struct) + 6);

    return CreateBoolean(env, true);
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

napi_value UpdateTeleSignalingSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateTeleSignalingSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateTeleSignalingSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_TeleSignaling_Struct nextSetting = TeleSignalingSetting;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedUint32(env, args[0], "YX01_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX01_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX02_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX02_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX03_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX03_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX04_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX04_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX05_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX05_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX06_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX06_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX07_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX07_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "YX08_Time", &uintValue)) {
        return nullptr;
    }
    nextSetting.YX08_Time = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "Enable_Logic", &uintValue)) {
        return nullptr;
    }
    nextSetting.Enable_Logic = uintValue;

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_TeleSignaling_CRCLength_4Byte);
    TeleSignalingSetting = nextSetting;
    TeleSignalingSettingReady = true;
    
    RemoteAdjust_TeleSignaling_Struct  *TeleSignaling_Pkg = new RemoteAdjust_TeleSignaling_Struct();
    TeleSignaling_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    TeleSignaling_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_TeleSignaling;
    TeleSignaling_Pkg->Length = CommonSetting_TeleSignaling_Length_1Byte;
    memcpy(&TeleSignaling_Pkg->TeleSignaling, &TeleSignalingSetting, sizeof(CommonSetting_TeleSignaling_Struct));

    //emit slots_Send_CommonSetting_TeleSignaling(TeleSignaling_Pkg, sizeof(CommonSetting_TeleSignaling_Struct)+6);

    TcpClient::GetInstance().Send(reinterpret_cast<char *>(TeleSignaling_Pkg), sizeof(CommonSetting_TeleSignaling_Struct) + 6);

    return CreateBoolean(env, true);
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

napi_value UpdateTeleControllingSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateTeleControllingSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateTeleControllingSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_TeleControlling_Struct nextSetting = TeleControllingSetting;
    double numberValue = 0;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK1_XZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK1_XZ = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK1_TZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK1_TZ = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK1_HZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK1_HZ = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK2_XZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK2_XZ = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK2_TZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK2_TZ = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "HoldingTime_YK2_HZ", &uintValue)) {
        return nullptr;
    }
    nextSetting.HoldingTime_YK2_HZ = uintValue;

    if (!GetRequiredNamedDouble(env, args[0], "Sync_NoVoltage", &numberValue)) {
        return nullptr;
    }
    nextSetting.Sync_NoVoltage = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "Sync_ThereVoltage", &numberValue)) {
        return nullptr;
    }
    nextSetting.Sync_ThereVoltage = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "Sync_Volue_VoltageDifferenceBlock", &numberValue)) {
        return nullptr;
    }
    nextSetting.Sync_Volue_VoltageDifferenceBlock = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "Sync_Volue_AngleDifferenceBlock", &numberValue)) {
        return nullptr;
    }
    nextSetting.Sync_Volue_AngleDifferenceBlock = static_cast<float>(numberValue);
    if (!GetRequiredNamedDouble(env, args[0], "Sync_Volue_FrequencyDifferenceBlock", &numberValue)) {
        return nullptr;
    }
    nextSetting.Sync_Volue_FrequencyDifferenceBlock = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Sync_DelayTime", &uintValue)) {
        return nullptr;
    }
    nextSetting.Sync_DelayTime = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "Sync_BreakerCloseTime", &uintValue)) {
        return nullptr;
    }
    nextSetting.Sync_BreakerCloseTime = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "Sync_Enable_CloseMode_YK", &uintValue)) {
        return nullptr;
    }
    nextSetting.Sync_Enable_CloseMode_YK = uintValue;

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_TeleControlling_CRCLength_4Byte);
    TeleControllingSetting = nextSetting;
    TeleControllingSettingReady = true;
    
    
    RemoteAdjust_TeleControlling_Struct  *TeleControlling_Pkg = new RemoteAdjust_TeleControlling_Struct();
    TeleControlling_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    TeleControlling_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_TeleControlling;
    TeleControlling_Pkg->Length = CommonSetting_TeleControlling_Length_1Byte;
    memcpy(&TeleControlling_Pkg->TeleControlling, &TeleControllingSetting, sizeof(CommonSetting_TeleControlling_Struct));

    //emit slots_Send_CommonSetting_TeleControlling(TeleControlling_Pkg, sizeof(CommonSetting_TeleControlling_Struct)+6);
    
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(TeleControlling_Pkg), sizeof(CommonSetting_TeleControlling_Struct) + 6);
    
    return CreateBoolean(env, true);
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

napi_value UpdateExceedingLimitSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateExceedingLimitSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateExceedingLimitSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_ExceedingLimit_Struct nextSetting = ExceedingLimitSetting;
    double numberValue = 0;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_LineVoltageExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_LineVoltageExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_LineVoltageExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_LineVoltageExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_LineVoltageExceedingLowerLimit", &uintValue)) return nullptr;
    nextSetting.Enable_LineVoltageExceedingLowerLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_LineVoltageExceedingLowerLimit", &numberValue)) return nullptr;
    nextSetting.Value_LineVoltageExceedingLowerLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_ZeroSequenceVoltageExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_ZeroSequenceVoltageExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_ZeroSequenceVoltageExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_ZeroSequenceVoltageExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageImbalanceRateExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageImbalanceRateExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageImbalanceRateExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_VoltageImbalanceRateExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PhaseCurrentExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_PhaseCurrentExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_PhaseCurrentExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_PhaseCurrentExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_ZeroSequenceCurrentExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_ZeroSequenceCurrentExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_ZeroSequenceCurrentExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_ZeroSequenceCurrentExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentImbalanceRateExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentImbalanceRateExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_CurrentImbalanceRateExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_CurrentImbalanceRateExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PhaseDifferentialCurrentExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_PhaseDifferentialCurrentExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_PhaseDifferentialCurrentExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_PhaseDifferentialCurrentExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_LoadRateExceedingUpperLimit", &uintValue)) return nullptr;
    nextSetting.Enable_LoadRateExceedingUpperLimit = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_LoadRateRateExceedingUpperLimit", &numberValue)) return nullptr;
    nextSetting.Value_LoadRateRateExceedingUpperLimit = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Time_Delay", &uintValue)) return nullptr;
    nextSetting.Time_Delay = uintValue;

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_ExceedingLimit_CRCLength_4Byte);
    ExceedingLimitSetting = nextSetting;
    ExceedingLimitSettingReady = true;
    
    RemoteAdjust_ExceedingLimit_Struct  *ExceedingLimit_Pkg = new RemoteAdjust_ExceedingLimit_Struct();
    ExceedingLimit_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    ExceedingLimit_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_ExceedingLimit;
    ExceedingLimit_Pkg->Length = CommonSetting_PrimarySystem_Length_1Byte;
    memcpy(&ExceedingLimit_Pkg->ExceedingLimit, &ExceedingLimitSetting, sizeof(CommonSetting_ExceedingLimit_Struct));
//    qDebug("11111111111");
    //emit slots_Send_CommonSetting_ExceedingLimit(ExceedingLimit_Pkg, sizeof(CommonSetting_ExceedingLimit_Struct)+6);
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(ExceedingLimit_Pkg), sizeof(CommonSetting_ExceedingLimit_Struct) + 6);
    
    
    return CreateBoolean(env, true);
}

napi_value GetPowerQualitySetting(napi_env env, napi_callback_info info)
{
    (void)info;

    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, PowerQualitySettingReady));
    napi_set_named_property(env, result, "Enable_FrequencyDeviation",
        CreateUint32(env, PowerQualitySetting.Enable_FrequencyDeviation));
    napi_set_named_property(env, result, "Value_FrequencyDeviation",
        CreateDouble(env, PowerQualitySetting.Value_FrequencyDeviation));
    napi_set_named_property(env, result, "Enable_VoltageDeviation",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageDeviation));
    napi_set_named_property(env, result, "Value_VoltageDeviation",
        CreateDouble(env, PowerQualitySetting.Value_VoltageDeviation));
    napi_set_named_property(env, result, "Enable_VoltageUnbalance",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageUnbalance));
    napi_set_named_property(env, result, "Value_VoltageUnbalance",
        CreateDouble(env, PowerQualitySetting.Value_VoltageUnbalance));
    napi_set_named_property(env, result, "Enable_VoltageFluct",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageFluct));
    napi_set_named_property(env, result, "Value_VoltageFluct",
        CreateDouble(env, PowerQualitySetting.Value_VoltageFluct));
    napi_set_named_property(env, result, "Enable_VoltageFlicke",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageFlicke));
    napi_set_named_property(env, result, "Value_VoltageFlicke",
        CreateDouble(env, PowerQualitySetting.Value_VoltageFlicke));
    napi_set_named_property(env, result, "Enable_VoltageSeg",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageSeg));
    napi_set_named_property(env, result, "Value_VoltageSeg",
        CreateDouble(env, PowerQualitySetting.Value_VoltageSeg));
    napi_set_named_property(env, result, "Enable_VoltageTHD",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageTHD));
    napi_set_named_property(env, result, "Value_VoltageTHD",
        CreateDouble(env, PowerQualitySetting.Value_VoltageTHD));
    napi_set_named_property(env, result, "Enable_VoltageHAR",
        CreateUint32(env, PowerQualitySetting.Enable_VoltageHAR));
    napi_set_named_property(env, result, "Value_VoltageHAR",
        CreateDouble(env, PowerQualitySetting.Value_VoltageHAR));
    napi_set_named_property(env, result, "Enable_CurrentUnbalance",
        CreateUint32(env, PowerQualitySetting.Enable_CurrentUnbalance));
    napi_set_named_property(env, result, "Value_CurrentUnbalance",
        CreateDouble(env, PowerQualitySetting.Value_CurrentUnbalance));
    napi_set_named_property(env, result, "Enable_CurrentTHD",
        CreateUint32(env, PowerQualitySetting.Enable_CurrentTHD));
    napi_set_named_property(env, result, "Value_CurrentTHD",
        CreateDouble(env, PowerQualitySetting.Value_CurrentTHD));
    napi_set_named_property(env, result, "Enable_CurrentHAR",
        CreateUint32(env, PowerQualitySetting.Enable_CurrentHAR));
    napi_set_named_property(env, result, "Value_CurrentHAR",
        CreateDouble(env, PowerQualitySetting.Value_CurrentHAR));
    napi_set_named_property(env, result, "CRC", CreateUint32(env, PowerQualitySetting.CRC));

    return result;
}

napi_value UpdatePowerQualitySetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updatePowerQualitySetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updatePowerQualitySetting argument must be an object");
        return nullptr;
    }

    CommonSetting_PowerQuality_Struct nextSetting = PowerQualitySetting;
    double numberValue = 0;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_FrequencyDeviation", &uintValue)) return nullptr;
    nextSetting.Enable_FrequencyDeviation = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_FrequencyDeviation", &numberValue)) return nullptr;
    nextSetting.Value_FrequencyDeviation = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageDeviation", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageDeviation = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageDeviation", &numberValue)) return nullptr;
    nextSetting.Value_VoltageDeviation = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageUnbalance", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageUnbalance = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageUnbalance", &numberValue)) return nullptr;
    nextSetting.Value_VoltageUnbalance = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageFluct", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageFluct = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageFluct", &numberValue)) return nullptr;
    nextSetting.Value_VoltageFluct = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageFlicke", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageFlicke = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageFlicke", &numberValue)) return nullptr;
    nextSetting.Value_VoltageFlicke = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageSeg", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageSeg = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageSeg", &numberValue)) return nullptr;
    nextSetting.Value_VoltageSeg = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageTHD", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageTHD = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageTHD", &numberValue)) return nullptr;
    nextSetting.Value_VoltageTHD = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageHAR", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageHAR = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_VoltageHAR", &numberValue)) return nullptr;
    nextSetting.Value_VoltageHAR = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentUnbalance", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentUnbalance = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_CurrentUnbalance", &numberValue)) return nullptr;
    nextSetting.Value_CurrentUnbalance = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentTHD", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentTHD = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_CurrentTHD", &numberValue)) return nullptr;
    nextSetting.Value_CurrentTHD = static_cast<float>(numberValue);

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentHAR", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentHAR = uintValue;
    if (!GetRequiredNamedDouble(env, args[0], "Value_CurrentHAR", &numberValue)) return nullptr;
    nextSetting.Value_CurrentHAR = static_cast<float>(numberValue);

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_PowerQuality_CRCLength_4Byte);
    PowerQualitySetting = nextSetting;
    PowerQualitySettingReady = true;

    RemoteAdjust_PowerQuality_Struct *PowerQuality_Pkg = new RemoteAdjust_PowerQuality_Struct();
    PowerQuality_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    PowerQuality_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_PowerQuality;
    PowerQuality_Pkg->Length = CommonSetting_PowerQuality_Length_1Byte;
    memcpy(&PowerQuality_Pkg->PowerQuality, &PowerQualitySetting, sizeof(CommonSetting_PowerQuality_Struct));
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(PowerQuality_Pkg), sizeof(CommonSetting_PowerQuality_Struct) + 6);

    return CreateBoolean(env, true);
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

napi_value UpdateStatisticsSetting(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateStatisticsSetting requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateStatisticsSetting argument must be an object");
        return nullptr;
    }

    CommonSetting_Statistics_Struct nextSetting = StatisticsSetting;
    std::uint32_t uintValue = 0;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_Bus", &uintValue)) return nullptr;
    nextSetting.Enable_Bus = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "Enable_Line", &uintValue)) return nullptr;
    nextSetting.Enable_Line = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_VoltageMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_VoltageMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_VoltageMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_VoltageMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageMinValue", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageMinValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_VoltageMinValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_VoltageMinValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_VoltageMinValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_VoltageMinValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_VoltageOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_VoltageOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_VoltageOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_VoltageOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageImbalanceMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_VoltageImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_VoltageImbalanceMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_VoltageImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_VoltageImbalanceMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_VoltageQualifiedRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_VoltageQualifiedRateOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_VoltageQualifiedRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_VoltageQualifiedRateOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_VoltageQualifiedRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_VoltageQualifiedRateOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_CurrentMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_CurrentMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_CurrentMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_CurrentMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentMinValue", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentMinValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_CurrentMinValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_CurrentMinValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_CurrentMinValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_CurrentMinValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_CurrentOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_CurrentOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_CurrentOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_CurrentOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_CurrentImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_CurrentImbalanceMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_CurrentImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_CurrentImbalanceMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_CurrentImbalanceMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_CurrentImbalanceMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PowerMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_PowerMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PowerMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PowerMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PowerMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PowerMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_PowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PowerOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PowerFactorMaxValue", &uintValue)) return nullptr;
    nextSetting.Enable_PowerFactorMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PowerFactorMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PowerFactorMaxValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PowerFactorMaxValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PowerFactorMaxValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PowerFactorOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_PowerFactorOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PowerFactorrOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PowerFactorrOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PowerFactorOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PowerFactorOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_LoadRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_LoadRateOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_LoadRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_LoadRateOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_LoadRateOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_LoadRateOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PositiveActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_PositiveActivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PositiveActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PositiveActivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PositiveActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PositiveActivePowerOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_PositiveReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_PositiveReactivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_PositiveReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_PositiveReactivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_PositiveReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_PositiveReactivePowerOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_ReverseActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_ReverseActivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_ReverseActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_ReverseActivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_ReverseActivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_ReverseActivePowerOnTimeValue = uintValue;

    if (!GetRequiredNamedUint32(env, args[0], "Enable_ReverseReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.Enable_ReverseReactivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodType_ReverseReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodType_ReverseReactivePowerOnTimeValue = uintValue;
    if (!GetRequiredNamedUint32(env, args[0], "PeriodLength_ReverseReactivePowerOnTimeValue", &uintValue)) return nullptr;
    nextSetting.PeriodLength_ReverseReactivePowerOnTimeValue = uintValue;

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(
        reinterpret_cast<std::uint32_t *>(&nextSetting),
        CommonSetting_Statistics_CRCLength_4Byte);
    StatisticsSetting = nextSetting;
    StatisticsSettingReady = true;

    RemoteAdjust_Statistics_Struct *Statistics_Pkg = new RemoteAdjust_Statistics_Struct();
    Statistics_Pkg->Common_addr = Common_Addr_RemoteAdjust;
    Statistics_Pkg->Object_addr = YT_ObjectAddr_CommonSetting_Statistics;
    Statistics_Pkg->Length = CommonSetting_Statistics_Length_1Byte;
    memcpy(&Statistics_Pkg->Statistics, &StatisticsSetting, sizeof(CommonSetting_Statistics_Struct));
    TcpClient::GetInstance().Send(reinterpret_cast<char *>(Statistics_Pkg), sizeof(CommonSetting_Statistics_Struct) + 6);

    return CreateBoolean(env, true);
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

napi_value UpdateRelaySettingByZone(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "updateRelaySettingByZone requires one object argument");
        return nullptr;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "updateRelaySettingByZone argument must be an object");
        return nullptr;
    }

    std::uint32_t zoneCode = 0;
    if (!GetRequiredNamedUint32(env, args[0], "zoneCode", &zoneCode)) {
        return nullptr;
    }
    if (zoneCode < 1 || zoneCode > 20) {
        napi_throw_range_error(env, nullptr, "relay setting zoneCode must be between 1 and 20");
        return nullptr;
    }

    napi_value fieldsArray = nullptr;
    if (!GetRequiredNamedArray(env, args[0], "fields", &fieldsArray)) {
        return nullptr;
    }

    RelaySettingWriteFieldMap fieldMap;
    std::uint32_t fieldCount = 0;
    if (!BuildRelaySettingWriteFieldMap(env, fieldsArray, &fieldMap, &fieldCount)) {
        return nullptr;
    }

    const std::uint32_t zoneIndex = zoneCode - 1;
    RelaySetting_Struct nextSetting = RelaySettingReady[zoneIndex] ? RelaySetting[zoneIndex] : RelaySetting_Struct {};
    ApplyRelayWriteFieldsToSetting(fieldMap, &nextSetting);

    nextSetting.CRC = 0;
    nextSetting.CRC = CRC32(reinterpret_cast<std::uint32_t *>(&nextSetting), RelaySetting_CRCLength);

    RelaySetting[zoneIndex] = nextSetting;
    RelaySettingReady[zoneIndex] = true;
    SettingCode_Now = zoneCode;

    return CreateBoolean(env, true);
}
