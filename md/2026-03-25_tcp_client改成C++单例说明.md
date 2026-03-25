# tcp_client 改成 C++ 单例说明

## 这次改动

这次把原来的全局变量 + C 函数实现，改成了：

- `TcpClient` 单例类

对外接口保持不变，下面这些函数名还在：

- `tcp_client_start`
- `tcp_client_stop`
- `tcp_client_is_running`
- `tcp_client_send`

也就是说：

- ArkTS 不用改
- `napi_init.cpp` 不用改调用方式

## 现在的结构

### 对外层

头文件仍然是：

- `tcp_client.h`

它继续暴露 C 接口，给 `napi_init.cpp` 调用。

### 实现层

原来的：

- `tcp_client.c`

已经切成：

- `tcp_client.cpp`

内部用 `TcpClient::GetInstance()` 返回唯一实例。

## 为什么这样改

原来这部分逻辑依赖很多全局变量：

- 线程句柄
- socket fd
- 运行状态
- 目标主机和端口

改成单例后，这些状态全部收口到一个对象里，后面继续扩展：

- 已连接状态
- 发送队列
- 重连策略
- 回调通知

会更清楚。

## 构建变化

`CMakeLists.txt` 里已经从：

- `tcp_client.c`

切到：

- `tcp_client.cpp`

这样编译器会按 C++ 方式编译这个 TCP 客户端实现。
