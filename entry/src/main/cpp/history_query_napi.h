#pragma once

#include <node_api.h>

napi_value OpenHistoryQuery(napi_env env, napi_callback_info info);
napi_value NextHistoryBatch(napi_env env, napi_callback_info info);
napi_value CloseHistoryQuery(napi_env env, napi_callback_info info);
