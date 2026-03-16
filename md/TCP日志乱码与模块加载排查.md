# TCP 日志乱码与模块加载排查

## 1. 日志为什么是乱码

`hdc hilog` 输出的是 UTF-8 日志，但 Windows PowerShell 默认常常按本地代码页解析，所以会把：

- `首页加载成功`

显示成：

- `棣栭〉鍔犺浇鎴愬姛`

这不是应用日志内容坏了，而是终端解码错了。

本次处理：

- 在 `看TCP日志.ps1` 里强制切到 UTF-8
- 继续使用本地 tag 过滤，只看 `JY_TCP_ARK`、`JY_TCP_NATIVE`、`JY_ENTRY`

## 2. 为什么 native 模块一直加载失败

日志可读之后，真正的问题变成了：

`加载TCP客户端 native 模块失败: entry, com.example.new_jydl_v3/entry`

排查结果：

1. `libentry.so` 已经成功打进 `hap`
2. `napi_init.cpp` 里的模块注册名也是 `entry`
3. 但模块构建配置里缺少 `arkOptions.runtimeOnly.packages`

在当前 HarmonyOS / OpenHarmony 构建链路下，仅仅在 `oh-package.json5` 里声明 `libentry.so` 依赖还不够，还需要把它放进模块的运行时包配置，否则运行时可能拿不到这个 NAPI 包。

本次处理：

- 在 `entry/build-profile.json5` 里新增：

```json5
"arkOptions": {
  "runtimeOnly": {
    "packages": [
      "libentry.so"
    ]
  }
}
```

- `EntryAbility.ets` 恢复为官方支持的：

```ts
import tcpClientModule from 'libentry.so';
```

而不是继续走不稳定的动态 `requireNapi` 变量调用。

## 3. 第二层根因

补上 `runtimeOnly.packages` 之后，日志从：

- `加载TCP客户端 native 模块失败: entry, com.example.new_jydl_v3/entry`

变成了：

- `加载TCP客户端 native 模块失败: libentry.so`

这说明运行时已经开始按 `libentry.so` 解析了，但导入对象本身还是不对。

继续排查后确认：

1. `napi_init.cpp` 实际导出的属性是命名导出：
   - `startTcpClient`
   - `stopTcpClient`
   - `isTcpClientRunning`
2. 但 `entry/src/main/cpp/types/libentry/Index.d.ts` 之前写成了：
   - `export default tcpClientModule`
3. ArkTS 入口又写成了：
   - `import tcpClientModule from 'libentry.so'`

这会让类型声明和 native 实际导出模型不一致，运行时拿到的默认导入对象可能是 `undefined`。

本次处理：

- `Index.d.ts` 改成命名导出
- `Libentry.mock.ets` 也改成命名导出，和真实 native 导出保持一致
- `EntryAbility.ets` 改成：

```ts
import * as tcpClientModule from 'libentry.so';
```

也就是“命名导出 + 命名空间导入”这一套，避免继续依赖 default export 适配。

## 4. 当前结果

重新执行 `assembleHap` 后结果为：

`BUILD SUCCESSFUL`

说明目前：

- ArkTS 代码可编译
- native so 已参与打包
- `runtimeOnly` 配置已生效
- ArkTS 的导入方式已和 native 实际导出保持一致

下一步只需要重新安装最新 `hap`，再用 `看TCP日志.ps1` 观察实际启动日志。

## 5. 参考

官方文档提到 `libentry.so` 需要配合 `runtimeOnly.packages` 使用：

[OpenHarmony 官方文档](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/napi/use-napi-load-module-with-info.md)

## 6. 新增诊断链路

在仍然无法导入 `libentry.so` 的情况下，已经把 `EntryAbility.ets` 改成三层探测：

1. `import * as tcpClientModule from 'libentry.so'`
2. `requireNapi('entry', true, 'com.example.new_jydl_v3/entry')`
3. `requireNapi('entry', true)` 和 `requireNapi('entry')`

失败时会直接输出：

- `import` 这条链路上三个函数的 `typeof`
- 三个 `requireNapi` 调用各自是否拿到有效模块

这样下一次日志不再只有“加载失败”，而是能直接看出是哪一层失效。

## 7. 设备环境结论

设备查询结果：

- `const.ohos.fullname = OpenHarmony-5.1.0.108`
- `const.ohos.apiversion = 18`
- CPU 架构是 `aarch64`

同时设备中已安装的 `entry.hap` 与本地最新构建包哈希一致，说明设备上跑的确实是最新包，不是旧包残留。

## 8. OpenHarmony 配置实验

做过一次进一步验证：

- 把根 `build-profile.json5` 的 `runtimeOS` 从 `HarmonyOS` 切到 `OpenHarmony`

构建器立刻要求显式配置 OpenHarmony 的 `compileSdkVersion`，继续补上之后，又被本机 OpenHarmony SDK license 未接受拦住，无法在当前机器上完成这条路线的构建验证。

所以当前保留的是：

- 可以正常编译出包的 HarmonyOS 产品配置
- 外加更细的 native 模块多链路探测日志

## 9. 目前最可能的最终根因

最新诊断日志已经表明：

- `import * as tcpClientModule from 'libentry.so'` 返回 `undefined`
- `requireNapi('entry', true, 'com.example.new_jydl_v3/entry')` 返回 `undefined`
- `requireNapi('entry', true)` 返回 `undefined`
- `requireNapi('entry')` 返回 `undefined`

这说明问题已经不是：

- 导出函数名不匹配
- `Index.d.ts` 写法不对
- 代码里调用方式不对

而是运行时根本没有把 `libentry.so` 注册成可用模块。

结合以下事实：

- 设备是 `OpenHarmony-5.1.0.108`
- 工程产品当前仍是 `runtimeOS: HarmonyOS`
- 官方和社区的 OpenHarmony NAPI 工程示例都使用 `runtimeOS: OpenHarmony`

当前最可能的最终根因是：

**工程是按 HarmonyOS 产品配置打包的，但真机是 OpenHarmony 5.1，导致 bundled native 模块在 OpenHarmony 设备上没有被正确解析加载。**

## 10. 解决方案

需要把工程产品配置切到 OpenHarmony，并使用 OpenHarmony 5.1 SDK 重新构建。

建议的项目级 `build-profile.json5` 产品配置如下：

```json5
{
  "name": "default",
  "signingConfig": "default",
  "compileSdkVersion": "5.1.0(18)",
  "targetSdkVersion": "5.1.0(18)",
  "compatibleSdkVersion": "5.1.0(18)",
  "runtimeOS": "OpenHarmony",
  "buildOption": {
    "nativeCompiler": "BiSheng",
    "strictMode": {
      "caseSensitiveCheck": true,
      "useNormalizedOHMUrl": true
    }
  }
}
```

同时保留模块级 `entry/build-profile.json5` 里的：

```json5
"arkOptions": {
  "runtimeOnly": {
    "packages": [
      "libentry.so"
    ]
  }
}
```

## 11. 当前机器上的阻塞点

这条路线我已经本地验证过方向是对的，但当前机器在切到 OpenHarmony 后被 SDK 环境拦住了：

- 构建器要求显式配置 `compileSdkVersion`
- 补上后，又提示 OpenHarmony 5.1 SDK license 未接受

所以当前机器要先做两件事：

1. 在 DevEco Studio 的 SDK Manager 里安装并启用 OpenHarmony 5.1 SDK
2. 接受 OpenHarmony 5.1 SDK license

完成这两步后，再切换到上面的 OpenHarmony 产品配置重新打包。
