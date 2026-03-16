#include "napi/native_api.h"
#include "tcp_client.h"

#include <string>
#include <vector>


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

namespace {
bool GetRequiredString(napi_env env, napi_value value, std::string &result)
{
    size_t valueLength = 0;
    if (napi_get_value_string_utf8(env, value, nullptr, 0, &valueLength) != napi_ok) {
        napi_throw_type_error(env, nullptr, "host must be a string");
        return false;
    }

    std::vector<char> buffer(valueLength + 1, '\0');
    if (napi_get_value_string_utf8(env, value, buffer.data(), buffer.size(), &valueLength) != napi_ok) {
        napi_throw_type_error(env, nullptr, "failed to read host");
        return false;
    }
    result.assign(buffer.data(), valueLength);
    return true;
}

bool GetRequiredPort(napi_env env, napi_value value, int32_t &port)
{
    if (napi_get_value_int32(env, value, &port) != napi_ok) {
        napi_throw_type_error(env, nullptr, "port must be an integer");
        return false;
    }

    if (port <= 0 || port > 65535) {
        napi_throw_range_error(env, nullptr, "port must be between 1 and 65535");
        return false;
    }
    return true;
}

napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

napi_value CreateUndefined(napi_env env)
{
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}
} // namespace

static napi_value StartTcpClient(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc < 2) {
        napi_throw_type_error(env, nullptr, "startTcpClient requires host and port");
        return nullptr;
    }

    std::string host;
    int32_t port = 0;
    if (!GetRequiredString(env, args[0], host) || !GetRequiredPort(env, args[1], port)) {
        return nullptr;
    }

    return CreateBoolean(env, tcp_client_start(host.c_str(), port) == 1);
}

static napi_value StopTcpClient(napi_env env, napi_callback_info info)
{
    (void)info;
    tcp_client_stop();
    return CreateUndefined(env);
}

static napi_value IsTcpClientRunning(napi_env env, napi_callback_info info)
{
    (void)info;
    return CreateBoolean(env, tcp_client_is_running() == 1);
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"startTcpClient", nullptr, StartTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopTcpClient", nullptr, StopTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isTcpClientRunning", nullptr, IsTcpClientRunning, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_priv = ((void*)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
