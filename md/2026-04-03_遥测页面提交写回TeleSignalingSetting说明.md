# 2026-04-03 遥测页面提交写回 TeleSignalingSetting 说明

## 目标

- 在 `CommonSetting_TeleMeasuring_Set.ets` 点击“提交”后：
  - 弹出“等待回应”提示弹窗（仅提示，暂不做真实回应逻辑）。
  - 将界面值写入 `data.cpp` 中 `CommonSetting_TeleSignaling_Struct TeleSignalingSetting`。

## 页面改动

文件：`entry/src/main/ets/pages/CommonSetting_TeleMeasuring_Set.ets`

- 增加 native 写接口声明：
  - `getTeleSignalingSetting`
  - `updateTeleSignalingSetting`
- 增加等待回应状态：
  - `submitWaitingDialogVisible`
  - `submitWaitingMessage`
- 增加写入流程方法：
  - `createTeleSignalingWriteValue`
  - `writeNativeTeleSignalingData`
  - `showSubmitWaiting` / `closeSubmitWaiting`
- 提交逻辑改为：
  - 写入失败：弹 `提交失败，请检查遥信参数结构体写入。`
  - 写入成功：弹 `界面参数已写入遥信参数结构体，等待装置回应...`

## 字段映射

`CommonSettingTeleMeasuringData` -> `CommonSetting_TeleSignaling_Struct`

- `cycleDetection` -> `YX01_Time`
- `frequencyDeadBand` -> `YX02_Time`
- `acVoltageDeadBand` -> `YX03_Time`
- `dcVoltageDeadBand` -> `YX04_Time`
- `acCurrentDeadBand` -> `YX05_Time`
- `powerDeadBand` -> `YX06_Time`
- `powerFactorDeadBand` -> `YX07_Time`
- `primaryEnergyMode` -> `Enable_Logic`（一次值=0，二次值=1）
- `YX08_Time`：界面无对应输入项，本次写回时保留当前结构体值（fallback）

## Native 改动

文件：`entry/src/main/cpp/setting_napi.cpp`

- 新增 `UpdateTeleSignalingSetting(...)`：
  - 读取 ArkTS 传入字段；
  - 写入 `TeleSignalingSetting`；
  - 重新计算 `CRC`（`CommonSetting_YX_CRCLength_4Byte`）；
  - `TeleSignalingSettingReady = true`。

文件：`entry/src/main/cpp/setting_napi.h`

- 新增声明：`UpdateTeleSignalingSetting(...)`

文件：`entry/src/main/cpp/napi_init.cpp`

- 新增导出：`updateTeleSignalingSetting`

文件：`entry/src/main/cpp/types/libentry/Index.d.ts`

- 新增 `CommonSettingTeleSignalingWriteValue`
- 新增函数声明：`updateTeleSignalingSetting(...)`

文件：`entry/src/mock/Libentry.mock.ets`

- 新增 mock：`updateTeleSignalingSetting`，返回 `true`

## 额外修正

为了通过编译，清理了 `UpdateTeleControllingSetting` 中一段无效遗留代码（包含不存在类型和 `emit` 语句），该段不属于本次需求且会导致 native 构建失败。

## 构建验证

- 命令：`assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
