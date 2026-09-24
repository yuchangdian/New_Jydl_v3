#pragma once
#include "data_types.h"
#include "IEC104.h"
#include "SystemSetting_JYBSMR131.h"
#include <cstddef>
#include <cstdint>
#include <type_traits>

namespace jybsmr131 {
// 与 Qt data.h 的调用方式一致：CRC32 按 32 位字计数，CRC16 按 16 位字计数。
// 实际算法是小端逐字异或；void 指针允许直接传入未对齐的报文载荷。
std::uint32_t CRC32(const void *data, std::uint32_t wordCount);
std::uint16_t CRC16(const void *data, std::uint16_t wordCount);
std::uint32_t Xor32(const std::uint8_t *data, std::size_t byteLength);
std::uint16_t Xor16(const std::uint8_t *data, std::size_t byteLength);

template <typename T>
struct SettingLayout {
    static_assert(std::is_standard_layout<T>::value, "定值必须具有标准布局");
    static_assert(sizeof(T) % 4 == 0, "定值长度必须为 4 的倍数");
    static_assert(offsetof(T, CRC) == sizeof(T) - 4, "CRC 必须是最后一个 32 位字段");
    static constexpr std::uint32_t ByteLength = sizeof(T);
    static constexpr std::uint32_t CrcWordCount = sizeof(T) / 4 - 1;
};

// 原 data.cpp 的可变长度全局量改为编译期常量，始终与当前协议结构一致。
constexpr std::uint32_t BroadbandPhasorSetting_Length_1Byte = SettingLayout<BroadbandPhasorSetting_Struct>::ByteLength;
constexpr std::uint32_t BroadbandPhasorSetting_CRCLength_4Byte = SettingLayout<BroadbandPhasorSetting_Struct>::CrcWordCount;
constexpr std::uint32_t FaultRecordSetting_Length_1Byte = SettingLayout<FaultRecordSetting_Struct>::ByteLength;
constexpr std::uint32_t FaultRecordSetting_CRCLength_4Byte = SettingLayout<FaultRecordSetting_Struct>::CrcWordCount;
constexpr std::uint32_t RelaySetting_DataLength = SettingLayout<RelaySetting_Struct>::ByteLength;
constexpr std::uint32_t RelaySetting_CRCLength = SettingLayout<RelaySetting_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_PrimarySystem_Length_1Byte = SettingLayout<CommonSetting_PrimarySystem_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_PrimarySystem_CRCLength_4Byte = SettingLayout<CommonSetting_PrimarySystem_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_AnalogQuantity_Length_1Byte = SettingLayout<CommonSetting_AnalogQuantity_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_AnalogQuantity_CRCLength_4Byte = SettingLayout<CommonSetting_AnalogQuantity_Struct>::CrcWordCount;
constexpr std::uint32_t PowerQualitySetting_Length_1Byte = SettingLayout<PowerQualitySetting_struct>::ByteLength;
constexpr std::uint32_t PowerQualitySetting_CRCLength_4Byte = SettingLayout<PowerQualitySetting_struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_ExceedingLimit_Length_1Byte = SettingLayout<CommonSetting_ExceedingLimit_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_ExceedingLimit_CRCLength_4Byte = SettingLayout<CommonSetting_ExceedingLimit_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_Statistics_Length_1Byte = SettingLayout<CommonSetting_Statistics_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_Statistics_CRCLength_4Byte = SettingLayout<CommonSetting_Statistics_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_YK_Length_1Byte = SettingLayout<CommonSetting_TeleControlling_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_YK_CRCLength_4Byte = SettingLayout<CommonSetting_TeleControlling_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_YC_Length_1Byte = SettingLayout<CommonSetting_TeleMeasuring_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_YC_CRCLength_4Byte = SettingLayout<CommonSetting_TeleMeasuring_Struct>::CrcWordCount;
constexpr std::uint32_t CommonSetting_YX_Length_1Byte = SettingLayout<CommonSetting_TeleSignaling_Struct>::ByteLength;
constexpr std::uint32_t CommonSetting_YX_CRCLength_4Byte = SettingLayout<CommonSetting_TeleSignaling_Struct>::CrcWordCount;
constexpr std::uint32_t SoftStrap_DataLength = SettingLayout<ProtectionSoftStrap_Struct>::ByteLength;
constexpr std::uint32_t SoftStrap_CRCLength = SettingLayout<ProtectionSoftStrap_Struct>::CrcWordCount;

template <typename T>
struct DataSnapshot {
    bool ready = false;
    T value {};
};

constexpr std::uint16_t kAllDigitalInputsMask = 0x07FF;
struct DigitalInputSnapshot {
    DigitalInputData_Struct DigitalInputData {};
    // 位 0..10 对应 GLKGW..SwitchState；零值不能代替“尚未收到”。
    std::uint16_t validMask = 0;
    std::uint8_t BreakerState_Now = kSW_UnCertain;
    bool Ready() const { return validMask != 0; }
    bool Complete() const { return validMask == kAllDigitalInputsMask; }
};

static_assert(sizeof(DigitalInputData_Struct) == 11, "新版开入数据必须为 11 字节");
static_assert(offsetof(DigitalInputData_Struct, SwitchState) == 10, "开关状态必须位于最后一个字节");
static_assert(sizeof(RemoteSignalALL_Struct) == 26, "整组遥信为 7 字节时间和 19 个状态");
static_assert(sizeof(RecordSettingUnit) == 8, "录波启动单元必须为 8 字节");
static_assert(sizeof(PQSettingUnit) == 8, "电能质量告警单元必须为 8 字节");
static_assert(sizeof(PowerQualitySetting_struct) == 200, "电能质量告警定值必须为 200 字节");
static_assert(offsetof(PowerQualitySetting_struct, CRC) == 196, "电能质量告警校验字段偏移不匹配");
static_assert(offsetof(FaultRecordSetting_Struct, CRC) == 160, "故障录波校验字段偏移不匹配");
static_assert(offsetof(BroadbandPhasorSetting_Struct, CRC) == 68, "宽频定值校验字段偏移不匹配");
} // namespace jybsmr131
