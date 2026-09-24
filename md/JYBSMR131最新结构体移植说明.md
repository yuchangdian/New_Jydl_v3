# JYBSMR131 最新结构体移植说明

日期：2026-09-16。

后续补充的 `data.h/data.cpp` 和录波数据状态接口见 [数据与录波结构补充移植](JYBSMR131数据与录波结构补充移植.md)。新增整组遥信、11 路开入状态和 CRC 字数兼容函数；完整验证记录以补充说明为准。

## 本次落地内容

参考用户提供的 `IEC104.h`、`setting.h`、`SystemSetting_JYBSMR131.h`、`RelaySetting_Json.h`，并读取同目录中 IEC104 明确依赖的 `BPMU_JYBSMR131.h`、`FaultRecord_JYBSMR131.h`。

原始文件不能直接覆盖当前工程：公共地址从 `0x00xx` 改为 `0x13xx`，工频包删减了通道，模拟量定值改为八通道，而且两个系统定值头文件本身存在布局冲突。因此新增 `entry/src/main/cpp/protocol/jybsmr131/`，所有新类型放在 `jybsmr131` 命名空间。旧协议头文件和旧定值页面继续使用原来的布局和地址。

本次整理了 95 个类型定义（其中 3 个依赖缺失载荷类型的包保留为模板），以及 134 个数值协议常量。移除 Qt 依赖、Qt 元类型声明、外部全局变量声明、设备文件路径和界面尺寸；字段名称、顺序、类型和字段注释按原文件保留。使用固定宽度整数和成对的 `#pragma pack(push, 1)` / `pop`，不影响包含者的内存对齐。

## 差异处理

| 项目 | 处理结果 |
| --- | --- |
| `setting.h` 的一次系统参数 | 44 字节，含 `RatedCurrent_Primary`，保留原类型名 |
| `SystemSetting_JYBSMR131.h` 的一次系统参数 | 40 字节，不含额定电流，独立命名为 `SystemSettingWithoutRatedCurrent` |
| 模拟量参数 | Ua、Ub、Uc、Uo、IA、IB、IC、Io 三组参数加 CRC，共 100 字节 |
| 工频量 | 完整包 157 字节，含 6 字节头；载荷 151 字节 |
| 电压 / 电流谐波相量 | 完整包各 373 字节；载荷 367 字节，三相各 10 组频率 / 幅值 / 相角 |
| 波形 | 完整包 813 字节；400 个有符号 16 位采样值，转换为数值后除以 100 |
| 遥信变化 | 完整包 14 字节；不再套用旧版带 CRC 的 10 字节载荷 |
| 故障录波 / 宽频相量定值 | 分别 164 / 72 字节，补齐依赖结构 |
| 源文件重复的计量初始化 / 对时常量 | 采用末尾新版地址 `0x0066` / `0x0077`，不对外提供这些对象的定值写入接口 |
| 旧定值名称与新版地址重叠 | 不导入冲突的旧遥调常量，旧工程仍使用原 `IEC104.h` |
| SOE 固定长度宏与新结构不一致 | 不照搬旧长度宏，按结构本身确定长度；本次提供新结构和文本适配函数，未启用新版 SOE 二进制流解码 |

`Xor32` / `Xor16` 对应 Qt 中名为 CRC32 / CRC16 的逐字异或算法，不是多项式 CRC。实现按小端字节读取，避免未对齐指针转换。函数长度参数为字节数，分别要求 4 / 2 的倍数；不要与旧函数的“字数”参数混用。

## 通信接入

- `tcp_client.cpp` 按新公共地址分流；完整新版包交给 `PacketStore`，不进入旧版解码器。
- 已接入工频、两类谐波相量、六通道波形、11 种遥信变化，以及系统 / 模拟量 / 故障录波 / 宽频相量四种定值。
- 检查帧头长度、实际结构长度、定值校验和全 FF 无效数据。失败不覆盖上次有效快照；连接重建、断开时清空缓存。快照读写使用互斥锁。
- 校验通过的 40 / 44 字节系统回包决定后续写入布局。只能修改已读取的字段；禁止修改 CRC、重复字段、未知字段、错误数组长度、越界整数、非整数枚举和非有限数值。自动重算校验，发送本身不修改设备确认值。
- 上层仍需根据定值业务范围校验输入。本次二进制接口检查数据表示和字段布局，不替代每项保护 / 录波参数的业务范围约束。
- 原来的工频、谐波显示 NAPI 会优先读取本连接已收到的新版对应数据。已识别新版遥测时，谐波查询自动使用 `0x1311`；尚未识别时维持旧查询地址。主动读取新版设备可使用下面的新接口，不会自动切换旧定值写入协议。
- 首页兼容新版缺少 Ux 和独立测量 CT 的情况：保留已有通道，缺失通道显示 `--`，频率读取实际 Ua 频率。

## ArkTS 使用入口

`entry/src/main/ets/protocol/Jybsmr131.ets` 提供地址枚举和 `Jybsmr131Protocol`。

```ts
import { Jybsmr131Protocol, Jybsmr131TelemetryAddress,
  Jybsmr131SettingAddress } from '../protocol/Jybsmr131';

// 查询与接收是异步的；TCP 连接继续由 EntryAbility 管理。
Jybsmr131Protocol.requestTelemetry(Jybsmr131TelemetryAddress.BaseValue);
// 在后续刷新周期中获取快照，先检查 ready。
const telemetry = Jybsmr131Protocol.telemetry(Jybsmr131TelemetryAddress.BaseValue);
const ua = Jybsmr131Protocol.value(telemetry, 'Ua_RMS');

Jybsmr131Protocol.requestSetting(Jybsmr131SettingAddress.System);
// 收到有效回包后，payloadLength 为 40 或 44；40 字节版本没有额定电流字段。
const setting = Jybsmr131Protocol.setting(Jybsmr131SettingAddress.System);
const ratedCurrent = Jybsmr131Protocol.value(setting, 'RatedCurrent_Primary');
```

字段以 `{ name, values }` 数组暴露：标量的 `values` 长度为 1，数组保留全部元素，嵌套字段使用 `Correction.Ua`、`VoltageMutation.ActValue` 等名称。缺失字段返回 `undefined`，波形 `Value` 已完成除以 100 的换算，不要重复缩放。

底层导出：`getJybsmr131Packet(commonAddress, objectAddress)`、`requestJybsmr131Packet(commonAddress, objectAddress)`、`updateJybsmr131Setting(objectAddress, fields)`。类型声明同步写入 `entry/src/main/cpp/types/libentry/Index.d.ts`。写入返回 `true` 只代表 TCP 发送成功，须以设备后续有效回包确认。

`soe_text.h/.cpp` 将所提供的 SOE 文本函数接口转换为 `std::string`，复用本项目已有事件代码表。没有提供新版完整代码表与函数实现，因此没有新增猜测的事件文案。

## 缺失资料与明确边界

1. 参考目录缺少 `powerquality.h`，无法确认 `PowerQualityIndicator_struct`、`HarmonicDistortion_struct`、`PowerQualitySetting_struct` 的字段类型、顺序和长度。对应三个包保留为必须传入真实载荷类型才能实例化的模板；电能质量、63 次谐波 / 间谐波的 native 二进制解码及电能质量定值写入暂未启用，调用查询返回 `false`。原有电能质量页面的 IPC JSON 链路继续工作。
2. `RelaySetting_Json.h` 只有 `char* build_json(int code, int direction, long long timestamp_ms);` 声明，缺少实现、JSON 格式和返回缓冲区释放约定。移植文件保存函数类型 `BuildJsonFunction`，没有编造 JSON 或导出无实现的函数。需要补充对应实现文件才能完成这部分。
3. 新版 SOE、录波记录和电能质量事件的完整接收流程不在这些头文件中；本次不把其数据强行送入旧版解码器。对无法支持的包记录日志并按报文边界跳过。
4. 没有新增 Qt 风格定值编辑页面，没有把旧参数名称映射到语义不确定的新参数上；新设备的四类定值通过独立接口读写。

## 验证

- `tests/run-jybsmr131-tests.ps1`：四组 native 测试通过。覆盖硬编码字节样例、40 / 44 字节布局、谐波分组、400 个有符号波形采样、无效 CRC、全 FF、字段修改、越界和截断报文、未对齐读取、查询白名单、并发读取及断线清空。
- Node 测试共 31 项通过：本次 ArkTS 适配 4 项，加上原有谐波、实时指标和合格率测试 27 项。
- 使用 DevEco Studio / OpenHarmony SDK 构建 `entry@default` 的 debug HAP。最终结果见 `md/jybsmr131-build.log`。
- 尚未在实际设备上联调，不把编译成功或发送成功表述为设备已确认。

`tools/import-jybsmr131.cjs <参考目录>` 可重新导入类型和生成字段描述；只覆盖该工具生成的头文件和 `fields.inc`，不会覆盖手写 codec、NAPI、SOE 适配和 JSON 接口说明。
