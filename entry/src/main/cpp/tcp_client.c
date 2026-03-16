#include "tcp_client.h"

#include <arpa/inet.h>
#include <errno.h>
#include <hilog/log.h>
#include <netdb.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

static pthread_t g_tcp_thread;
static pthread_mutex_t g_state_mutex = PTHREAD_MUTEX_INITIALIZER;
static bool g_thread_created = false;
static bool g_should_run = false;
static int g_socket_fd = -1;
static char g_server_host[256] = {0};
static int g_server_port = 0;
static const int TCP_LOG_DOMAIN = 0x0000;
static const char *TCP_LOG_TAG = "JY_TCP_NATIVE";

#define TCP_LOGI(format, ...) OH_LOG_Print(LOG_APP, LOG_INFO, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)
#define TCP_LOGW(format, ...) OH_LOG_Print(LOG_APP, LOG_WARN, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)
#define TCP_LOGE(format, ...) OH_LOG_Print(LOG_APP, LOG_ERROR, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)

static void tcp_client_close_socket_locked(void)
{
    if (g_socket_fd >= 0) {
        shutdown(g_socket_fd, SHUT_RDWR);
        close(g_socket_fd);
        g_socket_fd = -1;
    }
}

static void tcp_client_sleep_seconds(unsigned int seconds)
{
    while (seconds > 0) {
        seconds = sleep(seconds);
    }
}

static int tcp_client_connect(const char *host, int port)
{
    struct addrinfo hints;
    struct addrinfo *result = NULL;
    struct addrinfo *current = NULL;
    char port_buffer[16];
    int socket_fd = -1;
    int status = 0;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    (void)snprintf(port_buffer, sizeof(port_buffer), "%d", port);
    status = getaddrinfo(host, port_buffer, &hints, &result);
    if (status != 0) {
        TCP_LOGE("getaddrinfo failed. host=%{public}s port=%{public}d reason=%{public}s",
            host, port, gai_strerror(status));
        return -1;
    }

    for (current = result; current != NULL; current = current->ai_next) {
        socket_fd = socket(current->ai_family, current->ai_socktype, current->ai_protocol);
        if (socket_fd < 0) {
            continue;
        }

        if (connect(socket_fd, current->ai_addr, current->ai_addrlen) == 0) {
            break;
        }

        close(socket_fd);
        socket_fd = -1;
    }

    freeaddrinfo(result);
    return socket_fd;
}

static void *tcp_client_thread_main(void *arg)
{
    (void)arg;
    char host[256];
    int port = 0;
    char recv_buffer[1024];

    while (true) {
        pthread_mutex_lock(&g_state_mutex);
        if (!g_should_run) {
            pthread_mutex_unlock(&g_state_mutex);
            break;
        }
        (void)snprintf(host, sizeof(host), "%s", g_server_host);
        port = g_server_port;
        pthread_mutex_unlock(&g_state_mutex);

        int socket_fd = tcp_client_connect(host, port);
        if (socket_fd < 0) {
            tcp_client_sleep_seconds(3);
            continue;
        }

        pthread_mutex_lock(&g_state_mutex);
        if (!g_should_run) {
            close(socket_fd);
            pthread_mutex_unlock(&g_state_mutex);
            break;
        }
        g_socket_fd = socket_fd;
        pthread_mutex_unlock(&g_state_mutex);

        TCP_LOGI("connected. host=%{public}s port=%{public}d", host, port);

        while (true) {
            ssize_t received_size = recv(socket_fd, recv_buffer, sizeof(recv_buffer) - 1, 0);
            if (received_size > 0) {
                recv_buffer[received_size] = '\0';
                TCP_LOGI("received: %{public}s", recv_buffer);
                continue;
            }

            if (received_size == 0) {
                TCP_LOGW("server closed connection");
            } else if (errno != EINTR) {
                TCP_LOGE("recv failed. errno=%{public}d", errno);
            }
            break;
        }

        pthread_mutex_lock(&g_state_mutex);
        if (g_socket_fd == socket_fd) {
            tcp_client_close_socket_locked();
        } else {
            close(socket_fd);
        }
        bool should_continue = g_should_run;
        pthread_mutex_unlock(&g_state_mutex);

        if (!should_continue) {
            break;
        }

        tcp_client_sleep_seconds(3);
    }

    pthread_mutex_lock(&g_state_mutex);
    g_thread_created = false;
    tcp_client_close_socket_locked();
    pthread_mutex_unlock(&g_state_mutex);
    return NULL;
}

int tcp_client_start(const char *host, int port)
{
    if (host == NULL || host[0] == '\0' || port <= 0 || port > 65535) {
        return 0;
    }

    pthread_mutex_lock(&g_state_mutex);
    if (g_thread_created) {
        pthread_mutex_unlock(&g_state_mutex);
        return 1;
    }

    (void)snprintf(g_server_host, sizeof(g_server_host), "%s", host);
    g_server_port = port;
    g_should_run = true;

    int create_result = pthread_create(&g_tcp_thread, NULL, tcp_client_thread_main, NULL);
    if (create_result != 0) {
        g_should_run = false;
        pthread_mutex_unlock(&g_state_mutex);
        TCP_LOGE("failed to create thread. errno=%{public}d", create_result);
        return 0;
    }

    g_thread_created = true;
    pthread_mutex_unlock(&g_state_mutex);
    TCP_LOGI("client thread started. host=%{public}s port=%{public}d", host, port);
    return 1;
}

void tcp_client_stop(void)
{
    pthread_t thread;
    bool has_thread = false;

    pthread_mutex_lock(&g_state_mutex);
    g_should_run = false;
    if (g_thread_created) {
        thread = g_tcp_thread;
        has_thread = true;
    }
    tcp_client_close_socket_locked();
    pthread_mutex_unlock(&g_state_mutex);

    if (has_thread) {
        pthread_join(thread, NULL);
    }
    TCP_LOGI("client thread stopped");
}

int tcp_client_is_running(void)
{
    int is_running;

    pthread_mutex_lock(&g_state_mutex);
    is_running = g_thread_created ? 1 : 0;
    pthread_mutex_unlock(&g_state_mutex);
    return is_running;
}
