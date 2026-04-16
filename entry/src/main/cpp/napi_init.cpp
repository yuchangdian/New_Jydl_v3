#include <node_api.h>
#include "napi/native_api.h"

#include <cstdlib>
#include <cstring>

#include "setting_napi.h"
#include "telemetry_napi.h"
#include "tcp_client.h"



static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;
}

static napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

static napi_value CreateUndefined(napi_env env)
{
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}

static bool GetRequiredString(napi_env env, napi_value value, char **result)
{
    size_t valueLength = 0;
    if (napi_get_value_string_utf8(env, value, nullptr, 0, &valueLength) != napi_ok) {
        napi_throw_type_error(env, nullptr, "host must be a string");
        return false;
    }

    char *buffer = static_cast<char *>(std::malloc(valueLength + 1));
    if (buffer == nullptr) {
        napi_throw_error(env, nullptr, "failed to allocate host buffer");
        return false;
    }

    if (napi_get_value_string_utf8(env, value, buffer, valueLength + 1, &valueLength) != napi_ok) {
        std::free(buffer);
        napi_throw_type_error(env, nullptr, "failed to read host");
        return false;
    }

    *result = buffer;
    return true;
}

static bool GetRequiredPort(napi_env env, napi_value value, int32_t *port)
{
    if (napi_get_value_int32(env, value, port) != napi_ok) {
        napi_throw_type_error(env, nullptr, "port must be an integer");
        return false;
    }

    if (*port <= 0 || *port > 65535) {
        napi_throw_range_error(env, nullptr, "port must be between 1 and 65535");
        return false;
    }
    return true;
}

static napi_value StartTcpClient(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 2) {
        napi_throw_type_error(env, nullptr, "startTcpClient requires host and port");
        return nullptr;
    }

    char *host = nullptr;
    int32_t port = 0;
    if (!GetRequiredString(env, args[0], &host) || !GetRequiredPort(env, args[1], &port)) {
        std::free(host);
        return nullptr;
    }

    bool started = TcpClient::GetInstance().Start(host, port) == 1;
    std::free(host);
    return CreateBoolean(env, started);
}

static napi_value StopTcpClient(napi_env env, napi_callback_info info)
{
    (void)info;
    TcpClient::GetInstance().Stop();
    return CreateUndefined(env);
}

static napi_value IsTcpClientRunning(napi_env env, napi_callback_info info)
{
    (void)info;
    return CreateBoolean(env, TcpClient::GetInstance().IsRunning() == 1);
}

// SendTcpData 是 ArkTS 到 native 发送链路的入口封装。
// 它负责把 ArkTS 字符串取出来，再转交给 tcp_client_send 执行真正的 socket 发送。
static napi_value SendTcpData(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    if (argc < 1) {
        napi_throw_type_error(env, nullptr, "sendTcpData requires a string argument");
        return nullptr;
    }

    char *data = nullptr;
    if (!GetRequiredString(env, args[0], &data)) {
        return nullptr;
    }

    size_t length = std::strlen(data);
    bool sent = TcpClient::GetInstance().Send(data, static_cast<int>(length)) == 1;
    std::free(data);

    return CreateBoolean(env, sent);
}


EXTERN_C_START
// Init 是 native 模块导出表初始化函数。
// 当 libentry.so 被加载后，ArkTS 侧能调用到哪些原生函数，都在这里挂到 exports 上。
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"startTcpClient", nullptr, StartTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopTcpClient", nullptr, StopTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isTcpClientRunning", nullptr, IsTcpClientRunning, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBaseFreqDisplayData", nullptr, GetBaseFreqDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestHarmonicDisplayData", nullptr, RequestHarmonicDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getHarmonicVoltageDisplayData", nullptr, GetHarmonicVoltageDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getHarmonicCurrentDisplayData", nullptr, GetHarmonicCurrentDisplayData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPrimarySystemSetting", nullptr, GetPrimarySystemSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updatePrimarySystemSetting", nullptr, UpdatePrimarySystemSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAnalogQuantitySetting", nullptr, GetAnalogQuantitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateAnalogQuantitySetting", nullptr, UpdateAnalogQuantitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleMeasuringSetting", nullptr, GetTeleMeasuringSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleMeasuringSetting", nullptr, UpdateTeleMeasuringSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleSignalingSetting", nullptr, GetTeleSignalingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleSignalingSetting", nullptr, UpdateTeleSignalingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getTeleControllingSetting", nullptr, GetTeleControllingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateTeleControllingSetting", nullptr, UpdateTeleControllingSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getExceedingLimitSetting", nullptr, GetExceedingLimitSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateExceedingLimitSetting", nullptr, UpdateExceedingLimitSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getPowerQualitySetting", nullptr, GetPowerQualitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updatePowerQualitySetting", nullptr, UpdatePowerQualitySetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStatisticsSetting", nullptr, GetStatisticsSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateStatisticsSetting", nullptr, UpdateStatisticsSetting, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRelaySettingByZone", nullptr, GetRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"requestRelaySettingByZone", nullptr, RequestRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateRelaySettingByZone", nullptr, UpdateRelaySettingByZone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendTcpData", nullptr, SendTcpData, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr}
        
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = nullptr,
    .reserved = {0},
};

// RegisterEntryModule 是 native 动态库的注册入口。
// so 被装载时，系统会先执行这个 constructor，把上面的 Init 注册给 NAPI 运行时。
extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
