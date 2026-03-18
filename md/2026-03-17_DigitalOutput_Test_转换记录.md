# DigitalOutput_Test 转换记录

1. 参照 `CommonSetting_PrimarySystem_Set.ui` 到 `CommonSetting_PrimarySystem_Set.ets` 的实现方式，把 `DigitalOutput_Test.ui` 转成了 ArkTS 页面 `DigitalOutput_Test.ets`。
2. 页面按原 UI 几何布局转换，保留了顶部标题栏、22 个开出测试勾选项、底部确认/关闭/返回栏和时间区域。
3. 当前工程菜单里“开出测试”是二级直达项，没有第三层“整定”，所以本次先把二级菜单“开出测试”直接接到了该页面。
4. 底部按钮在保留原位置和尺寸的基础上，额外做了更圆润的圆角。
