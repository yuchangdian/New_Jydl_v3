# napi_init 切换到 cpp 说明

## 本次修改

已将 native 模块 `entry` 的构建入口从：

- `napi_init.c`

切换为：

- `napi_init.cpp`

修改文件：

- `entry/src/main/cpp/CMakeLists.txt`

修改前：

```cmake
add_library(entry SHARED napi_init.c tcp_client.c)
```

修改后：

```cmake
add_library(entry SHARED napi_init.cpp tcp_client.c)
```

## 为了保持原有功能不变，额外做的处理

不仅切换了 `CMakeLists.txt`，还把：

- `entry/src/main/cpp/napi_init.cpp`

收敛成了和：

- `entry/src/main/cpp/napi_init.c`

同一套导出逻辑。

当前 `napi_init.cpp` 保持了和原 `napi_init.c` 一致的能力：

1. 导出函数仍然是：
   - `startTcpClient`
   - `stopTcpClient`
   - `isTcpClientRunning`
   - `add`
2. `startTcpClient(host, port)` 的参数校验规则不变
3. `host` 字符串读取失败时的错误行为不变
4. `port` 的整数校验和范围校验不变
5. 底层仍然调用：
   - `tcp_client_start`
   - `tcp_client_stop`
   - `tcp_client_is_running`

也就是说，这次改动的核心是：

- **把 NAPI 入口的编译语言改成 C++**

而不是：

- 改 ArkTS 导出接口
- 改模块名
- 改 native 能力

## 当前含义

现在 ArkTS 侧加载的 `libentry.so`，其 NAPI 桥接入口将来自：

- `entry/src/main/cpp/napi_init.cpp`

不再来自：

- `entry/src/main/cpp/napi_init.c`

## 验证结果

已执行模块构建验证，结果：

- `assembleHap` 构建成功
- `BuildNativeWithNinja` 成功
- 当前 `libentry.so` 由 `napi_init.cpp` 参与编译

这说明当前工程已经完成：

1. 构建入口切到 `napi_init.cpp`
2. 现有 ArkTS 所依赖的原生导出能力未被破坏

## 后续注意

1. 后面如果继续扩展 C++ native 能力，应该优先改 `napi_init.cpp`，不要再改 `napi_init.c`。
2. 不要把 `napi_init.c` 和 `napi_init.cpp` 同时编进同一个 `libentry.so`，否则容易出现重复注册或行为混乱。
3. 如果后续要把更多 C++ 文件接进 `libentry.so`，继续在 `entry/src/main/cpp/CMakeLists.txt` 里追加 `.cpp` 文件即可。
4. 如果后续新增 ArkTS 可见导出，记得同步更新：
   - `entry/src/main/cpp/types/libentry/Index.d.ts`
   - `entry/src/mock/Libentry.mock.ets`
