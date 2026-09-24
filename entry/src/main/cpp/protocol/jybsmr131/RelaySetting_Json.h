#pragma once

namespace jybsmr131 {
// 原文件仅提供此函数声明，没有实现和 JSON 字段约定。
// 保留函数类型供后续对接，不声明一个没有实现的可调用导出，也不猜测报文格式。
// 原签名：char* build_json(int code, int direction, long long timestamp_ms);
using BuildJsonFunction = char *(*)(int code, int direction, long long timestamp_ms);
}
