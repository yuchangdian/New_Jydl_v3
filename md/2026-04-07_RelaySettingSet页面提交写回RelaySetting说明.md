## 目标

把 `RelaySettingSet.ets` 当前界面的值与 `data.cpp` 里的 `RelaySetting_Struct RelaySetting[20]` 建立提交写回联系。

本次只做：

1. 点击提交后弹出“等待回应”弹窗。
2. 把当前页面所在区号的值写入 `RelaySetting[20]` 对应区。

## 实现方式

### 页面侧

在 `RelaySettingSet.ets` 中新增了：

- 提交等待弹窗状态
- 当前页面全部绑定字段转写回 payload 的方法
- `submitCurrentData()` 提交流程

提交流程是：

1. 先保存当前区本地文件
2. 再调用 native `updateRelaySettingByZone(...)`
3. 成功后弹“等待回应”

### Native 侧

新增 `updateRelaySettingByZone(...)`：

1. 接收页面传来的 `zoneCode + fields`
2. 根据字段 `id` 反向写入 `RelaySetting_Struct`
3. 计算 CRC
4. 写回 `RelaySetting[zoneIndex]`
5. 标记 `RelaySettingReady[zoneIndex] = true`
6. 更新 `SettingCode_Now`

这次没有追加真正的发送等待链路，只完成“写结构体 + 弹等待回应”，符合当前要求。

## 关于 20 个区

本次写回不是固定写某一个结构体，而是：

- 页面当前区号 `01~20`
- 转成 `zoneIndex = zoneCode - 1`
- 写入 `RelaySetting[zoneIndex]`

所以点击不同区进入整定页后提交，会分别落到 `RelaySetting[0] ~ RelaySetting[19]`。

## 额外处理

保护定值中的时间类字段，页面值按秒填写，native 写回时统一乘 `2000` 转成结构体里的时间刻度，与之前读取时“除以 2000”的逻辑对应。

另外低频保护里的“解列/减载”没有直接信任页面里的枚举码值，而是按中文文本重新映射，避免前端枚举码和 native 语义不一致。

## 验证

在当前工程 `E:\baidu\arkTS_code\New_Jydl_v3` 下执行：

`assembleHap --analyze=normal --parallel --incremental`

结果：

`BUILD SUCCESSFUL`
