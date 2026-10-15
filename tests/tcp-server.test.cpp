#include "../entry/src/main/cpp/tcp_server.h"
#include "../entry/src/main/cpp/tcp_server_c.h"
#include <array>
#include <atomic>
#include <cassert>
#include <chrono>
#include <condition_variable>
#include <cstring>
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
using Socket = SOCKET;
constexpr Socket kInvalid = INVALID_SOCKET;
void Close(Socket socket) { closesocket(socket); }
#else
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
using Socket = int;
constexpr Socket kInvalid = -1;
void Close(Socket socket) { close(socket); }
#endif

extern "C" int tcp_server_test_send_from_c(const void *data, size_t length);
using namespace std::chrono_literals;

template <typename Predicate>
void Wait(Predicate predicate)
{
    const auto deadline = std::chrono::steady_clock::now() + 5s;
    while (!predicate() && std::chrono::steady_clock::now() < deadline) std::this_thread::sleep_for(5ms);
    assert(predicate());
}

Socket Connect(std::uint16_t port)
{
    Socket socket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    assert(socket != kInvalid);
    sockaddr_in address {};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    assert(connect(socket, reinterpret_cast<sockaddr *>(&address), sizeof(address)) == 0);
#ifdef _WIN32
    const DWORD timeout = 5000;
#else
    const timeval timeout {5, 0};
#endif
    assert(setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, reinterpret_cast<const char *>(&timeout), sizeof(timeout)) == 0);
    return socket;
}

void SendAll(Socket socket, const std::vector<std::uint8_t> &bytes)
{
    std::size_t offset = 0;
    while (offset < bytes.size()) {
        const auto sent = send(socket, reinterpret_cast<const char *>(bytes.data() + offset),
                               static_cast<int>(bytes.size() - offset), 0);
        assert(sent > 0);
        offset += static_cast<std::size_t>(sent);
    }
}

std::vector<std::uint8_t> Receive(Socket socket, std::size_t length)
{
    std::vector<std::uint8_t> bytes(length);
    std::size_t offset = 0;
    while (offset < length) {
        const auto count = recv(socket, reinterpret_cast<char *>(bytes.data() + offset),
                                static_cast<int>(length - offset), 0);
        assert(count > 0);
        offset += static_cast<std::size_t>(count);
    }
    return bytes;
}

int main()
{
    auto &server = TcpServer::GetInstance();
    assert(&server == &TcpServer::GetInstance());
    server.Stop();
    assert(!server.Send("a", 1));
    assert(!server.Start(2404, "not-an-ip"));
    assert(server.Start(0, "127.0.0.1"));
    assert(server.GetPort() > 0);
    const auto port = server.GetPort();
    assert(server.Start(0, "127.0.0.1") && server.GetPort() == port);
    assert(!server.Start(1, "127.0.0.1"));
    assert(!server.Send(nullptr, 1));
    assert(!server.Send("", 0));
    assert(!server.Send("a", TcpServer::kMaxPendingBytes + 1));
    std::atomic<int> connections {0};
    server.SetConnectionHandler([&](bool connected) { if (connected) ++connections; });
    Socket first = Connect(port);
    Wait([&]() { return connections == 1 && server.IsClientConnected(); });

    const std::vector<std::uint8_t> binary {0x11, 0x13, 0, 0x55, 0, 0xFF, 0};
    assert(tcp_server_test_send_from_c(binary.data(), binary.size()) == 1);
    assert(Receive(first, binary.size()) == binary);
    server.SetReceiveHandler([&](const std::uint8_t *data, std::size_t length) {
        assert(server.Send(data, length)); // 回调中再次 Send 不会死锁。
    });
    SendAll(first, {0x68});
    SendAll(first, {0, 0xFE, 0x55});
    assert(Receive(first, 4) == std::vector<std::uint8_t>({0x68, 0, 0xFE, 0x55}));
    std::cout << "PASS singleton, binary C API, receive callback and reentrant send\n";

    // 大数据及多个发送线程，队列需保持每个 Send 的字节连续且不丢失。
    std::vector<std::uint8_t> large(900000);
    for (std::size_t i = 0; i < large.size(); ++i) large[i] = static_cast<std::uint8_t>(i % 251);
    assert(server.Send(large.data(), large.size()));
    std::this_thread::sleep_for(100ms);
    assert(Receive(first, large.size()) == large);
    std::array<std::thread, 4> writers;
    for (std::size_t index = 0; index < writers.size(); ++index) {
        writers[index] = std::thread([&, index]() {
            std::vector<std::uint8_t> message(1024, static_cast<std::uint8_t>(index + 1));
            for (int i = 0; i < 30; ++i) assert(server.Send(message.data(), message.size()));
        });
    }
    for (auto &writer : writers) writer.join();
    const auto concurrent = Receive(first, 4 * 30 * 1024);
    std::array<int, 4> counts {};
    for (std::size_t offset = 0; offset < concurrent.size(); offset += 1024) {
        const auto tag = concurrent[offset];
        assert(tag >= 1 && tag <= 4);
        ++counts[tag - 1];
        for (std::size_t i = 0; i < 1024; ++i) assert(concurrent[offset + i] == tag);
    }
    for (auto count : counts) assert(count == 30);
    std::cout << "PASS large payload, partial send handling and concurrent frame ordering\n";

    // 暂停 I/O 回调，确定旧队列尚未写入 socket；新连接应丢弃旧队列。
    std::mutex gateMutex;
    std::condition_variable gate;
    bool entered = false;
    bool release = false;
    server.SetReceiveHandler([&](const std::uint8_t *, std::size_t) {
        std::unique_lock<std::mutex> lock(gateMutex);
        entered = true;
        gate.notify_all();
        assert(gate.wait_for(lock, 5s, [&]() { return release; }));
    });
    SendAll(first, {0x7F});
    {
        std::unique_lock<std::mutex> lock(gateMutex);
        assert(gate.wait_for(lock, 5s, [&]() { return entered; }));
    }
    std::vector<std::uint8_t> oldData(TcpServer::kMaxPendingBytes, 0xEE);
    assert(server.Send(oldData.data(), oldData.size()));
    assert(!server.Send("x", 1)); // 队列上限有效，业务线程无需等待慢客户端。
    Socket second = Connect(port);
    {
        std::lock_guard<std::mutex> lock(gateMutex);
        release = true;
    }
    gate.notify_all();
    Wait([&]() { return connections == 2; });
    const std::vector<std::uint8_t> fresh {0x12, 0x34, 0};
    assert(server.Send(fresh.data(), fresh.size()));
    assert(Receive(second, fresh.size()) == fresh);
    Close(first);
    Close(second);
    Wait([&]() { return !server.IsClientConnected(); });
    assert(!tcp_server_send(fresh.data(), fresh.size()));
    std::cout << "PASS queue limit, new-client replacement, stale-queue isolation and disconnect\n";

    std::atomic<std::size_t> receivedBytes {0};
    server.SetReceiveHandler([&](const std::uint8_t *data, std::size_t length) {
        const auto offset = receivedBytes.load();
        assert(offset + length <= large.size());
        assert(std::memcmp(data, large.data() + offset, length) == 0);
        receivedBytes += length;
    });
    Socket finishing = Connect(port);
    Wait([&]() { return connections == 3; });
    SendAll(finishing, large);
#ifdef _WIN32
    assert(shutdown(finishing, SD_SEND) == 0);
#else
    assert(shutdown(finishing, SHUT_WR) == 0);
#endif
    Wait([&]() { return receivedBytes == large.size() && !server.IsClientConnected(); });
    Close(finishing);
    std::cout << "PASS large inbound stream remains complete before peer EOF\n";

    server.Stop();
    server.Stop();
    assert(!server.IsRunning() && server.GetPort() == 0);
    assert(server.Start(port, "127.0.0.1"));
    server.SetReceiveHandler([&](const std::uint8_t *, std::size_t) { server.Stop(); });
    Socket stoppedByCallback = Connect(port);
    SendAll(stoppedByCallback, {0x66});
    Wait([&]() { return !server.IsRunning(); });
    server.Stop(); // 业务线程收尾 join，回调中的 Stop 只请求退出。
    Close(stoppedByCallback);
    server.SetReceiveHandler(nullptr);
    server.SetConnectionHandler(nullptr);

    // 端口占用应明确失败，停止后可重新启动。
    Socket occupied = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    assert(occupied != kInvalid);
    sockaddr_in occupiedAddress {};
    occupiedAddress.sin_family = AF_INET;
    occupiedAddress.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    assert(bind(occupied, reinterpret_cast<sockaddr *>(&occupiedAddress), sizeof(occupiedAddress)) == 0);
    assert(listen(occupied, 1) == 0);
#ifdef _WIN32
    int occupiedLength = sizeof(occupiedAddress);
#else
    socklen_t occupiedLength = sizeof(occupiedAddress);
#endif
    assert(getsockname(occupied, reinterpret_cast<sockaddr *>(&occupiedAddress), &occupiedLength) == 0);
    assert(!server.Start(ntohs(occupiedAddress.sin_port), "127.0.0.1"));
    Close(occupied);
    assert(!server.IsRunning());
    std::array<std::thread, 4> lifecycleThreads;
    for (auto &thread : lifecycleThreads) thread = std::thread([&]() {
        for (int i = 0; i < 5; ++i) {
            server.Start(0, "127.0.0.1");
            server.Stop();
        }
    });
    for (auto &thread : lifecycleThreads) thread.join();
    server.Stop();
    assert(!server.IsRunning());
    std::cout << "PASS stop from callback, restart, occupied port and concurrent lifecycle\n";
}
