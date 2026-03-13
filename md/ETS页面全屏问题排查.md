# ETS 页面全屏问题排查

## 结论

这个项目里“有些 ETS 页面不能全屏”的主因，不是页面根布局尺寸写错，而是**全屏开关只放在了 `Index.ets` 页面里**。

具体表现是：

1. 应用启动时，`EntryAbility` 先加载 `pages/Index`。
2. `Index.ets` 在 `onPageShow()` 里调用 `setWindowLayoutFullScreen(true)`，进入全屏布局。
3. 当从 `Index.ets` 跳转到其它页面时，`Index.ets` 的 `onPageHide()` 会执行 `setWindowLayoutFullScreen(false)`，把窗口退出全屏布局。
4. 目标页面本身没有再把窗口切回全屏，所以这些页面就显示成“非全屏”。

因此，问题本质上是：**全屏能力绑定在首页生命周期上，而不是绑定在窗口或所有需要全屏的页面上。**

## 证据

### 1. 入口能力默认加载的是首页

文件：`entry/src/main/ets/entryability/EntryAbility.ets`

- `onWindowStageCreate()` 在第 21 行定义。
- `windowStage.loadContent('pages/Index', ...)` 在第 25 行。

这说明应用启动后先进入 `Index.ets`。

### 2. 只有 `Index.ets` 处理了全屏

文件：`entry/src/main/ets/pages/Index.ets`

- 第 76 行：`window.getLastWindow(getContext(this))`
- 第 78 行：`this.windowClass.setWindowLayoutFullScreen(flag)`
- 第 81 行：`onPageShow()`
- 第 85 行：`onPageHide()`

也就是说：

- 进入 `Index.ets` 时会开启全屏布局。
- 离开 `Index.ets` 时会关闭全屏布局。

### 3. 其它页面没有对应的全屏处理

我在 `entry/src/main/ets` 下搜索了下面这些关键字：

- `setWindowLayoutFullScreen`
- `getLastWindow`
- `onPageShow(`
- `onPageHide(`

搜索结果只命中了 `entry/src/main/ets/pages/Index.ets`，没有命中其它页面文件。  
这说明其它 `@Entry` 页面没有重新开启全屏。

### 4. 页面跳转确实会离开 `Index.ets`

文件：`entry/src/main/ets/components/TopMenu.ets`

- 第 107 行定义 `openPage(url: string)`
- 第 108 行调用 `router.pushUrl(...)`
- 第 118、126、130、134、138、142、146、150、154、158 行分别跳到不同页面

这意味着从首页菜单进入其它页面时，`Index.ets` 会触发 `onPageHide()`，从而把全屏关闭。

### 5. 项目里确实有多页结构

文件：`entry/src/main/resources/base/profile/main_pages.json`

第 3 到 16 行列出了多个页面，包括：

- `pages/Index`
- `pages/SoftStrap`
- `pages/SoftStrapSet`
- `pages/RelaySettingDisp`
- `pages/RelaySetting_DispSelect`
- `pages/RelaySettingSet`
- `pages/RelaySetting_SetSelect`
- `pages/CommonSetting_PrimarySystem_Set`
- `pages/CommonSetting_TeleMeasuring_Set`
- `pages/CommonSetting_TeleSignaling_Set`
- `pages/CommonSetting_TeleControlling_Set`
- `pages/CommonSetting_ExceedingLimit_Set`
- `pages/CommonSetting_AnalogQuantity_Set`
- `pages/CommonSetting_Statistics_Set`

## 受影响页面

从当前代码看，除 `Index.ets` 之外，下面这些 `@Entry` 页面都没有自己的全屏开启逻辑，因此都可能出现“不能全屏”的现象：

- `pages/SoftStrap`
- `pages/SoftStrapSet`
- `pages/RelaySetting_DispSelect`
- `pages/RelaySettingDisp`
- `pages/RelaySetting_SetSelect`
- `pages/RelaySettingSet`
- `pages/CommonSetting_PrimarySystem_Set`
- `pages/CommonSetting_TeleMeasuring_Set`
- `pages/CommonSetting_TeleSignaling_Set`
- `pages/CommonSetting_TeleControlling_Set`
- `pages/CommonSetting_ExceedingLimit_Set`
- `pages/CommonSetting_AnalogQuantity_Set`
- `pages/CommonSetting_Statistics_Set`

## 为什么我判断不是页面根布局尺寸问题

我抽查了几个页面：

- `entry/src/main/ets/pages/SoftStrap.ets:16-17`
- `entry/src/main/ets/pages/SoftStrapSet.ets:335-336`
- `entry/src/main/ets/pages/RelaySetting_DispSelect.ets:142-143`

这些页面的根节点都已经写了 `.width('100%')` 和 `.height('100%')`。  
这说明页面本身是想撑满可用区域的，真正没有撑满的是**窗口可用区域**，不是页面布局尺寸。

## 更准确的原因描述

可以把现在的行为理解成下面这个流程：

1. `Index.ets` 显示时，窗口允许全屏布局。
2. 用户从首页跳到其它页面。
3. `Index.ets` 隐藏时，主动把窗口恢复成非全屏布局。
4. 新页面没有再开启全屏。
5. 用户看到的就是“有些页面不是全屏”。

所以这不是“某几个页面单独写坏了”，而是**全屏控制放置位置不对**导致的连锁结果。

## 修复建议

### 方案一：把全屏逻辑上移到窗口创建阶段

把 `setWindowLayoutFullScreen(true)` 放到 `EntryAbility.onWindowStageCreate()` 或窗口初始化公共逻辑里统一处理。  
这样只要应用窗口创建出来，就始终保持全屏布局，不依赖某一个页面。

这个方案最稳，适合“整个应用都要全屏”的场景。

### 方案二：做成公共方法，在每个需要全屏的页面里调用

如果不是所有页面都需要全屏，可以抽一个公共工具方法，让每个需要全屏的页面在 `onPageShow()` 时主动开启。

但当前写法里，至少不要只让 `Index.ets` 在 `onPageHide()` 时关闭全屏，否则页面切走后会把后续页面一起带成非全屏。

### 方案三：如果要真正铺到系统栏区域，再补安全区处理

如果你的“全屏”目标不仅是窗口全屏布局，还希望内容延展到状态栏、导航栏区域，那么除了窗口全屏设置外，还要检查页面根节点是否需要额外处理安全区，例如统一的根容器策略。

不过从当前代码看，**第一优先级问题仍然是全屏开关只存在于 `Index.ets`**。

## 本次排查说明

- 本次是静态代码排查，没有改动业务代码。
- 已确认问题不在 `entry/src/main/module.json5` 这类模块配置文件里，没有看到限制全屏的窗口模式配置。
- 如果后续需要，我可以直接继续把这个问题修掉，并统一处理所有页面的全屏行为。
