# TCP 客户端崩溃原因排查

## 崩溃日志

日志文件：

`E:/baidu/arkTS_code/log_error/jscrash-com.example.new_jydl_v3-19700103150651.709.txt`

关键信息：

1. `Reason: SyntaxError`
2. `Error message: the requested module '@normalized:Y&&&libentry.so&' does not provide an export name 'isTcpClientRunning'`
3. 崩溃位置在 `entryability/EntryAbility` 导入 `libentry.so` 之后、调用 `startNativeTcpClient` 之前。

## 原因

这次不是 TCP 连接失败，也不是 C 线程崩溃。

实际原因是 ArkTS 在加载 `libentry.so` 时，使用了命名导入：

`import { isTcpClientRunning, startTcpClient, stopTcpClient } from 'libentry.so'`

当前设备运行时在处理这个 native so 模块的命名导出绑定时，认为 `isTcpClientRunning` 不存在，因此在界面初始化阶段直接抛出 `SyntaxError`，应用还没真正进入 TCP 逻辑就已经崩了。

## 已处理

我已经把导入方式改成更稳妥的默认导入：

`import tcpClientModule from 'libentry.so'`

然后改为：

1. `tcpClientModule.isTcpClientRunning()`
2. `tcpClientModule.startTcpClient(...)`
3. `tcpClientModule.stopTcpClient()`

同时把 `Index.d.ts` 改成默认导出对象声明，避免类型层和运行时导入模型不一致。

## 验证

已重新执行 `assembleHap`，结果为：

`BUILD SUCCESSFUL`

## 结论

这次报错的直接原因是 `libentry.so` 的 ArkTS 导入方式，而不是 TCP 客户端 C 代码本身。
