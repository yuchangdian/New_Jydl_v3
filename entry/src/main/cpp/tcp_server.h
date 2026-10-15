#ifndef TCP_SERVER_H
#define TCP_SERVER_H

#include <cstddef>
#include <cstdint>
#include <functional>
#include <memory>

// 2404 实时数据转发服务；同 Qt Qclient，只保留一个客户端，新连接替换旧连接。
class TcpServer final {
public:
    static constexpr std::uint16_t kDefaultPort = 2404;
    static constexpr std::size_t kMaxPendingBytes = 1024 * 1024;
    using ReceiveHandler = std::function<void(const std::uint8_t *, std::size_t)>;
    using ConnectionHandler = std::function<void(bool)>;

    static TcpServer &GetInstance();

    // 默认监听本机所有 IPv4 地址。port=0 由系统分配端口，供本机测试使用。
    bool Start(std::uint16_t port = kDefaultPort, const char *bindAddress = "0.0.0.0");
    void Stop();
    bool IsRunning() const;
    bool IsClientConnected() const;
    std::uint16_t GetPort() const;

    // 复制二进制数据入队，不阻塞调用方；true 表示已入队，不代表对端确认。
    // 未连接、队列已满或参数无效时返回 false；断开/替换连接会丢弃未发完的旧队列。
    bool Send(const void *data, std::size_t length);

    // 回调在服务端 I/O 线程执行，不持有内部锁；数据指针仅在本次回调内有效。
    // TCP 回调是任意长度字节块，业务方负责拆包/拼包。回调应尽快返回。
    // 回调中 Stop 仅请求退出，业务线程可再次 Stop 等待完成；Start 需从业务线程调用。
    // 注销不能取消已取得/正在执行的回调，释放捕获对象前应先 Stop 等待回调结束。
    void SetReceiveHandler(ReceiveHandler handler);
    void SetConnectionHandler(ConnectionHandler handler);

private:
    TcpServer();
    ~TcpServer();
    TcpServer(const TcpServer &) = delete;
    TcpServer &operator=(const TcpServer &) = delete;
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

#endif
