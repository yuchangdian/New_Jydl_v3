# 电能质量实时指标 Qt 对齐说明

## 本次结果

参考用户提供的 `PowerQualityRealtimeMonitoringPage.cpp`、`.h`、`.ui`，新增 `entry/src/main/ets/pages/quality/PowerQualityRealtimeMonitoringPage.ets`。数据接口、格式化、字段映射、刷新和 UI 均放在这个新文件中。

`pages/quality/broadband.ets` 仍作为页面容器：“实时指标”显示新组件，新增“宽频相量”菜单继续访问原 `WidebandContent`。原页面文件没有删除或覆盖，外层路由和“谐波、间谐波、合格率”入口继续保留。

## UI

- 按 Qt 的 735 宽度适配组件实际可用 vp，避免把物理屏幕 px 直接当作 vp。
- 顶部灰色栏高度按 47 缩放，正常时留空；读取中、断开连接或请求失败时显示状态。
- 数据区共 14 行，每行高度按 39 缩放，白色和 `#d3d3d3` 交替，行底有细线。
- 标题列按 115 缩放并右对齐；三组数值均分剩余宽度，各自包含前缀和数值。
- 保持 Qt 的空白续行标题、不平衡度第三格留空；数值字体可缩小以容纳四位小数和相角。
- 数据区独立纵向滚动，顶部保持固定；数值变化纳入列表 key，确保刷新后行内容更新。

## 数据来源与映射

使用本项目已有 IPC 服务 `/api/yc/sub`，沿用 `PROJECT_CODE`、`TERMINAL_ID` 和 `ts=0`。读取前检查连接，并使用当前 Ability 上下文连接服务。

| 行 | 数据源 | 主要字段 | 显示格式 |
| --- | --- | --- | --- |
| 频率 | RemoteMetry | Ua/Ub/Uc_Frequency | 四位小数，Hz |
| 频率偏差 | PowerQuality | FreqDeviation_A/B/C | 四位小数，Hz |
| 频率合格率 | PowerQuality | FreqQualifiRate_A/B/C | 四位小数，% |
| 电压 | RemoteMetry | Ua/Ub/Uc_RMS、Ua/Ub/Uc_Phase | 有效值四位，V，相角三位，° |
| 相电压偏差 | PowerQuality | VoltageDeviation_A/B/C | 四位小数，% |
| 线电压偏差 | PowerQuality | VoltageDeviation_AB/BC/CA | 四位小数，% |
| 电压合格率 | PowerQuality | VoltageQualifiRate_A/B/C | 四位小数，% |
| 电压序分量 | PowerQuality | Voltage_U1/U2/Uo | 四位小数，V |
| 电压不平衡度 | PowerQuality | Voltage_U2_Unbalance、Voltage_Uo_Unbalance | 四位小数，% |
| 电压短闪变 | PowerQuality | VoltageShortFlicke_A/B/C | 四位小数，无单位 |
| 电压长闪变 | PowerQuality | VoltageLongFlicke_A/B/C | 四位小数，无单位 |
| 电流 | RemoteMetry | IA/IB/IC_RMS、IA/IB/IC_Phase | 有效值四位，A，相角三位，° |
| 电流序分量 | PowerQuality | Current_I1/I2/Io | 四位小数，A |
| 电流不平衡度 | PowerQuality | Current_I2_Unbalance、Current_In_Unbalance | 四位小数，% |

兼容项目的数组响应（线路 1，索引 0）和单线路标量响应，同时支持外层 `data` 和直接字段对象。Qt 的 `Voltage_Uo`、`Current_Io` 缺失时兼容项目的 `Voltage_U0`、`Current_I0`；`Current_In_Unbalance` 缺失时兼容 `Current_Io_Unbalance`，合法的 0 值不会被覆盖。

保护电流 IA/IB/IC 与测量电流 Ia/Ib/Ic 是不同字段，按 Qt 取前者。接口如果只返回总频率/电压合格率，不把总值复制为三相合格率，缺少的分相字段显示 `--`。

两类响应分别更新各自行；一轮完成后间隔 2 秒再次读取，不叠加慢请求。组件退出时清除定时器，并通过生命周期标记拒绝过期响应继续更新页面或请求下一组数据。请求失败保留上一份有效数据并提示，空数组、缺失值和非有限数显示 `--`。

## 验证

- 9 项 Node 数据测试全部通过：14 行顺序、频率精度、三相相量及电流大小写、偏差/合格率/闪变、零序字段兼容、总合格率不冒充分相、非法数字、响应格式、分组刷新。
- DevEco/Hvigor `default` 产品、OpenHarmony API 18 的 `assembleHap` 编译和签名通过。日志位于 `md/realtime-monitoring-build.log`。现有其他页面仍有 API 弃用等警告。
- `WidebandContent.ets`、`quality_index.ets`、`harmonic.ets` 修改前后 SHA-256 一致，本轮未更改这些文件内容。
- 本轮没有执行文件删除。任务开始时工作区已有 `VoltageMonitoring.ets`、`SequenceMonitoring.ets`、`VoltageFlickerMonitoring.ets` 的暂存删除状态，本轮没有更改这些已有状态。
- 尚未在设备上运行新页面。IPC 服务可用性、实际返回字段、触摸滚动及最终视觉效果需设备验证；新增页面不改变现有 native TCP 协议。

测试命令（PowerShell）：

```powershell
$env:REALTIME_TYPESCRIPT_PATH = 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/node_modules/typescript'
node --test tests/realtime-monitoring.test.cjs
```
