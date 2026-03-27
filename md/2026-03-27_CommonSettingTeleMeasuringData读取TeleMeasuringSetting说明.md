## 说明

本次需求描述里写的是：

- 页面：`CommonSetting_TeleMeasuring_Set.ets`
- 数据结构：`CommonSetting_TeleSignaling_Struct TeleSignalingSetting`

但这两个对象语义上并不对应。

`CommonSetting_TeleMeasuring_Set.ets` 页面字段是：

- 遥测变化检测周期
- 电度量上送值
- 频率死区
- 交流电压死区
- 直流电压死区
- 交流电流死区
- 功率死区
- 功率因数死区

它们和 `CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting` 一一对应，
而不是 `TeleSignalingSetting`。

所以这次按合理语义，实际接的是：

- `CommonSetting_TeleMeasuring_Set.ets`
- `CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting`

## 本次完成内容

### 1. native 侧增加遥测参数 ready 标志

- `setting.h` 增加 `extern bool TeleMeasuringSettingReady;`
- `data.cpp` 定义 `bool TeleMeasuringSettingReady = false;`

### 2. TCP 解码真正落 TeleMeasuringSetting

在 `tcp_client.cpp` 的 `DecodeRemoteAdjustPacket()` 中新增：

- `YT_ObjectAddr_CommonSetting_TeleMeasuring`

收到长度正确且 CRC 正确的遥测参数定值报文后：

1. `memcpy` 到 `TeleMeasuringSetting`
2. `TeleMeasuringSettingReady = true`
3. 打印 `CommonSetting_TeleMeasuring updated`

### 3. NAPI 导出 getTeleMeasuringSetting()

在 `setting_napi.cpp` 中新增 `getTeleMeasuringSetting()`，
把下面这些字段导出给 ArkTS：

- `ready`
- `Cycle_Detection`
- `DeadBand_Frequency`
- `DeadBand_ACvoltage`
- `DeadBand_DCvoltage`
- `DeadBand_ACcurrent`
- `DeadBand_Power`
- `DeadBand_PowerFactor`
- `Enable_PrimaryEnergy`
- `CRC`

并在 `napi_init.cpp` 注册导出。

### 4. 页面打开时读取 native 数据

在 `CommonSetting_TeleMeasuring_Set.ets` 中新增：

- native 类型声明
- native 模块加载逻辑
- `isUsableCommonSettingTeleMeasuringStructValue()`
- `createCommonSettingTeleMeasuringDataFromStruct()`
- `loadNativeTeleMeasuringData()`

页面 `aboutToAppear()` 时会：

1. 先计算界面缩放
2. 调 `loadNativeTeleMeasuringData()`
3. 读取 native `getTeleMeasuringSetting()`
4. 若 `ready=true` 且字段有效，则覆盖 `formData`
5. 页面显示最新值

如果 native 还没收到有效遥测参数报文，则页面保留默认值。

## 字段映射关系

- `Cycle_Detection` -> `cycleDetection`
- `Enable_PrimaryEnergy` -> `primaryEnergyMode`
- `DeadBand_Frequency` -> `frequencyDeadBand`
- `DeadBand_ACvoltage` -> `acVoltageDeadBand`
- `DeadBand_DCvoltage` -> `dcVoltageDeadBand`
- `DeadBand_ACcurrent` -> `acCurrentDeadBand`
- `DeadBand_Power` -> `powerDeadBand`
- `DeadBand_PowerFactor` -> `powerFactorDeadBand`

其中：

- `Enable_PrimaryEnergy = 1` -> `一次值`
- `Enable_PrimaryEnergy = 0` -> `二次值`

数值字段统一格式化为两位小数。

## 本次涉及文件

- `entry/src/main/cpp/setting.h`
- `entry/src/main/cpp/data.cpp`
- `entry/src/main/cpp/tcp_client.cpp`
- `entry/src/main/cpp/setting_napi.h`
- `entry/src/main/cpp/setting_napi.cpp`
- `entry/src/main/cpp/napi_init.cpp`
- `entry/src/main/cpp/types/libentry/Index.d.ts`
- `entry/src/mock/Libentry.mock.ets`
- `entry/src/main/ets/pages/CommonSetting_TeleMeasuring_Set.ets`

## 验证结果

已执行：

`assembleHap --analyze=normal --parallel --incremental`

结果：

`BUILD SUCCESSFUL`

## 如果后续你坚持要按 TeleSignalingSetting 去接

那就不是“按字段语义映射”，而是“把遥信参数硬塞到遥测参数页”。

这种接法可以做，但需要你明确说明：

- 哪个 `YXxx_Time` 对应页面哪个输入框
- `Enable_Logic` 要映射到哪个页面字段

否则结果会是形式上能显示，语义上不成立。
