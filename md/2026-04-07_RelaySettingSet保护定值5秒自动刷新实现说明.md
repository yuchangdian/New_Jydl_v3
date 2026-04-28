# RelaySettingSet 保护定值 5 秒自动刷新实现说明

## 本次改动

1. 在 `entry/src/main/ets/pages/RelaySettingSet.ets` 增加了保护定值页自动刷新链路。
2. 页面进入后，首次加载完成会启动 `setTimeout + generation token` 方式的循环刷新。
3. 页面离开时会清理定时器，避免重复叠加。
4. 每轮自动刷新流程是：
   - 先调用 native `requestRelaySettingByZone(zoneCode)` 发送当前区读取请求。
   - 延迟 300ms 后读取 `getRelaySettingByZone(zoneCode)` 返回的缓存值。
   - 若 native 数据就绪，则轻量更新 `currentProfileData`、`lastSyncedProfileData`、`currentDisplayValues`、`currentWidthCache`。
5. 自动刷新不会重新走页面初始化加载流程，不会重置 `visibleSectionCount` 和 `visibleMonitorSectionCount`。

## 未提交编辑保护

1. 页面新增了 `lastSyncedProfileData` 和 `hasPendingLocalEdits`。
2. 输入框或选择框发生编辑后，会按字段比对 `currentProfileData` 和 `lastSyncedProfileData`。
3. 只要存在未提交改动，自动刷新就暂停，不会覆盖当前输入。
4. 点击提交成功后，会把当前页面值同步为新的 `lastSyncedProfileData`，然后恢复自动刷新。
5. 点击默认值后，也会同步新的基线值并恢复自动刷新。

## Native 请求链路

1. 在 `entry/src/main/cpp/setting_napi.cpp` 新增了 `RequestRelaySettingByZone`。
2. 该接口会发送两帧：
   - `YT_ObjectAddr_RelaySetting_AreaCode`，先切当前区号。
   - `YT_ObjectAddr_RelaySetting`，再请求当前区保护定值。
3. 已增加发送日志，日志内容包含区号、对象地址、发送长度和是否发送成功。
4. `tcp_client.cpp` 原有回包解析逻辑继续复用，收到回包后仍写入 `RelaySetting[zoneIndex]` 和 `RelaySettingReady[zoneIndex]`。

## 同步修改

1. `entry/src/main/cpp/setting_napi.h` 增加了 `RequestRelaySettingByZone` 声明。
2. `entry/src/main/cpp/napi_init.cpp` 导出了 `requestRelaySettingByZone`。
3. `entry/src/main/cpp/types/libentry/Index.d.ts` 增加了类型声明。
4. `entry/src/mock/Libentry.mock.ets` 增加了 mock 实现。

## 构建结果

1. 已在当前工程 `E:\baidu\arkTS_code\New_Jydl_v3` 执行增量构建。
2. 构建通过，只有项目里原本就存在的 deprecated 警告，没有新增编译错误。
