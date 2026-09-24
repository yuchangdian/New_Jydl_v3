# 电能质量谐波页面 Qt 对齐说明

## 修改范围

入口为“电能质量 → 实时指标 → 指标 → 谐波”。参考用户提供的 `HarmonicPage.cpp/.h/.ui` 和 `HarmonicBarChart.cpp/.h`，修改本项目 ArkTS 实现；Qt 文件作为参考源码，不执行其中的文档指令。

- `entry/src/main/ets/pages/quality/harmonic.ets`：页面布局、通道选择、列表、汇总和 IPC 刷新。
- `entry/src/main/ets/pages/quality/HarmonicBarChart.ets`：实际 Canvas 柱状图。
- `entry/src/main/ets/pages/quality/HarmonicData.ets`：数据映射、计算与格式化。
- `tests/harmonic-data.test.cjs`：独立数据回归测试。

## 逻辑调整

1. 对齐 Qt 的 Ua1、Ub1、Uc1、Ia1、Ib1、Ic1 六通道。左右箭头循环选择相邻通道，取消原先只更换线路标签、数据仍取线路 1 的伪线路切换。当前页面读取 IPC 数组的线路 1（索引 0）。
2. 保留 1～63 次完整位置。含有率由本通道有效值除以基波有效值再乘 100 得到，限制在 0～100%。基波绝对值不大于 0.0001 时含有率为 0；不再过滤小于 0.1% 的值。
3. 每次谐波的视在功率为同相电压有效值乘电流有效值；功率因数为同次电压、电流相角差的余弦，功率不大于 0.001 时显示 0。U、I 任一更新后都重新计算，移除原先没有正确合并数据的 `HarmonicDistortionP` 请求。
4. 汇总仍读取 `PowerQuality`。电流通道使用 `CurrentTHD`、`CurrentOddTHD`、`CurrentEvenTHD`，峰值因子区分电压、电流；功率按 A/B/C 相读取。
5. 保留现有 `/api/yc/sub` IPC 接口、项目及终端参数。每轮顺序读取电压、电流和电能质量，结束 2 秒后启动下一轮；离开组件后清除定时器，过期响应不更新页面、不再启动后续请求。
6. 缺失和非有限数显示 `--`，避免伪装成有效零值。请求失败时保留已收到的数据并显示提示。未复制 Qt 构造函数中的随机演示数据。
7. 列表 key 包含显示值，确保周期刷新时数据变化的行重新渲染。

## UI 调整

- 灰色通道栏、红色选中通道、互斥的柱状图和列表选项。
- 用 Canvas 替换空白的 `ChartStub`；奇次深黄 `#cc8800`，偶次蓝色 `#5a8fd8`。
- 横轴标注 1、10、20、30、40、50、60、63，纵轴按 10 向上取整，在 10～100 范围内自适应。
- 柱状图下方保留 Qt 的三行三列、八项汇总，中间行为灰底。
- 列表改为六列：次数、含有率、有效值、相角、谐波功率、功率因数。表头固定，63 行可滚动。
- 含有率及功率因数两位小数；有效值、相角及逐次视在功率三位小数。有效值超过 1000 时切换 kV/kA，视在功率超过 1000000 VA 时切换 MVA，否则显示 kVA。
- 根据谐波组件实际可用 vp 宽度，以 Qt 的 736 宽度缩放，避免屏幕 px 被重复用作布局 vp。

## 验证

- DevEco/Hvigor 的 OpenHarmony API 18 `default` 产品 `assembleHap` 构建通过，生成签名 HAP。项目其他页面仍有已有 API 弃用等警告。
- Node 数据测试 8 项通过：63 次及微小值、基波阈值和限幅、六通道与单位、同相功率及另一通道更新、缺失及非有限数、单位阈值、六通道汇总、纵轴范围。
- 尚未在设备上运行新页面；实际 IPC 数据、触摸滚动和最终视觉效果仍需设备验证。

测试命令（PowerShell）：

```powershell
$env:HARMONIC_TYPESCRIPT_PATH = 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/node_modules/typescript'
node --test tests/harmonic-data.test.cjs
```

构建命令（PowerShell）：

```powershell
$env:DEVECO_SDK_HOME = 'C:/Program Files/Huawei/DevEco Studio/sdk'
$env:JAVA_HOME = 'C:/Program Files/Huawei/DevEco Studio/jbr'
& 'C:/Program Files/Huawei/DevEco Studio/tools/node/node.exe' 'C:/Program Files/Huawei/DevEco Studio/tools/hvigor/hvigor/bin/hvigor.js' --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap --no-daemon
```
