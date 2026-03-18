# CommonSetting_PowerQuality_Set 转换记录

1. 参照 `CommonSetting_PrimarySystem_Set.ui` 到 `CommonSetting_PrimarySystem_Set.ets` 的实现方式，把 `CommonSetting_PowerQuality_Set.ui` 转成了 ArkTS 页面 `CommonSetting_PowerQuality_Set.ets`。
2. 页面先按原 UI 结构落地，保留了顶部标题栏、11 组电能质量告警项、底部操作栏、默认值和“投入/退出”选择。
3. “电能质量 -> 告警定值 -> 整定” 已接到新页面。
4. 底部按钮在保留原布局的基础上，把圆角半径加大，先做成更圆润的样式，后续可以继续细调。
5. 根据后续要求，把 `CommonSetting_PowerQuality_Set.ets` 的字号整体调大一档，主要提升了标题、字段标签、输入框、底部按钮和弹窗文字大小。
