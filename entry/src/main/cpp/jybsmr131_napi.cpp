#include "jybsmr131_napi.h"
#include "protocol/jybsmr131/codec.h"
#include "tcp_client.h"
#include <cmath>

namespace {
napi_value Boolean(napi_env env, bool value)
{
    napi_value result;
    napi_get_boolean(env, value, &result);
    return result;
}
napi_value Number(napi_env env, double value)
{
    napi_value result;
    napi_create_double(env, value, &result);
    return result;
}
bool Address(napi_env env, napi_value value, std::uint16_t &result)
{
    double number = 0;
    if (napi_get_value_double(env, value, &number) != napi_ok || !std::isfinite(number) ||
        std::floor(number) != number || number < 0 || number > 65535) return false;
    result = static_cast<std::uint16_t>(number);
    return true;
}
bool Arguments(napi_env env, napi_callback_info info, napi_value (&args)[2])
{
    std::size_t argc = 2;
    if (napi_get_cb_info(env, info, &argc, args, nullptr, nullptr) == napi_ok && argc == 2) return true;
    napi_throw_type_error(env, nullptr, "需要两个参数");
    return false;
}
bool Addresses(napi_env env, napi_callback_info info, std::uint16_t &common, std::uint16_t &object)
{
    napi_value args[2] = {};
    if (!Arguments(env, info, args)) return false;
    if (Address(env, args[0], common) && Address(env, args[1], object)) return true;
    napi_throw_type_error(env, nullptr, "通信地址必须是 0 到 65535 的整数");
    return false;
}
bool ReadChanges(napi_env env, napi_value array, std::vector<jybsmr131::NumericField> &changes)
{
    bool isArray = false;
    std::uint32_t count = 0;
    if (napi_is_array(env, array, &isArray) != napi_ok || !isArray ||
        napi_get_array_length(env, array, &count) != napi_ok || count == 0 || count > 128) return false;
    for (std::uint32_t i = 0; i < count; ++i) {
        napi_value item, name, values;
        if (napi_get_element(env, array, i, &item) != napi_ok ||
            napi_get_named_property(env, item, "name", &name) != napi_ok ||
            napi_get_named_property(env, item, "values", &values) != napi_ok) return false;
        std::size_t length = 0;
        if (napi_get_value_string_utf8(env, name, nullptr, 0, &length) != napi_ok || length == 0 || length > 128) return false;
        char text[129] = {};
        if (napi_get_value_string_utf8(env, name, text, sizeof(text), &length) != napi_ok) return false;
        std::uint32_t valueCount = 0;
        if (napi_is_array(env, values, &isArray) != napi_ok || !isArray ||
            napi_get_array_length(env, values, &valueCount) != napi_ok || valueCount == 0 || valueCount > 400) return false;
        jybsmr131::NumericField field;
        field.name.assign(text, length);
        for (std::uint32_t j = 0; j < valueCount; ++j) {
            napi_value element;
            double number = 0;
            if (napi_get_element(env, values, j, &element) != napi_ok ||
                napi_get_value_double(env, element, &number) != napi_ok || !std::isfinite(number)) return false;
            field.values.push_back(number);
        }
        changes.push_back(field);
    }
    return true;
}
}
napi_value GetJybsmr131Packet(napi_env env, napi_callback_info info)
{
    std::uint16_t common, object;
    if (!Addresses(env, info, common, object)) return nullptr;
    const auto snapshot = jybsmr131::PacketStore::Instance().Get(common, object);
    napi_value result, fields;
    napi_create_object(env, &result);
    napi_set_named_property(env, result, "ready", Boolean(env, snapshot.ready));
    napi_set_named_property(env, result, "revision", Number(env, snapshot.revision));
    napi_set_named_property(env, result, "sessionId", Number(env, snapshot.sessionId));
    napi_set_named_property(env, result, "commonAddress", Number(env, common));
    napi_set_named_property(env, result, "objectAddress", Number(env, object));
    napi_set_named_property(env, result, "payloadLength", Number(env, snapshot.payloadLength));
    napi_create_array_with_length(env, snapshot.fields.size(), &fields);
    for (std::size_t i = 0; i < snapshot.fields.size(); ++i) {
        const auto &field = snapshot.fields[i];
        napi_value item, name, values;
        napi_create_object(env, &item);
        napi_create_string_utf8(env, field.name.c_str(), field.name.size(), &name);
        napi_set_named_property(env, item, "name", name);
        napi_create_array_with_length(env, field.values.size(), &values);
        for (std::size_t j = 0; j < field.values.size(); ++j) napi_set_element(env, values, j, Number(env, field.values[j]));
        napi_set_named_property(env, item, "values", values);
        napi_set_element(env, fields, i, item);
    }
    napi_set_named_property(env, result, "fields", fields);
    return result;
}
napi_value RequestJybsmr131Packet(napi_env env, napi_callback_info info)
{
    std::uint16_t common, object;
    if (!Addresses(env, info, common, object)) return nullptr;
    std::vector<std::uint8_t> frame;
    if (!jybsmr131::BuildQuery(common, object, frame)) return Boolean(env, false);
    return Boolean(env, TcpClient::GetInstance().Send(reinterpret_cast<const char *>(frame.data()), frame.size()) == 1);
}
napi_value GetJybsmr131DigitalInputs(napi_env env, napi_callback_info info)
{
    (void)info;
    const auto state = jybsmr131::PacketStore::Instance().GetDigitalInputs();
    napi_value result;
    napi_create_object(env, &result);
    napi_set_named_property(env, result, "ready", Boolean(env, state.Ready()));
    napi_set_named_property(env, result, "complete", Boolean(env, state.Complete()));
    napi_set_named_property(env, result, "validMask", Number(env, state.validMask));
    napi_set_named_property(env, result, "BreakerState_Now", Number(env, state.BreakerState_Now));
    const char *names[] = {"GLKGW", "JDKGW", "KHBJ", "WCN", "YFJD", "HW", "TW", "Run", "Alarm", "SyncErr", "SwitchState"};
    const auto *values = reinterpret_cast<const std::uint8_t *>(&state.DigitalInputData);
    for (std::size_t i = 0; i < sizeof(state.DigitalInputData); ++i) {
        // 尚未收到的通道不创建属性，ArkTS 读取为 undefined。
        if ((state.validMask & (1u << i)) != 0) napi_set_named_property(env, result, names[i], Number(env, values[i]));
    }
    return result;
}
napi_value UpdateJybsmr131Setting(napi_env env, napi_callback_info info)
{
    napi_value args[2] = {};
    if (!Arguments(env, info, args)) return nullptr;
    std::uint16_t object;
    std::vector<jybsmr131::NumericField> changes;
    if (!Address(env, args[0], object) || !ReadChanges(env, args[1], changes)) {
        napi_throw_type_error(env, nullptr, "定值参数必须包含有效对象地址和数值字段数组");
        return nullptr;
    }
    std::vector<std::uint8_t> frame;
    if (!jybsmr131::PacketStore::Instance().BuildSetting(object, changes, frame)) return Boolean(env, false);
    // true 仅表示 TCP 发送成功；设备确认值由后续有效回包更新。
    return Boolean(env, TcpClient::GetInstance().Send(reinterpret_cast<const char *>(frame.data()), frame.size()) == 1);
}
