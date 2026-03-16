# ArkTS 启动 TCP 客户端接入说明

## 需求

1. 在 `entry/src/main/cpp` 下新增一个 C 语言实现的 TCP 客户端。
2. ArkTS 界面打开时自动启动该 TCP 客户端。
3. Ability 销毁时停止客户端线程，避免重复启动和资源泄漏。

## 实现方案

1. 在 `entry/src/main/cpp/tcp_client.c` 中实现 TCP 客户端后台线程，负责连接服务端、接收数据、断线重连。
2. 在 `entry/src/main/cpp/napi_init.cpp` 中暴露 `startTcpClient`、`stopTcpClient`、`isTcpClientRunning` 给 ArkTS。
3. 在 `entry/src/main/ets/entryability/EntryAbility.ets` 的 `windowStage.loadContent` 成功回调里启动客户端。
4. 在 `onWindowStageDestroy` 和 `onDestroy` 中停止客户端。
5. 在 `entry/src/main/module.json5` 中补充 `ohos.permission.INTERNET` 权限。

## 当前默认配置

1. 服务器地址：`127.0.0.1`
2. 服务器端口：`9000`

如果后续要改服务端地址，直接改 `entry/src/main/ets/entryability/EntryAbility.ets` 里的 `TCP_SERVER_HOST` 和 `TCP_SERVER_PORT` 即可。

## 验证结果

1. 已执行 `assembleHap` 构建。
2. 结果为 `BUILD SUCCESSFUL`。
3. 当前构建里仍存在项目原有 ArkTS 过时 API 警告，例如 `pushUrl`、`back`、`getParams`，但不影响本次 TCP 客户端接入编译通过。
