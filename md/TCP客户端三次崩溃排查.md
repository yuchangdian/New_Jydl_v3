# TCP客户端三次崩溃排查

## 崩溃现象

日志文件：

- `E:/baidu/arkTS_code/log_error/jscrash-com.example.new_jydl_v3-19700101110910.996.txt`

核心报错：

- `TypeError: Cannot read property startTcpClient of undefined`

堆栈位置：

- `loadTcpClientModule`
- `startNativeTcpClient`
- `EntryAbility` 页面加载回调

## 直接原因

这次不是 TCP 客户端线程崩溃，也不是 `libentry.so` 成功加载后执行崩溃。

直接原因是上一版为了诊断模块加载失败，我在 `EntryAbility.ets` 里新增了这类探测代码：

- `typeof tcpClientModule.startTcpClient`
- `typeof tcpClientModule.stopTcpClient`
- `typeof tcpClientModule.isTcpClientRunning`

但当前运行时里 `tcpClientModule` 本身就是 `undefined`，所以一旦执行到这几句，ArkTS 会先因为访问：

- `undefined.startTcpClient`

直接抛出 `TypeError`，应用因此崩溃。

也就是说：

1. 底层问题仍然是 native 模块没有成功拿到
2. 但这次“直接闪退”是诊断代码没有做空值保护导致的

## 已处理

已经把 `EntryAbility.ets` 里的模块探测改成空值安全：

- 增加 `getModuleMemberType(...)`
- 如果模块对象不存在，直接返回字符串 `undefined`
- 不再直接访问 `tcpClientModule.startTcpClient`

现在即使 native 模块仍然加载失败，也只会打印失败日志，不会再因为诊断代码本身崩溃。

## 当前状态

修复后重新执行 `assembleHap`：

- `BUILD SUCCESSFUL`

下一步需要重新安装最新 `hap`，再看新的 `JY_TCP_ARK` 日志输出。
