# DigitalInput_Test / DigitalOutput_Test 迭代记录

## 本次修改

1. 将 `DigitalInput_Test.ets` 与 `DigitalOutput_Test.ets` 中分散的页面变量整理为 class 形式的配置结构：
   - 文案配置
   - 字号配置
   - 布局配置
2. 将 `DigitalInputTestData.ets` 与 `DigitalOutputTestData.ets` 中条目数据整理为“位置 + 状态”的结构：
   - `position`
   - `state`
3. 放大了两个页面的标题、列表项、底部按钮、时间区域文字。
4. 将原来的勾选表现统一改为自绘方框，点击后显示 `√`。
5. `DigitalInput_Test.ets` 增加了点击切换勾选状态。
6. `DigitalOutput_Test.ets` 保留原有本地持久化，同时把勾选状态切换迁移到新的结构里。
7. 顺手修正了 `DigitalOutput_Test.ets` 页头标题文案为“开出测试”。
8. 修复勾选框点击后不显示的问题：
   - 点击时改为替换整个数组项，确保 ArkTS 触发界面刷新
   - 勾选标记改为 `checked_black.png` 资源图片，避免字符勾号渲染不出来
9. 进一步改为系统 `Checkbox` 控件，并把 `ForEach` 的 key 带上勾选状态，避免列表项复用导致的勾选态不即时刷新。
10. 按反馈把勾选框恢复为正方形，自绘边框圆角改为 `0`。

## 涉及文件

- `entry/src/main/ets/pages/DigitalInput_Test.ets`
- `entry/src/main/ets/pages/DigitalOutput_Test.ets`
- `entry/src/main/ets/models/DigitalInputTestData.ets`
- `entry/src/main/ets/models/DigitalOutputTestData.ets`

## 验证结果

已执行 `assembleHap`，构建通过。
