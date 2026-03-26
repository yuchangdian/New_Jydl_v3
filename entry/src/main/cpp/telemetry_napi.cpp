#include "telemetry_napi.h"

#include "data.h"

namespace {

napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

napi_value CreateDouble(napi_env env, double value)
{
    napi_value result = nullptr;
    napi_create_double(env, value, &result);
    return result;
}

napi_value CreateBaseFreqDisplayObject(napi_env env, const YC_BaseFreq_Struct &value, bool ready)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, ready));
    napi_set_named_property(env, result, "Ua_Rms", CreateDouble(env, value.Ua_Rms));
    napi_set_named_property(env, result, "Ua_Phase", CreateDouble(env, value.Ua_Phase));
    napi_set_named_property(env, result, "Ub_Rms", CreateDouble(env, value.Ub_Rms));
    napi_set_named_property(env, result, "Ub_Phase", CreateDouble(env, value.Ub_Phase));
    napi_set_named_property(env, result, "Uc_Rms", CreateDouble(env, value.Uc_Rms));
    napi_set_named_property(env, result, "Uc_Phase", CreateDouble(env, value.Uc_Phase));
    napi_set_named_property(env, result, "Uo_Rms", CreateDouble(env, value.Uo_Rms));
    napi_set_named_property(env, result, "Uo_Phase", CreateDouble(env, value.Uo_Phase));
    napi_set_named_property(env, result, "Ux_Rms", CreateDouble(env, value.Ux_Rms));
    napi_set_named_property(env, result, "Ux_Phase", CreateDouble(env, value.Ux_Phase));
    napi_set_named_property(env, result, "IA_Rms", CreateDouble(env, value.IA_Rms));
    napi_set_named_property(env, result, "IA_Phase", CreateDouble(env, value.IA_Phase));
    napi_set_named_property(env, result, "IB_Rms", CreateDouble(env, value.IB_Rms));
    napi_set_named_property(env, result, "IB_Phase", CreateDouble(env, value.IB_Phase));
    napi_set_named_property(env, result, "IC_Rms", CreateDouble(env, value.IC_Rms));
    napi_set_named_property(env, result, "IC_Phase", CreateDouble(env, value.IC_Phase));
    napi_set_named_property(env, result, "Io_Rms", CreateDouble(env, value.Io_Rms));
    napi_set_named_property(env, result, "Io_Phase", CreateDouble(env, value.Io_Phase));
    napi_set_named_property(env, result, "Ia_Rms", CreateDouble(env, value.Ia_Rms));
    napi_set_named_property(env, result, "Ia_Phase", CreateDouble(env, value.Ia_Phase));
    napi_set_named_property(env, result, "Ib_Rms", CreateDouble(env, value.Ib_Rms));
    napi_set_named_property(env, result, "Ib_Phase", CreateDouble(env, value.Ib_Phase));
    napi_set_named_property(env, result, "Ic_Rms", CreateDouble(env, value.Ic_Rms));
    napi_set_named_property(env, result, "Ic_Phase", CreateDouble(env, value.Ic_Phase));

    return result;
}

} // namespace

napi_value GetBaseFreqDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const YC_BaseFreq_Struct snapshot = BaseFreq_Dsip;
    const bool ready = BaseFreqDisplayReady;
    return CreateBaseFreqDisplayObject(env, snapshot, ready);
}
