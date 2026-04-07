# 2026-04-03 遥控参数提交写回 TeleControllingSetting 说明

## 目标

- 在 `CommonSetting_TeleControlling_Set.ets` 页面点击“提交”后：
  - 将界面参数写入 `data.cpp` 对应的 `TeleControllingSetting` 结构体；
  - 弹出“等待回应”提示弹窗（仅提示，不实现回应逻辑）。

## 改动点

### 1. 页面提交链路（ArkTS）

文件：`entry/src/main/ets/pages/CommonSetting_TeleControlling_Set.ets`

- 新增写入参数接口 `CommonSettingTeleControllingWriteValue`。
- 扩展 `TeleControllingNativeModule`，增加：
  - `updateTeleControllingSetting?: (value) => boolean`
- 新增提交等待状态：
  - `submitWaitingDialogVisible`
  - `submitWaitingMessage`
- 新增方法：
  - `parseTeleControllingFieldNumber`
  - `parseTeleControllingFieldUint`
  - `getRemoteCloseModeCode`
  - `createTeleControllingWriteValue`
  - `writeNativeTeleControllingData`
  - `showSubmitWaiting`
  - `closeSubmitWaiting`
  - `showFeedback`
- 修改 `submitCurrentData`：
  - 先本地保存；
  - 再调用 native 写入 `TeleControllingSetting`；
  - 成功后弹“等待回应”；
  - 失败弹“提交失败”。
- 新增 `SubmitWaitingOverlay` 弹层并挂载到页面 `build()`。

### 2. Native 写入接口（C++）

文件：`entry/src/main/cpp/setting_napi.cpp`

- 新增 `UpdateTeleControllingSetting(napi_env, napi_callback_info)`：
  - 从 ArkTS 参数对象读取遥控字段；
  - 逐项写入 `CommonSetting_TeleControlling_Struct nextSetting`；
  - 重算 `CRC`；
  - 回写全局 `TeleControllingSetting`；
  - 置位 `TeleControllingSettingReady = true`；
  - 返回 `true/false`。

文件：`entry/src/main/cpp/setting_napi.h`

- 新增函数声明：
  - `napi_value UpdateTeleControllingSetting(napi_env env, napi_callback_info info);`

文件：`entry/src/main/cpp/napi_init.cpp`

- 新增 NAPI 导出：
  - `updateTeleControllingSetting`

### 3. 类型声明和 mock

文件：`entry/src/main/cpp/types/libentry/Index.d.ts`

- 新增 `CommonSettingTeleControllingWriteValue` 类型。
- 新增导出函数声明：
  - `updateTeleControllingSetting(value): boolean`

文件：`entry/src/mock/Libentry.mock.ets`

- 新增 mock：
  - `updateTeleControllingSetting` 返回 `true`。

## 当前边界

- 本次实现仅完成“界面 -> data.cpp 结构体写入 + 等待回应提示弹窗”。
- 未实现“等待回应的真实状态机/超时处理/回应包联动”。

## 构建验证

- 命令：`assembleHap --analyze=normal --parallel --incremental`
- 结果：`BUILD SUCCESSFUL`
