#pragma once
#include "napi/native_api.h"
napi_value GetJybsmr131Packet(napi_env env, napi_callback_info info);
napi_value GetJybsmr131DigitalInputs(napi_env env, napi_callback_info info);
napi_value RequestJybsmr131Packet(napi_env env, napi_callback_info info);
napi_value UpdateJybsmr131Setting(napi_env env, napi_callback_info info);
