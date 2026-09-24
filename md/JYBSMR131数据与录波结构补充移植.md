# JYBSMR131 数据与录波结构补充移植

日期：2026-09-16。

## 核对结论

本次参考 `FaultRecord_JYBSMR131.h`、`BPMU_JYBSMR131.h`、`data.cpp`、`data.h`。两个录波头文件的字段与上一轮已经导入的版本一致，保留现有定义；逐项核对了字段名称、类型和顺序。公共 `RecordSettingUnit` 只定义一次，故障录波头文件引用它，避免重复声明。

Qt `data.cpp` 主要声明全局实例和初始化长度，并没有新的解码算法。继续采用项目已有的报文缓存，补充结构体快照读取接口，不另外建立一套可能不同步的可变全局数据。

## 本轮修改

文件均位于 `entry/src/main/cpp/protocol/jybsmr131/`，与旧协议分开。

| 内容 | 落地方式 |
| --- | --- |
| `DigitalInputData_Struct` | 导入 `data_types.h`，保留 GLKGW 至 SwitchState 共 11 个字节 |
| `RemoteSignalALL_Struct` | 导入 `data_types.h`，保持 7 字节时间和 19 个状态，共 26 字节 |
| `CRC32` / `CRC16` | 新增 `data.cpp` 实现，参数仍按 32 位字 / 16 位字计数；按小端字节读取，支持未对齐载荷 |
| 原有 `Xor32` / `Xor16` | 移到同一数据层，继续按字节计长，现有解包和写入校验继续调用 |
| 各定值长度及 CRC 字数 | `data.h` 中用 `SettingLayout<T>` 从实际结构计算，校验 CRC 必须处在最后 4 字节 |
| 断路器当前状态 | 从已收到的 `SwitchState` 回包读取；未收到时保持 `SW_UnCertain`，不根据 HW / TW 猜测 |
| 定值、谐波、波形全局实例 | 通过 `PacketStore` 获取独立结构体快照；未知数据 `ready=false`，更改快照不改变接收缓存 |

`CRC32(data, 2)` 计算 8 字节，`CRC16(data, 2)` 计算 4 字节；不能把 `Xor32` / `Xor16` 的字节长度直接传给这两个兼容接口。两个名称中的 CRC 都沿用 Qt 命名，实际算法为逐字异或。

新增静态布局检查：开入 11 字节、整组遥信 26 字节、录波启动单元 8 字节、故障录波 CRC 偏移 160、宽频相量 CRC 偏移 68。故障录波和宽频定值分别为 164 / 72 字节，校验字数为 40 / 17。

## 状态读取

`PacketStore` 新增以下接口，均在互斥锁保护下读取上次验证通过的缓存：

- `GetDigitalInputs()`：11 路开入及断路器状态，`validMask` 的位 0 至 10 对应 GLKGW 至 SwitchState。
- `GetAllSignals()`：整组遥信原始 19 个状态。
- `GetPrimarySystemSetting()` / `GetSystemSettingWithoutRatedCurrent()`：分别读取 44 / 40 字节系统定值；布局不匹配时返回未就绪。
- `GetAnalogQuantitySetting()`、`GetFaultRecordSetting()`、`GetBroadbandPhasorSetting()`。
- `GetHarmonicVoltage()`、`GetHarmonicCurrent()`、`GetWaveform(objectAddress)`。

强类型 C++ 波形快照保留 `int16_t` 原始值；原有通用数值接口中的 `Value` 已除以 100。两者单位不同，调用方不要重复缩放。

整组遥信的 19 个字段与新版 11 路开入名称不同，参考文件没有提供映射。二者分别缓存和暴露，不互相覆盖。整组查询使用 `common=0x1333, object=0x0011, length=0`；接收时仅接受所提供结构的 26 字节载荷。

## ArkTS 接口

新增 `getJybsmr131DigitalInputs()` NAPI，类型为 `Jybsmr131DigitalInputValue`。`Jybsmr131.ets` 同步提供 `digitalInputs()`、`signal(address)`、`requestAllSignals()` 和遥信 / 开关状态枚举。

```ts
const inputs = Jybsmr131Protocol.digitalInputs();
// ready：至少收到一路；complete：11 路都已收到。
// 未收到的通道为 undefined，真实零值不会被当作缺失。
if (inputs.SwitchState !== undefined) {
  const state = inputs.BreakerState_Now;
}

Jybsmr131Protocol.requestAllSignals();
// 在后续刷新周期读取回包。
const all = Jybsmr131Protocol.signal(Jybsmr131SignalAddress.All);
const remoteOrLocal = Jybsmr131Protocol.value(all, 'RemoteOrLocal');
```

断线重连沿用已有 `PacketStore.Reset()`：所有开入有效位、整组遥信、定值和遥测快照一起清空。数据读取未接入新的 UI 页面，本次范围是数据结构、函数及调用接口。

## 保留与缺失资料

- 已有的定值区号初值、二次额定电流、密码、保护定值数组和旧版 SOE 队列继续由原数据层维护。本轮不复制另一套身份配置或旧协议缓存。
- 源 `data.cpp` 中的 `PowerQualitySetting`、`PQDIF_BSMR130`、63 次谐波 / 间谐波等实例仍依赖尚未提供的 `powerquality.h`，没有用旧设备结构代替。上一轮列出的电能质量二进制解码边界不变。
- `data.h` 声明的 `SettingCode` / `ChangeSettingCode_Flag` 在提供的 `data.cpp` 中没有定义，也没有更新规则，不新增假定的状态流转。
- BPMU 文件注释中的报告码赋值不是可执行初始化，故障录波报告代码也缺少具体赋值来源。本轮保留报告代码结构，不据此启用新的事件接收流程。

## 验证结果

- 三个参考头文件的结构逐项比对通过。
- 6 组 native 测试通过，包括 CRC 字数、两种系统布局、独立快照、开入有效位、断路器状态、19 路与 11 路分离、错长度拒绝及重连清空。
- 5 项 ArkTS 适配测试通过。
- `entry@default` debug HAP 构建成功。日志：`md/jybsmr131-data-build.log`。
- 未进行实际设备联调。

后续重新运行 `tools/import-jybsmr131.cjs` 会生成 `data_types.h` 及整组遥信字段描述；手写的 `data.h` / `data.cpp` 不会被覆盖。

## `PowerQualitySetting_struct` 重复声明说明

当前旧协议目录有两份相同用途的类型声明：`entry/src/main/cpp/setting.h` 定义 `PowerQualitySettingUnit` 和 `PowerQualitySetting_struct`，`entry/src/main/cpp/quality.h` 又定义了一遍。它们不是两个协议版本；从字段看都是由 11 个告警定值单元和末尾 CRC 组成的 92 字节旧版电能质量定值。

现在实际编译路径只包含 `setting.h`，没有 C++ 文件包含 `quality.h`，所以没有出现重定义错误。若同一个编译单元以后同时包含这两个头文件，各自的头文件保护宏不能保护跨文件的同名类型，编译会报重定义。`protocol/jybsmr131/IEC104.h` 中的同名文字是缺少 `powerquality.h` 时使用的模板形参，不是第三份具体结构定义；`data.cpp` 中的两个名称是该类型的实例。

现已按要求删除 `setting.h` 中的重复定义、未使用的 `QualitySetting` 声明及其长度宏。旧版结构只保留在 `quality.h`；实际创建旧版实例的 `data.cpp` 显式包含该头文件。`quality.h` 同时补充 `<cstdint>`，不再依赖其他头文件间接提供固定宽度整数类型。
