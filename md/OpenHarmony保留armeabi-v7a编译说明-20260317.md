## 结论

当前工程可以保留 `entry/build-profile.json5` 中的 `armeabi-v7a`，但前提是必须使用 `OpenHarmony` 产品编译，不能继续使用 `HarmonyOS` 产品编译。

## 本地工程现状

工程级 `build-profile.json5` 已经同时定义了两个产品：

- `default` 的 `runtimeOS` 是 `HarmonyOS`
- `openharmony` 的 `runtimeOS` 是 `OpenHarmony`

模块级 `entry/build-profile.json5` 当前 `abiFilters` 为：

```json5
"abiFilters": [
  "armeabi-v7a",
  "arm64-v8a"
]
```

因此：

- 当使用 `product=default` 编译时，会按 `HarmonyOS` 规则校验，`armeabi-v7a` 会报不支持
- 当使用 `product=openharmony` 编译时，可以保留 `armeabi-v7a`

## 已验证结果

执行以下命令后，`compileNative` 编译成功：

```powershell
"C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe" "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry -p product=openharmony compileNative --analyze=normal --parallel --incremental --daemon
```

并且生成了以下架构目录：

- `entry/build/openharmony/intermediates/cmake/default/obj/armeabi-v7a`
- `entry/build/openharmony/intermediates/cmake/default/obj/arm64-v8a`

## 使用建议

如果你的目标是 OpenHarmony：

1. 保留当前 `abiFilters`
2. 后续 native 编译、打包都使用 `-p product=openharmony`
3. 不要再用 `-p product=default` 去编译带 `armeabi-v7a` 的模块

## 说明

结合华为创建工程文档尾部的 OpenHarmony 说明，关键点不是删除 `armeabi-v7a`，而是新增并使用 `runtimeOS` 为 `OpenHarmony` 的产品配置。
