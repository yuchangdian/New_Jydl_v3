#ifndef TCP_CLIENT_H
#define TCP_CLIENT_H

#ifdef __cplusplus
extern "C" {
#endif

int tcp_client_start(const char *host, int port);
void tcp_client_stop(void);
int tcp_client_is_running(void);

#ifdef __cplusplus
}
#endif

#endif
