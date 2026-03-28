# 保护定值整定页 appfreeze 分析与处理

## 现象

- 日志文件：`E:\baidu\arkTS_code\log_error\appfreeze-com.example.new_jydl_v3-19700101081159.282.txt`
- 故障类型：`THREAD_BLOCK_6S`
- 直接表现：主线程卡住，页面不是闪退，而是进入整定页后长时间无响应。

## 日志结论

- 主线程卡在 `uvLoopTask`：
  - `appfreeze-com.example.new_jydl_v3-19700101081159.282.txt:42`
  - `appfreeze-com.example.new_jydl_v3-19700101081159.282.txt:1748`
- 整定页首批内容其实已经出来了：
  - `appfreeze-com.example.new_jydl_v3-19700101081159.282.txt:1494`
  - 日志显示 `RelaySettingSet 首批分组就绪，区号=01，耗时=773ms`
- 但“全部分组渲染完成”拖到了 9 秒后：
  - `appfreeze-com.example.new_jydl_v3-19700101081159.282.txt:2503`
  - 日志显示 `RelaySettingSet 全部分组渲染完成，区号=01，耗时=9110ms`
- watchdog 记录的阻塞事件也是 `uvLoopTask`：
  - `appfreeze-com.example.new_jydl_v3-19700101081159.282.txt:2505`

## 根因

这次不是普通异常，也不是文件打不开，而是整定页首开后又在主线程里继续跑了“大量同步 JS 工作”。

触发链路在：

- `entry/src/main/ets/pages/RelaySettingSet.ets:1332`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1361`
- `entry/src/main/ets/pages/RelaySettingSet.ets:793`

原来的逻辑是：

1. 页面进入后先 `setTimeout(0)` 跑 `prepareCurrentZone(...)`
2. 首批 section 渲染出来后，又立刻 `setTimeout(0)` 调 `migrateLegacyRelayProfilesIfNeeded()`
3. `migrateLegacyRelayProfilesIfNeeded()` 在主线程同步执行：
   - 20 个区循环迁移
   - 多次 `fs.readTextSync / fs.openSync / fs.writeSync`
   - 最后再全量重建旧镜像 store

虽然用了 `setTimeout(0)`，但 ArkTS 的这个回调还是跑在主线程 `uvLoopTask` 上，所以只是“延后执行”，不是“后台执行”。日志里首批 UI 已经出来，但后续 timer 回调把主线程继续占满了，最终被系统判定为 `THREAD_BLOCK_6S`。

## 已处理

已做两处修正：

1. 去掉页面首开后自动触发的全量迁移入口。
   - 不再在 `prepareCurrentZone(...)` 结束后立刻跑 `migrateLegacyRelayProfilesIfNeeded()`
2. 当前区文件已存在时，不再重复同步落盘。
   - 位置：`entry/src/main/ets/pages/RelaySettingSet.ets:1342`

这样调整后：

- 启动时只加载当前区
- 当前区若已经有区级文件，不再重复写文件
- 其它区继续保持“首次真正进入该区时再按需迁移”的懒加载策略

## 为什么还是会感觉进页面慢

进一步对日志和页面结构对比后，发现还有第二个问题：

- `RelaySettingSet 首批分组就绪` 在 773ms 就打印了
- 但 `pages/RelaySettingSet finish inPage transition` 一直到全部分组渲染完成后才出现

这说明真正拖住“进入页面”的，不只是数据准备，还包括页面进入动画期间的持续补渲染。

对应代码原来是：

- 先渲染前 4 个主分组
- 然后用 `setTimeout(0)` 连续补渲染剩余主分组
- 监视区 `MonitorSections()` 还是一次性整块渲染

虽然逻辑上已经是“分批”，但因为补渲染是紧贴着路由进入阶段连续执行，主线程会一直忙于布局和创建大量 `TextInput / Row / Column`，结果是：

- 首批数据其实准备好了
- 但用户视觉上还是要等到路由完成 inPage transition，才感觉页面“真正进来”

## 本次追加处理

针对“进入页面还是要等 5、6 秒”的问题，又做了两处调整：

1. 后续补渲染不再 `setTimeout(0)` 连续抢主线程
   - 改成先延后约 320ms，再按约 48ms 的节奏继续补渲染
2. 监视区也改成延后分批渲染
   - 不再在第一页内容出来时一次性把整块监视区一起挂上

对应位置：

- `entry/src/main/ets/pages/RelaySettingSet.ets:485`
- `entry/src/main/ets/pages/RelaySettingSet.ets:511`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1305`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1348`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1422`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1681`

## 编译结果

- 已执行 `assembleHap`
- 结果：`BUILD SUCCESSFUL`

## 后续建议

如果后面还要继续压缩保存耗时，下一步优先处理 `saveValueEntries()` 里的旧镜像全量重建逻辑，改成“只更新当前区对应的 legacy profile”，不要每次保存都把 20 区全量回刷一遍。
