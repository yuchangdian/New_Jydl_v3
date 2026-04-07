# 2026-04-03 统计参数页面提交写回 StatisticsSetting 说明

## 本次目标

把 `CommonSetting_Statistics_Set.ets` 页面里的 `formData: CommonSettingStatisticsField[]`，
在点击“提交”后写入 `data.cpp` 对应的 `CommonSetting_Statistics_Struct StatisticsSetting`，
并弹出“等待回应”弹窗。

## 本次处理结果

### 1. 页面侧已接入提交写回

文件：

- `entry/src/main/ets/pages/CommonSetting_Statistics_Set.ets`

已完成：

- 新增 `CommonSettingStatisticsWriteValue` 写入接口定义。
- 新增 `updateStatisticsSetting(...)` 的 NAPI 调用声明。
- 新增“提交等待弹窗”状态：
  - `submitWaitingDialogVisible`
  - `submitWaitingMessage`
- 新增提交映射逻辑：
  - `投入 -> 1`
  - `退出 -> 0`
  - `分钟级 -> 1`
  - `小时级 -> 2`
  - `日级 -> 3`
- 新增 `createStatisticsWriteValue(...)`，把页面 `formData` 的值逐项映射到统计结构体字段。
- 新增 `writeNativeStatisticsData()`，提交时实际调用 native 写入。
- `submitCurrentData()` 现已改为：
  1. 先保存本地文件
  2. 再写入 `StatisticsSetting`
  3. 成功后弹“等待回应”
  4. 失败则弹错误提示

### 2. Native 已接入 StatisticsSetting 写入

文件：

- `entry/src/main/cpp/setting_napi.cpp`
- `entry/src/main/cpp/setting_napi.h`
- `entry/src/main/cpp/napi_init.cpp`

已完成：

- 新增 `UpdateStatisticsSetting(...)`
- 从 ArkTS 读取统计参数全部字段
- 逐项写入 `CommonSetting_Statistics_Struct`
- 重算 `CRC`
- 回写全局 `StatisticsSetting`
- 置位 `StatisticsSettingReady = true`
- 组包 `RemoteAdjust_Statistics_Struct`
- 通过 TCP 发送统计参数定值报文

发送报文使用：

- `Common_addr = Common_Addr_RemoteAdjust`
- `Object_addr = YT_ObjectAddr_CommonSetting_Statistics`
- `Length = CommonSetting_Statistics_Length_1Byte`

### 3. 类型声明和 mock 已同步

文件：

- `entry/src/main/cpp/types/libentry/Index.d.ts`
- `entry/src/mock/Libentry.mock.ets`

已完成：

- 新增 `CommonSettingStatisticsWriteValue`
- 新增 `updateStatisticsSetting(...)` 类型导出
- 新增 mock 实现，避免预览或编译阶段缺符号

## 说明

### 1. 特殊字段名保持和底层一致

统计结构体里有一个字段名本身就是：

- `PeriodType_PowerFactorrOnTimeValue`

这里的 `Factorr` 是底层现有命名，我这次保持一致，没有擅自改结构体字段名，
避免前端和 native 对不上。

### 2. 本次没有改页面布局

这次只补了提交写回链路和等待回应弹窗，没有改统计参数页原有业务布局。

## 验证结果

已执行增量构建：

- `assembleHap --incremental`

结果：

- `BUILD SUCCESSFUL`
