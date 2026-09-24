#include "telemetry_napi.h"

#include "data.h"
#include "IEC104.h"
#include "tcp_client.h"
#include "protocol/jybsmr131/codec.h"
#include <limits>
#include <hilog/log.h>

namespace {

double LatestValue(const jybsmr131::PacketSnapshot &packet, const char *name, std::size_t index = 0)
{
    for (const auto &field : packet.fields) {
        if (field.name == name && index < field.values.size()) return field.values[index];
    }
    return std::numeric_limits<double>::quiet_NaN();
}

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

bool SendRemoteMetryQueryFrame(std::uint16_t objectAddr, std::uint16_t commonAddr = Common_Addr_RemoteMetry)
{
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

napi_value CreateBaseFreqDisplayObject(napi_env env, const YC_BaseFreq_Struct &value, bool ready,
                                      const char *protocolVersion = "legacy")
{
    napi_value result = nullptr;
    napi_create_object(env, &result);

    napi_set_named_property(env, result, "ready", CreateBoolean(env, ready));
    napi_value version;
    napi_create_string_utf8(env, protocolVersion, NAPI_AUTO_LENGTH, &version);
    napi_set_named_property(env, result, "protocolVersion", version);
    napi_set_named_property(env, result, "Ua_Frequency", CreateDouble(env, value.Ua_Frequency));
    napi_set_named_property(env, result, "Ub_Frequency", CreateDouble(env, value.Ub_Frequency));
    napi_set_named_property(env, result, "Uc_Frequency", CreateDouble(env, value.Uc_Frequency));
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

    const auto latest = jybsmr131::PacketStore::Instance().Get(
        jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_BaseValue);
    if (latest.ready) {
        YC_BaseFreq_Struct value = {};
        value.Ua_Frequency = LatestValue(latest, "Ua_Frequency");
        value.Ub_Frequency = LatestValue(latest, "Ub_Frequency");
        value.Uc_Frequency = LatestValue(latest, "Uc_Frequency");
        value.Ua_Rms = LatestValue(latest, "Ua_RMS");
        value.Ub_Rms = LatestValue(latest, "Ub_RMS");
        value.Uc_Rms = LatestValue(latest, "Uc_RMS");
        value.Uo_Rms = LatestValue(latest, "Uo_RMS");
        value.IA_Rms = LatestValue(latest, "IA_RMS");
        value.IB_Rms = LatestValue(latest, "IB_RMS");
        value.IC_Rms = LatestValue(latest, "IC_RMS");
        value.Io_Rms = LatestValue(latest, "Io_RMS");
        value.Ua_Phase = LatestValue(latest, "Ua_Phase");
        value.Ub_Phase = LatestValue(latest, "Ub_Phase");
        value.Uc_Phase = LatestValue(latest, "Uc_Phase");
        value.Uo_Phase = LatestValue(latest, "Uo_Phase");
        value.IA_Phase = LatestValue(latest, "IA_Phase");
        value.IB_Phase = LatestValue(latest, "IB_Phase");
        value.IC_Phase = LatestValue(latest, "IC_Phase");
        value.Io_Phase = LatestValue(latest, "Io_Phase");
        // 新设备没有旧版的独立测量 CT 和线路电压通道，不补造数值。
        value.Ux_Rms = value.Ux_Phase = value.Ia_Rms = value.Ia_Phase =
            value.Ib_Rms = value.Ib_Phase = value.Ic_Rms = value.Ic_Phase =
                std::numeric_limits<float>::quiet_NaN();
        return CreateBaseFreqDisplayObject(env, value, true, "jybsmr131");
    }

    const YC_BaseFreq_Struct snapshot = BaseFreq_Dsip;
    const bool ready = BaseFreqDisplayReady;
    return CreateBaseFreqDisplayObject(env, snapshot, ready);
}

napi_value RequestHarmonicDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const auto &store = jybsmr131::PacketStore::Instance();
    const bool latest = store.Get(jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_BaseValue).ready ||
        store.Get(jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_HarmonicU).ready ||
        store.Get(jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_HarmonicI).ready;
    const std::uint16_t common = latest ? jybsmr131::kCommon_Addr_RemoteMetry : Common_Addr_RemoteMetry;
    const bool voltageSent = SendRemoteMetryQueryFrame(RemoteMetry_HarmonicU, common);
    const bool currentSent = SendRemoteMetryQueryFrame(RemoteMetry_HarmonicI, common);
    TELEMETRY_LOGI(
        "RequestHarmonicDisplayData voltageSent=%{public}s currentSent=%{public}s",
        voltageSent ? "true" : "false",
        currentSent ? "true" : "false");
    return CreateBoolean(env, voltageSent && currentSent);
}

napi_value GetHarmonicVoltageDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const auto latest = jybsmr131::PacketStore::Instance().Get(
        jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_HarmonicU);
    if (latest.ready) {
        YC_HarmonicU_Struct value = {};
        for (std::size_t i = 0; i < 10; ++i) {
            value.Ua_Frequency[i] = LatestValue(latest, "Ua_Frequency", i);
            value.Ua_RMS[i] = LatestValue(latest, "Ua_RMS", i);
            value.Ua_Angle[i] = LatestValue(latest, "Ua_Angle", i);
            value.Ub_Frequency[i] = LatestValue(latest, "Ub_Frequency", i);
            value.Ub_RMS[i] = LatestValue(latest, "Ub_RMS", i);
            value.Ub_Angle[i] = LatestValue(latest, "Ub_Angle", i);
            value.Uc_Frequency[i] = LatestValue(latest, "Uc_Frequency", i);
            value.Uc_RMS[i] = LatestValue(latest, "Uc_RMS", i);
            value.Uc_Angle[i] = LatestValue(latest, "Uc_Angle", i);
        }
        return CreateHarmonicVoltageDisplayObject(env, value, true);
    }

    const YC_HarmonicU_Struct snapshot = HarmonicU_Dsip;
    const bool ready = HarmonicVoltageDisplayReady;
    return CreateHarmonicVoltageDisplayObject(env, snapshot, ready);
}

napi_value GetHarmonicCurrentDisplayData(napi_env env, napi_callback_info info)
{
    (void)info;

    const auto latest = jybsmr131::PacketStore::Instance().Get(
        jybsmr131::kCommon_Addr_RemoteMetry, jybsmr131::kRemoteMetry_HarmonicI);
    if (latest.ready) {
        YC_HarmonicI_Struct value = {};
        for (std::size_t i = 0; i < 10; ++i) {
            value.Ia_Frequency[i] = LatestValue(latest, "Ia_Frequency", i);
            value.Ia_RMS[i] = LatestValue(latest, "Ia_RMS", i);
            value.Ia_Angle[i] = LatestValue(latest, "Ia_Angle", i);
            value.Ib_Frequency[i] = LatestValue(latest, "Ib_Frequency", i);
            value.Ib_RMS[i] = LatestValue(latest, "Ib_RMS", i);
            value.Ib_Angle[i] = LatestValue(latest, "Ib_Angle", i);
            value.Ic_Frequency[i] = LatestValue(latest, "Ic_Frequency", i);
            value.Ic_RMS[i] = LatestValue(latest, "Ic_RMS", i);
            value.Ic_Angle[i] = LatestValue(latest, "Ic_Angle", i);
        }
        return CreateHarmonicCurrentDisplayObject(env, value, true);
    }

    const YC_HarmonicI_Struct snapshot = HarmonicI_Dsip;
    const bool ready = HarmonicCurrentDisplayReady;
    return CreateHarmonicCurrentDisplayObject(env, snapshot, ready);
}
