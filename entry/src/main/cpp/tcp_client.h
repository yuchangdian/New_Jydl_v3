#ifndef TCP_CLIENT_H
#define TCP_CLIENT_H

#include <array>
#include <cstddef>
#include <cstdint>
#include <pthread.h>

#include <mutex>

class TcpClient final {
public:
    static TcpClient &GetInstance();

    int Start(const char *host, int port);
    void Stop();
    int IsRunning();
    int Send(const char *data, int length);

private:
    TcpClient() = default;
    ~TcpClient() = default;

    TcpClient(const TcpClient &) = delete;
    TcpClient &operator=(const TcpClient &) = delete;

    static void *ThreadMainEntry(void *arg);
    void ThreadMain();
    static void SleepSeconds(unsigned int seconds);
    int Connect(const char *host, int port);
    void CloseSocketLocked();
    void HandleReceivedBytes(const std::uint8_t *data, std::size_t length);
    void DispatchDecodedFrames();
    bool TryReadUint16(std::size_t offset, std::uint16_t *value) const;
    void DecodeRemoteMetryPacket(std::uint16_t objectAddr, std::size_t *decodeOffset);
    void DecodeRemoteSignalPacket(std::uint16_t objectAddr, std::size_t *decodeOffset);
    void DecodeRemoteAdjustPacket(std::uint16_t objectAddr, std::size_t *decodeOffset);
    void DecodeSoePackage(std::uint16_t objectAddr, std::size_t *decodeOffset);
    void SkipUnsupportedDecode(const char *decoderName, std::uint16_t objectAddr, std::size_t *decodeOffset);

    pthread_t tcpThread_ {};
    std::mutex stateMutex_;
    bool threadCreated_ = false;
    bool shouldRun_ = false;
    int socketFd_ = -1;
    char serverHost_[256] = {0};
    int serverPort_ = 0;
    std::array<std::uint8_t, 4096> decodeBuffer_ {};
    std::size_t bufferedSize_ = 0;
};

#endif
