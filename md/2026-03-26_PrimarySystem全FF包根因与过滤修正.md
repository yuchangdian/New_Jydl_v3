# PrimarySystem 全 FF 包根因与过滤修正

## 结论

已经确认：

- `CommonSetting_PrimarySystem` 的原始 payload 长度为 72 字节
- 72 字节全部都是 `FF`

这说明问题不在 ArkTS 页面，也不在 `memcpy` 解析本身，而在于：

- 对端下发的这帧一次系统参数数据本身就是全 `FF`

## 为什么之前还能通过 CRC

当前 CRC 计算方式是按 `uint32_t` 做逐字异或：

- `data.h` 里的 `CRC32(...)`

`CommonSetting_PrimarySystem_Struct` 总长度是 72 字节，也就是 18 个 4 字节字段。

其中：

- 前 17 个 4 字节字段参与 CRC
- 最后 1 个 4 字节字段是包内 CRC

如果前 17 个字段全是：

- `0xFFFFFFFF`

那么 17 次异或结果仍然是：

- `0xFFFFFFFF`

而包里的 CRC 也正好是：

- `0xFFFFFFFF`

所以这类“全 FF 空包”会错误地通过当前 CRC 校验。

## 对应到打印值

- `4294967295` = `0xFFFFFFFF`
- `-nan` = 把 `0xFFFFFFFF` 当作 `float` 解释后的结果

所以之前看到：

- `grounding=4294967295`
- `phase=4294967295`
- `ctMode=4294967295`
- `ioMode=4294967295`
- 所有浮点都是 `-nan`

本质都是同一个原因。

## 已做修正

在：

- `entry/src/main/cpp/tcp_client.cpp`

里新增了两部分：

### 1. 原始 payload 十六进制打印

现在收到一次系统参数包时，会先把原始 72 字节按十六进制打印出来。

### 2. 全 FF 包过滤

如果检测到：

- 整个一次系统参数 payload 全部为 `0xFF`

则直接记录：

- `CommonSetting_PrimarySystem payload is all 0xFF, ignored as invalid`

并且：

- 不再写入 `PrimarySystemSetting`
- 不再把 `PrimarySystemSettingReady` 当成这次数据已更新

## 当前意义

这说明：

- 解析代码本身没有把正常值“算坏”
- 现在收到的就是一帧无效的一次系统参数数据

后面如果要继续追根因，方向应该转到：

- 设备端为什么在这个时机返回全 `FF`
- 这是不是“未整定 / 未读取成功 / 占位响应 / 异常响应”

## 构建结果

已重新执行：

- `assembleHap --analyze=normal --parallel --incremental`

结果：

- `BUILD SUCCESSFUL`
