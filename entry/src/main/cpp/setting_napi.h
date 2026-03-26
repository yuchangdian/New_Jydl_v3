#ifndef NEW_JYDL_V3_SETTING_NAPI_H
#define NEW_JYDL_V3_SETTING_NAPI_H

#include <node_api.h>
#include "napi/native_api.h"

napi_value GetPrimarySystemSetting(napi_env env, napi_callback_info info);
napi_value GetAnalogQuantitySetting(napi_env env, napi_callback_info info);

#endif
