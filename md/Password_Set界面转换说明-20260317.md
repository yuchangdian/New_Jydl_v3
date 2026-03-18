# Password_Set 界面转换说明

## 本次目标

- 参照 `CommonSetting_PrimarySystem_Set.ui` 转 `CommonSetting_PrimarySystem_Set.ets` 的处理方式，把 `Password_Set.ui` 转成 ArkTS 页面。
- 新页面命名为 `Password_Set.ets`。
- 补上二级菜单 `装置设置 -> 密码设置` 的页面跳转。
- 底部三个按钮改成更圆润的样式。

## 转换思路

- 保留原 `ui` 的页面结构，按 `HeaderBar + 中间三行密码输入区 + BottomBar` 组织 ArkTS 页面。
- 保留原始中文文案：
  - `装置设置—`
  - `密码设置`
  - `请输入旧密码：`
  - `请输入新密码：`
  - `请再次确认新密码：`
- 中间三行输入框继续使用密码输入形式，长度限制保持 `20`。
- 页面宽度按 `1024` 基准做缩放，和现有设置页保持一致。

## 具体改动

- 新增页面：`entry/src/main/ets/pages/Password_Set.ets`
- 注册页面：`entry/src/main/resources/base/profile/main_pages.json`
- 增加菜单跳转：`entry/src/main/ets/components/TopMenu.ets`

## 当前结果

- 已完成 `Password_Set.ui` 到 `Password_Set.ets` 的界面转换。
- 已完成 `装置设置 -> 密码设置` 菜单点击跳转。
- 底部 `确认 / 关闭 / 返回` 按钮已加大圆角，视觉上比原来更圆润。
- `确认` 按钮当前仅保留点击入口，后续再接具体密码校验和保存逻辑。

## 本次迭代

- 按你的要求把 `Password_Set.ets` 的中间表单字号继续调大：
  - 标题字号从 `20` 提到 `22`
  - 表单标签和输入字号从 `20` 提到 `22`
  - 底部按钮和时间字号从 `18` 提到 `20`
- 为了让中间三行更接近视觉中心，把表单容器整体向左平移了一点，当前使用固定偏移量 `56`。
- 同时把表单标签宽度和整体宽度略微放大，避免文字放大后显得拥挤。

## 验证

- 已执行本地构建：
  - `assembleHap --mode module -p module=entry@default -p product=default`
- 构建通过。
- 当前输出仅包含项目内已有的 ArkTS 弃用警告，没有新增编译错误。
