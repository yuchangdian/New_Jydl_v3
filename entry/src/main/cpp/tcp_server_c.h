#ifndef TCP_SERVER_C_H
#define TCP_SERVER_C_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define TCP_SERVER_DEFAULT_PORT 2404
typedef void (*tcp_server_receive_callback)(const unsigned char *data, size_t length, void *context);
typedef void (*tcp_server_connection_callback)(int connected, void *context);

// C 接口与 TcpServer::GetInstance() 使用同一个实例。成功返回 1，失败返回 0。
int tcp_server_start(uint16_t port);
void tcp_server_stop(void);
int tcp_server_is_running(void);
int tcp_server_is_client_connected(void);
int tcp_server_send(const void *data, size_t length);
// 收到的是 TCP 字节块，需由业务方组帧。注册新的回调会替换之前的回调。
// 注销后仍可能有正在执行的回调；释放 context 前应从业务线程 stop 并等待完成。
void tcp_server_set_receive_callback(tcp_server_receive_callback callback, void *context);
void tcp_server_set_connection_callback(tcp_server_connection_callback callback, void *context);

#ifdef __cplusplus
}
#endif
#endif
