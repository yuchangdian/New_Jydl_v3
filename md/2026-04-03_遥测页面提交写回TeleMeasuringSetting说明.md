# 遥测页面提交写回 TeleMeasuringSetting 说明

## 目标
- 在 `CommonSetting_TeleMeasuring_Set.ets` 页面点击“提交”后：
  - 弹出“等待回应”提示框；
  - 将界面参数写入 `data.cpp` 中的 `CommonSetting_TeleMeasuring_Struct TeleMeasuringSetting`。

## 本次修正
- 修正了页面中原本误接到遥信结构体的提交逻辑：
  - 旧逻辑错误地调用了 `getTeleSignalingSetting / updateTeleSignalingSetting`
  - 现在改为 `getTeleMeasuringSetting / updateTeleMeasuringSetting`

- 修正了“电度量上送值”映射：
  - `一次值 -> 1`
  - `二次值 -> 0`

## ArkTS 侧
- 新增 `CommonSettingTeleMeasuringWriteValue` 映射对象。
- 点击提交时：
  1. 读取界面 `formData`
  2. 映射为 `Cycle_Detection / DeadBand_* / Enable_PrimaryEnergy`
  3. 调用 `updateTeleMeasuringSetting(...)`
  4. 成功后弹“等待回应”弹窗
  5. 失败时弹错误提示

## Native 侧
- 新增 `UpdateTeleMeasuringSetting(...)`：
  - 读取 JS 传入对象
  - 写入 `TeleMeasuringSetting`
  - 重算 CRC
  - 置 `TeleMeasuringSettingReady = true`
  - 组 `RemoteAdjust_TeleMeasuring_Struct` 并发送

## 验证
- 已执行增量构建：
  - `assembleHap --incremental`
- 结果：
  - `BUILD SUCCESSFUL`
