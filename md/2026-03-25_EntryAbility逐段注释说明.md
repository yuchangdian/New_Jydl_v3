# EntryAbility 逐段注释说明

## 这次做了什么

这次只处理了：

- [EntryAbility.ets](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/ets/entryability/EntryAbility.ets)

处理方式是：

- 重写文件内注释
- 保持原有函数结构不变
- 保持原有调用顺序不变
- 不改生命周期流程

## 现在这份文件的阅读顺序

建议你按下面顺序读：

1. 先看常量区
2. 再看 `TcpClientModule` 接口声明
3. 再看 `loadTcpClientModule()`
4. 再看 `startNativeTcpClient()` / `stopNativeTcpClient()`
5. 最后看生命周期函数

## 各函数的职责

### `getModuleMemberType()`

用于调试 native 模块导出情况。

### `isValidTcpClientModule()`

用于判断当前拿到的对象是不是一个可用的 TCP native 模块。

### `loadTcpClientModule()`

用于按顺序尝试加载 `libentry.so` / `requireNapi('entry')`，并缓存成功结果。

### `startNativeTcpClient()`

用于从 ArkTS 层触发 native TCP 客户端启动。

### `stopNativeTcpClient()`

用于从 ArkTS 层触发 native TCP 客户端停止。

### `onCreate()`

应用初始化入口。

### `onWindowStageCreate()`

界面真正启动入口。

### `onDestroy()` / `onWindowStageDestroy()`

退出时的资源回收入口。

## 下一步建议

如果你要继续做“逐函数、逐段中文注释版”，最合适的顺序是：

1. [Index.ets](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/ets/pages/Index.ets)
2. [napi_init.cpp](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/napi_init.cpp)
3. [tcp_client.c](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/tcp_client.c)

这样会和实际运行链路保持一致。
