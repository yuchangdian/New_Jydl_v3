#include "../entry/src/main/cpp/protocol/jybsmr131/codec.h"
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
#include <limits>
#include <thread>

using namespace jybsmr131;
struct AfterProtocolHeaders { std::uint8_t tag; std::uint32_t value; };
static_assert(offsetof(AfterProtocolHeaders, value) == 4, "协议头不能泄漏 pack(1)");
static_assert(sizeof(FaultRecordSetting_Struct) == 164, "故障录波定值应为 164 字节");
static_assert(sizeof(BroadbandPhasorSetting_Struct) == 72, "宽频定值应为 72 字节");
static_assert(sizeof(PowerQualitySetting_struct) == 200, "电能质量告警定值应为 200 字节");
static_assert(kYT_ObjectAddr_MeterageInit == 0x0066 && kYT_ObjectAddr_DateTimeSet == 0x0077, "新地址应覆盖源文件旧定义");
static_assert(sizeof(SOE_Start_Struct) == 14 && sizeof(SOE_Act_Struct) == 9, "SOE 应使用新版布局");

void Put16(std::vector<std::uint8_t> &bytes, std::size_t offset, std::uint16_t value)
{ bytes[offset] = value & 255; bytes[offset + 1] = static_cast<std::uint8_t>(value >> 8); }
void Put32(std::vector<std::uint8_t> &bytes, std::size_t offset, std::uint32_t value)
{ Put16(bytes, offset, value & 65535); Put16(bytes, offset + 2, static_cast<std::uint16_t>(value >> 16)); }
void PutFloat(std::vector<std::uint8_t> &bytes, std::size_t offset, float value)
{ std::uint32_t bits; std::memcpy(&bits, &value, 4); Put32(bytes, offset, bits); }
std::vector<std::uint8_t> Frame(std::uint16_t common, std::uint16_t object, std::size_t payload)
{
    std::vector<std::uint8_t> bytes(payload + 6);
    Put16(bytes, 0, common); Put16(bytes, 2, object); Put16(bytes, 4, static_cast<std::uint16_t>(payload));
    return bytes;
}
void Seal(std::vector<std::uint8_t> &bytes) { Put32(bytes, bytes.size() - 4, Xor32(bytes.data() + 6, bytes.size() - 10)); }
double Value(const PacketSnapshot &packet, const char *name, std::size_t index = 0)
{
    for (const auto &field : packet.fields) if (field.name == name && field.values.size() > index) return field.values[index];
    return std::numeric_limits<double>::quiet_NaN();
}
int main()
{
    PacketStore store;
    assert(!store.Get(0x1311, 0x11).ready);
    auto base = Frame(0x1311, 0x11, 151);
    Put16(base, 6, 59999);
    Put32(base, 13, 1);
    PutFloat(base, 17, 50.125f);
    PutFloat(base, 29, 230.5f);
    PutFloat(base, 61, 5.25f);
    PutFloat(base, 153, 0.98f);
    assert(store.Decode(base.data(), base.size()));
    auto snapshot = store.Get(0x1311, 0x11);
    assert(Value(snapshot, "Time_ms") == 59999 && Value(snapshot, "Flag_BD_LockOK") == 1);
    assert(Value(snapshot, "Ua_Frequency") == 50.125 && Value(snapshot, "Ua_RMS") == 230.5);
    assert(Value(snapshot, "IA_RMS") == 5.25 && std::abs(Value(snapshot, "Ft") - 0.98) < 0.00001);
    assert(std::isnan(Value(snapshot, "Ux_RMS")));
    assert(!store.Decode(nullptr, 0));
    for (std::size_t i = 0; i < base.size(); ++i) assert(!store.Decode(base.data(), i));
    auto oversized = base; oversized.push_back(0);
    assert(!store.Decode(oversized.data(), oversized.size()));
    auto old = base; Put16(old, 0, 0x0011);
    assert(!store.Decode(old.data(), old.size()));
    assert(Value(store.Get(0x1311, 0x11), "Ua_RMS") == 230.5);
    auto unaligned = base; unaligned.insert(unaligned.begin(), 0);
    assert(store.Decode(unaligned.data() + 1, unaligned.size() - 1));
    std::cout << "PASS base layout, bounds, unaligned access and legacy isolation\n";

    for (const auto object : {0x33, 0x44}) {
        auto harmonic = Frame(0x1311, static_cast<std::uint16_t>(object), 367);
        PutFloat(harmonic, 13, 250.0f);
        PutFloat(harmonic, 53, 1.25f);
        PutFloat(harmonic, 369, -15.5f);
        assert(store.Decode(harmonic.data(), harmonic.size()));
        auto packet = store.Get(0x1311, static_cast<std::uint16_t>(object));
        assert(Value(packet, object == 0x33 ? "Ua_Frequency" : "Ia_Frequency") == 250.0);
        assert(Value(packet, object == 0x33 ? "Ua_RMS" : "Ia_RMS") == 1.25);
        assert(Value(packet, object == 0x33 ? "Uc_Angle" : "Ic_Angle", 9) == -15.5);
    }
    for (std::uint16_t object = 0xB1; object <= 0xB6; ++object) {
        auto wave = Frame(0x1311, object, 807);
        Put16(wave, 13, 65535); Put16(wave, 15, 32768); Put16(wave, 811, 32767);
        assert(store.Decode(wave.data(), wave.size()));
        auto packet = store.Get(0x1311, object);
        assert(Value(packet, "Value") == -0.01);
        assert(Value(packet, "Value", 1) == -327.68);
        assert(Value(packet, "Value", 399) == 327.67);
        assert(packet.revision > 0);
        assert(store.Get(0x1311, object).revision == packet.revision);
        assert(!store.Decode(wave.data(), wave.size() - 1));
        assert(store.Get(0x1311, object).revision == packet.revision);
        assert(store.Decode(wave.data(), wave.size()));
        assert(store.Get(0x1311, object).revision > packet.revision);
        assert(store.Get(0x1311, object).sessionId == packet.sessionId);
    }
    auto signal = Frame(0x1333, 0x010B, 8); signal[6] = 2; Put16(signal, 7, 12345);
    assert(store.Decode(signal.data(), signal.size()));
    assert(Value(store.Get(0x1333, 0x010B), "State") == 2);
    std::cout << "PASS harmonic arrays, six signed waveform channels and new signal layout\n";

    const std::uint8_t checksumFixture[] = {99, 0x78, 0x56, 0x34, 0x12, 0xFF, 0, 0, 0};
    assert(Xor32(checksumFixture + 1, 8) == 0x12345687);
    assert(Xor16(checksumFixture + 1, 8) == 0x44B3);
    assert(CRC32(checksumFixture + 1, 2) == 0x12345687); // Qt 参数为字数，不是字节数。
    assert(CRC32(checksumFixture + 1, 1) == 0x12345678);
    assert(CRC16(checksumFixture + 1, 4) == 0x44B3);
    assert(CRC16(checksumFixture + 1, 1) == 0x5678);
    assert(CRC32(nullptr, 0) == 0 && CRC16(nullptr, 0) == 0);
    static_assert(BroadbandPhasorSetting_Length_1Byte == 72 && BroadbandPhasorSetting_CRCLength_4Byte == 17, "宽频长度应从结构生成");
    static_assert(FaultRecordSetting_Length_1Byte == 164 && FaultRecordSetting_CRCLength_4Byte == 40, "录波长度应从结构生成");
    static_assert(PowerQualitySetting_Length_1Byte == 200 && PowerQualitySetting_CRCLength_4Byte == 49, "告警定值长度应从结构生成");
    for (const std::size_t size : {40u, 44u}) {
        auto setting = Frame(0x1344, 0x11, size);
        Put32(setting, 6, 2);
        PutFloat(setting, size == 44 ? 14 : 10, 100.0f);
        if (size == 44) PutFloat(setting, 10, 600.0f);
        Seal(setting);
        assert(store.Decode(setting.data(), setting.size()));
        auto packet = store.Get(0x1344, 0x11);
        assert(packet.payloadLength == size && Value(packet, "PTp_Primary") == 100.0);
        assert(store.GetPrimarySystemSetting().ready == (size == 44));
        assert(store.GetSystemSettingWithoutRatedCurrent().ready == (size == 40));
        if (size == 44) assert(store.GetPrimarySystemSetting().value.RatedCurrent_Primary == 600);
        else assert(store.GetSystemSettingWithoutRatedCurrent().value.PTp_Primary == 100);
        assert(size == 44 ? Value(packet, "RatedCurrent_Primary") == 600 : std::isnan(Value(packet, "RatedCurrent_Primary")));
        std::vector<std::uint8_t> output;
        assert(store.BuildSetting(0x11, {{"PTp_Primary", {200.0}}}, output));
        assert(output.size() == setting.size());
        assert(Value(store.Get(0x1344, 0x11), "PTp_Primary") == 100.0); // 发送不代表设备确认。
        assert(store.Decode(output.data(), output.size()));
        assert(Value(store.Get(0x1344, 0x11), "PTp_Primary") == 200.0);
        auto corrupt = setting; corrupt[10] ^= 1;
        assert(!store.Decode(corrupt.data(), corrupt.size()));
        assert(Value(store.Get(0x1344, 0x11), "PTp_Primary") == 200.0);
        assert(!store.BuildSetting(0x11, {{"CRC", {0}}}, output) && output.empty());
        assert(!store.BuildSetting(0x11, {{"PT_Line_Phase", {1}}}, output));
        assert(!store.BuildSetting(0x11, {{"SystemGroundingMode", {1.5}}}, output));
        assert(!store.BuildSetting(0x11, {{"PTp_Primary", {std::numeric_limits<double>::infinity()}}}, output));
        assert(!store.BuildSetting(0x11, {{"PTp_Primary", {1}}, {"PTp_Primary", {2}}}, output));
        if (size == 40) assert(!store.BuildSetting(0x11, {{"RatedCurrent_Primary", {500}}}, output));
        std::fill(setting.begin() + 6, setting.end(), 255);
        assert(!store.Decode(setting.data(), setting.size()));
    }
    for (const auto pair : {std::make_pair(0x22, 100), std::make_pair(0x33, 200),
                            std::make_pair(0x44, 164), std::make_pair(0x55, 72)}) {
        auto setting = Frame(0x1344, static_cast<std::uint16_t>(pair.first), pair.second);
        Seal(setting);
        assert(store.Decode(setting.data(), setting.size()));
        const char *field = pair.first == 0x22 ? "Correction.Ua" :
            pair.first == 0x33 ? "VoltageLongFlicke.ActValue" :
            pair.first == 0x44 ? "VoltageMutation.ActValue" : "VoltageSubsynOsc.ActValue";
        std::vector<std::uint8_t> output;
        assert(store.BuildSetting(static_cast<std::uint16_t>(pair.first), {{field, {12.5}}}, output));
        assert(store.Decode(output.data(), output.size()));
        assert(Value(store.Get(0x1344, static_cast<std::uint16_t>(pair.first)), field) == 12.5);
    }
    std::cout << "PASS both system variants, nested settings, CRC and invalid writes\n";

    // 与 Qt 告警界面逐项对应：3 个基础参数 + 23 组 Enable / ActValue。
    PacketStore alarmStore;
    const char *alarmNames[] = {
        "VoltageUnbalance", "VoltageDeviation", "FreqDeviation", "VoltageShortFlicke",
        "VoltageLongFlicke", "VoltageFluct", "VoltageSeg", "VoltageSwell", "VoltageTHD",
        "VoltageOddTHD", "VoltageEvenTHD", "VoltageOddHAR", "VoltageEvenHAR",
        "VoltageInterTHD", "VoltageInterHAR", "CurrentUnbalance", "CurrentTHD",
        "CurrentOddTHD", "CurrentEvenTHD", "CurrentOddHAR", "CurrentEvenHAR",
        "CurrentInterTHD", "CurrentInterHAR"
    };
    auto alarmFrame = Frame(0x1344, 0x33, 200);
    Put32(alarmFrame, 6, 1);
    Put32(alarmFrame, 10, 123);
    Put32(alarmFrame, 14, 456);
    for (std::size_t i = 0; i < 23; ++i) {
        Put32(alarmFrame, 18 + i * 8, i % 2);
        PutFloat(alarmFrame, 22 + i * 8, static_cast<float>(i) + 0.125f);
    }
    Seal(alarmFrame);
    assert(alarmStore.Decode(alarmFrame.data(), alarmFrame.size()));
    const auto alarmSnapshot = alarmStore.Get(0x1344, 0x33);
    assert(alarmSnapshot.ready && alarmSnapshot.payloadLength == 200 && alarmSnapshot.fields.size() == 50);
    assert(Value(alarmSnapshot, "VoltageRef_SegSwell") == 1);
    assert(Value(alarmSnapshot, "RecoedSize_Normal") == 123);
    assert(Value(alarmSnapshot, "RecoedSize_Violation") == 456);
    std::vector<NumericField> alarmChanges = {
        {"VoltageRef_SegSwell", {0}}, {"RecoedSize_Normal", {250}}, {"RecoedSize_Violation", {500}}
    };
    for (std::size_t i = 0; i < 23; ++i) {
        const std::string name = alarmNames[i];
        assert(Value(alarmSnapshot, (name + ".Enable").c_str()) == i % 2);
        assert(Value(alarmSnapshot, (name + ".ActValue").c_str()) == static_cast<double>(i) + 0.125);
        alarmChanges.push_back({name + ".Enable", {static_cast<double>((i + 1) % 2)}});
        alarmChanges.push_back({name + ".ActValue", {static_cast<double>(i) + 0.5}});
    }
    const auto typedAlarm = alarmStore.GetPowerQualitySetting();
    assert(typedAlarm.ready && typedAlarm.value.VoltageRef_SegSwell == 1);
    assert(typedAlarm.value.VoltageUnbalance.ActValue == 0.125f);
    assert(typedAlarm.value.CurrentInterHAR.ActValue == 22.125f);
    std::vector<std::uint8_t> alarmOutput;
    assert(alarmStore.BuildSetting(0x33, alarmChanges, alarmOutput) && alarmOutput.size() == 206);
    assert(Value(alarmStore.Get(0x1344, 0x33), "RecoedSize_Normal") == 123);
    assert(alarmStore.Decode(alarmOutput.data(), alarmOutput.size()));
    for (const auto &change : alarmChanges)
        assert(Value(alarmStore.Get(0x1344, 0x33), change.name.c_str()) == change.values[0]);
    alarmOutput[22] ^= 1;
    assert(!alarmStore.Decode(alarmOutput.data(), alarmOutput.size()));
    assert(Value(alarmStore.Get(0x1344, 0x33), "VoltageUnbalance.ActValue") == 0.5);
    std::cout << "PASS alarm setting 49 fields, typed C++ snapshot, write roundtrip and CRC rejection\n";

    assert(store.GetFaultRecordSetting().ready && store.GetFaultRecordSetting().value.VoltageMutation.ActValue == 12.5f);
    assert(store.GetBroadbandPhasorSetting().ready && store.GetBroadbandPhasorSetting().value.VoltageSubsynOsc.ActValue == 12.5f);
    assert(store.GetAnalogQuantitySetting().ready && store.GetAnalogQuantitySetting().value.Correction.Ua == 12.5f);
    assert(store.GetPowerQualitySetting().ready && store.GetPowerQualitySetting().value.VoltageLongFlicke.ActValue == 12.5f);
    auto settingCopy = store.GetFaultRecordSetting();
    settingCopy.value.VoltageMutation.ActValue = 999;
    assert(settingCopy.value.VoltageMutation.ActValue == 999);
    assert(store.GetFaultRecordSetting().value.VoltageMutation.ActValue == 12.5f);
    assert(store.GetHarmonicVoltage().ready && store.GetHarmonicVoltage().value.Ua_RMS[0] == 1.25f);
    assert(store.GetHarmonicCurrent().ready && store.GetHarmonicCurrent().value.Ic_Angle[9] == -15.5f);
    // C++ 强类型波形保留协议原始整数；通用数值接口才除以 100。
    assert(store.GetWaveform(0xB1).ready && store.GetWaveform(0xB1).value.Value[0] == -1);
    assert(!store.GetWaveform(0x33).ready);
    std::cout << "PASS typed snapshots, raw waveform units and Qt word-count CRC interface\n";

    PacketStore signals;
    assert(!signals.GetDigitalInputs().Ready() && !signals.GetDigitalInputs().Complete());
    assert(signals.GetDigitalInputs().BreakerState_Now == kSW_UnCertain);
    auto single = Frame(0x1333, 0x0101, 8);
    single[6] = 0;
    assert(signals.Decode(single.data(), single.size()));
    auto inputs = signals.GetDigitalInputs();
    assert(inputs.Ready() && !inputs.Complete() && inputs.validMask == 1);
    assert(inputs.DigitalInputData.GLKGW == 0 && inputs.BreakerState_Now == 0);
    for (std::uint16_t index = 1; index < 11; ++index) {
        Put16(single, 2, 0x0101 + index);
        single[6] = static_cast<std::uint8_t>(index % 2 + 1);
        assert(signals.Decode(single.data(), single.size()));
    }
    inputs = signals.GetDigitalInputs();
    assert(inputs.Complete() && inputs.validMask == 0x07FF);
    assert(inputs.DigitalInputData.JDKGW == 2 && inputs.DigitalInputData.KHBJ == 1);
    assert(inputs.DigitalInputData.Run == 2 && inputs.DigitalInputData.SyncErr == 2);
    assert(inputs.BreakerState_Now == inputs.DigitalInputData.SwitchState);
    single[6] = kSW_CtrlCircuitOpen;
    assert(signals.Decode(single.data(), single.size()));
    assert(signals.GetDigitalInputs().BreakerState_Now == 0x11);
    auto badSignal = single; badSignal.push_back(0); badSignal.push_back(0); Put16(badSignal, 4, 10);
    assert(!signals.Decode(badSignal.data(), badSignal.size()));
    assert(signals.GetDigitalInputs().BreakerState_Now == 0x11);
    auto all = Frame(0x1333, 0x11, 26);
    Put16(all, 6, 12345); all[13] = 2; all[31] = 1;
    assert(signals.Decode(all.data(), all.size()));
    assert(signals.GetAllSignals().ready && signals.GetAllSignals().value.Time_ms == 12345);
    assert(signals.GetAllSignals().value.MonitoringKM == 2 && signals.GetAllSignals().value.RemoteOrLocal == 1);
    assert(Value(signals.Get(0x1333, 0x11), "RemoteOrLocal") == 1);
    assert(signals.GetDigitalInputs().validMask == 0x07FF && signals.GetDigitalInputs().BreakerState_Now == 0x11);
    signals.Reset();
    assert(signals.Decode(all.data(), all.size()));
    assert(!signals.GetDigitalInputs().Ready()); // 不将 19 路旧命名整组数据猜测映射到 11 路。
    signals.Reset();
    assert(!signals.GetAllSignals().ready && signals.GetDigitalInputs().BreakerState_Now == 0);
    std::cout << "PASS digital input aggregation, breaker state, independent all-signals layout and reset\n";

    std::vector<std::uint8_t> query;
    assert(BuildQuery(0x1311, 0x11, query) && query == std::vector<std::uint8_t>({0x11, 0x13, 0x11, 0, 0, 0}));
    assert(BuildQuery(0x1311, 0x55, query) && query == std::vector<std::uint8_t>({0x11, 0x13, 0x55, 0, 0, 0}));
    assert(BuildQuery(0x1344, 0x11, query));
    assert(BuildQuery(0x1344, 0x33, query));
    assert(BuildQuery(0x1333, 0x11, query) && query == std::vector<std::uint8_t>({0x33, 0x13, 0x11, 0, 0, 0}));
    assert(!BuildQuery(0x1333, 0x0201, query));
    assert(!BuildQuery(0x1322, 0x0106, query) && query.empty());
    assert(!BuildQuery(0x1344, 0x66, query));
    assert(!BuildQuery(0x1311, 0x81, query));
    // Qt 实际结构为 441 字节，不能沿用旧头文件的 417 字节长度常量。
    auto quality = Frame(0x1311, 0x55, 435);
    Put16(quality, 6, 1234);
    PutFloat(quality, 13, -0.125f); // 频率偏差 A
    PutFloat(quality, 13 + 4 * 4, 99.75f); // 分相频率合格率 A
    PutFloat(quality, 13 + 4 * 8, -1.5f); // 相电压偏差 A
    PutFloat(quality, 13 + 4 * 11, 2.5f); // 线电压偏差 AB
    PutFloat(quality, 13 + 4 * 18, 230.0f); // 正序电压
    PutFloat(quality, 13 + 4 * 23, 0.0f); // 零序电流，合法零值
    PutFloat(quality, 13 + 4 * 27, 0.75f); // 电流零序不平衡度
    PutFloat(quality, 13 + 4 * 37, 1.25f); // A 相长闪变
    PutFloat(quality, 13 + 4 * 106, 0.95f); // 最后一个指标
    assert(store.Decode(quality.data(), quality.size()));
    const auto qualitySnapshot = store.Get(0x1311, 0x55);
    assert(qualitySnapshot.ready && qualitySnapshot.payloadLength == 435 && qualitySnapshot.fields.size() == 113);
    assert(Value(qualitySnapshot, "Time_ms") == 1234);
    assert(Value(qualitySnapshot, "PowerQuality.FreqDeviation_A") == -0.125);
    assert(Value(qualitySnapshot, "PowerQuality.FreqQualifiRate_A") == 99.75);
    assert(Value(qualitySnapshot, "PowerQuality.VoltageDeviation_A") == -1.5);
    assert(Value(qualitySnapshot, "PowerQuality.VoltageDeviation_AB") == 2.5);
    assert(Value(qualitySnapshot, "PowerQuality.Voltage_U1") == 230.0);
    assert(Value(qualitySnapshot, "PowerQuality.Current_Io") == 0.0);
    assert(Value(qualitySnapshot, "PowerQuality.Current_In_Unbalance") == 0.75);
    assert(Value(qualitySnapshot, "PowerQuality.VoltageLongFlicke_A") == 1.25);
    assert(std::abs(Value(qualitySnapshot, "PowerQuality.FullWave_Ft") - 0.95) < 0.00001);
    auto invalidQuality = Frame(0x1311, 0x55, 417);
    assert(!store.Decode(invalidQuality.data(), invalidQuality.size()));
    assert(store.Get(0x1311, 0x55).revision == qualitySnapshot.revision);
    assert(store.Decode(quality.data(), quality.size()));
    assert(store.Get(0x1311, 0x55).revision > qualitySnapshot.revision);
    auto unknown = Frame(0x1311, 0xAA, 417);
    assert(!store.Decode(unknown.data(), unknown.size()));
    std::thread reader([&store]() { for (int i = 0; i < 500; ++i) store.Get(0x1311, 0x11); });
    for (int i = 0; i < 500; ++i) assert(store.Decode(base.data(), base.size()));
    reader.join();
    const auto beforeReset = store.Get(0x1311, 0x11);
    store.Reset();
    assert(!store.Get(0x1311, 0x11).ready);
    assert(!store.Get(0x1311, 0x55).ready);
    assert(store.Get(0x1311, 0x11).revision == 0);
    assert(store.Get(0x1311, 0x11).sessionId > beforeReset.sessionId);
    assert(!store.GetFaultRecordSetting().ready && !store.GetBroadbandPhasorSetting().ready &&
           !store.GetPowerQualitySetting().ready);
    assert(!store.GetHarmonicVoltage().ready && !store.GetWaveform(0xB1).ready);
    assert(!store.BuildSetting(0x11, {{"PTp_Primary", {200.0}}}, query));
    assert(store.Decode(base.data(), base.size()));
    assert(store.Get(0x1311, 0x11).revision > beforeReset.revision);
    std::cout << "PASS query whitelist, complete setting schemas, concurrent snapshots and reset\n";
}
