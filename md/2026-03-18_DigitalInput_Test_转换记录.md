# DigitalInput_Test 转换记录

1. 参照 `CommonSetting_PrimarySystem_Set.ui` 到 `CommonSetting_PrimarySystem_Set.ets` 的实现方式，把 `DigitalInput_Test.ui` 转成了 ArkTS 页面 `DigitalInput_Test.ets`。
2. 页面按原 UI 几何布局转换，保留了顶部标题栏、19 个开入状态指示项、底部关闭/返回栏和时间区域。
3. 当前工程菜单里“开入测试”是二级直达项，所以本次把二级菜单“开入测试”直接接到了该页面。
4. 底部按钮在保留原位置和尺寸的基础上，额外做了更圆润的圆角。
