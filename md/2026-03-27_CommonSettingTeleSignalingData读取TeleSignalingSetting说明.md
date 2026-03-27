## 遥信参数页面读取链路说明

这次只实现要求 1：当 `CommonSetting_TeleSignaling_Set.ets` 页面打开时，读取 native 侧 `TeleSignalingSetting`，映射成 `CommonSettingTeleSignalingData`，然后显示到界面。

### 读取时机

- 页面在 `aboutToAppear()` 中调用 `loadNativeTeleSignalingData()`
- 这里只读取一次，没有加 `0.5` 秒定时刷新

### native 数据来源

- `data.cpp` 定义全局 `TeleSignalingSetting`
- `data.cpp` 定义全局 `TeleSignalingSettingReady = false`
- `tcp_client.cpp` 在收到 `YT_ObjectAddr_CommonSetting_TeleSignaling` 且 CRC 校验通过后：
  - 更新 `TeleSignalingSetting`
  - 置 `TeleSignalingSettingReady = true`
  - 打印 `CommonSetting_TeleSignaling updated`
  - 打印遥信参数明细日志

### NAPI 导出

- `setting_napi.cpp` 新增 `GetTeleSignalingSetting()`
- `napi_init.cpp` 注册 `getTeleSignalingSetting`
- ArkTS 页面通过 `libentry.so` / `requireNapi('entry', ...)` 读取该对象

### 字段映射关系

- `YX01_Time -> yx01Time`
- `YX02_Time -> yx02Time`
- `YX03_Time -> yx03Time`
- `YX04_Time -> yx04Time`
- `YX05_Time -> yx05Time`
- `YX06_Time -> yx06Time`
- `YX07_Time -> yx07Time`
- `YX08_Time -> yx08Time`
- `Enable_Logic -> logicMode`

### 显示规则

- `YX01_Time ~ YX08_Time` 的协议单位是 `0.5ms`
- 页面显示单位是 `ms`
- 所以界面显示时做了 `value * 0.5` 的换算，并保留两位小数
- 这里的 `0.5` 是单位换算，不是刷新周期

### 逻辑值映射

- `0 -> 原值`
- `1 -> 取反`
- `2 -> 屏蔽`

### 保护逻辑

- 只有当 `ready = true` 且 `YX01_Time ~ YX08_Time`、`Enable_Logic` 都合法时，才会覆盖页面默认值
- 如果 native 还没有收到有效遥信整定数据，页面继续显示原始默认值

### 构建结果

- 已执行 `assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
