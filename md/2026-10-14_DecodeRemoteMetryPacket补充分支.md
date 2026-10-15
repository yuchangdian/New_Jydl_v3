# DecodeRemoteMetryPacket 补充分支

按用户本轮指定，只补充其已添加的谐波、间谐波和波形包解析，保持原函数签名和 Qt 的对象名称、逐个 case、sizeof 检查及结构体赋值写法。

## 代码位置

- `entry/src/main/cpp/tcp_client.cpp`：`DecodeRemoteMetryPacket()` 中增加 18 个分支，分别写入 `Package_HD_Ua1` 至 `Package_HD_Ic1`、`Package_IHD_Ua1` 至 `Package_IHD_Ic1`、`Package_PlotBuf_Ua1` 至 `Package_PlotBuf_Ic1`。
- `entry/src/main/cpp/IEC104.h`：保留用户已加入的两个包结构及 extern 声明，补齐对应的 18 个原名地址宏。
- `entry/src/main/cpp/data.cpp`：补齐这 18 个 extern 缓冲的实例定义。
- `entry/src/main/cpp/powerquality.h`：去掉未使用的 QString 依赖，修正与 quality.h 重名的头文件保护宏；已有的 PQSettingUnit 和 PowerQualitySetting_struct 直接包含 quality.h 复用，避免重复定义及 PowerQualitySetting 全局名称冲突。谐波数据结构字段不变。

## 帧起点和长度

参考 Qt `qserialclient.cpp` 的 `RemoteMetry_Decode(Object_temp, Length_temp + 6, DecodeBuf)`：

- Qt 的 DecodeBuf 从公共地址开始，包含 6 字节包头。
- 当前函数在读完 Length 后，payloadOffset 已指向载荷；因此新增结构从 `payloadOffset - 6` 处赋值，DecodeLength 为 `payloadLength + 6`。
- 谐波及间谐波完整包 517 字节，Length 为 511；每路保留 Rms[63]、Angle[63] 及时间字段。
- 波形完整包 813 字节，Length 为 807；每路保留 400 个有符号 int16_t。绘图读取时再转浮点除以 100，接收缓冲不预先缩放。
- 长度不匹配时记录警告、保留原缓冲，并按原函数逻辑推进游标，不影响下一包。

原分发中 0x1311 报文会提前进入已有 PacketStore；为使新增分支可达，只将上述 18 个对象同时交给本函数。波形继续更新原 PacketStore，以保持原有页面读取路径。0x0011 报文仍走原来的遥测分发。

本轮没有改动 protocol/jybsmr131 目录、NAPI、ArkTS 页面、函数签名或导入脚本。

## 验证

- 直接编译并执行实际 tcp_client.cpp：18 路在 0x0011、0x1311 两种公共地址下均通过；逐项检查时间、63 个幅值和角度、全部 400 个有符号采样点，覆盖包头拆分、多帧连续接收、非零帧起点、错误长度保留旧数据。
- 原有新版波形缓存及除以 100 的数值读取验证通过。
- 原有 native 协议回归 6 组通过。
- OpenHarmony default debug HAP 编译及签名成功。
- 未进行实际设备 TCP 联调。

临时解析测试位于已忽略的 `tests/.build/current-metry/`，没有新增正式测试接口。
