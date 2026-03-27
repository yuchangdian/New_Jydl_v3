## 遥控参数页面读取链路说明

这次只实现要求 1：当 `CommonSetting_TeleControlling_Set.ets` 页面打开时，读取 native 侧 `TeleControllingSetting`，映射成 `CommonSettingTeleControllingData`，然后显示到界面。

### 说明

- 你原始描述里把页面写成了遥控，但 struct 名写成了 `TeleSignalingSetting`
- 这两者不一致
- 本次按结构一致性处理为 `CommonSetting_TeleControlling_Struct TeleControllingSetting`

### 读取时机

- 页面在 `aboutToAppear()` 中调用 `loadNativeTeleControllingData()`
- 这里只读取一次，没有加定时刷新
- 如果 native 当前还没有有效遥控整定数据，页面会回退到原来的本地持久化值

### native 数据来源

- `data.cpp` 定义全局 `TeleControllingSetting`
- `data.cpp` 定义全局 `TeleControllingSettingReady = false`
- `tcp_client.cpp` 在收到 `YT_ObjectAddr_CommonSetting_TeleControlling` 且 CRC 校验通过后：
  - 更新 `TeleControllingSetting`
  - 置 `TeleControllingSettingReady = true`
  - 打印 `CommonSetting_TeleControlling updated`
  - 打印遥控参数明细日志

### NAPI 导出

- `setting_napi.cpp` 新增 `GetTeleControllingSetting()`
- `napi_init.cpp` 注册 `getTeleControllingSetting`
- ArkTS 页面通过 `libentry.so` / `requireNapi('entry', ...)` 读取该对象

### 字段映射关系

- `HoldingTime_YK1_XZ -> yk1SelectHoldingTime`
- `HoldingTime_YK1_TZ -> yk1TripHoldingTime`
- `HoldingTime_YK1_HZ -> yk1CloseHoldingTime`
- `HoldingTime_YK2_XZ -> yk2SelectHoldingTime`
- `HoldingTime_YK2_TZ -> yk2TripHoldingTime`
- `HoldingTime_YK2_HZ -> yk2CloseHoldingTime`
- `Sync_NoVoltage -> syncNoVoltage`
- `Sync_ThereVoltage -> syncThereVoltage`
- `Sync_Volue_VoltageDifferenceBlock -> syncVoltageDifferenceBlock`
- `Sync_Volue_AngleDifferenceBlock -> syncAngleDifferenceBlock`
- `Sync_Volue_FrequencyDifferenceBlock -> syncFrequencyDifferenceBlock`
- `Sync_DelayTime -> syncDelayTime`
- `Sync_BreakerCloseTime -> syncBreakerCloseTime`
- `Sync_Enable_CloseMode_YK -> remoteCloseMode`

### 合闸方式映射

- `0 -> 闭锁`
- `1 -> 普通`
- `2 -> 检同期`
- `3 -> 检线无压且母有压`
- `4 -> 检线有压且母无压`
- `5 -> 检线无压且母无压`
- `6 -> 检线无压或母无压`

### 页面中文处理

- `CommonSetting_TeleControlling_Set.ets` 里的中文显示字符串已经改成直接中文
- 不再使用 `\uXXXX` 形式

### 构建结果

- 已执行 `assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
