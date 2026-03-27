## 本次改动

在 `tcp_client.cpp` 里新增了两组收到后立即打印的日志：

- 遥测参数定值 `CommonSetting_TeleMeasuring`
- 模拟量参数定值 `CommonSetting_AnalogQuantity`

打印时机都是：

1. 收到对应报文
2. 长度正确
3. CRC 校验通过
4. 成功写入全局 struct 之后

## 日志函数

新增函数：

- `LogAnalogQuantityParameter(...)`
- `LogAnalogQuantitySetting(...)`
- `LogTeleMeasuringSetting(...)`

位置在：

- `entry/src/main/cpp/tcp_client.cpp`

## 模拟量打印内容

`AnalogQuantitySetting` 按三组打印：

- `Reference`
- `Correction`
- `ZeroDrift`

每组又分 4 行：

- `U=(Ua,Ub,Uc,Uo)`
- `protectI=(IA,IB,IC,Io)`
- `measureI=(Ia,Ib,Ic,Is)`
- `extra=(Ux,Iby1,Iby2,Iby3)`

最后再打印：

- `crc`

## 遥测参数打印内容

`TeleMeasuringSetting` 打 2 行：

- `cycle / primaryEnergy / freq / acV / dcV`
- `acI / power / powerFactor / crc`

## 调用位置

模拟量参数定值更新成功后：

- `CommonSetting_AnalogQuantity updated`
- 然后调用 `LogAnalogQuantitySetting(AnalogQuantitySetting)`

遥测参数定值更新成功后：

- `CommonSetting_TeleMeasuring updated`
- 然后调用 `LogTeleMeasuringSetting(TeleMeasuringSetting)`

## 你在日志里会看到的关键字

- `AnalogQuantitySetting Reference`
- `AnalogQuantitySetting Correction`
- `AnalogQuantitySetting ZeroDrift`
- `TeleMeasuringSetting`

日志标签仍然是：

- `JY_TCP_NATIVE`

## 验证结果

已执行：

`assembleHap --analyze=normal --parallel --incremental`

结果：

`BUILD SUCCESSFUL`
