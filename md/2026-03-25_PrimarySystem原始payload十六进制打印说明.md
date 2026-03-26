# PrimarySystem 原始 payload 十六进制打印说明

## 本次修改

在 `entry/src/main/cpp/tcp_client.cpp` 中，给一次系统参数包增加了原始 payload 十六进制日志。

## 打印位置

位置在：

- `YT_ObjectAddr_CommonSetting_PrimarySystem`

处理分支里，`memcpy` 到 `primarySystemBuf` 之前。

现在顺序是：

1. 先打印原始 payload 长度
2. 按每行 16 字节打印十六进制内容
3. 再拷贝到 `primarySystemBuf`
4. 再做 CRC 校验
5. 校验通过后继续打印 `PrimarySystemSetting` 解析后的字段值

## 日志格式

会多出类似下面的日志：

```text
PrimarySystem raw payload length=72
PrimarySystem raw[000]: FF FF FF FF ...
PrimarySystem raw[016]: FF FF FF FF ...
```

## 用途

这样可以直接判断：

- 是不是设备原始下发的数据本身就是全 `FF`
- 还是某一段字段错位
- 还是只有 CRC 正好等于 `0xFFFFFFFF`

## 构建结果

已重新执行：

- `assembleHap --analyze=normal --parallel --incremental`

结果：

- `BUILD SUCCESSFUL`
