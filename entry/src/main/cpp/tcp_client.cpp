#include "tcp_client.h"
#include "IEC104.h"
#include "setting.h"

#include <errno.h>
#include <hilog/log.h>
#include <netdb.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cstdio>
#include <cstring>
#include <string>

namespace {

constexpr int TCP_LOG_DOMAIN = 0x0000;
constexpr const char *TCP_LOG_TAG = "JY_TCP_NATIVE";

#define TCP_LOGI(format, ...) OH_LOG_Print(LOG_APP, LOG_INFO, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)
#define TCP_LOGW(format, ...) OH_LOG_Print(LOG_APP, LOG_WARN, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)
#define TCP_LOGE(format, ...) OH_LOG_Print(LOG_APP, LOG_ERROR, TCP_LOG_DOMAIN, TCP_LOG_TAG, format, ##__VA_ARGS__)

void LogPrimarySystemSetting(const CommonSetting_PrimarySystem_Struct &setting)
{
    TCP_LOGI(
        "PrimarySystemSetting grounding=%{public}u busPT=(%{public}.3f,%{public}.3f) "
        "busZeroPT=(%{public}.3f,%{public}.3f)",
        setting.SystemGroundingMode,
        static_cast<double>(setting.PTp_Bus_Primary),
        static_cast<double>(setting.PTp_Bus_Secondary),
        static_cast<double>(setting.PTo_Bus_Primary),
        static_cast<double>(setting.PTo_Bus_Secondary));

    TCP_LOGI(
        "PrimarySystemSetting linePT=(%{public}.3f,%{public}.3f) phase=%{public}u "
        "protectCT=(%{public}.3f,%{public}.3f)",
        static_cast<double>(setting.PT_Line_Primary),
        static_cast<double>(setting.PT_Line_Secondary),
        setting.PT_Line_Phase,
        static_cast<double>(setting.CTp_Protection_Primary),
        static_cast<double>(setting.CTp_Protection_Secondary));

    TCP_LOGI(
        "PrimarySystemSetting zeroCT=(%{public}.3f,%{public}.3f) "
        "measureCT=(%{public}.3f,%{public}.3f)",
        static_cast<double>(setting.CTo_Primary),
        static_cast<double>(setting.CTo_Secondary),
        static_cast<double>(setting.CTp_Measure_Primary),
        static_cast<double>(setting.CTp_Measure_Secondary));

    TCP_LOGI(
        "PrimarySystemSetting ctMode=%{public}u ioMode=%{public}u ratedPower=%{public}.3f crc=%{public}u",
        setting.Mode_CTConnectioin,
        setting.Mode_Iosample,
        static_cast<double>(setting.RatedPower_Line),
        setting.CRC);
}

void LogPrimarySystemPayloadHex(const std::uint8_t *data, std::size_t length)
{
    if (data == nullptr || length == 0) {
        TCP_LOGW("PrimarySystem payload is empty");
        return;
    }

    constexpr std::size_t bytesPerLine = 16;
    char byteBuffer[8] = {};
    TCP_LOGI("PrimarySystem raw payload length=%{public}d", static_cast<int>(length));

    for (std::size_t offset = 0; offset < length; offset += bytesPerLine) {
        std::string line;
        for (std::size_t index = offset; index < length && index < offset + bytesPerLine; ++index) {
            if (!line.empty()) {
                line += ' ';
            }
            std::snprintf(byteBuffer, sizeof(byteBuffer), "%02X", data[index]);
            line += byteBuffer;
        }
        TCP_LOGI("PrimarySystem raw[%{public}03d]: %{public}s",
            static_cast<int>(offset), line.c_str());
    }
}

void LogAnalogQuantityParameter(
    const char *groupName,
    const CommonSetting_AnalogQuantity_Parameter_Struct &parameter)
{
    TCP_LOGI(
        "AnalogQuantitySetting %{public}s U=(%{public}.3f,%{public}.3f,%{public}.3f,%{public}.3f)",
        groupName,
        static_cast<double>(parameter.Ua),
        static_cast<double>(parameter.Ub),
        static_cast<double>(parameter.Uc),
        static_cast<double>(parameter.Uo));

    TCP_LOGI(
        "AnalogQuantitySetting %{public}s protectI=(%{public}.3f,%{public}.3f,%{public}.3f,%{public}.3f)",
        groupName,
        static_cast<double>(parameter.IA),
        static_cast<double>(parameter.IB),
        static_cast<double>(parameter.IC),
        static_cast<double>(parameter.Io));

    TCP_LOGI(
        "AnalogQuantitySetting %{public}s measureI=(%{public}.3f,%{public}.3f,%{public}.3f,%{public}.3f)",
        groupName,
        static_cast<double>(parameter.Ia),
        static_cast<double>(parameter.Ib),
        static_cast<double>(parameter.Ic),
        static_cast<double>(parameter.Is));

    TCP_LOGI(
        "AnalogQuantitySetting %{public}s extra=(%{public}.3f,%{public}.3f,%{public}.3f,%{public}.3f)",
        groupName,
        static_cast<double>(parameter.Ux),
        static_cast<double>(parameter.Iby1),
        static_cast<double>(parameter.Iby2),
        static_cast<double>(parameter.Iby3));
}

void LogAnalogQuantitySetting(const CommonSetting_AnalogQuantity_Struct &setting)
{
    LogAnalogQuantityParameter("Reference", setting.Reference);
    LogAnalogQuantityParameter("Correction", setting.Correction);
    LogAnalogQuantityParameter("ZeroDrift", setting.ZeroDrift);
    TCP_LOGI("AnalogQuantitySetting crc=%{public}u", setting.CRC);
}

void LogTeleMeasuringSetting(const CommonSetting_TeleMeasuring_Struct &setting)
{
    TCP_LOGI(
        "TeleMeasuringSetting cycle=%{public}.3f primaryEnergy=%{public}u "
        "freq=%{public}.3f acV=%{public}.3f dcV=%{public}.3f",
        static_cast<double>(setting.Cycle_Detection),
        setting.Enable_PrimaryEnergy,
        static_cast<double>(setting.DeadBand_Frequency),
        static_cast<double>(setting.DeadBand_ACvoltage),
        static_cast<double>(setting.DeadBand_DCvoltage));

    TCP_LOGI(
        "TeleMeasuringSetting acI=%{public}.3f power=%{public}.3f powerFactor=%{public}.3f crc=%{public}u",
        static_cast<double>(setting.DeadBand_ACcurrent),
        static_cast<double>(setting.DeadBand_Power),
        static_cast<double>(setting.DeadBand_PowerFactor),
        setting.CRC);
}

void LogTeleSignalingSetting(const CommonSetting_TeleSignaling_Struct &setting)
{
    TCP_LOGI(
        "TeleSignalingSetting yx01=%{public}u yx02=%{public}u yx03=%{public}u yx04=%{public}u",
        setting.YX01_Time,
        setting.YX02_Time,
        setting.YX03_Time,
        setting.YX04_Time);

    TCP_LOGI(
        "TeleSignalingSetting yx05=%{public}u yx06=%{public}u yx07=%{public}u yx08=%{public}u",
        setting.YX05_Time,
        setting.YX06_Time,
        setting.YX07_Time,
        setting.YX08_Time);

    TCP_LOGI(
        "TeleSignalingSetting logic=%{public}u crc=%{public}u",
        setting.Enable_Logic,
        setting.CRC);
}

void LogTeleControllingSetting(const CommonSetting_TeleControlling_Struct &setting)
{
    TCP_LOGI(
        "TeleControllingSetting yk1=(%{public}u,%{public}u,%{public}u) yk2=(%{public}u,%{public}u,%{public}u)",
        setting.HoldingTime_YK1_XZ,
        setting.HoldingTime_YK1_TZ,
        setting.HoldingTime_YK1_HZ,
        setting.HoldingTime_YK2_XZ,
        setting.HoldingTime_YK2_TZ,
        setting.HoldingTime_YK2_HZ);

    TCP_LOGI(
        "TeleControllingSetting syncVoltage no=%{public}.3f yes=%{public}.3f diff=%{public}.3f",
        static_cast<double>(setting.Sync_NoVoltage),
        static_cast<double>(setting.Sync_ThereVoltage),
        static_cast<double>(setting.Sync_Volue_VoltageDifferenceBlock));

    TCP_LOGI(
        "TeleControllingSetting syncAngle=%{public}.3f syncFreq=%{public}.3f delay=%{public}u breakerClose=%{public}u",
        static_cast<double>(setting.Sync_Volue_AngleDifferenceBlock),
        static_cast<double>(setting.Sync_Volue_FrequencyDifferenceBlock),
        setting.Sync_DelayTime,
        setting.Sync_BreakerCloseTime);

    TCP_LOGI(
        "TeleControllingSetting closeMode=%{public}u crc=%{public}u",
        setting.Sync_Enable_CloseMode_YK,
        setting.CRC);
}

void LogExceedingLimitSetting(const CommonSetting_ExceedingLimit_Struct &setting)
{
    TCP_LOGI(
        "ExceedingLimitSetting lineV=(%{public}u,%{public}.3f) lineVLow=(%{public}u,%{public}.3f) zeroV=(%{public}u,%{public}.3f)",
        setting.Enable_LineVoltageExceedingUpperLimit,
        static_cast<double>(setting.Value_LineVoltageExceedingUpperLimit),
        setting.Enable_LineVoltageExceedingLowerLimit,
        static_cast<double>(setting.Value_LineVoltageExceedingLowerLimit),
        setting.Enable_ZeroSequenceVoltageExceedingUpperLimit,
        static_cast<double>(setting.Value_ZeroSequenceVoltageExceedingUpperLimit));

    TCP_LOGI(
        "ExceedingLimitSetting voltageImb=(%{public}u,%{public}.3f) phaseI=(%{public}u,%{public}.3f) zeroI=(%{public}u,%{public}.3f)",
        setting.Enable_VoltageImbalanceRateExceedingUpperLimit,
        static_cast<double>(setting.Value_VoltageImbalanceRateExceedingUpperLimit),
        setting.Enable_PhaseCurrentExceedingUpperLimit,
        static_cast<double>(setting.Value_PhaseCurrentExceedingUpperLimit),
        setting.Enable_ZeroSequenceCurrentExceedingUpperLimit,
        static_cast<double>(setting.Value_ZeroSequenceCurrentExceedingUpperLimit));

    TCP_LOGI(
        "ExceedingLimitSetting currentImb=(%{public}u,%{public}.3f) phaseDiff=(%{public}u,%{public}.3f) zeroDiff=(%{public}u,%{public}.3f)",
        setting.Enable_CurrentImbalanceRateExceedingUpperLimit,
        static_cast<double>(setting.Value_CurrentImbalanceRateExceedingUpperLimit),
        setting.Enable_PhaseDifferentialCurrentExceedingUpperLimit,
        static_cast<double>(setting.Value_PhaseDifferentialCurrentExceedingUpperLimit),
        setting.Enable_ZeroSequenceDifferentialCurrentExceedingUpperLimit,
        static_cast<double>(setting.Value_ZeroSequenceDifferentialCurrentExceedingUpperLimit));

    TCP_LOGI(
        "ExceedingLimitSetting loadRate=(%{public}u,%{public}.3f) delay=%{public}u crc=%{public}u",
        setting.Enable_LoadRateExceedingUpperLimit,
        static_cast<double>(setting.Value_LoadRateRateExceedingUpperLimit),
        setting.Time_Delay,
        setting.CRC);
}

bool IsAllBytesValue(const std::uint8_t *data, std::size_t length, std::uint8_t expected)
{
    if (data == nullptr || length == 0) {
        return false;
    }

    for (std::size_t index = 0; index < length; ++index) {
        if (data[index] != expected) {
            return false;
        }
    }
    return true;
}

} // namespace

TcpClient &TcpClient::GetInstance()
{
    static TcpClient instance;
    return instance;
}

int TcpClient::Start(const char *host, int port)
{
    if (host == nullptr || host[0] == '\0' || port <= 0 || port > 65535) {
        return 0;
    }

    std::lock_guard<std::mutex> lock(stateMutex_);
    if (threadCreated_) {
        return 1;
    }

    std::snprintf(serverHost_, sizeof(serverHost_), "%s", host);
    serverPort_ = port;
    shouldRun_ = true;

    const int createResult = pthread_create(&tcpThread_, nullptr, &TcpClient::ThreadMainEntry, this);
    if (createResult != 0) {
        shouldRun_ = false;
        TCP_LOGE("failed to create thread. errno=%{public}d", createResult);
        return 0;
    }

    threadCreated_ = true;
    TCP_LOGI("client thread started. host=%{public}s port=%{public}d", host, port);
    return 1;
}

void TcpClient::Stop()
{
    pthread_t thread {};
    bool hasThread = false;

    {
        std::lock_guard<std::mutex> lock(stateMutex_);
        shouldRun_ = false;
        if (threadCreated_) {
            thread = tcpThread_;
            hasThread = true;
        }
        CloseSocketLocked();
    }

    if (hasThread) {
        pthread_join(thread, nullptr);
    }
    TCP_LOGI("client thread stopped");
}

int TcpClient::IsRunning()
{
    std::lock_guard<std::mutex> lock(stateMutex_);
    return threadCreated_ ? 1 : 0;
}

int TcpClient::Send(const char *data, int length)
{
    int socketFd = -1;
    ssize_t sentSize = 0;

    if (data == nullptr || length <= 0) {
        TCP_LOGE("send failed: invalid data or length");
        return 0;
    }

    {
        std::lock_guard<std::mutex> lock(stateMutex_);
        if (!threadCreated_ || socketFd_ < 0) {
            TCP_LOGW("send failed: tcp client is not connected");
            return 0;
        }

        socketFd = socketFd_;
        sentSize = send(socketFd, data, static_cast<size_t>(length), 0);
    }

    if (sentSize < 0) {
        TCP_LOGE("send failed. errno=%{public}d", errno);
        return 0;
    }

    if (sentSize != length) {
        TCP_LOGW("send incomplete. expected=%{public}d actual=%{public}d", length, static_cast<int>(sentSize));
        return 0;
    }

    TCP_LOGI("send success. length=%{public}d", length);
    return 1;
}

void *TcpClient::ThreadMainEntry(void *arg)
{
    static_cast<TcpClient *>(arg)->ThreadMain();
    return nullptr;
}

void TcpClient::ThreadMain()
{
    char host[256] = {0};
    int port = 0;
    std::array<std::uint8_t, 4096> recvBuffer {};

    while (true) {
        {
            std::lock_guard<std::mutex> lock(stateMutex_);
            if (!shouldRun_) {
                break;
            }
            std::snprintf(host, sizeof(host), "%s", serverHost_);
            port = serverPort_;
        }

        const int socketFd = Connect(host, port);
        if (socketFd < 0) {
            SleepSeconds(3);
            continue;
        }

        {
            std::lock_guard<std::mutex> lock(stateMutex_);
            if (!shouldRun_) {
                close(socketFd);
                break;
            }
            socketFd_ = socketFd;
        }

        TCP_LOGI("connected. host=%{public}s port=%{public}d", host, port);

        while (true) {
            const ssize_t receivedSize = recv(socketFd, recvBuffer.data(), recvBuffer.size(), 0);
            if (receivedSize > 0) {
                TCP_LOGI("received packet. length=%{public}d", static_cast<int>(receivedSize));
                HandleReceivedBytes(recvBuffer.data(), static_cast<std::size_t>(receivedSize));
                continue;
            }

            if (receivedSize == 0) {
                TCP_LOGW("server closed connection");
            } else if (errno != EINTR) {
                TCP_LOGE("recv failed. errno=%{public}d", errno);
            }
            break;
        }

        bool shouldContinue = false;
        {
            std::lock_guard<std::mutex> lock(stateMutex_);
            if (socketFd_ == socketFd) {
                CloseSocketLocked();
            } else {
                close(socketFd);
            }
            shouldContinue = shouldRun_;
        }

        if (!shouldContinue) {
            break;
        }

        SleepSeconds(3);
    }

    std::lock_guard<std::mutex> lock(stateMutex_);
    threadCreated_ = false;
    CloseSocketLocked();
}

void TcpClient::SleepSeconds(unsigned int seconds)
{
    while (seconds > 0) {
        seconds = sleep(seconds);
    }
}

int TcpClient::Connect(const char *host, int port)
{
    struct addrinfo hints;
    struct addrinfo *result = nullptr;
    struct addrinfo *current = nullptr;
    char portBuffer[16];
    int socketFd = -1;

    std::memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    std::snprintf(portBuffer, sizeof(portBuffer), "%d", port);
    const int status = getaddrinfo(host, portBuffer, &hints, &result);
    if (status != 0) {
        TCP_LOGE("getaddrinfo failed. host=%{public}s port=%{public}d reason=%{public}s",
            host, port, gai_strerror(status));
        return -1;
    }

    for (current = result; current != nullptr; current = current->ai_next) {
        socketFd = socket(current->ai_family, current->ai_socktype, current->ai_protocol);
        if (socketFd < 0) {
            continue;
        }

        if (connect(socketFd, current->ai_addr, current->ai_addrlen) == 0) {
            break;
        }

        close(socketFd);
        socketFd = -1;
    }

    freeaddrinfo(result);
    return socketFd;
}

void TcpClient::CloseSocketLocked()
{
    if (socketFd_ >= 0) {
        shutdown(socketFd_, SHUT_RDWR);
        close(socketFd_);
        socketFd_ = -1;
    }
}

void TcpClient::HandleReceivedBytes(const std::uint8_t *data, std::size_t length)
{
    if (data == nullptr || length == 0) {
        return;
    }

    if (length >= decodeBuffer_.size()) {
        TCP_LOGW("received packet is too large to decode. length=%{public}d", static_cast<int>(length));
        return;
    }

    std::memcpy(decodeBuffer_.data(), data, length);
    bufferedSize_ = length;
    DispatchDecodedFrames();
}

void TcpClient::DispatchDecodedFrames()
{
    std::uint16_t commonAddr = 0;
    std::uint16_t objectAddr = 0;
    std::size_t decodeOffset = 0;
    bool finishFlag = false;

    while (!finishFlag) {
        if (!TryReadUint16(decodeOffset, &commonAddr)) {
            TCP_LOGW("decode stopped: missing common address. offset=%{public}d", static_cast<int>(decodeOffset));
            break;
        }
        decodeOffset += sizeof(std::uint16_t);

        if (!TryReadUint16(decodeOffset, &objectAddr)) {
            TCP_LOGW("decode stopped: missing object address. offset=%{public}d", static_cast<int>(decodeOffset));
            break;
        }

        switch (commonAddr) {
            case Common_Addr_RemoteMetry:
                decodeOffset += sizeof(std::uint16_t);
                DecodeRemoteMetryPacket(objectAddr, &decodeOffset);
                break;
            case Common_Addr_RemoteSignal:
                decodeOffset += sizeof(std::uint16_t);
                DecodeRemoteSignalPacket(objectAddr, &decodeOffset);
                break;
            case Common_Addr_RemoteAdjust:
                decodeOffset += sizeof(std::uint16_t);
                TCP_LOGI("objectAddr = %{public}u", objectAddr);
                DecodeRemoteAdjustPacket(objectAddr, &decodeOffset);
                break;
            case Common_Addr_SOE:
                DecodeSoePackage(objectAddr, &decodeOffset);
                break;
            default:
                TCP_LOGW("decode stopped: unsupported common address=%{public}u", commonAddr);
                finishFlag = true;
                break;
        }

        if (decodeOffset >= bufferedSize_) {
            finishFlag = true;
        }
    }
}

bool TcpClient::TryReadUint16(std::size_t offset, std::uint16_t *value) const
{
    if (value == nullptr || offset + sizeof(std::uint16_t) > bufferedSize_) {
        return false;
    }

    *value = static_cast<std::uint16_t>(decodeBuffer_[offset]) |
        (static_cast<std::uint16_t>(decodeBuffer_[offset + 1]) << 8);
    return true;
}

void TcpClient::DecodeRemoteMetryPacket(std::uint16_t objectAddr, std::size_t *decodeOffset)
{
    std::uint16_t dataLength = 0;
    if (decodeOffset == nullptr) {
        return;
    }

    if (!TryReadUint16(*decodeOffset, &dataLength)) {
        TCP_LOGW("RemoteMetry_Decode stopped: missing data length. offset=%{public}d", static_cast<int>(*decodeOffset));
        *decodeOffset = bufferedSize_;
        return;
    }
    *decodeOffset += sizeof(std::uint16_t);

    const std::size_t payloadOffset = *decodeOffset;
    const std::size_t payloadLength = static_cast<std::size_t>(dataLength);
    if (payloadOffset + payloadLength > bufferedSize_) {
        TCP_LOGW("RemoteMetry_Decode stopped: payload overflow. object=%{public}u length=%{public}d",
            objectAddr, dataLength);
        *decodeOffset = bufferedSize_;
        return;
    }

    switch (objectAddr) {
        case RemoteMetry_BaseFreq:
            if (payloadLength == BaseFreq_DataLenth) {
                std::memcpy(&BaseFreq_Dsip, decodeBuffer_.data() + payloadOffset, sizeof(YC_BaseFreq_Struct));
                BaseFreqDisplayReady = true;
                TCP_LOGI("BaseFreq_Dsip updated");
            } else {
                TCP_LOGW("BaseFreq_Dsip length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(BaseFreq_DataLenth), dataLength);
            }
            break;
        case RemoteMetry_PowerEnergy:
            if (payloadLength == Energy_DataLenth) {
                std::memcpy(&Energy_Dsip, decodeBuffer_.data() + payloadOffset, sizeof(YC_Energy_Struct));
                TCP_LOGI("Energy_Dsip updated");
            } else {
                TCP_LOGW("Energy_Dsip length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(Energy_DataLenth), dataLength);
            }
            break;
        case RemoteMetry_HarmonicU:
            if (payloadLength == HarmonicU_DataLenth) {
                std::memcpy(&HarmonicU_Dsip, decodeBuffer_.data() + payloadOffset, sizeof(YC_HarmonicU_Struct));
                TCP_LOGI("HarmonicU_Dsip updated");
            } else {
                TCP_LOGW("HarmonicU_Dsip length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(HarmonicU_DataLenth), dataLength);
            }
            break;
        case RemoteMetry_HarmonicI:
            if (payloadLength == HarmonicI_DataLenth) {
                std::memcpy(&HarmonicI_Dsip, decodeBuffer_.data() + payloadOffset, sizeof(YC_HarmonicI_Struct));
                HarmonicCurrentDisplayReady = true;
                TCP_LOGI("HarmonicI_Dsip updated");
            } else {
                TCP_LOGW("HarmonicI_Dsip length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(HarmonicI_DataLenth), dataLength);
            }
            break;
        default:
            TCP_LOGW("RemoteMetry_Decode ignored unsupported object=%{public}u", objectAddr);
            break;
    }

    *decodeOffset += payloadLength;
}

void TcpClient::DecodeRemoteSignalPacket(std::uint16_t objectAddr, std::size_t *decodeOffset)
{
    std::uint16_t dataLength = 0;
    if (decodeOffset == nullptr) {
        return;
    }

    if (!TryReadUint16(*decodeOffset, &dataLength)) {
        TCP_LOGW("RemoteSignal_Decode stopped: missing data length. offset=%{public}d", static_cast<int>(*decodeOffset));
        *decodeOffset = bufferedSize_;
        return;
    }
    *decodeOffset += sizeof(std::uint16_t);

    const std::size_t payloadOffset = *decodeOffset;
    const std::size_t payloadLength = static_cast<std::size_t>(dataLength);
    if (payloadOffset + payloadLength > bufferedSize_) {
        TCP_LOGW("RemoteSignal_Decode stopped: payload overflow. object=%{public}u length=%{public}d",
            objectAddr, dataLength);
        *decodeOffset = bufferedSize_;
        return;
    }

    RemoteSignal_Change_Struct yxChangeVal {};
    if (payloadLength >= sizeof(yxChangeVal)) {
        std::memcpy(&yxChangeVal, decodeBuffer_.data() + payloadOffset, sizeof(yxChangeVal));
    }
    *decodeOffset += payloadLength;

    std::uint16_t crcWords[YX_Change_CRC16Lenth] = {0};
    std::memcpy(crcWords, &yxChangeVal.State, sizeof(crcWords));
    const std::uint16_t tCRC = CRC16(crcWords, YX_Change_CRC16Lenth);

    if (dataLength != YX_Change_DataLenth || tCRC != yxChangeVal.CRC) {
        TCP_LOGW("RemoteSignal_Decode CRC/length error. object=%{public}u expectedLen=%{public}d actualLen=%{public}d crc=%{public}u packetCrc=%{public}u",
            objectAddr, static_cast<int>(YX_Change_DataLenth), dataLength, tCRC, yxChangeVal.CRC);
        return;
    }

    if (YX_Change_Queue.size() < DATA_QUEUE_MAX_LENGTH) {
        YX_Change_Queue.push_back(yxChangeVal);
    }

    const std::uint16_t tempState = yxChangeVal.State;
    const bool stateBool = (yxChangeVal.State == SW_Close);

    if ((objectAddr & RemoteSignal_Type_Mask) == RemoteSignal_RAState_Mask) {
        switch (objectAddr) {
            case YX_ObjectAddr_CommonSetting_PrimarySystem:
                TCP_LOGI("RemoteSignal confirm CommonSetting_PrimarySystem. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_ProtectionSoftStrap:
                TCP_LOGI("RemoteSignal confirm ProtectionSoftStrap. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_RelaySetting_AreaCode:
                TCP_LOGI("RemoteSignal confirm RelaySetting_AreaCode. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_RelaySetting:
                TCP_LOGI("RemoteSignal confirm RelaySetting. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_AnalogQuantity:
                TCP_LOGI("RemoteSignal confirm CommonSetting_AnalogQuantity. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_TeleMeasuring:
                TCP_LOGI("RemoteSignal confirm CommonSetting_TeleMeasuring. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_TeleSignaling:
                TCP_LOGI("RemoteSignal confirm CommonSetting_TeleSignaling. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_TeleControlling:
                TCP_LOGI("RemoteSignal confirm CommonSetting_TeleControlling. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_ExceedingLimit:
                TCP_LOGI("RemoteSignal confirm CommonSetting_ExceedingLimit. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            case YX_ObjectAddr_CommonSetting_Statistics:
                TCP_LOGI("RemoteSignal confirm CommonSetting_Statistics. state=%{public}s",
                    stateBool ? "true" : "false");
                break;
            default:
                TCP_LOGI("RemoteSignal confirm unsupported RAState object=%{public}u state=%{public}s",
                    objectAddr, stateBool ? "true" : "false");
                break;
        }
        return;
    }

    if ((objectAddr & RemoteSignal_Type_Mask) == RemoteSignal_DI_Mask) {
        switch (objectAddr) {
            case RemoteSignal_MonitoringKM:
                DigitalInputData.MonitoringKM = yxChangeVal.State;
                break;
            case RemoteSignal_DisableReclose:
                DigitalInputData.DisableReclose = yxChangeVal.State;
                break;
            case RemoteSignal_SprintLessEnergy:
                DigitalInputData.SprintLessEnergy = yxChangeVal.State;
                break;
            case RemoteSignal_ExternalTrip:
                DigitalInputData.ExternalTrip = yxChangeVal.State;
                break;
            case RemoteSignal_ExternalClose:
                DigitalInputData.ExternalClose = yxChangeVal.State;
                break;
            case RemoteSignal_PWRboard24V:
                DigitalInputData.PWRboard24V = yxChangeVal.State;
                break;
            case RemoteSignal_TWJ:
                DigitalInputData.TWJ_Flag = yxChangeVal.State;
                break;
            case RemoteSignal_HWJ:
                DigitalInputData.HWJ_Flag = yxChangeVal.State;
                break;
            case RemoteSignal_HHJ:
                DigitalInputData.HHJ_Flag = yxChangeVal.State;
                break;
            case RemoteSignal_STJ:
                DigitalInputData.STJ_Flag = yxChangeVal.State;
                break;
            case RemoteSignal_RTJ:
                DigitalInputData.RTJ_Flag = yxChangeVal.State;
                break;
            case RemoteSignal_PilotProtection:
                DigitalInputData.PilotProtection = yxChangeVal.State;
                break;
            case RemoteSignal_LowFreqProtection:
                DigitalInputData.LowFreqProtection = yxChangeVal.State;
                break;
            case RemoteSignal_LowVoltProtection:
                DigitalInputData.LowVoltProtection = yxChangeVal.State;
                break;
            case RemoteSignal_OutageReclose:
                DigitalInputData.OutageReclose = yxChangeVal.State;
                break;
            case RemoteSignal_ResetButton:
                DigitalInputData.ResetButton = yxChangeVal.State;
                break;
            case RemoteSignal_DeviceMaintain:
                DigitalInputData.DeviceMaintain = yxChangeVal.State;
                break;
            case RemoteSignal_RemoteOrLocal:
                DigitalInputData.RemoteOrLocal = yxChangeVal.State;
                break;
            case RemoteSignal_GroundingChoicTrip:
                DigitalInputData.GroundingChoicTrip = yxChangeVal.State;
                break;
            case RemoteSignal_BreakState:
                BreakerState_Now = yxChangeVal.State;
                if (BreakerState_Now == SW_Close) {
                    TCP_LOGI("BreakerState_Now updated to SW_Close");
                } else if (BreakerState_Now == SW_Open) {
                    TCP_LOGI("BreakerState_Now updated to SW_Open");
                } else {
                    TCP_LOGI("BreakerState_Now updated to unknown state=%{public}u", BreakerState_Now);
                }
                break;
            default:
                TCP_LOGI("RemoteSignal DI unsupported object=%{public}u state=%{public}u", objectAddr, yxChangeVal.State);
                break;
        }
        return;
    }

    if ((objectAddr & RemoteSignal_Type_Mask) == RemoteSignal_LED_Mask) {
        switch (objectAddr) {
            case RemoteSignal_LED_Run:
                TCP_LOGI("RemoteSignal LED Run=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Triping:
                TCP_LOGI("RemoteSignal LED Triping=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Closing:
                TCP_LOGI("RemoteSignal LED Closing=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Charge:
                TCP_LOGI("RemoteSignal LED Charge=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Sync:
                TCP_LOGI("RemoteSignal LED Sync=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Comm:
                TCP_LOGI("RemoteSignal LED Comm=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            case RemoteSignal_LED_Backup:
                TCP_LOGI("RemoteSignal LED Backup=%{public}s", tempState == LED_On ? "ON" : "OFF");
                break;
            default:
                TCP_LOGI("RemoteSignal LED unsupported object=%{public}u state=%{public}u", objectAddr, tempState);
                break;
        }
        return;
    }

    TCP_LOGI("RemoteSignal object without handler. object=%{public}u state=%{public}u", objectAddr, yxChangeVal.State);
}

void TcpClient::DecodeRemoteAdjustPacket(std::uint16_t objectAddr, std::size_t *decodeOffset)
{
    std::uint16_t dataLength = 0;
    if (decodeOffset == nullptr) {
        return;
    }

    if (!TryReadUint16(*decodeOffset, &dataLength)) {
        TCP_LOGW("RemoteAdjust_Decode stopped: missing data length. offset=%{public}d", static_cast<int>(*decodeOffset));
        *decodeOffset = bufferedSize_;
        return;
    }
    *decodeOffset += sizeof(std::uint16_t);

    const std::size_t payloadOffset = *decodeOffset;
    const std::size_t payloadLength = static_cast<std::size_t>(dataLength);
    if (payloadOffset + payloadLength > bufferedSize_) {
        TCP_LOGW("RemoteAdjust_Decode stopped: payload overflow. object=%{public}u length=%{public}d",
            objectAddr, dataLength);
        *decodeOffset = bufferedSize_;
        return;
    }

    switch (objectAddr) {
        case YT_ObjectAddr_CommonSetting_PrimarySystem:
            if (payloadLength == CommonSetting_PrimarySystem_Length_1Byte) {
                CommonSetting_PrimarySystem_Struct primarySystemBuf {};
                const std::uint8_t *primarySystemPayload = decodeBuffer_.data() + payloadOffset;
                LogPrimarySystemPayloadHex(primarySystemPayload, payloadLength);
                if (IsAllBytesValue(primarySystemPayload, payloadLength, 0xFF)) {
                    TCP_LOGW("CommonSetting_PrimarySystem payload is all 0xFF, ignored as invalid");
                    break;
                }
                std::memcpy(&primarySystemBuf, primarySystemPayload, sizeof(primarySystemBuf));
                const std::uint32_t tempCRC = CRC32(reinterpret_cast<std::uint32_t *>(&primarySystemBuf), CommonSetting_PrimarySystem_CRCLength_4Byte);
                if (tempCRC == primarySystemBuf.CRC) {
                    std::memcpy(&PrimarySystemSetting, &primarySystemBuf, sizeof(PrimarySystemSetting));
                    PrimarySystemSettingReady = true;
                    TCP_LOGI("CommonSetting_PrimarySystem updated");
                    LogPrimarySystemSetting(PrimarySystemSetting);
                } else {
                    TCP_LOGW("CommonSetting_PrimarySystem CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, primarySystemBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_PrimarySystem length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_PrimarySystem_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_ProtectionSoftStrap:
            if (payloadLength == SoftStrap_DataLength) {
                ProtectionSoftStrap_Struct softStrapBuf {};
                std::memcpy(&softStrapBuf, decodeBuffer_.data() + payloadOffset, sizeof(softStrapBuf));
                const std::uint32_t tempCRC = CRC32(reinterpret_cast<std::uint32_t *>(&softStrapBuf), SoftStrap_CRCLength);
                if (tempCRC == softStrapBuf.CRC) {
                    std::memcpy(&ProtectionSoftStrap_Buf, &softStrapBuf, sizeof(ProtectionSoftStrap_Buf));
                    std::memcpy(&ProtectionSoftStrap, &softStrapBuf, sizeof(ProtectionSoftStrap));
                    TCP_LOGI("ProtectionSoftStrap updated");
                } else {
                    TCP_LOGW("ProtectionSoftStrap CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, softStrapBuf.CRC);
                }
            } else {
                TCP_LOGW("ProtectionSoftStrap length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(SoftStrap_DataLength), dataLength);
            }
            break;
        case YT_ObjectAddr_RelaySetting_AreaCode:
            if (payloadLength == 4) {
                std::uint16_t tempCode = 0;
                std::uint16_t tempCode2 = 0;
                if (TryReadUint16(payloadOffset, &tempCode) &&
                    TryReadUint16(payloadOffset + sizeof(std::uint16_t), &tempCode2)) {
                    if (tempCode == tempCode2) {
                        SettingCode_Now = tempCode;
                        TCP_LOGI("SettingCode_Now updated to %{public}u", tempCode);
                    } else {
                        TCP_LOGW("SettingCode_Now mismatch. first=%{public}u second=%{public}u", tempCode, tempCode2);
                    }
                } else {
                    TCP_LOGW("SettingCode_Now decode failed: insufficient bytes");
                }
            } else {
                TCP_LOGW("SettingCode_Now length mismatch. expected=4 actual=%{public}d", dataLength);
            }
            break;
        case YT_ObjectAddr_RelaySetting:
            if (payloadLength == (RelaySetting_DataLength + sizeof(std::uint16_t))) {
                std::uint16_t tempCode = 0;
                if (!TryReadUint16(payloadOffset, &tempCode)) {
                    TCP_LOGW("RelaySetting decode failed: missing setting code");
                    break;
                }

                RelaySetting_Struct relaySettingBuf {};
                std::memcpy(&relaySettingBuf, decodeBuffer_.data() + payloadOffset + sizeof(std::uint16_t), sizeof(relaySettingBuf));
                const std::uint32_t tempCRC = CRC32(reinterpret_cast<std::uint32_t *>(&relaySettingBuf), RelaySetting_CRCLength);
                if ((tempCRC == relaySettingBuf.CRC) && (tempCode >= 1) && (tempCode <= 20)) {
                    std::memcpy(&RelaySetting[tempCode - 1], &relaySettingBuf, sizeof(relaySettingBuf));
                    RelaySettingReady[tempCode - 1] = true;
                    TCP_LOGI("RelaySetting updated. code=%{public}u", tempCode);
                } else {
                    TCP_LOGW("RelaySetting CRC/code error. calc=%{public}u packet=%{public}u code=%{public}u",
                        tempCRC, relaySettingBuf.CRC, tempCode);
                }
            } else {
                TCP_LOGW("RelaySetting length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(RelaySetting_DataLength + sizeof(std::uint16_t)), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_AnalogQuantity:
            if (payloadLength == CommonSetting_AnalogQuantity_Length_1Byte) {
                CommonSetting_AnalogQuantity_Struct analogQuantityBuf {};
                std::memcpy(&analogQuantityBuf, decodeBuffer_.data() + payloadOffset, sizeof(analogQuantityBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&analogQuantityBuf), CommonSetting_AnalogQuantity_CRCLength_4Byte);
                if (tempCRC == analogQuantityBuf.CRC) {
                    std::memcpy(&AnalogQuantitySetting, &analogQuantityBuf, sizeof(AnalogQuantitySetting));
                    AnalogQuantitySettingReady = true;
                    TCP_LOGI("CommonSetting_AnalogQuantity updated");
                    LogAnalogQuantitySetting(AnalogQuantitySetting);
                } else {
                    TCP_LOGW("CommonSetting_AnalogQuantity CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, analogQuantityBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_AnalogQuantity length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_AnalogQuantity_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_TeleMeasuring:
            if (payloadLength == CommonSetting_YC_Length_1Byte) {
                CommonSetting_TeleMeasuring_Struct teleMeasuringBuf {};
                std::memcpy(&teleMeasuringBuf, decodeBuffer_.data() + payloadOffset, sizeof(teleMeasuringBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&teleMeasuringBuf), CommonSetting_YC_CRCLength_4Byte);
                if (tempCRC == teleMeasuringBuf.CRC) {
                    std::memcpy(&TeleMeasuringSetting, &teleMeasuringBuf, sizeof(TeleMeasuringSetting));
                    TeleMeasuringSettingReady = true;
                    TCP_LOGI("CommonSetting_TeleMeasuring updated");
                    LogTeleMeasuringSetting(TeleMeasuringSetting);
                } else {
                    TCP_LOGW("CommonSetting_TeleMeasuring CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, teleMeasuringBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_TeleMeasuring length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_YC_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_TeleSignaling:
            if (payloadLength == CommonSetting_YX_Length_1Byte) {
                CommonSetting_TeleSignaling_Struct teleSignalingBuf {};
                std::memcpy(&teleSignalingBuf, decodeBuffer_.data() + payloadOffset, sizeof(teleSignalingBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&teleSignalingBuf), CommonSetting_YX_CRCLength_4Byte);
                if (tempCRC == teleSignalingBuf.CRC) {
                    std::memcpy(&TeleSignalingSetting, &teleSignalingBuf, sizeof(TeleSignalingSetting));
                    TeleSignalingSettingReady = true;
                    TCP_LOGI("CommonSetting_TeleSignaling updated");
                    LogTeleSignalingSetting(TeleSignalingSetting);
                } else {
                    TCP_LOGW("CommonSetting_TeleSignaling CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, teleSignalingBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_TeleSignaling length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_YX_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_TeleControlling:
            if (payloadLength == CommonSetting_YK_Length_1Byte) {
                CommonSetting_TeleControlling_Struct teleControllingBuf {};
                std::memcpy(&teleControllingBuf, decodeBuffer_.data() + payloadOffset, sizeof(teleControllingBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&teleControllingBuf), CommonSetting_YK_CRCLength_4Byte);
                if (tempCRC == teleControllingBuf.CRC) {
                    std::memcpy(&TeleControllingSetting, &teleControllingBuf, sizeof(TeleControllingSetting));
                    TeleControllingSettingReady = true;
                    TCP_LOGI("CommonSetting_TeleControlling updated");
                    LogTeleControllingSetting(TeleControllingSetting);
                } else {
                    TCP_LOGW("CommonSetting_TeleControlling CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, teleControllingBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_TeleControlling length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_YK_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_ExceedingLimit:
            if (payloadLength == CommonSetting_ExceedingLimit_Length_1Byte) {
                CommonSetting_ExceedingLimit_Struct exceedingLimitBuf {};
                std::memcpy(&exceedingLimitBuf, decodeBuffer_.data() + payloadOffset, sizeof(exceedingLimitBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&exceedingLimitBuf), CommonSetting_ExceedingLimit_CRCLength_4Byte);
                if (tempCRC == exceedingLimitBuf.CRC) {
                    std::memcpy(&ExceedingLimitSetting, &exceedingLimitBuf, sizeof(ExceedingLimitSetting));
                    ExceedingLimitSettingReady = true;
                    TCP_LOGI("CommonSetting_ExceedingLimit updated");
                    LogExceedingLimitSetting(ExceedingLimitSetting);
                } else {
                    TCP_LOGW("CommonSetting_ExceedingLimit CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, exceedingLimitBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_ExceedingLimit length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_ExceedingLimit_Length_1Byte), dataLength);
            }
            break;
        case YT_ObjectAddr_CommonSetting_Statistics:
            if (payloadLength == CommonSetting_Statistics_Length_1Byte) {
                CommonSetting_Statistics_Struct statisticsBuf {};
                std::memcpy(&statisticsBuf, decodeBuffer_.data() + payloadOffset, sizeof(statisticsBuf));
                const std::uint32_t tempCRC =
                    CRC32(reinterpret_cast<std::uint32_t *>(&statisticsBuf), CommonSetting_Statistics_CRCLength_4Byte);
                if (tempCRC == statisticsBuf.CRC) {
                    std::memcpy(&StatisticsSetting, &statisticsBuf, sizeof(StatisticsSetting));
                    StatisticsSettingReady = true;
                    TCP_LOGI("CommonSetting_Statistics updated");
                } else {
                    TCP_LOGW("CommonSetting_Statistics CRC error. calc=%{public}u packet=%{public}u",
                        tempCRC, statisticsBuf.CRC);
                }
            } else {
                TCP_LOGW("CommonSetting_Statistics length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(CommonSetting_Statistics_Length_1Byte), dataLength);
            }
            break;
        default:
            TCP_LOGW("RemoteAdjust_Decode ignored unsupported object=%{public}u", objectAddr);
            break;
    }

    *decodeOffset += payloadLength;
}

void TcpClient::DecodeSoePackage(std::uint16_t objectAddr, std::size_t *decodeOffset)
{
    if (decodeOffset == nullptr) {
        return;
    }

    const std::size_t packetOffset = *decodeOffset;
    std::uint16_t dataLength = 0;
    if (!TryReadUint16(packetOffset + sizeof(std::uint16_t), &dataLength)) {
        TCP_LOGW("SOE_Pakage_Decode stopped: missing data length. offset=%{public}d", static_cast<int>(packetOffset));
        *decodeOffset = bufferedSize_;
        return;
    }

    const std::size_t payloadLength = static_cast<std::size_t>(dataLength);
    const std::size_t packetLength = sizeof(std::uint16_t) * 2 + payloadLength;
    if (packetOffset + packetLength > bufferedSize_) {
        TCP_LOGW("SOE_Pakage_Decode stopped: payload overflow. object=%{public}u length=%{public}d",
            objectAddr, dataLength);
        *decodeOffset = bufferedSize_;
        return;
    }

    const std::uint16_t soeMark = static_cast<std::uint16_t>(objectAddr & 0xF000);
    auto pushSoeNode = [&](const SOE_Node_Struct &soeNode) {
        if (SOE_Node_Queue.size() < DATA_QUEUE_MAX_LENGTH) {
            SOE_Node_Queue.push_back(soeNode);
            return;
        }
        TCP_LOGW("SOE_Node_Queue is full. object=%{public}u", objectAddr);
    };

    switch (soeMark) {
        case SOE_StartMark:
            if (dataLength == SOE_StartDataLen) {
                SOE_Start_Struct soeStartInfo {};
                SOE_Node_Struct soeNodeBuf {};

                std::memcpy(&soeStartInfo, decodeBuffer_.data() + packetOffset, sizeof(soeStartInfo));
                soeNodeBuf.type = SOE_Type_Start;
                soeNodeBuf.Object_addr = soeStartInfo.Object_addr;
                soeNodeBuf.GroupNum = soeStartInfo.GroupNum;
                soeNodeBuf.Information = soeStartInfo.Information;
                soeNodeBuf.Time_ms = static_cast<std::uint16_t>(soeStartInfo.Time_ms % 1000);
                soeNodeBuf.Time_s = static_cast<std::uint8_t>(soeStartInfo.Time_ms / 1000);
                soeNodeBuf.Time_min = soeStartInfo.Time_min;
                soeNodeBuf.Time_hour = soeStartInfo.Time_hour;
                soeNodeBuf.Time_day = soeStartInfo.Time_day;
                soeNodeBuf.Time_month = soeStartInfo.Time_month;
                soeNodeBuf.Time_year = soeStartInfo.Time_year;
                pushSoeNode(soeNodeBuf);
                TCP_LOGI("SOE_Type_Start decoded. object=%{public}u group=%{public}u",
                    soeNodeBuf.Object_addr, soeNodeBuf.GroupNum);
            } else {
                TCP_LOGW("SOE_Type_Start length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(SOE_StartDataLen), dataLength);
            }
            break;
        case SOE_ActMark:
            if (dataLength == SOE_ActDataLen) {
                SOE_Act_Struct soeActInfo {};
                SOE_Node_Struct soeNodeBuf {};

                std::memcpy(&soeActInfo, decodeBuffer_.data() + packetOffset, sizeof(soeActInfo));
                soeNodeBuf.type = SOE_Type_Act;
                soeNodeBuf.Object_addr = soeActInfo.Object_addr;
                soeNodeBuf.GroupNum = soeActInfo.GroupNum;
                soeNodeBuf.Information = soeActInfo.Information;
                soeNodeBuf.Time_ms = soeActInfo.Time_ms;
                pushSoeNode(soeNodeBuf);
                TCP_LOGI("SOE_Type_Act decoded. object=%{public}u group=%{public}u",
                    soeNodeBuf.Object_addr, soeNodeBuf.GroupNum);
            } else {
                TCP_LOGW("SOE_Type_Act length mismatch. expected=%{public}d actual=%{public}d",
                    static_cast<int>(SOE_ActDataLen), dataLength);
            }
            break;
        case SOE_EventMark:
            TCP_LOGI("SOE_EventMark packet skipped. object=%{public}u length=%{public}d", objectAddr, dataLength);
            break;
        default:
            if (dataLength == SOE_3ValueDataLen) {
                SOE_3Value_Struct soe3Value {};
                SOE_Node_Struct soeNodeBuf {};

                std::memcpy(&soe3Value, decodeBuffer_.data() + packetOffset, sizeof(soe3Value));
                soeNodeBuf.type = SOE_Type_3Value;
                soeNodeBuf.Object_addr = soe3Value.Object_addr;
                soeNodeBuf.GroupNum = soe3Value.GroupNum;
                soeNodeBuf.Value1 = soe3Value.Value1;
                soeNodeBuf.Value2 = soe3Value.Value2;
                soeNodeBuf.Value3 = soe3Value.Value3;
                pushSoeNode(soeNodeBuf);
                TCP_LOGI("SOE_Type_3Value decoded. object=%{public}u group=%{public}u",
                    soeNodeBuf.Object_addr, soeNodeBuf.GroupNum);
            } else if (dataLength == SOE_2ValueDataLen) {
                SOE_2Value_Struct soe2Value {};
                SOE_Node_Struct soeNodeBuf {};

                std::memcpy(&soe2Value, decodeBuffer_.data() + packetOffset, sizeof(soe2Value));
                soeNodeBuf.type = SOE_Type_2Value;
                soeNodeBuf.Object_addr = soe2Value.Object_addr;
                soeNodeBuf.GroupNum = soe2Value.GroupNum;
                soeNodeBuf.Value1 = soe2Value.Value1;
                soeNodeBuf.Value2 = soe2Value.Value2;
                pushSoeNode(soeNodeBuf);
                TCP_LOGI("SOE_Type_2Value decoded. object=%{public}u group=%{public}u",
                    soeNodeBuf.Object_addr, soeNodeBuf.GroupNum);
            } else if (dataLength == SOE_1ValueDataLen) {
                SOE_1Value_Struct soe1Value {};
                SOE_Node_Struct soeNodeBuf {};

                std::memcpy(&soe1Value, decodeBuffer_.data() + packetOffset, sizeof(soe1Value));
                soeNodeBuf.type = SOE_Type_1Value;
                soeNodeBuf.Object_addr = soe1Value.Object_addr;
                soeNodeBuf.GroupNum = soe1Value.GroupNum;
                soeNodeBuf.Value1 = soe1Value.Value;
                pushSoeNode(soeNodeBuf);
                TCP_LOGI("SOE_Type_1Value decoded. object=%{public}u group=%{public}u",
                    soeNodeBuf.Object_addr, soeNodeBuf.GroupNum);
            } else {
                TCP_LOGW("SOE_Pakage_Decode ignored unsupported packet. object=%{public}u mark=0x%{public}x length=%{public}d",
                    objectAddr, soeMark, dataLength);
            }
            break;
    }

    *decodeOffset += packetLength;
}

void TcpClient::SkipUnsupportedDecode(const char *decoderName, std::uint16_t objectAddr, std::size_t *decodeOffset)
{
    TCP_LOGW("%{public}s is not integrated yet. object=%{public}u", decoderName, objectAddr);
    if (decodeOffset != nullptr) {
        *decodeOffset = bufferedSize_;
    }
}
