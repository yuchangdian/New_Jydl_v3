# TCP 客户端二次崩溃排查

## 崩溃日志

日志文件：

`E:/baidu/arkTS_code/log_error/jscrash-com.example.new_jydl_v3-19700103151433.003.txt`

关键信息：

1. `Reason: TypeError`
2. `Error message: Cannot read property isTcpClientRunning of undefined`
3. 触发位置在 `EntryAbility.startNativeTcpClient`

## 原因

这次和上一次不同。

上一次是 `libentry.so` 的命名导出绑定失败，这一次是默认导入变量本身就是 `undefined`，所以在调用：

`tcpClientModule.isTcpClientRunning()`

时直接崩溃。

说明当前这台 OpenHarmony 5.1 设备运行时，对 `import tcpClientModule from 'libentry.so'` 这种写法没有正确返回 native 模块对象。

## 已处理

我已经不再依赖 ES 的 `.so` 导入结果，而是改为在运行时显式调用 NAPI 加载：

1. `requireNapi('entry', true, 'com.example.new_jydl_v3/entry')`
2. `requireNapi('entry', true)`
3. `requireNapi('entry')`

并增加空值保护：

1. 如果模块没取到，记录日志并直接返回
2. 不再因为 `undefined.isTcpClientRunning()` 这种调用导致界面崩溃

## 验证

已重新执行 `assembleHap`，结果为：

`BUILD SUCCESSFUL`

## 结论

第二次崩溃的直接原因是 `libentry.so` 默认导入结果为 `undefined`，不是 TCP 客户端线程本身崩溃。
