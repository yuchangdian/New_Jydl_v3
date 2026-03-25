# tcp_client 接收解码框架接入说明

## 这次做了什么

这次把你给的 `Qclient::rec_message_client()` 逻辑，按当前项目的 C++ 单例结构接到了：

- [tcp_client.cpp](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/tcp_client.cpp)

## 转换思路

原函数的核心逻辑其实是 3 件事：

1. 取到一批收到的原始字节
2. 拷进 `buffer`
3. 按 `Common_Addr_*` 分发到不同解码函数

我在当前 `TcpClient` 里把它拆成了这些方法：

- `HandleReceivedBytes(...)`
- `DispatchDecodedFrames()`
- `TryReadUint16(...)`
- `DecodeRemoteMetryPacket(...)`
- `DecodeRemoteSignalPacket(...)`
- `DecodeRemoteAdjustPacket(...)`
- `DecodeSoePackage(...)`

## 为什么没有照搬 `cond_.wait(...)`

你给的 Qt 版本前半段是：

- 等条件变量
- 等 `read_if == true`
- 然后 `readAll()`

但当前这个项目里的 `tcp_client.cpp` 已经有独立接收线程，而且线程本身就在阻塞 `recv(...)`。

所以在这里：

- `recv(...)` 本身就已经承担了“等数据到来”的作用

也就是说，条件变量那一层在当前架构里不需要再照搬。

## 这次是怎么嵌进去的

现在 `ThreadMain()` 里收到数据后，不再把数据当普通字符串打印，而是：

1. 记录收到的字节数
2. 调 `HandleReceivedBytes(...)`
3. 把数据复制到类成员缓冲区
4. 再走 `DispatchDecodedFrames()` 做分发

## 和原逻辑保持一致的地方

下面这些点我保留了原来的思路：

- 仍然使用 4096 大小的接收/解码缓冲区
- 仍然先读 `Common_temp`
- 仍然再读 `Object_temp`
- `RemoteMetry / RemoteSignal / RemoteAdjust` 分支仍然在进入解码前额外前移 2 字节
- `SOE` 分支仍然保持原来那种不先额外前移 2 字节的偏移逻辑
- 遇到未知 `Common_Addr_*` 就停止本轮解析

## 当前还没接上的部分

仓库里现在没有这些函数的实现：

- `RemoteMetry_Decode`
- `RemoteSignal_Decode`
- `RemoteAdjust_Decode`
- `SOE_Pakage_Decode`

所以这次我只能把：

- 接收框架
- 偏移推进逻辑
- 报文分发结构

先搭好。

目前分支状态是：

- `RemoteMetry_Decode` 已经按你提供的函数接入
- `RemoteSignal_Decode` 已经按你提供的函数接入
- `RemoteAdjust_Decode` 已经按你提供的函数接入
- `SOE_Pakage_Decode` 仍是占位

其中 `RemoteMetry_Decode` 的适配方式是：

- 原来的 `BaseFreq_Val` 改成当前工程里的 `BaseFreq_Dsip`
- 原来的 `Energy_Val` 改成当前工程里的 `Energy_Dsip`
- 原来的 `HarmonicU_Val` 改成当前工程里的 `HarmonicU_Dsip`
- 原来的 `HarmonicI_Val` 改成当前工程里的 `HarmonicI_Dsip`
- Qt 的 `emit` 和 `qDebug` 改成当前 native 层可用的日志输出

其中 `RemoteSignal_Decode` 的适配方式是：

- CRC 校验、长度校验、对象地址分类逻辑都已保留
- `YX_Change_Queue` 改成当前工程里的 `std::deque`，并沿用 `DATA_QUEUE_MAX_LENGTH`
- `DigitalInputData` 和 `BreakerState_Now` 的状态更新已接入
- Qt 的 `emit signal_Confirm_*` 当前工程没有对应实现，所以先改成日志
- `Led_Set->turnOn/turnOff...` 当前工程没有对应对象，所以先改成日志
- 你提供的 `RemoteSignal_LED_Triping` 分支我按明显语义缺口补成了 `case RemoteSignal_LED_Triping:`

其中 `RemoteAdjust_Decode` 的适配方式是：

- 一次系统定值、软压板、保护定值区号、保护定值、模拟量定值这 5 个分支都已接入
- CRC32 校验逻辑已保留
- 你原来依赖的 `CommonSetting_PrimarySystem_Buf / CommonSetting_AnalogQuantity_Buf / RelaySetting_Buf`
  当前工程没有完整可用定义，所以改成了函数内局部临时结构
- CRC 校验通过后，再写回当前工程真实存在的全局配置对象
- `YT_ObjectAddr_RelaySetting` 分支按当前报文结构使用“前 2 字节为定值区号，后续为 RelaySetting_Struct”来处理
- Qt 的 `qDebug` 已替换成 native 日志

其它三个分支目前先接的是“安全占位”：

- 会打日志
- 会结束本轮解析
- 不会假装做了业务解码

## 你下一步真正要补什么

如果你后面要把业务真正跑起来，下一步应该补的是：

1. 把 Qt 版本里的 4 个解码函数迁进当前工程
2. 再把 `DecodeRemoteMetryPacket(...)` 等占位函数替换成真实解码调用
3. 如果原解码依赖全局 `buffer` / `p_BufSave`，要一起改成当前 `TcpClient` 的成员缓冲区写法

## 一句话结论

这次已经把“接收数据 -> 拷贝缓冲区 -> 按公共地址分发”的骨架接进 `TcpClient` 了。

现在缺的不是接收框架，而是你原来 Qt 版本里的那 4 个业务解码函数本体。
