#include "tcp_server.h"
#include "tcp_server_c.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <cerrno>
#include <cstdio>
#include <deque>
#include <mutex>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

#ifdef TCP_SERVER_TESTING
#define SERVER_LOGI(format, ...) ((void)0)
#define SERVER_LOGE(format, ...) ((void)0)
#else
#include <hilog/log.h>
#define SERVER_LOGI(format, ...) OH_LOG_Print(LOG_APP, LOG_INFO, 0x0000, "JY_TCP_SERVER", format, ##__VA_ARGS__)
#define SERVER_LOGE(format, ...) OH_LOG_Print(LOG_APP, LOG_ERROR, 0x0000, "JY_TCP_SERVER", format, ##__VA_ARGS__)
#endif

namespace {
#ifdef _WIN32
using Socket = SOCKET;
using SocketLength = int;
using PollDescriptor = WSAPOLLFD;
constexpr Socket kInvalidSocket = INVALID_SOCKET;
int SocketError() { return WSAGetLastError(); }
bool WouldBlock(int error) { return error == WSAEWOULDBLOCK; }
bool Interrupted(int error) { return error == WSAEINTR; }
void CloseSocket(Socket socket) { closesocket(socket); }
bool SetNonblocking(Socket socket) { u_long enabled = 1; return ioctlsocket(socket, FIONBIO, &enabled) == 0; }
int Poll(PollDescriptor *fds, unsigned long count) { return WSAPoll(fds, count, 100); }
bool InitializeSockets()
{
    struct Runtime {
        bool ready;
        Runtime() { WSADATA data; ready = WSAStartup(MAKEWORD(2, 2), &data) == 0; }
        ~Runtime() { if (ready) WSACleanup(); }
    };
    static Runtime runtime;
    return runtime.ready;
}
#else
using Socket = int;
using SocketLength = socklen_t;
using PollDescriptor = pollfd;
constexpr Socket kInvalidSocket = -1;
int SocketError() { return errno; }
bool WouldBlock(int error) { return error == EAGAIN || error == EWOULDBLOCK; }
bool Interrupted(int error) { return error == EINTR; }
void CloseSocket(Socket socket) { close(socket); }
bool SetNonblocking(Socket socket)
{
    const int flags = fcntl(socket, F_GETFL, 0);
    return flags >= 0 && fcntl(socket, F_SETFL, flags | O_NONBLOCK) == 0;
}
int Poll(PollDescriptor *fds, unsigned long count) { return poll(fds, count, 100); }
bool InitializeSockets() { return true; }
#endif

#ifdef MSG_NOSIGNAL
constexpr int kSendFlags = MSG_NOSIGNAL;
#else
constexpr int kSendFlags = 0;
#endif

void SetOption(Socket socket, int level, int option)
{
    const int enabled = 1;
    setsockopt(socket, level, option, reinterpret_cast<const char *>(&enabled), sizeof(enabled));
}
} // namespace

struct TcpServer::Impl {
    struct PendingData {
        std::vector<std::uint8_t> bytes;
        std::size_t offset = 0;
    };

    std::mutex lifecycleMutex;
    mutable std::mutex mutex;
    std::thread worker;
    std::thread::id workerId;
    std::atomic<bool> running {false};
    std::atomic<bool> stopping {false};
    Socket listener = kInvalidSocket;
    Socket client = kInvalidSocket;
    std::uint16_t port = 0;
    std::uint16_t requestedPort = 0;
    std::string bindAddress;
    std::deque<PendingData> pending;
    std::size_t queuedBytes = 0;
    ReceiveHandler receiveHandler;
    ConnectionHandler connectionHandler;

    bool IsWorker() const
    {
        std::lock_guard<std::mutex> lock(mutex);
        return workerId == std::this_thread::get_id();
    }

    void NotifyConnection(bool connected)
    {
        ConnectionHandler handler;
        {
            std::lock_guard<std::mutex> lock(mutex);
            handler = connectionHandler;
        }
        try {
            if (handler) handler(connected);
        } catch (...) {
            SERVER_LOGE("连接状态回调发生异常");
        }
    }

    void Disconnect()
    {
        bool connected = false;
        {
            std::lock_guard<std::mutex> lock(mutex);
            if (client != kInvalidSocket) {
                CloseSocket(client);
                client = kInvalidSocket;
                connected = true;
            }
            pending.clear();
            queuedBytes = 0;
        }
        if (connected) {
            SERVER_LOGI("TCP 客户端已断开");
            NotifyConnection(false);
        }
    }

    bool AcceptClients()
    {
        bool accepted = false;
        for (int count = 0; count < 16 && !stopping; ++count) {
            sockaddr_in peer {};
            SocketLength length = sizeof(peer);
            const Socket next = accept(listener, reinterpret_cast<sockaddr *>(&peer), &length);
            if (next == kInvalidSocket) break;
            if (!SetNonblocking(next)) {
                CloseSocket(next);
                continue;
            }
            SetOption(next, SOL_SOCKET, SO_KEEPALIVE);
            SetOption(next, IPPROTO_TCP, TCP_NODELAY);
            Disconnect();
            if (stopping) {
                CloseSocket(next);
                break;
            }
            {
                std::lock_guard<std::mutex> lock(mutex);
                client = next;
            }
            accepted = true;
            SERVER_LOGI("TCP 客户端已连接，端口=%{public}u", static_cast<unsigned>(ntohs(peer.sin_port)));
            NotifyConnection(true);
        }
        return accepted;
    }

    bool Receive(Socket socket)
    {
        std::array<std::uint8_t, 16384> bytes {};
        for (int count = 0; count < 16 && !stopping; ++count) {
            const auto received = recv(socket, reinterpret_cast<char *>(bytes.data()), bytes.size(), 0);
            if (received == 0) return false;
            if (received < 0) {
                const int error = SocketError();
                if (Interrupted(error)) continue;
                return WouldBlock(error);
            }
            ReceiveHandler handler;
            {
                std::lock_guard<std::mutex> lock(mutex);
                handler = receiveHandler;
            }
            try {
                if (handler) handler(bytes.data(), static_cast<std::size_t>(received));
            } catch (...) {
                SERVER_LOGE("数据接收回调发生异常");
            }
        }
        return true;
    }

    bool Flush(Socket socket)
    {
        // 单轮最多发送 256 KiB，避免持续发送导致接收、Stop 或连接切换饥饿。
        std::size_t budget = 256 * 1024;
        std::lock_guard<std::mutex> lock(mutex);
        while (!pending.empty() && budget > 0 && !stopping) {
            auto &item = pending.front();
            const auto length = std::min(std::min(item.bytes.size() - item.offset, budget), std::size_t(65536));
            const auto sent = send(socket, reinterpret_cast<const char *>(item.bytes.data() + item.offset),
                                   static_cast<int>(length), kSendFlags);
            if (sent <= 0) {
                if (sent < 0 && Interrupted(SocketError())) continue;
                return sent < 0 && WouldBlock(SocketError());
            }
            item.offset += static_cast<std::size_t>(sent);
            budget -= static_cast<std::size_t>(sent);
            if (item.offset == item.bytes.size()) {
                queuedBytes -= item.bytes.size();
                pending.pop_front();
            }
        }
        return true;
    }

    void Run()
    {
        while (!stopping) {
            std::array<PollDescriptor, 2> fds {};
            unsigned long count = 1;
            fds[0].fd = listener;
            fds[0].events = POLLIN;
            {
                std::lock_guard<std::mutex> lock(mutex);
                if (client != kInvalidSocket) {
                    count = 2;
                    fds[1].fd = client;
                    fds[1].events = POLLIN | (pending.empty() ? 0 : POLLOUT);
                }
            }
            const int result = Poll(fds.data(), count);
            if (stopping) break;
            if (result < 0) {
                if (Interrupted(SocketError())) continue;
                SERVER_LOGE("TCP poll 失败，错误=%{public}d", SocketError());
                break;
            }
            if (fds[0].revents & (POLLERR | POLLHUP | POLLNVAL)) break;
            // 替换连接后丢弃针对旧 socket 的 poll 结果，下一轮重新读取新连接状态。
            if ((fds[0].revents & POLLIN) && AcceptClients()) continue;
            if (count != 2 || stopping) continue;
            const auto events = fds[1].revents;
            if ((events & POLLIN) && !Receive(fds[1].fd)) {
                Disconnect();
                continue;
            }
            if (stopping) break;
            if ((events & POLLOUT) && !Flush(fds[1].fd)) {
                Disconnect();
                continue;
            }
            // HUP 可能和仍有未读数据的 POLLIN 同时出现；先继续读完，由 recv=0 收尾。
            if ((events & (POLLERR | POLLNVAL)) || ((events & POLLHUP) && !(events & POLLIN))) Disconnect();
        }
        Disconnect();
        {
            std::lock_guard<std::mutex> lock(mutex);
            CloseSocket(listener);
            listener = kInvalidSocket;
            port = 0;
            workerId = std::thread::id();
            running = false;
        }
        SERVER_LOGI("TCP 服务端已停止");
    }
};

TcpServer::TcpServer() : impl_(new Impl()) { InitializeSockets(); }
TcpServer::~TcpServer() { Stop(); }
TcpServer &TcpServer::GetInstance() { static TcpServer instance; return instance; }

bool TcpServer::Start(std::uint16_t port, const char *bindAddress)
{
    // I/O 回调中可以 Send 或 Stop；Start 需从业务线程调用，避免等待自身退出。
    if (impl_->IsWorker() || bindAddress == nullptr || !InitializeSockets()) return false;
    std::lock_guard<std::mutex> lifecycle(impl_->lifecycleMutex);
    if (impl_->running) {
        std::lock_guard<std::mutex> lock(impl_->mutex);
        return !impl_->stopping && impl_->requestedPort == port && impl_->bindAddress == bindAddress;
    }
    if (impl_->worker.joinable()) impl_->worker.join();
    sockaddr_in address {};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    if (inet_pton(AF_INET, bindAddress, &address.sin_addr) != 1) return false;
    const Socket listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listener == kInvalidSocket) return false;
#ifdef _WIN32
    SetOption(listener, SOL_SOCKET, SO_EXCLUSIVEADDRUSE);
#else
    SetOption(listener, SOL_SOCKET, SO_REUSEADDR);
#endif
    if (!SetNonblocking(listener) || bind(listener, reinterpret_cast<sockaddr *>(&address), sizeof(address)) != 0 ||
        listen(listener, 8) != 0) {
        SERVER_LOGE("TCP 监听失败，地址=%{public}s，端口=%{public}u，错误=%{public}d",
                    bindAddress, static_cast<unsigned>(port), SocketError());
        CloseSocket(listener);
        return false;
    }
    SocketLength addressLength = sizeof(address);
    if (getsockname(listener, reinterpret_cast<sockaddr *>(&address), &addressLength) != 0) {
        CloseSocket(listener);
        return false;
    }
    std::lock_guard<std::mutex> lock(impl_->mutex);
    impl_->listener = listener;
    impl_->port = ntohs(address.sin_port);
    impl_->requestedPort = port;
    impl_->bindAddress = bindAddress;
    impl_->stopping = false;
    impl_->running = true;
    try {
        impl_->worker = std::thread([this]() { impl_->Run(); });
        impl_->workerId = impl_->worker.get_id();
    } catch (...) {
        CloseSocket(listener);
        impl_->listener = kInvalidSocket;
        impl_->port = 0;
        impl_->running = false;
        return false;
    }
    SERVER_LOGI("TCP 服务端正在监听 %{public}s:%{public}u", bindAddress, static_cast<unsigned>(impl_->port));
    return true;
}

void TcpServer::Stop()
{
    if (impl_->IsWorker()) {
        impl_->stopping = true;
        return;
    }
    std::lock_guard<std::mutex> lifecycle(impl_->lifecycleMutex);
    impl_->stopping = true;
    if (impl_->worker.joinable()) impl_->worker.join();
}

bool TcpServer::IsRunning() const { return impl_->running && !impl_->stopping; }
bool TcpServer::IsClientConnected() const
{
    std::lock_guard<std::mutex> lock(impl_->mutex);
    return impl_->running && !impl_->stopping && impl_->client != kInvalidSocket;
}
std::uint16_t TcpServer::GetPort() const
{
    std::lock_guard<std::mutex> lock(impl_->mutex);
    return impl_->port;
}
bool TcpServer::Send(const void *data, std::size_t length)
{
    if (data == nullptr || length == 0 || length > kMaxPendingBytes) return false;
    std::lock_guard<std::mutex> lock(impl_->mutex);
    if (!impl_->running || impl_->stopping || impl_->client == kInvalidSocket ||
        length > kMaxPendingBytes - impl_->queuedBytes) return false;
    Impl::PendingData item;
    const auto *bytes = static_cast<const std::uint8_t *>(data);
    item.bytes.assign(bytes, bytes + length);
    impl_->pending.push_back(std::move(item));
    impl_->queuedBytes += length;
    return true;
}
void TcpServer::SetReceiveHandler(ReceiveHandler handler)
{
    std::lock_guard<std::mutex> lock(impl_->mutex);
    impl_->receiveHandler = std::move(handler);
}
void TcpServer::SetConnectionHandler(ConnectionHandler handler)
{
    std::lock_guard<std::mutex> lock(impl_->mutex);
    impl_->connectionHandler = std::move(handler);
}

extern "C" {
int tcp_server_start(uint16_t port) { return TcpServer::GetInstance().Start(port) ? 1 : 0; }
void tcp_server_stop(void) { TcpServer::GetInstance().Stop(); }
int tcp_server_is_running(void) { return TcpServer::GetInstance().IsRunning() ? 1 : 0; }
int tcp_server_is_client_connected(void) { return TcpServer::GetInstance().IsClientConnected() ? 1 : 0; }
int tcp_server_send(const void *data, size_t length) { return TcpServer::GetInstance().Send(data, length) ? 1 : 0; }
void tcp_server_set_receive_callback(tcp_server_receive_callback callback, void *context)
{
    TcpServer::GetInstance().SetReceiveHandler(callback ? TcpServer::ReceiveHandler(
        [callback, context](const std::uint8_t *data, std::size_t length) { callback(data, length, context); }) : nullptr);
}
void tcp_server_set_connection_callback(tcp_server_connection_callback callback, void *context)
{
    TcpServer::GetInstance().SetConnectionHandler(callback ? TcpServer::ConnectionHandler(
        [callback, context](bool connected) { callback(connected ? 1 : 0, context); }) : nullptr);
}
}
