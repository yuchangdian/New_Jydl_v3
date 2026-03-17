## 问题现象

执行 `compileNative` 时失败，报错如下：

- `hvigor ERROR: 00303114 Configuration Error`
- `"armeabi-v7a" not supported for HarmonyOS`

## 直接原因

文件 `entry/build-profile.json5` 的 `externalNativeOptions.abiFilters` 当前配置为：

```json5
"abiFilters": [
  "armeabi-v7a",
  "arm64-v8a"
]
```

其中 `armeabi-v7a` 属于 Android 常见 ABI，不适用于当前 HarmonyOS 原生编译配置，因此 hvigor 在配置检查阶段直接失败。

## 当前工程判断

- `entry/src/main/cpp/CMakeLists.txt` 仅编译源码 `napi_init.c` 和 `tcp_client.c`
- 当前没有发现额外的预编译第三方 `so`
- 因此本次问题不是 CMake 逻辑错误，而是 `abiFilters` 配置包含了不支持的架构

## 建议修改方向

- 从 `entry/build-profile.json5` 的 `abiFilters` 中删除 `armeabi-v7a`
- 先只保留 `arm64-v8a` 再次编译
- 如果后续你的运行目标是模拟器，再根据模拟器架构决定是否补充其它 HarmonyOS 支持的 ABI

## 修改后重点验证

1. 重新执行 `compileNative`
2. 确认生成目录下是否出现 `arm64-v8a/libentry.so`
3. 如果后续出现链接或运行时问题，再继续排查是否有目标设备架构不匹配
