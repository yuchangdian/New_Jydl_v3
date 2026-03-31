# RelaySettingSet 读取 RelaySetting 区号定值说明

## 本次目标

把 `RelaySettingSet.ets` 页面里的输入框值，与 `data.cpp` 里的 `RelaySetting_Struct RelaySetting[20]` 建立读取联系。

本次只完成要求 1：

- 页面打开时，根据当前区号读取 `RelaySetting[20]` 中对应区的数据
- 把收到的数据依次赋值到页面当前区的 profile
- 界面显示最新值

没有做：

- 页面修改后反向写回 `RelaySetting[20]`
- 保护定值下发

## 实现方式

### 1. native 侧增加区号 ready 标记

文件：

- `entry/src/main/cpp/setting.h`
- `entry/src/main/cpp/data.cpp`
- `entry/src/main/cpp/tcp_client.cpp`

处理：

- 新增 `bool RelaySettingReady[20]`
- TCP 收到 `YT_ObjectAddr_RelaySetting`，CRC 和区号通过后：
  - 更新 `RelaySetting[tempCode - 1]`
  - 置 `RelaySettingReady[tempCode - 1] = true`

### 2. native 导出按区号读取接口

文件：

- `entry/src/main/cpp/setting_napi.h`
- `entry/src/main/cpp/setting_napi.cpp`
- `entry/src/main/cpp/napi_init.cpp`
- `entry/src/main/cpp/types/libentry/Index.d.ts`
- `entry/src/mock/Libentry.mock.ets`

新增接口：

- `getRelaySettingByZone(zoneCode: number)`

返回结构：

- `ready`
- `zoneCode`
- `fields`

其中 `fields` 不是大 struct 原样暴露，而是页面可直接使用的数组：

```ts
[
  { id: 'section-01-row-01-item-02-cell-01', value: '投入' },
  { id: 'section-01-row-01-item-05-cell-01', value: '120.00' }
]
```

这样做的原因：

- `RelaySettingSet.ets` 本身不是简单 `@State formData`
- 它是 `fieldId -> binding -> profile` 的结构
- 直接返回页面字段值，ArkTS 侧就能按现有 binding 通用回填，不需要为每个输入框单独写状态变量

### 3. 页面打开时优先读取 native 区号定值

文件：

- `entry/src/main/ets/pages/RelaySettingSet.ets`

处理：

- 新增 native 模块加载逻辑
- 在 `prepareCurrentZone()` 中：
  - 先按原逻辑读取当前区的本地 profile
  - 再尝试读取 native 的当前区号定值
  - 如果 native 当前区 ready，则用 native 字段覆盖当前 profile
  - 然后刷新页面缓存并显示

页面现在的优先级：

1. 当前区 native 定值
2. 当前区本地文件
3. 旧存储迁移值
4. 默认值

## 当前映射范围

已映射页面中实际存在的字段：

- 公共定值
- 通信定值
- 纵联保护
- 过电流保护
- 零序过流保护
- 自适应零序过流保护
- 重合闸保护
- 过负荷保护
- 低电压保护
- 过电压保护
- 低频保护
- 高频保护
- 逆功率保护
- 谐波电流保护
- 谐波电压保护
- 异常监测页面中已有的监测项

未映射到页面的 struct 字段：

- `BusRelay`
- `AbnormalMonitoring.HWJ`

原因：

- `RelaySettingSetSchema.ets` 当前没有这两个可编辑/可显示字段

## 已知边界

### 1. 时间类字段先按原始数值显示

这次只先完成读取链路，未额外做保护定值专用的单位换算。

也就是说：

- 类似 `Time_Delay`、`Time_Charge` 这类字段，当前先直接格式化成文本显示
- 如果协议里某些字段后续确认需要做 `0.5ms -> s` 或其他比例换算，再单独收口

### 2. 页面文案与 struct 个别字段存在历史错位

已按“结构顺序 + 页面字段位置”接入，但当前 schema 本身存在少量历史文案问题，例如：

- 重合闸页面里有字段文案更像“充电时间”却显示成了别的名字
- 谐波电流页面文案里有 `THDu/THDi` 的旧问题

这次没有顺手改 UI 文案，只先保证读取链路跑通。

## 验证结果

执行命令：

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk\default\hms'
$env:OHOS_BASE_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony'
& 'C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default -p requiredDeviceType=default assembleHap --analyze=normal --parallel --incremental
```

结果：

- `BUILD SUCCESSFUL`

## 后续建议

下一步如果继续做要求 2，建议直接沿用这次的 fieldId 链路：

- 页面 profile 改动
- 转成 native 需要的字段值
- 再按区号写回 `RelaySetting[20]`

这样读写会共用同一套字段映射，不容易再出现页面字段和 struct 字段错位。
