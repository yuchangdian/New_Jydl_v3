## 目标

把 `index.ets` 首页里的这 12 个相量显示变量接到 native 侧 `BaseFreq_Dsip`：

- `ua / ub / uc / u0 / ux`
- `ia / ib / ic / i0`
- `iia / iib / iic`

要求是页面打开后持续刷新，显示 `YC_BaseFreq_Struct BaseFreq_Dsip` 里的最新值。

## 本次实现

### 1. native 侧增加实时遥测导出

没有把这类实时量继续堆到 `napi_init.cpp` 或 `setting_napi.cpp`，单独新增了：

- `entry/src/main/cpp/telemetry_napi.h`
- `entry/src/main/cpp/telemetry_napi.cpp`

这里导出 `getBaseFreqDisplayData()`，专门给首页这种实时显示使用。

### 2. BaseFreq_Dsip 增加 ready 标志

新增：

- `data.h`：`extern bool BaseFreqDisplayReady;`
- `data.cpp`：`bool BaseFreqDisplayReady = false;`

TCP 收到 `RemoteMetry_BaseFreq` 报文并成功 `memcpy` 到 `BaseFreq_Dsip` 后，立即把该标志置为 `true`。

### 3. Index 页面 500ms 定时刷新

首页 `Index.ets` 新增：

- native 类型声明 `BaseFreqDisplayValue`
- native 模块加载逻辑
- `aboutToAppear()` 立即刷新一次
- `setInterval(..., 500)` 周期刷新
- `aboutToDisappear()` 清理定时器

刷新函数 `refreshBaseFreqDisplay()` 每次都从 native 调 `getBaseFreqDisplayData()`，拿到最新的 `BaseFreq_Dsip` 快照后，再更新页面状态变量。

## 字段对应关系

电压类：

- `ua` <- `Ua_Rms + Ua_Phase`
- `ub` <- `Ub_Rms + Ub_Phase`
- `uc` <- `Uc_Rms + Uc_Phase`
- `u0` <- `Uo_Rms + Uo_Phase`
- `ux` <- `Ux_Rms + Ux_Phase`

保护电流类：

- `ia` <- `IA_Rms + IA_Phase`
- `ib` <- `IB_Rms + IB_Phase`
- `ic` <- `IC_Rms + IC_Phase`
- `i0` <- `Io_Rms + Io_Phase`

测量电流类：

- `iia` <- `Ia_Rms + Ia_Phase`
- `iib` <- `Ib_Rms + Ib_Phase`
- `iic` <- `Ic_Rms + Ic_Phase`

不参与首页显示：

- `Iby1_Rms / Iby1_Phase`
- `Iby2_Rms / Iby2_Phase`
- `Iby3_Rms / Iby3_Phase`

## 显示格式

为了避免 `Index.ets` 原有历史编码问题继续污染相量字符串，这次没有直接依赖特殊符号字面量，而是用：

- `String.fromCharCode(8736)` 生成 `∠`
- `String.fromCharCode(176)` 生成 `°`

这样可以稳定拼成：

- 电压：`100.00V∠30.00°`
- 电流：`5.00A∠-12.50°`

## 这次额外处理

`Index.ets` 之前有历史编码污染迹象。为了避免新增逻辑把乱码扩散：

- 先把页面恢复到仓库里的原始版本
- 再重新补实时刷新逻辑
- 新增的相量格式化全部走安全拼接，不直接依赖有风险的乱码符号行

## 本次涉及文件

- `entry/src/main/cpp/data.h`
- `entry/src/main/cpp/data.cpp`
- `entry/src/main/cpp/tcp_client.cpp`
- `entry/src/main/cpp/telemetry_napi.h`
- `entry/src/main/cpp/telemetry_napi.cpp`
- `entry/src/main/cpp/napi_init.cpp`
- `entry/src/main/cpp/CMakeLists.txt`
- `entry/src/main/cpp/types/libentry/Index.d.ts`
- `entry/src/mock/Libentry.mock.ets`
- `entry/src/main/ets/pages/Index.ets`

## 验证结果

已执行：

`assembleHap --analyze=normal --parallel --incremental`

结果：

`BUILD SUCCESSFUL`

## 下一步

如果继续做，可以再把首页其它量也接上：

- `frequency`
- `voltage`
- `current`
- `power`
- `reactivePower`
- `powerFactor`
