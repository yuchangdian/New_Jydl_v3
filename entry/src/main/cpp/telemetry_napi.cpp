#include "telemetry_napi.h"

#include "data.h"
#include "IEC104.h"
#include "tcp_client.h"
#include <hilog/log.h>

namespace {

constexpr int TELEMETRY_NAPI_LOG_DOMAIN = 0x0000;
constexpr const char *TELEMETRY_NAPI_LOG_TAG = "JY_TELEMETRY_NAPI";
constexpr std::size_t HARMONIC_VALUE_GROUP_COUNT = 3;

#define TELEMETRY_LOGI(format, ...) OH_LOG_Print(LOG_APP, LOG_INFO, TELEMETRY_NAPI_LOG_DOMAIN, TELEMETRY_NAPI_LOG_TAG, format, ##__VA_ARGS__)
#define TELEMETRY_LOGW(format, ...) OH_LOG_Print(LOG_APP, LOG_WARN, TELEMETRY_NAPI_LOG_DOMAIN, TELEMETRY_NAPI_LOG_TAG, format, ##__VA_ARGS__)


napi_value CreateBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    //TELEMETRY_LOGI("SendRemoteMetryQueryFrame result=%{public}d", result);
    return result;
}

napi_value CreateDouble(napi_env env, double value)
{
    napi_value result = nullptr;
    napi_create_double(env, value, &result);
    //TELEMETRY_LOGI("napi_create_double result=%{public}d", result);
    return result;
}

bool SendRemoteMetryQueryFrame(std::uint16_t objectAddr)
{
    const std::uint16_t commonAddr = Common_Addr_RemoteMetry;
    const std::uint16_t dataLength = 0;
    const char frame[] = {
        static_cast<char>(commonAddr & 0xFF),
        static_cast<char>((commonAddr >> 8) & 0xFF),
        static_cast<char>(objectAddr & 0xFF),
        static_cast<char>((objectAddr >> 8) & 0xFF),
        static_cast<char>(dataLength & 0xFF),
        static_cast<char>((dataLength >> 8) & 0xFF)
    };
    const bool sent = TcpClient::GetInstance().Send(frame, static_cast<int>(sizeof(frame))) == 1;
    TELEMETRY_LOGI(
        "SendRemoteMetryQueryFrame common=%{public}u object=%{public}u length=%{public}d sent=%{public}s",
        commonAddr,
        objectAddr,
        static_cast<int>(sizeof(frame)),
        sent ? "true" : "false");
    return sent;
}

template <std::size_t N>
napi_value CreateFloatArray(napi_env env, const float (&values)[N])
{
    napi_value result = nullptr;
    napi_create_array_with_length(env, N, &result);
    for (std::uint32_t index = 0; index < N; index++) {
        napi_set_element(env, result, index, CreateDouble(env, values[index]));
    }
    return result;
}

template <std::size_t N>
void FillInterleavedHarmonicValues(
    float (&output)[N * HARMONIC_VALUE_GROUP_COUNT],
    const float (&frequency)[N],
    const float (&rms)[N],
    const float (&angle)[N])
{
    for (std::size_t index = 0; index < N; ++index) {
        const std::size_t baseIndex = index * HARMONIC_VALUE_GROUP_COUNT;
        output[baseIndex] = frequency[index];
        output[baseIndex + 1] = rms[index];
        output[baseIndex + 2] = angle[index];
    }
}

template <std::size_t N>
napi_value CreateInterleavedHarmonicArray(
    napi_env env,
    const float (&frequency)[N],
    const float (&rms)[N],
    const float (&angle)[N])
{
    float values[N * HARMONIC_VALUE_GROUP_COUNT] = {0};
    FillInterleavedHarmonicValues(values, frequency, rms, angle);
    return CreateFloatArray(env, values);
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

napi_value CreateHarmonicVoltageDisplayObject(napi_env env, const YC_HarmonicU_Struct &value, bool ready)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, ready));
    napi_set_named_property(env, result, "Ua",
        CreateInterleavedHarmonicArray(env, value.Ua_Frequency, value.Ua_RMS, value.Ua_Angle));
    napi_set_named_property(env, result, "Ub",
        CreateInterleavedHarmonicArray(env, value.Ub_Frequency, value.Ub_RMS, value.Ub_Angle));
    napi_set_named_property(env, result, "Uc",
        CreateInterleavedHarmonicArray(env, value.Uc_Frequency, value.Uc_RMS, value.Uc_Angle));

    return result;
}

napi_value CreateHarmonicCurrentDisplayObject(napi_env env, const YC_HarmonicI_Struct &value, bool ready)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, ready));
    napi_set_named_property(env, result, "Ia",
        CreateInterleavedHarmonicArray(env, value.Ia_Frequency, value.Ia_RMS, value.Ia_Angle));
    napi_set_named_property(env, result, "Ib",
        CreateInterleavedHarmonicArray(env, value.Ib_Frequency, value.Ib_RMS, value.Ib_Angle));
    napi_set_named_property(env, result, "Ic",
        CreateInterleavedHarmonicArray(env, value.Ic_Frequency, value.Ic_RMS, value.Ic_Angle));

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

napi_value RequestHarmonicDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const bool voltageSent = SendRemoteMetryQueryFrame(RemoteMetry_HarmonicU);
    const bool currentSent = SendRemoteMetryQueryFrame(RemoteMetry_HarmonicI);
    TELEMETRY_LOGI(
        "RequestHarmonicDisplayData voltageSent=%{public}s currentSent=%{public}s",
        voltageSent ? "true" : "false",
        currentSent ? "true" : "false");
    return CreateBoolean(env, voltageSent && currentSent);
}

napi_value GetHarmonicVoltageDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const YC_HarmonicU_Struct snapshot = HarmonicU_Dsip;
    const bool ready = HarmonicVoltageDisplayReady;
    return CreateHarmonicVoltageDisplayObject(env, snapshot, ready);
}

napi_value GetHarmonicCurrentDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const YC_HarmonicI_Struct snapshot = HarmonicI_Dsip;
    const bool ready = HarmonicCurrentDisplayReady;
    return CreateHarmonicCurrentDisplayObject(env, snapshot, ready);
}
