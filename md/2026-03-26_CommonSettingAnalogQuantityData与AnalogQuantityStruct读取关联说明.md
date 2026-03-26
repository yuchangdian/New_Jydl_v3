## 目标

把模拟量整定页面 `CommonSetting_AnalogQuantity_Set.ets` 和 native 侧 `data.cpp` 里的
`CommonSetting_AnalogQuantity_Struct AnalogQuantitySetting` 接起来，先完成“页面打开时读取 struct 并显示”的链路。

## 结构调整

这次没有继续把设置项读取逻辑堆在 `napi_init.cpp`。

- `napi_init.cpp` 只保留 NAPI 导出注册
- 新增 `setting_napi.h/.cpp`，专门负责把 native struct 转成 ArkTS 可用对象
- 一次系统整定和模拟量整定的读取导出都放到 `setting_napi.cpp`

这样后面如果继续接“写回 struct”或再接别的设置页面，不会把 `napi_init.cpp` 越堆越乱。

## native 侧读取链路

1. `tcp_client.cpp` 收到并校验通过模拟量整定报文后，更新全局 `AnalogQuantitySetting`
2. 同时把 `AnalogQuantitySettingReady` 置为 `true`
3. ArkTS 页面调用 `getAnalogQuantitySetting()`
4. `setting_napi.cpp` 把 `AnalogQuantitySetting` 组装成对象返回给 ArkTS

返回对象结构：

```ts
{
  ready: boolean,
  Reference: { Ua, Ub, Uc, Uo, IA, IB, IC, Io, Ia, Ib, Ic, Is, Ux, Iby1, Iby2, Iby3 },
  Correction: { ...同上... },
  ZeroDrift: { ...同上... },
  CRC: number
}
```

## ArkTS 侧赋值链路

页面文件：`entry/src/main/ets/pages/CommonSetting_AnalogQuantity_Set.ets`

打开页面时：

1. `aboutToAppear()` 调 `loadNativeAnalogQuantityData()`
2. `loadNativeAnalogQuantityData()` 调 native `getAnalogQuantitySetting()`
3. 先检查：
   - native 模块是否存在
   - `ready` 是否为 `true`
   - `Reference / Correction / ZeroDrift` 里的 16 个数值是否都是有效数字
4. 检查通过后，调用 `createCommonSettingAnalogQuantityValuesFromStruct()`
5. 把 struct 中的数值逐项格式化成字符串，赋值给 `CommonSettingAnalogQuantityData`
6. 页面输入框继续从 `fieldValues` 取值显示

## 字段对应关系

按三组参数分别映射：

- `Reference.Ua` -> `Edit_Analog_Reference_Ua`
- `Correction.Ua` -> `Edit_Analog_Correction_Ua`
- `ZeroDrift.Ua` -> `Edit_Analog_ZeroDrift_Ua`

其余字段完全同样的规律：

- `Ia / Ub / Ib / Uc / Ic / Uo / Is / IA / Ux / IB / Iby1 / IC / Iby2 / Io / Iby3`

也就是 native struct 的三大块：

- `Reference`
- `Correction`
- `ZeroDrift`

分别灌到页面类 `CommonSettingAnalogQuantityData` 的三列输入框变量里。

## 兼容处理

- 如果 native 模块还没准备好，页面保留默认值
- 如果 `ready=false`，页面保留默认值
- 如果某个字段不是有效数字，整包视为不可用，不覆盖页面默认值

这样可以避免 native 未收到有效报文时，把界面刷成空白或异常值。

## 本次涉及文件

- `entry/src/main/cpp/setting.h`
- `entry/src/main/cpp/data.cpp`
- `entry/src/main/cpp/tcp_client.cpp`
- `entry/src/main/cpp/napi_init.cpp`
- `entry/src/main/cpp/setting_napi.h`
- `entry/src/main/cpp/setting_napi.cpp`
- `entry/src/main/cpp/CMakeLists.txt`
- `entry/src/main/cpp/types/libentry/Index.d.ts`
- `entry/src/mock/Libentry.mock.ets`
- `entry/src/main/ets/pages/CommonSetting_AnalogQuantity_Set.ets`

## 验证结果

已执行 `assembleHap --analyze=normal --parallel --incremental`，构建通过。

## 下一步

如果继续做要求 2，可以在现有读取链路基础上反向建立：

- `CommonSettingAnalogQuantityData` -> ArkTS 提交对象
- ArkTS -> NAPI 写入接口
- NAPI -> `AnalogQuantitySetting`
