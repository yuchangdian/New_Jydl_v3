# CommonSettingPrimarySystemData 与 CommonSetting_PrimarySystem_Struct 读取关联说明

## 本次完成内容

本次先完成了要求 1：

- 页面 `CommonSetting_PrimarySystem_Set.ets` 打开时
- 优先从 native 层 `data.cpp` 里的全局结构体 `PrimarySystemSetting`
- 读取当前一次系统参数
- 转成 `CommonSettingPrimarySystemData`
- 再显示到界面输入框和选择框

如果 native 当前还没有收到有效数据，则回退读取原来的本地持久化文件。

## 读取链路

现在的链路是：

1. `tcp_client.cpp` 收到一次系统参数遥调报文
2. CRC 正确后写入 `PrimarySystemSetting`
3. 同时把 `PrimarySystemSettingReady = true`
4. `napi_init.cpp` 导出 `getPrimarySystemSetting()`
5. 页面 `CommonSetting_PrimarySystem_Set.ets` 在 `aboutToAppear()` 里调用这个导出
6. ArkTS 把返回的 struct 对象映射成 `CommonSettingPrimarySystemData`
7. `formData` 被整体替换，界面自动显示最新值

## 关键文件

### 1. native 数据源

- `entry/src/main/cpp/data.cpp`
- `entry/src/main/cpp/setting.h`

新增了：

- `PrimarySystemSettingReady`

作用：

- 标记 `PrimarySystemSetting` 现在是不是已经被 TCP 收到的有效报文更新过

### 2. TCP 收包后更新 ready 状态

- `entry/src/main/cpp/tcp_client.cpp`

在一次系统参数报文 CRC 校验通过后：

- 先 `memcpy` 到 `PrimarySystemSetting`
- 再 `PrimarySystemSettingReady = true`

### 3. NAPI 导出读取接口

- `entry/src/main/cpp/napi_init.cpp`
- `entry/src/main/cpp/types/libentry/Index.d.ts`

新增导出：

- `getPrimarySystemSetting()`

返回内容包括：

- `ready`
- `PTp_Bus_Primary`
- `PTp_Bus_Secondary`
- `PTo_Bus_Primary`
- `PTo_Bus_Secondary`
- `PT_Line_Primary`
- `PT_Line_Secondary`
- `PT_Line_Phase`
- `PT_Line_Phase_Text`
- `CTp_Protection_Primary`
- `CTp_Protection_Secondary`
- `CTo_Primary`
- `CTo_Secondary`
- `CTp_Measure_Primary`
- `CTp_Measure_Secondary`
- `Mode_CTConnectioin`
- `Mode_CTConnectioin_Text`
- `Mode_Iosample`
- `Mode_Iosample_Text`
- `RatedPower_Line`
- `CRC`

其中几个枚举值已经在 native 里转成界面可直接使用的中文：

- 相别：`A相 / B相 / C相 / AB相 / BC相 / CA相 / 三相`
- CT 接线方式：`三相式 / 两相式`
- 零序电流采集模式：`外部 / 自产`

## struct 到 CommonSettingPrimarySystemData 的赋值关系

映射函数放在：

- `entry/src/main/ets/models/CommonSettingPrimarySystemData.ets`

函数：

- `createCommonSettingPrimarySystemDataFromStruct(...)`

对应关系如下：

| struct 字段 | CommonSettingPrimarySystemData 字段 |
| --- | --- |
| `PTp_Bus_Primary` | `busPtPrimary` |
| `PTp_Bus_Secondary` | `busPtSecondary` |
| `PTo_Bus_Primary` | `busZeroPtPrimary` |
| `PTo_Bus_Secondary` | `busZeroPtSecondary` |
| `PT_Line_Primary` | `linePtPrimary` |
| `PT_Line_Secondary` | `linePtSecondary` |
| `CTp_Protection_Primary` | `protectCtPrimary` |
| `CTp_Protection_Secondary` | `protectCtSecondary` |
| `CTo_Primary` | `zeroCtPrimary` |
| `CTo_Secondary` | `zeroCtSecondary` |
| `CTp_Measure_Primary` | `measureCtPrimary` |
| `CTp_Measure_Secondary` | `measureCtSecondary` |
| `RatedPower_Line` | `ratedPower` |
| `PT_Line_Phase_Text` | `linePhase` |
| `Mode_CTConnectioin_Text` | `ctConnectionMode` |
| `Mode_Iosample_Text` | `zeroCurrentMode` |

补充说明：

- 数值字段会转成字符串后再放进 `CommonSettingPrimarySystemData`
- PT 一次侧这几个 kV 字段会尽量保留 1 位小数显示
- `ABC相` 会在 ArkTS 侧再归一成界面当前使用的 `三相`

## 页面打开时的读取逻辑

代码位置：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets`

现在 `aboutToAppear()` 逻辑变成：

1. 先算缩放比例
2. 调 `loadNativePrimarySystemData()`
3. 如果 native 模块可用并且 `ready=true`
4. 就把 native struct 映射后赋给 `this.formData`
5. 如果 native 不可用或还没准备好
6. 再回退到原来的 `loadPersistedData()`

## 当前结果

要求 1 已经完成：

- 页面打开时可以读取 `data.cpp` 对应的 `PrimarySystemSetting`
- 并依次赋值给 `CommonSettingPrimarySystemData`
- 最终界面显示最新值

## 构建验证

已执行模块构建并通过：

- `assembleHap --analyze=normal --parallel --incremental`

结果：

- `BUILD SUCCESSFUL`

## 下一步可继续做

如果继续做要求 2，可以在此基础上再补：

- 界面修改后反向写回 `CommonSetting_PrimarySystem_Struct`
- 再通过 native 发给底层或保存到全局结构体
