## 模拟量参数提交写回 AnalogQuantitySetting 说明

本次完成的是要求 1：

- `CommonSetting_AnalogQuantity_Set.ets` 点击提交后
- 把界面上的模拟量参数写回 `data.cpp` 里的全局 `CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting`
- 然后弹出“等待回应”提示框

### 页面侧改动

文件：`entry/src/main/ets/pages/CommonSetting_AnalogQuantity_Set.ets`

新增内容：

1. `updateAnalogQuantitySetting` 的 native 接口声明
2. 模拟量写值对象：
   - `CommonSettingAnalogQuantityWriteParameterValue`
   - `CommonSettingAnalogQuantityWriteValue`
3. 提交相关状态：
   - `submitWaitingDialogVisible`
   - `submitWaitingMessage`
   - `feedbackDialogVisible`
   - `feedbackMessage`
4. 提交流程：
   - `createAnalogQuantityWriteValue(...)`
   - `writeNativeAnalogQuantityData()`
   - `submitCurrentData()`
5. 弹窗：
   - `SubmitWaitingOverlay()`
   - `FeedbackOverlay()`

### native 侧改动

文件：`entry/src/main/cpp/setting_napi.cpp`

新增 `UpdateAnalogQuantitySetting(...)`：

1. 读取 ArkTS 传入的 `Reference / Correction / ZeroDrift`
2. 逐项写入 `AnalogQuantitySetting`
3. 重算 `CRC`
4. 置 `AnalogQuantitySettingReady = true`

本次只写回 native 全局结构体，没有继续补“下发到装置”的发送链路。

### 这次写回的字段

三组参数都完整写回：

- 电压：`Ua / Ub / Uc / Uo / Ux`
- 保护电流：`IA / IB / IC / Io`
- 测量电流：`Ia / Ib / Ic / Is`
- 备用电流：`Iby1 / Iby2 / Iby3`

每组都包含：

- `Reference`
- `Correction`
- `ZeroDrift`

### 当前边界

1. “等待回应”弹窗目前只是界面占位，不包含应答、超时、成功失败回传逻辑。
2. 本次是写 `AnalogQuantitySetting`，没有把数据继续组帧发送给对端装置。
