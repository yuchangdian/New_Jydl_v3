#ifndef NEW_JYDL_V3_TELEMETRY_NAPI_H
#define NEW_JYDL_V3_TELEMETRY_NAPI_H

#include <node_api.h>
#include "napi/native_api.h"

napi_value GetBaseFreqDisplayData(napi_env env, napi_callback_info info);
napi_value RequestHarmonicDisplayData(napi_env env, napi_callback_info info);
napi_value GetHarmonicVoltageDisplayData(napi_env env, napi_callback_info info);
napi_value GetHarmonicCurrentDisplayData(napi_env env, napi_callback_info info);

#endif
