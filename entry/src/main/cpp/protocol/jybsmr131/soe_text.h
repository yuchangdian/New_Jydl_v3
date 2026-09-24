#pragma once
#include "IEC104.h"
#include <string>

namespace jybsmr131 {
// 复用项目中已有的中文事件代码表，将 QString 返回值替换为 std::string。
// 未知事件仍返回空字符串，交给调用方显示原始代码。
std::string SOE_StartString(std::uint16_t code);
std::string SOE_ActString(std::uint16_t code);
std::string SOE_PhaseString(std::uint8_t phase);
std::string SOE_3ValString(const SOE_Node_Struct &node);
std::string SOE_2ValString(const SOE_Node_Struct &node);
std::string SOE_1ValString(const SOE_Node_Struct &node);
}
