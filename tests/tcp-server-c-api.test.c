#include "../entry/src/main/cpp/tcp_server_c.h"

int tcp_server_test_send_from_c(const void *data, size_t length)
{
    if (!tcp_server_is_running() || !tcp_server_is_client_connected()) return 0;
    return tcp_server_send(data, length);
}
