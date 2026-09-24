#pragma once
#include "data.h"
#include <cstring>
#include <cstddef>
#include <mutex>
#include <string>
#include <vector>
#include <map>

namespace jybsmr131 {
constexpr std::size_t kHeaderSize = 6;
struct NumericField {
    std::string name;
    std::vector<double> values;
};
struct PacketSnapshot {
    bool ready = false;
    std::uint64_t revision = 0;
    std::uint64_t sessionId = 0;
    std::uint16_t commonAddress = 0;
    std::uint16_t objectAddress = 0;
    std::size_t payloadLength = 0;
    std::vector<NumericField> fields;
};

bool IsCommonAddress(std::uint16_t common);
bool BuildQuery(std::uint16_t common, std::uint16_t object, std::vector<std::uint8_t> &frame);

class PacketStore {
public:
    static PacketStore &Instance();
    // 接收完整的 6 字节头 + 载荷；失败时保留上次有效数据。
    bool Decode(const std::uint8_t *frame, std::size_t length);
    PacketSnapshot Get(std::uint16_t common, std::uint16_t object) const;
    DigitalInputSnapshot GetDigitalInputs() const;
    DataSnapshot<RemoteSignalALL_Struct> GetAllSignals() const;
    DataSnapshot<CommonSetting_PrimarySystem_Struct> GetPrimarySystemSetting() const;
    DataSnapshot<SystemSettingWithoutRatedCurrent> GetSystemSettingWithoutRatedCurrent() const;
    DataSnapshot<CommonSetting_AnalogQuantity_Struct> GetAnalogQuantitySetting() const;
    DataSnapshot<PowerQualitySetting_struct> GetPowerQualitySetting() const;
    DataSnapshot<FaultRecordSetting_Struct> GetFaultRecordSetting() const;
    DataSnapshot<BroadbandPhasorSetting_Struct> GetBroadbandPhasorSetting() const;
    DataSnapshot<YC_HarmonicU_Struct> GetHarmonicVoltage() const;
    DataSnapshot<YC_HarmonicI_Struct> GetHarmonicCurrent() const;
    DataSnapshot<Package_YC_PlotBuf_Struct> GetWaveform(std::uint16_t object) const;
    void Reset();
    // 在已读取的实际布局上修改字段，自动重算校验，不改变缓存中的设备确认值。
    bool BuildSetting(std::uint16_t object, const std::vector<NumericField> &changes,
                      std::vector<std::uint8_t> &frame) const;
private:
    template <typename T>
    DataSnapshot<T> ReadData(std::uint16_t common, std::uint16_t object, bool hasHeader = false) const
    {
        static_assert(std::is_trivially_copyable<T>::value, "只能读取二进制数据结构");
        DataSnapshot<T> result;
        std::lock_guard<std::mutex> lock(mutex_);
        const auto it = frames_.find((static_cast<std::uint32_t>(common) << 16) | object);
        const std::size_t offset = hasHeader ? 0 : kHeaderSize;
        if (it != frames_.end() && it->second.size() == sizeof(T) + offset) {
            std::memcpy(&result.value, it->second.data() + offset, sizeof(T));
            result.ready = true;
        }
        return result;
    }
    mutable std::mutex mutex_;
    std::map<std::uint32_t, std::vector<std::uint8_t>> frames_;
    std::map<std::uint32_t, std::uint64_t> revisions_;
    std::uint64_t receiveRevision_ = 0;
    std::uint64_t sessionId_ = 0;
};

static_assert(sizeof(Package_YC_BaseValue_Struct) == 157, "工频报文布局不匹配");
static_assert(offsetof(Package_YC_BaseValue_Struct, Ua_Frequency) == 17, "工频字段偏移不匹配");
static_assert(sizeof(YC_HarmonicU_Struct) == 373 && sizeof(YC_HarmonicI_Struct) == 373, "谐波报文布局不匹配");
static_assert(sizeof(Package_YC_PlotBuf_Struct) == 813, "波形报文布局不匹配");
static_assert(sizeof(CommonSetting_PrimarySystem_Struct) == 44, "新版一次系统定值布局不匹配");
static_assert(sizeof(SystemSettingWithoutRatedCurrent) == 40, "不含额定电流的系统定值布局不匹配");
static_assert(sizeof(CommonSetting_AnalogQuantity_Struct) == 100, "模拟量定值布局不匹配");
static_assert(sizeof(RemoteSignal_Change_Struct) == 14, "新版遥信不包含旧版 CRC 尾部");
} // namespace jybsmr131
