# tcp_client 类声明与实现分离说明

## 这次调整

这次把 `TcpClient` 调整成了更标准的 C++ 结构：

- [tcp_client.h](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/tcp_client.h)
  只放类声明、成员声明、接口声明
- [tcp_client.cpp](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/tcp_client.cpp)
  只放成员函数实现

## 和上一版的区别

上一版虽然内部已经是单例思路，但类定义和实现都堆在 `.cpp` 里，
外部调用仍然走：

- `tcp_client_start`
- `tcp_client_stop`
- `tcp_client_is_running`
- `tcp_client_send`

这会让“单例类”更像内部包装，而不是项目真正使用的主接口。

这次改完后，调用方 [napi_init.cpp](/E:/baidu/arkTS_code/New_Jydl_v3/entry/src/main/cpp/napi_init.cpp)
已经直接调用：

- `TcpClient::GetInstance().Start(...)`
- `TcpClient::GetInstance().Stop()`
- `TcpClient::GetInstance().IsRunning()`
- `TcpClient::GetInstance().Send(...)`

这样单例类才是实际被使用的接口主体。

## 结果

现在这部分代码更符合常规 C++ 组织方式：

1. 头文件负责声明类
2. cpp 文件负责实现成员函数
3. 调用方直接依赖类接口
4. 单例模式真正成为主入口，而不是包在 C 函数后面
