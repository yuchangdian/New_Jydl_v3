## 越限报警参数页面读取链路说明

这次只实现要求 1：当 `CommonSetting_ExceedingLimit_Set.ets` 页面打开时，读取 native 侧 `ExceedingLimitSetting`，映射成 `CommonSettingExceedingLimitData`，然后显示到界面。

### 说明

- 你开头那句把 struct 写成了 `TeleControllingSetting`
- 但要求 1 下面明确写的是 `CommonSetting_ExceedingLimit_Struct ExceedingLimitSetting`
- 这次按后者实现

### 读取时机

- 页面在 `aboutToAppear()` 中调用 `loadNativeExceedingLimitData()`
- 这里只读取一次，没有加定时刷新
- 如果 native 当前还没有有效越限参数，就回退到原来的本地持久化值

### native 数据来源

- `data.cpp` 定义全局 `ExceedingLimitSetting`
- `data.cpp` 定义全局 `ExceedingLimitSettingReady = false`
- `tcp_client.cpp` 在收到 `YT_ObjectAddr_CommonSetting_ExceedingLimit` 且 CRC 校验通过后：
  - 更新 `ExceedingLimitSetting`
  - 置 `ExceedingLimitSettingReady = true`
  - 打印 `CommonSetting_ExceedingLimit updated`
  - 打印越限参数明细日志

### NAPI 导出

- `setting_napi.cpp` 新增 `GetExceedingLimitSetting()`
- `napi_init.cpp` 注册 `getExceedingLimitSetting`
- ArkTS 页面通过 `libentry.so` / `requireNapi('entry', ...)` 读取该对象

### 字段映射关系

- `Time_Delay -> delayTime`
- `Enable_LineVoltageExceedingUpperLimit -> lineVoltageUpperEnabled`
- `Value_LineVoltageExceedingUpperLimit -> lineVoltageUpperValue`
- `Enable_LineVoltageExceedingLowerLimit -> lineVoltageLowerEnabled`
- `Value_LineVoltageExceedingLowerLimit -> lineVoltageLowerValue`
- `Enable_ZeroSequenceVoltageExceedingUpperLimit -> zeroSequenceVoltageUpperEnabled`
- `Value_ZeroSequenceVoltageExceedingUpperLimit -> zeroSequenceVoltageUpperValue`
- `Enable_VoltageImbalanceRateExceedingUpperLimit -> voltageImbalanceRateUpperEnabled`
- `Value_VoltageImbalanceRateExceedingUpperLimit -> voltageImbalanceRateUpperValue`
- `Enable_PhaseCurrentExceedingUpperLimit -> phaseCurrentUpperEnabled`
- `Value_PhaseCurrentExceedingUpperLimit -> phaseCurrentUpperValue`
- `Enable_ZeroSequenceCurrentExceedingUpperLimit -> zeroSequenceCurrentUpperEnabled`
- `Value_ZeroSequenceCurrentExceedingUpperLimit -> zeroSequenceCurrentUpperValue`
- `Enable_CurrentImbalanceRateExceedingUpperLimit -> currentImbalanceRateUpperEnabled`
- `Value_CurrentImbalanceRateExceedingUpperLimit -> currentImbalanceRateUpperValue`
- `Enable_PhaseDifferentialCurrentExceedingUpperLimit -> phaseDifferentialCurrentUpperEnabled`
- `Value_PhaseDifferentialCurrentExceedingUpperLimit -> phaseDifferentialCurrentUpperValue`
- `Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit -> zeroSequenceDifferentialCurrentUpperEnabled`
- `Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit -> zeroSequenceDifferentialCurrentUpperValue`
- `Enable_LoadRateExceedingUpperLimit -> loadRateUpperEnabled`
- `Value_LoadRateRateExceedingUpperLimit -> loadRateUpperValue`

### 开关值映射

- `1 -> 投入`
- `0 -> 退出`

### 构建结果

- 已执行 `assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
