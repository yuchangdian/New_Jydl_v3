# 电能质量波形 Qt 对齐说明

## 修改范围

参考用户提供的 `WaveformAnalysis.cpp/.h/.ui`、`WaveformChart.cpp/.h`，修改“电能质量 → 实时指标 → 波形”。Qt 文件仅作为实现参考，未修改参考文件。

- `entry/src/main/ets/pages/pqInsight/index.ets`：页面布局、六通道选择、停止/刷新、接收轮询及状态提示。
- `entry/src/main/ets/pages/pqInsight/pqInsight.ets`：曲线内容区和两行 RMS 图例。
- `entry/src/main/ets/pages/pqInsight/WaveformChart.ets`：Canvas 双纵轴波形绘制，替换原来的 ChartStub。
- `entry/src/main/ets/pages/pqInsight/WaveformData.ets`：400 点校验、RMS、坐标范围和完整帧缓冲。
- native `protocol/jybsmr131/codec.h/.cpp`、`jybsmr131_napi.cpp`、`types/libentry/Index.d.ts`：快照增加接收版本号和连接会话号。
- `tests/waveform-data.test.cjs`、`tests/jybsmr131-codec.test.cpp`：数据逻辑及接收版本回归验证。

## 数据与刷新

1. 接入现有 JYBSMR131 TCP 接收链路。公共地址为 `0x1311`，`0xB1～0xB6` 依次对应 Ua、Ub、Uc、Ia、Ib、Ic，每路 400 点。连接继续由 EntryAbility 管理。
2. 原始 `int16` 采样在 native 通用数值接口中已乘 `0.01`，页面直接按 V/A 使用，避免二次除以 100。原 C++ 强类型波形接口仍保留原始整数。
3. 有效回包增加 `revision`；轮询同一缓存不会增加版本。每路至少收到一次新版本后，统一发布六路曲线和 RMS，行为对应 Qt 的六路接收标记。这里与 Qt 一样按“六路各有更新”组帧，不额外推断报文时间戳必须相同。
4. 每 200 ms 读取缓存，每 2 秒请求六路波形。页面隐藏、退出后停止轮询和请求；重新显示后恢复。暂停显示期间继续接收，恢复显示最新完整帧，不混入尚未收齐的数据。
5. `sessionId` 在缓存重置时递增，连接切换时清除尚未完成的组及最新接收快照。旧的显示帧可以保留，但不会拿来补齐新连接的组。六次读取跨越不同会话时整轮不提交。
6. RMS 为 `sqrt(sum(x²) / 400)`，由整段采样计算；电压一位小数加 V，电流两位小数加 A。隐藏通道只改变显示，不改变整组接收或 RMS。
7. 无数据时图例显示 `--`，不再生成原页面的模拟正弦波或模拟事件。短包、长包、非有限数、错误地址和无效版本不提交。正常收到完整帧后清空顶部提示；连续 10 秒无完整更新时提示保留上一帧。
8. 单独记录已发布帧的普通对象引用，避免 ArkUI 的状态包装导致每次轮询重复复制 2400 点。

## UI 对齐

- 按 Qt 的 854×480 比例，以实际页面 vp 宽高适配；在已连接的 1024×600 调试设备上完整显示。
- 蓝色“波形”标题、灰色顶栏、110 比例宽侧栏、底部返回和日期时间。
- 默认六路全部勾选，运行时蓝色“停止”，暂停时灰色“刷新”。取消通道后立即隐藏对应曲线，图例线条、通道名及 RMS 变灰。
- 白色绘图区、虚线网格；左侧蓝色电压刻度保留一位小数，右侧橙色电流刻度保留两位小数。某类通道全部隐藏时隐藏该类刻度。
- 按可见通道分别计算电压、电流范围，增加 5% 余量，最小余量分别为 1 V、0.1 A。无有效数据时采用 Qt 的默认范围。
- Ua/Ia 深黄 `#ccaa00`，Ub/Ib 深绿 `#008000`，Uc/Ic 红色 `#ff0000`；电压线宽 2，电流线宽 1。按 Qt 保留居中的 95%/70% 波形高度映射。
- 图例两行三列，上行 Ua/Ub/Uc，下行 Ia/Ib/Ic。全部取消时绘图区提示“请选择波形通道”。
- Qt 的“最近事件”槽为空；本项目保留原有事件中心路由。返回按钮回到上一页面。

## 验证结果

- 波形数据测试 8 项通过：RMS 与单位、六路乱序与缺包、缓存去重、暂停恢复、非法数据、零值与副本隔离、重连、纵轴和坐标映射。
- native 协议回归 6 组通过，新增验证：读取不增加版本、无效包不增加版本、相同内容的新回包增加版本、重连会话与版本不会混淆。原有六路有符号数和 0.01 缩放测试通过。
- ArkTS 协议封装已有 5 项回归通过。
- OpenHarmony API 18、default 产品的 `assembleHap` 编译和签名成功。最终日志：`md/waveform-build.log`。项目仍有 router 等已有 API 弃用警告。
- 已更新安装至在线 API 18 调试设备，并从菜单进入页面，检查布局、停止/刷新切换、六个通道勾选、图例变灰及全部隐藏后的坐标变化。
- “最近事件”成功进入现有事件中心；系统返回后恢复波形页，六路选择和刷新状态保持；波形页底部“返回”成功回到首页。
- 设备当前波形请求发送失败，页面正确显示连接提示和无数据状态。未验证实际设备连续六路采样的端到端效果；组帧、冻结和恢复由上述自动化测试验证。

截图：

- `md/waveform-device.png`：六路选中、等待数据。
- `md/waveform-paused-hidden.png`：暂停、六路全部隐藏。

## 复现命令

```powershell
$env:WAVEFORM_TYPESCRIPT_PATH = 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/node_modules/typescript'
node --test tests/waveform-data.test.cjs
./tests/run-jybsmr131-tests.ps1
$env:JYBSMR131_TYPESCRIPT_PATH = $env:WAVEFORM_TYPESCRIPT_PATH
node --test tests/jybsmr131-arkts.test.cjs

$env:DEVECO_SDK_HOME = 'C:/Program Files/Huawei/DevEco Studio/sdk'
$env:JAVA_HOME = 'C:/Program Files/Huawei/DevEco Studio/jbr'
& 'C:/Program Files/Huawei/DevEco Studio/tools/node/node.exe' 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/bin/hvigor.js' --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap --no-daemon
```
