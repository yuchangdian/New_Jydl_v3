## 统计参数页面读取链路说明

这次只实现要求 1：当 `CommonSetting_Statistics_Set.ets` 页面打开时，读取 native 侧 `StatisticsSetting`，映射成页面里的 `formData: CommonSettingStatisticsField[]`，然后显示到界面。

### 说明

- 你这次描述里前半句写成了 `CommonSettingExceedingLimitData.ets`
- 但后半句明确提到了 `@State formData: CommonSettingStatisticsField[]`
- 实际对应页面是 `CommonSetting_Statistics_Set.ets`
- 这次按统计参数页面实现

### 读取时机

- 页面在 `aboutToAppear()` 中调用 `loadNativeStatisticsData()`
- 这里只读取一次，没有加定时刷新
- 如果 native 当前还没有有效统计参数，就回退到原来的本地持久化值

### native 数据来源

- `data.cpp` 定义全局 `StatisticsSetting`
- `data.cpp` 定义全局 `StatisticsSettingReady = false`
- `tcp_client.cpp` 在收到 `YT_ObjectAddr_CommonSetting_Statistics` 且 CRC 校验通过后：
  - 更新 `StatisticsSetting`
  - 置 `StatisticsSettingReady = true`
  - 打印 `CommonSetting_Statistics updated`

### NAPI 导出

- `setting_napi.cpp` 新增 `GetStatisticsSetting()`
- `napi_init.cpp` 注册 `getStatisticsSetting`
- ArkTS 页面通过 `libentry.so` / `requireNapi('entry', ...)` 读取该对象

### 映射方式

- 顶部两项：
  - `Enable_Bus -> C_Box_Stats_En_Bus`
  - `Enable_Line -> C_Box_Stats_En_Line`
- 每个统计项都按三元组映射：
  - 使能值 -> `C_Box_Stats_En_*`
  - 周期类型 -> `C_Box_Stats_PDType_*`
  - 周期长度 -> `Edit_Stats_PDLen_*`

### 值转换规则

- 使能值：
  - `1 -> 投入`
  - `0 -> 退出`
- 周期类型：
  - `1 -> 分钟级`
  - `2 -> 小时级`
  - `3 -> 日级`
- 周期长度：
  - 直接转成字符串显示到输入框

### 构建结果

- 已执行 `assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
