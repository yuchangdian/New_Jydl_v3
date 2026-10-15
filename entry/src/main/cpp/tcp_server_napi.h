#ifndef TCP_SERVER_NAPI_H
#define TCP_SERVER_NAPI_H
#include "napi/native_api.h"

napi_value StartTcpServer(napi_env env, napi_callback_info info);
napi_value StopTcpServer(napi_env env, napi_callback_info info);
napi_value IsTcpServerRunning(napi_env env, napi_callback_info info);
napi_value IsTcpServerClientConnected(napi_env env, napi_callback_info info);
#endif
