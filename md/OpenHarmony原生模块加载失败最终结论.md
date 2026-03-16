# OpenHarmony 原生模块加载失败最终结论

## 1. 现象

设备日志稳定输出：

```text
JY_TCP_ARK: 加载TCP客户端 native 模块失败: import=undefined/undefined/undefined, require1=undefined, require2=undefined, require3=undefined
```

这说明问题已经不是：

- ArkTS 导入写法不对
- `Index.d.ts` 类型声明不对
- `startTcpClient`、`stopTcpClient`、`isTcpClientRunning` 的命名导出不匹配

而是运行时根本没有把 `libentry.so` 注册成可用模块。

## 2. 已确认的关键证据

### 2.1 设备环境

- 设备系统：`OpenHarmony-5.1.0.108`
- API 版本：`18`
- CPU 架构：`aarch64`

### 2.2 包内容

- `libentry.so` 已经实际打进 HAP
- 设备中安装的 HAP 与本地最新 HAP 哈希一致
- 说明设备运行的不是旧包

### 2.3 当前 HAP 的编译目标

解包后的 `module.json` 里可见：

```json
"compileSdkType":"HarmonyOS",
"compileSdkVersion":"6.0.1.112",
"targetAPIVersion":60001021
```

这说明当前装到设备上的包，是按 `HarmonyOS` 产品编译出来的，不是按 `OpenHarmony` 产品编译出来的。

## 3. 根因

当前工程此前一直是：

- `runtimeOS: "HarmonyOS"`
- `targetSdkVersion: "6.0.1(21)"`

但真机是：

- `OpenHarmony 5.1.0(18)`

这个组合下，应用虽然能安装和启动，但 bundled native 模块 `libentry.so` 没有在 OpenHarmony 设备上被正确注册，所以：

- `import * as tcpClientModule from 'libentry.so'` 得到 `undefined`
- `requireNapi('entry', ...)` 也全部得到 `undefined`

## 4. 已做修复

已经把项目根 [build-profile.json5](/E:/baidu/arkTS_code/New_Jydl_v3/build-profile.json5) 调整为 OpenHarmony 产品配置：

```json5
"type": "OpenHarmony"
"compileSdkVersion": "5.1.0(18)"
"targetSdkVersion": "5.1.0(18)"
"compatibleSdkVersion": "5.1.0(18)"
"runtimeOS": "OpenHarmony"
```

模块级 [entry/build-profile.json5](/E:/baidu/arkTS_code/New_Jydl_v3/entry/build-profile.json5) 仍保留：

```json5
"arkOptions": {
  "runtimeOnly": {
    "packages": [
      "libentry.so"
    ]
  }
}
```

这就是正确的修复方向。

## 5. 关于 5.1.0.107 和 5.1.0.108

这里需要纠正一个版本表述。

- 设备系统版本是 `OpenHarmony-5.1.0.108`
- 本机当前实际安装到 `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony` 的 SDK 组件版本是 `6.0.1.112`

也就是说，前面提到的 `5.1.0.107` 不是“本机已经安装的 SDK 版本”，而是 hvigor 在为 `compileSdkVersion: 5.1.0(18)` 解析 OpenHarmony API 18 组件时给出的提示文案。

**真正关键的不是必须拿到 `5.1.0.107`，而是要安装并接受 OpenHarmony `5.1.0(18)` 对应 SDK 的 license。**

如果你的 SDK Manager 里只有 `5.1.0.108`，那就直接使用 `5.1.0.108`，不需要执着于 `5.1.0.107` 这个补丁号。

## 6. 当前唯一阻塞点

切到 OpenHarmony 产品后，`assembleHap` 构建不再报代码错误，而是被 SDK 环境拦住：

```text
The SDK license agreement is not accepted.
```

进一步检查可知：

- 本机已安装 `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony`
- 但不存在 `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\licenses`

也就是说，这台机器的 OpenHarmony 5.1 SDK 组件已经在磁盘上，但 license 接受状态没有完成，所以 hvigor 拒绝继续构建。

## 7. 你现在只需要做的事

在 DevEco Studio 中执行：

1. 打开 `File > Settings > OpenHarmony SDK`
2. 找到并重新下载或重新应用 OpenHarmony `5.1.0(18)` 对应组件
3. 在弹窗中接受 license

如果你的界面里显示的是 `5.1.0.108`，就直接选 `5.1.0.108`。

需要确认的组件：

- `Toolchains`
- `ArkTS`
- `JS`
- `Native`
- `Previewer`

完成后要确认目录里出现：

```text
C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\licenses
```

并且里面有若干 `.sha256` 文件，这表示 license 已经接受成功。

## 8. 完成后如何验证

完成 license 接受后，重新构建并安装应用，再看日志。

正确情况下不应再出现：

```text
加载TCP客户端 native 模块失败: import=undefined/undefined/undefined, require1=undefined, require2=undefined, require3=undefined
```

而应该出现类似：

```text
JY_TCP_ARK: 已通过 libentry.so 导入加载TCP客户端 native 模块
JY_TCP_ARK: TCP客户端启动结果: success
JY_TCP_NATIVE: 已连接到服务端
```

## 9. 结论

这次问题的最终根因已经明确：

**不是 TCP 客户端代码错，也不是 ArkTS 调用错，而是应用包之前一直按 HarmonyOS 产品编译，导致 OpenHarmony 5.1 真机无法加载 `libentry.so`。**

现在代码和产品配置都已经朝正确方向改完，剩下就是把本机 OpenHarmony SDK license 接受掉，然后重新构建出真正的 OpenHarmony 包。
