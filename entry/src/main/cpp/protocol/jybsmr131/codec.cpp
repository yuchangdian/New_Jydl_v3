#include "codec.h"
#include <algorithm>
#include <cmath>
#include <cstring>
#include <limits>
#include <set>

namespace jybsmr131 {
namespace {
enum class Scalar { Uint8, Uint16, Uint32, Int16, Float32 };
struct FieldDescriptor {
    const char *name;
    std::size_t offset;
    Scalar scalar;
    std::size_t count;
    double scale;
};
#include "fields.inc"
struct Schema {
    const FieldDescriptor *fields = nullptr;
    std::size_t count = 0;
    std::size_t size = 0;
    bool hasHeader = false;
    bool hasCrc = false;
};
template <typename T, std::size_t N>
Schema Describe(const FieldDescriptor (&fields)[N], bool header, bool crc = false)
{
    return {fields, N, sizeof(T), header, crc};
}
std::uint16_t Read16(const std::uint8_t *p) { return p[0] | (static_cast<std::uint16_t>(p[1]) << 8); }
std::uint32_t Read32(const std::uint8_t *p) { return Read16(p) | (static_cast<std::uint32_t>(Read16(p + 2)) << 16); }
void Write16(std::uint8_t *p, std::uint16_t value) { p[0] = value & 255; p[1] = value >> 8; }
void Write32(std::uint8_t *p, std::uint32_t value) { Write16(p, value & 65535); Write16(p + 2, value >> 16); }
std::uint32_t Key(std::uint16_t common, std::uint16_t object) { return (static_cast<std::uint32_t>(common) << 16) | object; }
std::size_t Width(Scalar scalar) { return scalar == Scalar::Uint8 ? 1 : scalar == Scalar::Uint16 || scalar == Scalar::Int16 ? 2 : 4; }
Schema FindSchema(std::uint16_t common, std::uint16_t object, std::size_t payloadLength)
{
    if (common == kCommon_Addr_RemoteMetry) {
        switch (object) {
            case kRemoteMetry_BaseValue: return Describe<Package_YC_BaseValue_Struct>(fields_Package_YC_BaseValue_Struct, true);
            case kRemoteMetry_HarmonicU: return Describe<YC_HarmonicU_Struct>(fields_YC_HarmonicU_Struct, true);
            case kRemoteMetry_HarmonicI: return Describe<YC_HarmonicI_Struct>(fields_YC_HarmonicI_Struct, true);
            default:
                if (object >= kRemoteMetry_PlotBuf_Ua && object <= kRemoteMetry_PlotBuf_Ic)
                    return Describe<Package_YC_PlotBuf_Struct>(fields_Package_YC_PlotBuf_Struct, true);
        }
    }
    if (common == kCommon_Addr_RemoteSignal) {
        if (object == kYX_ObjectAddr_ALL)
            return Describe<RemoteSignalALL_Struct>(fields_RemoteSignalALL_Struct, false);
        if (object >= kYX_ObjectAddr_GLKGW && object <= kYX_ObjectAddr_SwitchState)
            return Describe<RemoteSignal_Change_Struct>(fields_RemoteSignal_Change_Struct, true);
    }
    if (common == kCommon_Addr_RemoteAdjust) {
        switch (object) {
            case kYT_ObjectAddr_Setting_System:
                if (payloadLength == sizeof(SystemSettingWithoutRatedCurrent))
                    return Describe<SystemSettingWithoutRatedCurrent>(fields_SystemSettingWithoutRatedCurrent, false, true);
                return Describe<CommonSetting_PrimarySystem_Struct>(fields_CommonSetting_PrimarySystem_Struct, false, true);
            case kYT_ObjectAddr_Setting_Analog:
                return Describe<CommonSetting_AnalogQuantity_Struct>(fields_CommonSetting_AnalogQuantity_Struct, false, true);
            case kYT_ObjectAddr_Setting_PowerQuality:
                return Describe<PowerQualitySetting_struct>(fields_PowerQualitySetting_struct, false, true);
            case kYT_ObjectAddr_Setting_FaultRecord:
                return Describe<FaultRecordSetting_Struct>(fields_FaultRecordSetting_Struct, false, true);
            case kYT_ObjectAddr_Setting_BPMU:
                return Describe<BroadbandPhasorSetting_Struct>(fields_BroadbandPhasorSetting_Struct, false, true);
        }
    }
    return {};
}
double ReadNumber(const std::uint8_t *p, Scalar scalar)
{
    if (scalar == Scalar::Uint8) return p[0];
    if (scalar == Scalar::Uint16) return Read16(p);
    if (scalar == Scalar::Int16) { const auto n = Read16(p); return n < 32768 ? n : static_cast<int>(n) - 65536; }
    const std::uint32_t bits = Read32(p);
    if (scalar == Scalar::Uint32) return bits;
    float value;
    std::memcpy(&value, &bits, sizeof(value));
    return value;
}
bool WriteNumber(std::uint8_t *p, Scalar scalar, double value)
{
    if (!std::isfinite(value)) return false;
    if (scalar == Scalar::Float32) {
        if (std::abs(value) > std::numeric_limits<float>::max()) return false;
        const float converted = static_cast<float>(value);
        std::uint32_t bits;
        std::memcpy(&bits, &converted, sizeof(bits));
        Write32(p, bits);
        return true;
    }
    const double minimum = scalar == Scalar::Int16 ? -32768.0 : 0.0;
    const double maximum = scalar == Scalar::Uint8 ? 255.0 : scalar == Scalar::Uint16 ? 65535.0 : scalar == Scalar::Int16 ? 32767.0 : 4294967295.0;
    if (std::floor(value) != value || value < minimum || value > maximum) return false;
    if (scalar == Scalar::Uint8) p[0] = static_cast<std::uint8_t>(value);
    else if (scalar == Scalar::Uint32) Write32(p, static_cast<std::uint32_t>(value));
    else Write16(p, static_cast<std::uint16_t>(static_cast<std::int32_t>(value)));
    return true;
}
}

bool IsCommonAddress(std::uint16_t common)
{
    return common == kCommon_Addr_RemoteMetry || common == kCommon_Addr_RemoteControl ||
        common == kCommon_Addr_RemoteSignal || common == kCommon_Addr_RemoteAdjust ||
        common == kCommon_Addr_SOE || common == kCommon_Addr_Record || common == kCommon_Addr_PQ_Event;
}
bool BuildQuery(std::uint16_t common, std::uint16_t object, std::vector<std::uint8_t> &frame)
{
    frame.clear();
    const Schema schema = FindSchema(common, object, 0);
    // 不接受遥控、计量清零、时间设置或尚缺少布局定义的对象。
    const bool readAllSignals = common == kCommon_Addr_RemoteSignal && object == kYX_ObjectAddr_ALL;
    if (!schema.fields || (common != kCommon_Addr_RemoteMetry && common != kCommon_Addr_RemoteAdjust && !readAllSignals)) return false;
    frame.resize(kHeaderSize, 0);
    Write16(frame.data(), common);
    Write16(frame.data() + 2, object);
    return true;
}
PacketStore &PacketStore::Instance() { static PacketStore store; return store; }
bool PacketStore::Decode(const std::uint8_t *frame, std::size_t length)
{
    if (!frame || length < kHeaderSize || Read16(frame + 4) != length - kHeaderSize) return false;
    const auto common = Read16(frame);
    const auto object = Read16(frame + 2);
    const auto payloadLength = length - kHeaderSize;
    const Schema schema = FindSchema(common, object, payloadLength);
    if (!schema.fields || schema.size != (schema.hasHeader ? length : payloadLength)) return false;
    if (schema.hasCrc) {
        const auto *payload = frame + kHeaderSize;
        if (payloadLength < 4 || payloadLength % 4 != 0 ||
            std::all_of(payload, payload + payloadLength, [](std::uint8_t b) { return b == 255; }) ||
            Xor32(payload, payloadLength - 4) != Read32(payload + payloadLength - 4)) return false;
    }
    std::lock_guard<std::mutex> lock(mutex_);
    frames_[Key(common, object)] = std::vector<std::uint8_t>(frame, frame + length);
    revisions_[Key(common, object)] = ++receiveRevision_;
    return true;
}
PacketSnapshot PacketStore::Get(std::uint16_t common, std::uint16_t object) const
{
    PacketSnapshot result;
    result.commonAddress = common;
    result.objectAddress = object;
    std::lock_guard<std::mutex> lock(mutex_);
    const auto it = frames_.find(Key(common, object));
    result.sessionId = sessionId_;
    if (it == frames_.end()) return result;
    const auto &frame = it->second;
    result.ready = true;
    result.revision = revisions_.at(Key(common, object));
    result.payloadLength = frame.size() - kHeaderSize;
    const Schema schema = FindSchema(common, object, result.payloadLength);
    const auto *base = frame.data() + (schema.hasHeader ? 0 : kHeaderSize);
    for (std::size_t i = 0; i < schema.count; ++i) {
        const auto &field = schema.fields[i];
        NumericField value;
        value.name = field.name;
        for (std::size_t j = 0; j < field.count; ++j)
            value.values.push_back(ReadNumber(base + field.offset + j * Width(field.scalar), field.scalar) * field.scale);
        result.fields.push_back(value);
    }
    return result;
}
void PacketStore::Reset()
{
    std::lock_guard<std::mutex> lock(mutex_);
    frames_.clear();
    revisions_.clear();
    // 重连后不复用接收版本，页面可丢弃上一连接未收齐的波形。
    ++sessionId_;
}

DigitalInputSnapshot PacketStore::GetDigitalInputs() const
{
    DigitalInputSnapshot result;
    // 所有字段均为 uint8_t，按 data.h 声明顺序对应 0x0101..0x010B。
    auto *states = reinterpret_cast<std::uint8_t *>(&result.DigitalInputData);
    std::lock_guard<std::mutex> lock(mutex_);
    for (std::uint16_t index = 0; index < 11; ++index) {
        const auto it = frames_.find(Key(kCommon_Addr_RemoteSignal, kYX_ObjectAddr_GLKGW + index));
        if (it == frames_.end()) continue;
        states[index] = it->second[kHeaderSize];
        result.validMask |= static_cast<std::uint16_t>(1u << index);
    }
    if ((result.validMask & (1u << 10)) != 0) result.BreakerState_Now = result.DigitalInputData.SwitchState;
    return result;
}

DataSnapshot<RemoteSignalALL_Struct> PacketStore::GetAllSignals() const
{ return ReadData<RemoteSignalALL_Struct>(kCommon_Addr_RemoteSignal, kYX_ObjectAddr_ALL); }
DataSnapshot<CommonSetting_PrimarySystem_Struct> PacketStore::GetPrimarySystemSetting() const
{ return ReadData<CommonSetting_PrimarySystem_Struct>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_System); }
DataSnapshot<SystemSettingWithoutRatedCurrent> PacketStore::GetSystemSettingWithoutRatedCurrent() const
{ return ReadData<SystemSettingWithoutRatedCurrent>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_System); }
DataSnapshot<CommonSetting_AnalogQuantity_Struct> PacketStore::GetAnalogQuantitySetting() const
{ return ReadData<CommonSetting_AnalogQuantity_Struct>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_Analog); }
DataSnapshot<PowerQualitySetting_struct> PacketStore::GetPowerQualitySetting() const
{ return ReadData<PowerQualitySetting_struct>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_PowerQuality); }
DataSnapshot<FaultRecordSetting_Struct> PacketStore::GetFaultRecordSetting() const
{ return ReadData<FaultRecordSetting_Struct>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_FaultRecord); }
DataSnapshot<BroadbandPhasorSetting_Struct> PacketStore::GetBroadbandPhasorSetting() const
{ return ReadData<BroadbandPhasorSetting_Struct>(kCommon_Addr_RemoteAdjust, kYT_ObjectAddr_Setting_BPMU); }
DataSnapshot<YC_HarmonicU_Struct> PacketStore::GetHarmonicVoltage() const
{ return ReadData<YC_HarmonicU_Struct>(kCommon_Addr_RemoteMetry, kRemoteMetry_HarmonicU, true); }
DataSnapshot<YC_HarmonicI_Struct> PacketStore::GetHarmonicCurrent() const
{ return ReadData<YC_HarmonicI_Struct>(kCommon_Addr_RemoteMetry, kRemoteMetry_HarmonicI, true); }
DataSnapshot<Package_YC_PlotBuf_Struct> PacketStore::GetWaveform(std::uint16_t object) const
{
    if (object < kRemoteMetry_PlotBuf_Ua || object > kRemoteMetry_PlotBuf_Ic) return {};
    return ReadData<Package_YC_PlotBuf_Struct>(kCommon_Addr_RemoteMetry, object, true);
}
bool PacketStore::BuildSetting(std::uint16_t object, const std::vector<NumericField> &changes,
                               std::vector<std::uint8_t> &frame) const
{
    frame.clear();
    if (changes.empty()) return false;
    std::lock_guard<std::mutex> lock(mutex_);
    const auto it = frames_.find(Key(kCommon_Addr_RemoteAdjust, object));
    if (it == frames_.end()) return false;
    auto next = it->second;
    const Schema schema = FindSchema(kCommon_Addr_RemoteAdjust, object, next.size() - kHeaderSize);
    if (!schema.hasCrc) return false;
    std::set<std::string> seen;
    for (const auto &change : changes) {
        if (change.name == "CRC" || !seen.insert(change.name).second) return false;
        const auto *field = std::find_if(schema.fields, schema.fields + schema.count,
            [&change](const FieldDescriptor &candidate) { return change.name == candidate.name; });
        if (field == schema.fields + schema.count || change.values.size() != field->count) return false;
        for (std::size_t j = 0; j < field->count; ++j)
            if (!WriteNumber(next.data() + kHeaderSize + field->offset + j * Width(field->scalar),
                             field->scalar, change.values[j] / field->scale)) return false;
    }
    Write32(next.data() + next.size() - 4, Xor32(next.data() + kHeaderSize, next.size() - kHeaderSize - 4));
    frame = std::move(next);
    return true;
}
} // namespace jybsmr131
