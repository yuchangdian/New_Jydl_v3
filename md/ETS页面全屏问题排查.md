# ETS 页面全屏问题排查

## 问题原因

这个项目里“有些 ETS 页面不能全屏”的主因，不是页面根布局没有写满，而是全屏控制放错了位置。

原来的逻辑是：

1. 应用启动后先进入 `pages/Index`。
2. `Index.ets` 在页面显示时开启全屏。
3. 从 `Index.ets` 跳到其它页面时，`Index.ets` 在页面隐藏时又把全屏关闭。
4. 目标页面没有重新开启全屏，所以看起来就成了“部分页面不能全屏”。

也就是说，问题本质上是：

- 全屏能力被绑定在首页生命周期里。
- 页面切换时，首页把窗口状态改回去了。
- 其它页面本身虽然大多写了 `.width('100%')` 和 `.height('100%')`，但拿到的已经不是全屏窗口区域。

## 代码证据

- `entry/src/main/ets/entryability/EntryAbility.ets`
  - 应用入口加载的是 `pages/Index`。
- `entry/src/main/ets/pages/Index.ets`
  - 原先只有这个页面控制 `setWindowLayoutFullScreen(...)`。
  - 原先还在 `onPageHide()` 里关闭全屏。
- `entry/src/main/ets/components/TopMenu.ets`
  - 首页通过菜单跳转到多个 `@Entry` 页面。

## 解决办法

推荐方案是把全屏控制提升到窗口级，而不是页面级。

具体做法：

1. 在 `EntryAbility.onWindowStageCreate()` 里加载首页成功后，统一获取窗口。
2. 在这里调用 `setWindowLayoutFullScreen(true)`。
3. 删除 `Index.ets` 里跟页面生命周期绑定的全屏开关逻辑，尤其是不再在 `onPageHide()` 里关闭全屏。

这样处理后：

- 应用窗口创建后就保持全屏布局。
- 页面之间切换不会再把全屏状态弄丢。
- 不需要给每个页面单独补一遍全屏逻辑。

## 本次已实施修改

已做小幅代码调整：

- `entry/src/main/ets/entryability/EntryAbility.ets`
  - 在 `loadContent('pages/Index', ...)` 成功后统一获取窗口。
  - 调用 `setWindowLayoutFullScreen(true)`，把全屏逻辑放到入口能力。
- `entry/src/main/ets/pages/Index.ets`
  - 删除页面级的全屏状态控制。
  - 删除原先会在页面切换时关闭全屏的逻辑。

## 关键位置

- `entry/src/main/ets/entryability/EntryAbility.ets:25`
- `entry/src/main/ets/entryability/EntryAbility.ets:31`
- `entry/src/main/ets/entryability/EntryAbility.ets:32`
- `entry/src/main/ets/pages/Index.ets:10`
- `entry/src/main/ets/pages/Index.ets:71`

## 验证结果

已执行构建验证，结果为 `BUILD SUCCESSFUL`。

本次修改没有引入新的编译错误。当前仍有一些项目里原本就存在的弃用告警，例如：

- `router.pushUrl`
- `router.back`
- `router.getParams`

这些告警与本次全屏修复无关。
