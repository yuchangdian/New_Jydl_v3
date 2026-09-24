#include "soe_text.h"
#include "../../IEC104.h"

namespace jybsmr131 {
namespace {
::SOE_Node_Struct ValueNode(const SOE_Node_Struct &node)
{
    // 旧版事件格式化只使用代码和值；不转换新版本更宽的分组号和时间字段。
    ::SOE_Node_Struct value = {};
    value.Object_addr = node.Object_addr;
    value.Value1 = node.Value1;
    value.Value2 = node.Value2;
    value.Value3 = node.Value3;
    return value;
}
}
std::string SOE_StartString(std::uint16_t code) { return ::SOE_StartString(code); }
std::string SOE_ActString(std::uint16_t code) { return ::SOE_ActString(code); }
std::string SOE_PhaseString(std::uint8_t phase) { return ::SOE_PhaseString(phase); }
std::string SOE_3ValString(const SOE_Node_Struct &node) { return ::SOE_3ValString(ValueNode(node)); }
std::string SOE_2ValString(const SOE_Node_Struct &node) { return ::SOE_2ValString(ValueNode(node)); }
std::string SOE_1ValString(const SOE_Node_Struct &node) { return ::SOE_1ValString(ValueNode(node)); }
}
