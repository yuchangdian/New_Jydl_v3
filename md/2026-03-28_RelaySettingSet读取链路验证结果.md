# RelaySettingSet 读取链路验证结果

## 验证范围

本次验证的是 `RelaySettingSet.ets` 读取 `RelaySetting[20]` 的要求 1 是否已经接通：

- 页面打开是否按当前区号取 native 定值
- native 区号定值是否能覆盖当前区 profile
- 页面可编辑字段是否有漏映射
- 工程是否可以正常编译

## 验证结果

### 1. 编译验证通过

执行：

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk\default\hms'
$env:OHOS_BASE_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony'
& 'C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default -p requiredDeviceType=default assembleHap --analyze=normal --parallel --incremental
```

结果：

- `BUILD SUCCESSFUL`

### 2. 区号读取路径正确

`RelaySettingSet.ets` 中已确认：

- 当前区号来自路由参数
- `prepareCurrentZone()` 先读当前区本地 profile
- 再调用 `loadNativeRelayZoneProfile()`
- 如果 native 当前区 `ready=true`，则用 native 字段覆盖当前 profile

对应位置：

- `entry/src/main/ets/pages/RelaySettingSet.ets:855`
- `entry/src/main/ets/pages/RelaySettingSet.ets:1461`

### 3. native ready 链路正确

已确认：

- `RelaySettingReady[20]` 已新增
- TCP 收到 `YT_ObjectAddr_RelaySetting` 并校验通过后，会更新对应区 struct 并置 ready

对应位置：

- `entry/src/main/cpp/data.cpp:21`
- `entry/src/main/cpp/setting.h:981`
- `entry/src/main/cpp/tcp_client.cpp:929`

### 4. 页面字段映射无遗漏

我用脚本核对了：

- `RelaySettingSetSchema.ets` 中所有可绑定字段
  - `input`
  - `select`
  - `monitor field`
- 与 `setting_napi.cpp` 中输出的 fieldId

结果：

- 页面可绑定字段总数：`193`
- native 输出 fieldId 总数：`193`
- `missing_bindable_in_napi`：空
- `extra_bindable_in_napi`：空

结论：

- 当前页面里所有真正显示值的字段，都已经有 native 回填项

## 当前仍需注意的点

### 1. 这次验证是代码级验证，不是现场报文验证

也就是说：

- 代码链路是通的
- 编译通过
- 字段覆盖关系完整

但还没有在我这里直接验证“某台设备实际下发某个区号定值后，界面显示出的每个数字都与现场报文一致”，因为这里没有直接替你操作真实设备界面和抓现场值做逐项比对。

### 2. 页面本身有个别历史文案风险

这不是本次读取链路新引入的问题，而是页面 schema 里本来就有的语义问题，例如：

- `section-20-row-01-item-05-cell-02`
  - 当前映射的是 `Time_Charge`
  - 但页面文案写的是“重合闸后加速段投入时间”
- `section-27-row-01-item-05-cell-02`
  - 实际映射的是 `Value_THDi`
  - 但页面文案写的是 `THDu定值`

所以如果这两个位置后面看起来“值能读出来，但名字别扭”，根因是页面文案，不是读取链路断了。

## 结论

从代码和构建角度看，要求 1 已经接通，而且字段覆盖完整。

如果下一步要做更强验证，建议直接做两件事：

1. 打印某个区号 `getRelaySettingByZone()` 返回的 `fields`
2. 用现场一个已知区号定值，逐项核对页面显示
