## 目标

让 DevEco Studio 里默认的 `product=default` 直接变成 OpenHarmony，这样可以保留：

```json5
"abiFilters": [
  "armeabi-v7a",
  "arm64-v8a"
]
```

并且在 IDE 里直接点编译、运行也不会再触发 HarmonyOS 对 `armeabi-v7a` 的校验报错。

## 推荐改法

只改根目录 `build-profile.json5`，不要改 `entry/build-profile.json5` 的 `abiFilters`。

### 改法一：把默认产品改成 OpenHarmony，同时保留原 HarmonyOS 配置

把 `products` 里的两个产品调整成：

- `default` -> OpenHarmony
- `harmonyos` -> 原来那个 HarmonyOS 配置

同时把 `applyToProducts` 里的 `openharmony` 改成 `harmonyos`。

## 修改后效果

- DevEco 当前大量缓存和运行配置仍在使用 `product=default`
- 改完后这些默认行为会自动落到 OpenHarmony
- `entry/build-profile.json5` 中保留 `armeabi-v7a` 也可以编译通过
- 如果后面还要回头编 HarmonyOS，可以改选 `harmonyos`

## 不建议的改法

- 不建议继续保留 `default=HarmonyOS` 再要求 IDE 自动支持 `armeabi-v7a`
- 因为 `HarmonyOS` 产品对该 ABI 的配置校验会直接失败，这不是 native 代码问题，而是产品类型约束
