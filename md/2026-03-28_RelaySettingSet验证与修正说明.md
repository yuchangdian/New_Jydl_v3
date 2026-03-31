# RelaySettingSet 验证与修正说明

## 结论

`RelaySettingSet.ets` 读取 `RelaySetting[20]` 的链路现在是通的，但在本次复核前存在一个实际问题：

- `getRelaySettingByZone()` 返回的 `fields` 是数组
- 数值类字段通过 `SetRelayTextField()` 追加到了数组里
- 枚举类字段却通过 `SetNamedProperty()` 挂到了数组对象属性上
- 页面读取逻辑只遍历数组元素，所以所有 `select` 字段都收不到

这个问题已经修正：

- 文件：`entry/src/main/cpp/setting_napi.cpp`
- 修正点：`SetRelayEnumField()` 改为调用 `SetRelayTextField()`，把枚举字段也按 `{ id, value }` 追加到 `fields` 数组

## 验证结果

### 1. 构建验证

执行增量构建后结果为：

- `BUILD SUCCESSFUL`

### 2. 字段覆盖验证

按 `RelaySettingSetSchema.ets` 统计，页面可绑定字段共 `193` 个：

- 主页面 `input/select`
- 监视区 `RelayMonitorFieldSpec`

按 `setting_napi.cpp` 统计，native 输出字段分两类：

- 直接写死字面量字段：`157`
- 通过 helper 参数展开的字段：`36`

这 `36` 个字段全部来自：

- 过流一二三段：`3 x 7 = 21`
- 零序一二三段：`3 x 5 = 15`

合计：

- `157 + 36 = 193`

所以从代码映射角度看，页面可绑定字段和 native 输出字段是一一对应的。

## 本次修正后的判断

如果：

- 对应区号已经收到 `RelaySetting[zone]`
- `RelaySettingReady[zone] = true`

那么页面打开时会：

1. 先读当前区号本地 profile
2. 再读 native `getRelaySettingByZone(zoneCode)`
3. 用 native 的返回值覆盖当前区 profile
4. 最后刷新界面显示

所以“按区号读取 `RelaySetting[20]` 并显示到页面”这一条，现在从代码和构建结果看是成立的。
