#include <node_api.h>
#include "napi/native_api.h"
#include <stdlib.h>

#include "tcp_client.h"

static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {NULL};

    napi_get_cb_info(env, info, &argc, args, NULL, NULL);

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
    napi_value result = NULL;
    napi_get_boolean(env, value, &result);
    return result;
}

static napi_value CreateUndefined(napi_env env)
{
    napi_value result = NULL;
    napi_get_undefined(env, &result);
    return result;
}

static bool GetRequiredString(napi_env env, napi_value value, char **result)
{
    size_t valueLength = 0;
    if (napi_get_value_string_utf8(env, value, NULL, 0, &valueLength) != napi_ok) {
        napi_throw_type_error(env, NULL, "host must be a string");
        return false;
    }

    char *buffer = (char *)malloc(valueLength + 1);
    if (buffer == NULL) {
        napi_throw_error(env, NULL, "failed to allocate host buffer");
        return false;
    }

    if (napi_get_value_string_utf8(env, value, buffer, valueLength + 1, &valueLength) != napi_ok) {
        free(buffer);
        napi_throw_type_error(env, NULL, "failed to read host");
        return false;
    }

    *result = buffer;
    return true;
}

static bool GetRequiredPort(napi_env env, napi_value value, int32_t *port)
{
    if (napi_get_value_int32(env, value, port) != napi_ok) {
        napi_throw_type_error(env, NULL, "port must be an integer");
        return false;
    }

    if (*port <= 0 || *port > 65535) {
        napi_throw_range_error(env, NULL, "port must be between 1 and 65535");
        return false;
    }
    return true;
}

static napi_value StartTcpClient(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {NULL};
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (argc < 2) {
        napi_throw_type_error(env, NULL, "startTcpClient requires host and port");
        return NULL;
    }

    char *host = NULL;
    int32_t port = 0;
    if (!GetRequiredString(env, args[0], &host) || !GetRequiredPort(env, args[1], &port)) {
        free(host);
        return NULL;
    }

    bool started = tcp_client_start(host, port) == 1;
    free(host);
    return CreateBoolean(env, started);
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

static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"startTcpClient", NULL, StartTcpClient, NULL, NULL, NULL, napi_default, NULL},
        {"stopTcpClient", NULL, StopTcpClient, NULL, NULL, NULL, napi_default, NULL},
        {"isTcpClientRunning", NULL, IsTcpClientRunning, NULL, NULL, NULL, napi_default, NULL},
        { "add", NULL, Add, NULL, NULL, NULL, napi_default, NULL }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

NAPI_MODULE(entry, Init)
