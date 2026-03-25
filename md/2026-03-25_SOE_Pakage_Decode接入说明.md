# SOE_Pakage_Decode 接入说明

## 这次做了什么

把 Qt 版本的 `Qclient::SOE_Pakage_Decode(...)` 按当前 `TcpClient` 单例结构接到了：

- [tcp_client.cpp](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/tcp_client.cpp)

## 当前工程里缺的那层怎么处理

你原函数里有这句：

```cpp
uint16_t typeSOE = SOEType_Search.typeSearch(Object_temp);
```

但当前工程里并没有：

- `SOEType_Search`
- `Date_type`
- `Time_type`

所以这次不是硬搬，而是按协议码本身来还原这层判断。

我用的是 `Object_temp` 的高四位标记：

- `0x1000` 对应 `SOE_StartMark`
- `0x2000` 对应 `SOE_ActMark`
- `0x3000` 对应 `SOE_ValueMark`
- `0x4000` 对应 `SOE_EventMark`

也就是：

- `SOE_StartMark` 按原来的 `Date_type` 分支处理
- `SOE_ActMark` 按原来的 `Time_type` 分支处理
- 其它值类型包继续按 `SOE_*DataLen` 判断是一值、二值还是三值

## 和原逻辑保持一致的地方

- `Data_Length` 仍然从 `(*pDecode) + 2` 位置读取
- `SOE` 分支仍然从对象地址开始解码，不额外提前挪偏移
- `SOE_Start_Struct / SOE_Act_Struct / SOE_3Value_Struct / SOE_2Value_Struct / SOE_1Value_Struct`
  仍然按原报文布局整体拷贝
- `SOE_Node_Queue` 仍然保留“队列未满才入队”的逻辑
- 末尾仍然是：

```cpp
(*pDecode) += 4;
(*pDecode) += Data_Length;
```

只是现在写成了等价的 `packetLength = 4 + Data_Length`

## 这次做的合理化改动

### 1. 去掉 Qt 临时全局对象

原函数依赖了这些 Qt 时代的临时变量：

- `SOE_StartInfo`
- `SOE_ActInfo`
- `SOE_3Val`
- `SOE_2Val`
- `SOE_1Val`
- `SOE_Node_Buf`

当前工程里不需要再把这些做成共享全局状态，所以改成了：

- 函数内局部结构体变量
- 解出一个包，就在局部生成一个 `SOE_Node_Struct`
- 再按原逻辑压入 `SOE_Node_Queue`

这样更符合现在的 C++ 单例结构，也避免多线程下共享临时对象带来的覆盖风险。

### 2. 给 SOE 解码补了边界保护

Qt 原代码默认 `buffer` 中数据一定完整，当前 native 版额外补了：

- `Data_Length` 是否能读到
- `4 + Data_Length` 是否越界

如果报文不完整，会直接停止本轮解码，不会继续解引用坏数据。

### 3. 事件类 SOE 先按“跳过”处理

你原函数里 `SOE_EventMark` 分支本来就是注释掉的。

所以这次保持同样结论：

- 事件类 SOE 暂不做业务落地
- 只记日志
- 偏移照常推进

这比伪造一个不完整解码更稳。

## 当前已经接好的 SOE 类型

- 启动类 SOE
- 动作类 SOE
- 三值 SOE
- 二值 SOE
- 一值 SOE

## 当前仍然没做的部分

- `SOE_EventMark` 的业务字段解释
- SOE 解码结果再进一步通知 ArkTS 或 UI

如果后面你把事件类 SOE 的原始 Qt 函数或字段定义继续贴出来，我可以继续按现在这套结构往里接。
