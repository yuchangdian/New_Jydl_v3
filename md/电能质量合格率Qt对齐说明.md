# 电能质量合格率 Qt 对齐说明

## 修改结果

参考用户提供的 `PowerQualityReportPage.cpp`、`.h` 和 `.ui`，新建 `entry/src/main/ets/pages/quality/PowerQualityReportPage.ets`，并将 `broadband.ets` 中“合格率”入口切换到新组件。原 `PowerQualityReport.ets` 文件保留，内容未修改。

## Qt 行为与本项目适配

Qt 在页面显示时只读查询 `/data/Report.db`：从 `Package_YC_PowerQuality_Struct` 表取最近九个有记录的本地自然日，每天选择 `CreatedAtMs` 最大、同时间再按 `Id` 最大的记录，最终按日期正序显示。它显示当天最后一条记录中的总合格率，不做平均，也不填造没有记录的日期。

本项目继续使用已有 IPC `/api/rate/get` 接口，参数为 `date_type=day`、当前 `terminal_id`、`line_id=1`。进入页面时检查并连接数据服务，然后读取日报。未增加 Qt SQLite 文件读取或二进制 Payload 解码；服务返回历史数据后，在 ArkTS 侧执行对应的日期整理。

- 支持原报表接口的 `DataDate`、`CreateTime`、`VoltageQualifiedRate`、`FrequencyQualifiedRate`。
- 同时支持 Qt 命名的 `CreatedAtMs`、`Id`、`VoltageQualifiRate_All`、`FreqQualifiRate_All`，以及 `PowerQuality` 嵌套字段。
- 有有效 `CreatedAtMs` 时按本地自然日分组；现有日报以 `DataDate` 作为统计日期，`CreateTime` 只用于同日排序，避免次日入库改变统计日。
- 同日多条记录按时间、Id 选择最后一条，再取最近九个日期并正序显示。接口没有时间和 Id 时，无法推断同日先后，保留首条同日记录。
- 数据不足九日时剩余行显示 `--`，不伪造日期；最新记录没有有效合格率时也显示 `--`，不拿更早记录的值替代。
- 接口返回 `TerminalId` 时过滤不属于当前终端的记录。
- 电压合格率保留两位小数，频率合格率保留三位小数，数字后加空格和 `%`。支持数字或线路数组，数组取线路 1；0 是有效值，缺失及非有限数显示 `--`。
- Qt 没有给闪变合格率绑定字段，本项目也没有可靠的闪变合格率来源，因此该列显示 `--`。越限次数不能推算合格率，不使用固定 100%。

“最近九日”以接口返回的历史范围为准。服务需返回足够历史记录及排序元数据，才能与 Qt 直接读取完整数据库的结果完全一致。

## UI

- 按组件实际可用 vp 宽度相对 Qt 的 739 宽度缩放。
- 顶部灰色栏高 53；正常时留空，读取中、无记录或失败时显示状态。
- 固定两行表头，总高 68：第一行为“电压、频率、闪变”，第二行为“日期、合格率、合格率、合格率”。
- 日期、电压、频率、闪变四列按 `11:20:20:20` 分配宽度，保留纵向分隔线。
- 九行数据，每行高 31，白色和 `#d7d7d7` 交替；数据区可纵向滚动，表头保持固定。
- 新版按 Qt 使用日报，不展示旧页面的日/周/月/季/年、线路选择和越限次数控件；旧实现仍保存在原文件中。
- 每次进入页面重新读取。离开时使请求失效，过期连接/响应不更新已退出的组件。读取失败保留九行占位并提示重新进入重试。

## 验证

- 10 项 Node 数据测试通过：最近九个记录日、同日末条记录及 Id、最新缺失值、日报统计日期、跨午夜及带时区时间、非法日期及空行、精度及零值、非法数字及闪变、终端过滤、响应结构。
- `PowerQualityReport.ets`、`PowerQualityRealtimeMonitoringPage.ets`、`harmonic.ets` 修改前后 SHA-256 一致。
- DevEco/Hvigor `default` 产品、OpenHarmony API 18 的 `assembleHap` 编译及签名通过；日志为 `md/qualification-report-build.log`。其他页面仍有已有的 API 弃用等警告。
- 尚未在设备上验证 IPC 返回历史范围、实际字段及最终视觉效果。

测试命令（PowerShell）：

```powershell
$env:REPORT_TYPESCRIPT_PATH = 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/node_modules/typescript'
node --test tests/qualification-report.test.cjs
```
