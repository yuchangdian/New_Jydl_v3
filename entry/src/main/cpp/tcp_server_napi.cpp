#include "tcp_server_napi.h"
#include "tcp_server.h"
#include <cmath>

namespace {
napi_value Boolean(napi_env env, bool value)
{
    napi_value result;
    napi_get_boolean(env, value, &result);
    return result;
}
}

napi_value StartTcpServer(napi_env env, napi_callback_info info)
{
    std::size_t argc = 1;
    napi_value argument;
    if (napi_get_cb_info(env, info, &argc, &argument, nullptr, nullptr) != napi_ok) return nullptr;
    double port = TcpServer::kDefaultPort;
    if (argc > 0 && (napi_get_value_double(env, argument, &port) != napi_ok || !std::isfinite(port) ||
                     std::floor(port) != port || port < 1 || port > 65535)) {
        napi_throw_range_error(env, nullptr, "监听端口必须是 1～65535 的整数");
        return nullptr;
    }
    return Boolean(env, TcpServer::GetInstance().Start(static_cast<std::uint16_t>(port)));
}

napi_value StopTcpServer(napi_env env, napi_callback_info info)
{
    (void)info;
    TcpServer::GetInstance().Stop();
    napi_value result;
    napi_get_undefined(env, &result);
    return result;
}
napi_value IsTcpServerRunning(napi_env env, napi_callback_info info)
{
    (void)info;
    return Boolean(env, TcpServer::GetInstance().IsRunning());
}
napi_value IsTcpServerClientConnected(napi_env env, napi_callback_info info)
{
    (void)info;
    return Boolean(env, TcpServer::GetInstance().IsClientConnected());
}
