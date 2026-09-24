#include "data.h"
#include <limits>

namespace jybsmr131 {
std::uint32_t Xor32(const std::uint8_t *data, std::size_t byteLength)
{
    if (!data || byteLength % 4 != 0) return 0;
    std::uint32_t result = 0;
    for (std::size_t i = 0; i < byteLength; i += 4) {
        result ^= static_cast<std::uint32_t>(data[i]) |
            (static_cast<std::uint32_t>(data[i + 1]) << 8) |
            (static_cast<std::uint32_t>(data[i + 2]) << 16) |
            (static_cast<std::uint32_t>(data[i + 3]) << 24);
    }
    return result;
}

std::uint16_t Xor16(const std::uint8_t *data, std::size_t byteLength)
{
    if (!data || byteLength % 2 != 0) return 0;
    std::uint16_t result = 0;
    for (std::size_t i = 0; i < byteLength; i += 2)
        result ^= static_cast<std::uint16_t>(data[i]) | (static_cast<std::uint16_t>(data[i + 1]) << 8);
    return result;
}

std::uint32_t CRC32(const void *data, std::uint32_t wordCount)
{
    if (wordCount > std::numeric_limits<std::size_t>::max() / 4) return 0;
    return Xor32(static_cast<const std::uint8_t *>(data), static_cast<std::size_t>(wordCount) * 4);
}

std::uint16_t CRC16(const void *data, std::uint16_t wordCount)
{
    return Xor16(static_cast<const std::uint8_t *>(data), static_cast<std::size_t>(wordCount) * 2);
}
} // namespace jybsmr131
