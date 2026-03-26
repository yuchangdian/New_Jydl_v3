# tcp_client 打印 PrimarySystemSetting 说明

## 本次修改

在 `entry/src/main/cpp/tcp_client.cpp` 里，收到一次系统参数并且 CRC 校验通过后，新增了 `PrimarySystemSetting` 的日志打印。

## 打印位置

位置在一次系统参数收包成功分支：

- `YT_ObjectAddr_CommonSetting_PrimarySystem`

处理流程现在是：

1. 收到报文
2. 拷贝到 `primarySystemBuf`
3. 做 CRC 校验
4. 校验通过后复制到 `PrimarySystemSetting`
5. `PrimarySystemSettingReady = true`
6. 打印 `CommonSetting_PrimarySystem updated`
7. 再调用 `LogPrimarySystemSetting(PrimarySystemSetting)`

## 打印内容

当前分 4 行打印：

1. 接地方式、母线 PT、母线零序 PT
2. 线路 PT、相别、保护 CT
3. 零序 CT、测量 CT
4. CT 接线方式、零序电流采集模式、线路额定容量、CRC

## 代码位置

- 新增日志函数：`entry/src/main/cpp/tcp_client.cpp`
- 调用位置：一次系统参数 `CRC` 校验通过后

## 构建结果

已重新执行：

- `assembleHap --analyze=normal --parallel --incremental`

结果：

- `BUILD SUCCESSFUL`
