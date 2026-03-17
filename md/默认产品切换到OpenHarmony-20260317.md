## 本次修改

已修改根目录 `build-profile.json5`，把 IDE 默认使用的 `default` 产品切换为 `OpenHarmony`：

- `default` 产品现在使用 `signingConfig: "openharmony"`
- `default` 产品现在使用 `runtimeOS: "OpenHarmony"`
- `default` 产品现在使用 `compileSdkVersion/targetSdkVersion/compatibleSdkVersion = 18`
- 原来的 `HarmonyOS` 产品保留下来，并改名为 `harmonyos`
- 模块 `applyToProducts` 同步改为 `["default", "harmonyos"]`

## 保留的配置

`entry/build-profile.json5` 中的：

```json5
"abiFilters": [
  "armeabi-v7a",
  "arm64-v8a"
]
```

保持不变。

## 验证结果

已使用默认产品 `product=default` 验证通过：

1. `compileNative` 成功
2. `assembleHap` 成功

输出文件：

- `entry/build/default/outputs/default/entry-default-signed.hap`
- `entry/build/default/outputs/default/entry-default-unsigned.hap`

## 说明

这样修改后，DevEco Studio 里原先默认走 `product=default` 的编译和运行配置，不需要再手动切换到 `openharmony`，就会直接按 OpenHarmony 规则构建，因此不会再因为 `armeabi-v7a` 报 HarmonyOS 不支持。
