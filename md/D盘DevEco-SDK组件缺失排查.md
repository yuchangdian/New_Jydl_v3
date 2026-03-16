# D盘 DevEco Studio SDK 组件缺失排查

## 现象

当前在 `D:\Program Files\Huawei\DevEco Studio` 这套新安装环境下执行构建，会报：

`00303168 Configuration Error`

`SDK component missing.`

## 已确认结论

这个报错不是 TCP 客户端接入代码导致的，也不是 `build-profile.json5` 新增 `openharmony` 产品直接导致的。

即使只构建原来的默认产品：

- `product=default`
- `runtimeOS=HarmonyOS`

也同样会报 `SDK component missing`。

## 根因

当前 D 盘 HarmonyOS SDK 根目录：

`D:\Program Files\Huawei\DevEco Studio\sdk\default\hms`

实际只有这些组件目录：

- `ets`
- `native`
- `previewer`
- `toolchains`

缺少：

- `js`

而 `hvigor` 的 HarmonyOS 默认构建链会校验 HarmonyOS SDK 组件完整性，至少会检查对应组件目录下是否存在：

- `uni-package.json`

缺少 `js` 组件时，就会直接报：

`SDK component missing`

## 代码层面的改动说明

本轮为了继续给 OpenHarmony 真机排查 `libentry.so` 加载失败，只额外做了这些项目侧改动：

1. 根 `build-profile.json5` 增加了一个 `openharmony` 产品，不影响 `default` 产品的原始配置。
2. 项目根新增了 `.local_sdk/openharmony` 代理目录，仅用于本地排查 OpenHarmony SDK 目录布局问题。
3. `看TCP日志.ps1` 的 `hdc.exe` 路径改成了新的 D 盘 DevEco 路径。

这些改动不会让 HarmonyOS 默认产品凭空缺失 SDK 组件。

## 最短修复方案

优先处理 SDK 安装完整性：

1. 打开 DevEco Studio
2. 进入 `File > Settings > HarmonyOS SDK`
3. 检查 `D:\Program Files\Huawei\DevEco Studio\sdk\default\hms` 对应的 HarmonyOS SDK 组件
4. 至少补齐：
   - `JS`
   - `ETS`
   - `Native`
   - `Previewer`
   - `Toolchains`

补齐后再次验证：

```powershell
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk\default\hms'
Remove-Item Env:OHOS_BASE_SDK_HOME -ErrorAction SilentlyContinue
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' 'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default -p requiredDeviceType=default assembleHap --analyze=normal --parallel --incremental
```

## 后续建议

先把 D 盘 HarmonyOS SDK 缺失的 `js` 组件补齐，让默认构建恢复。

默认构建恢复后，再继续单独验证 `openharmony` 产品包，解决 OpenHarmony 真机上 `libentry.so` 无法加载的问题。
