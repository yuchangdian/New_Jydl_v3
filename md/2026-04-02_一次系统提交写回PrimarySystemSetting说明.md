## 一次系统参数提交写回说明

本次只完成“界面点击提交后，把页面参数写回 native 的 `CommonSetting_PrimarySystem_Struct PrimarySystemSetting`，并弹出等待回应框”。

### 已完成内容

1. 页面 `CommonSetting_PrimarySystem_Set.ets` 点击提交时，除了原来的本地 `json` 保存，还会调用 native 接口 `updatePrimarySystemSetting(...)`。
2. ArkTS 侧通过 `createCommonSettingPrimarySystemWriteValue(...)` 把 `CommonSettingPrimarySystemData` 转成 native 写入对象。
3. native 侧新增 `UpdatePrimarySystemSetting`：
   - 读取 ArkTS 传入的字段
   - 写入全局 `PrimarySystemSetting`
   - 重新计算 `CRC`
   - 置 `PrimarySystemSettingReady = true`
4. 提交成功后，页面弹出“等待回应”弹窗。

### 字段写回关系

- `busPtPrimary` -> `PTp_Bus_Primary`
- `busPtSecondary` -> `PTp_Bus_Secondary`
- `busZeroPtPrimary` -> `PTo_Bus_Primary`
- `busZeroPtSecondary` -> `PTo_Bus_Secondary`
- `linePtPrimary` -> `PT_Line_Primary`
- `linePtSecondary` -> `PT_Line_Secondary`
- `linePhase` -> `PT_Line_Phase`
- `protectCtPrimary` -> `CTp_Protection_Primary`
- `protectCtSecondary` -> `CTp_Protection_Secondary`
- `zeroCtPrimary` -> `CTo_Primary`
- `zeroCtSecondary` -> `CTo_Secondary`
- `measureCtPrimary` -> `CTp_Measure_Primary`
- `measureCtSecondary` -> `CTp_Measure_Secondary`
- `ctConnectionMode` -> `Mode_CTConnectioin`
- `zeroCurrentMode` -> `Mode_Iosample`
- `ratedPower` -> `RatedPower_Line`

### 当前保留的边界

1. `SystemGroundingMode` 当前页面没有输入项，所以提交时保留当前 struct 里的原值，不从界面改。
2. “等待回应”弹窗目前只是界面占位，还没有继续接设备应答、超时、成功失败反馈链路。
3. 本次是写回 `data.cpp` 的全局结构体，不包含下发到装置的报文发送。
