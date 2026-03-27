#ifndef NEW_JYDL_V3_SETTING_NAPI_H
#define NEW_JYDL_V3_SETTING_NAPI_H

#include <node_api.h>
#include "napi/native_api.h"

napi_value GetPrimarySystemSetting(napi_env env, napi_callback_info info);
napi_value GetAnalogQuantitySetting(napi_env env, napi_callback_info info);
napi_value GetTeleMeasuringSetting(napi_env env, napi_callback_info info);
napi_value GetTeleSignalingSetting(napi_env env, napi_callback_info info);
napi_value GetTeleControllingSetting(napi_env env, napi_callback_info info);
napi_value GetExceedingLimitSetting(napi_env env, napi_callback_info info);
napi_value GetStatisticsSetting(napi_env env, napi_callback_info info);

#endif
