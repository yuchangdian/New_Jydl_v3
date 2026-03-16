# 精准查看 TCP 日志

你看到的 `HDC_LOG`、`Faultlogger`、`DumperService` 这些，不是应用自己的业务日志。

这次现象的根因不是应用打了太多日志，而是这台设备上的 `hdc hilog` 设备侧过滤不干净。即使带了 `-T`、`-P`、`-t app`，系统服务日志有时还是会混进来。

## 为什么会这样

`hdc hilog` 读的是系统日志缓冲区，不是只读你的应用私有日志。

所以你会看到：

- `HDC_LOG`：设备调试通道自己的日志
- `Faultlogger`、`DumperService`：崩溃抓取和转储服务日志
- `CoreService`、`CellularData`：系统服务日志

这些都不是 `com.example.new_jydl_v3` 的 ArkTS 或 C TCP 客户端日志。

## 最稳的办法

不要再依赖设备侧 `-T` 过滤，直接在电脑本地过滤唯一 tag。

项目里已经放好了脚本：

`看TCP日志.ps1`

它会做两件事：

1. 自动检查设备和应用进程
2. 只输出下面 3 个 tag 的日志

- `JY_TCP_ARK`
- `JY_TCP_NATIVE`
- `JY_ENTRY`

## 直接用法

先启动应用，再在项目根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\看TCP日志.ps1
```

## 手动用法

如果你不想跑脚本，也可以直接本地过滤：

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe' hilog | Select-String 'JY_TCP_ARK|JY_TCP_NATIVE|JY_ENTRY'
```

这条命令的关键点是：

- 前半段还是抓全量日志
- 后半段在电脑本地只保留你自己的唯一 tag

这样基本不会再被系统杂日志干扰。

## 注意

如果你设备里安装的还是旧包，你可能看不到 `JY_TCP_ARK`、`JY_TCP_NATIVE`、`JY_ENTRY`，因为这些 tag 是我后面新加的。

最新安装包在：

`entry/build/default/outputs/default/entry-default-signed.hap`

## 日志乱码原因

如果你看到：

- `棣栭〉鍔犺浇鎴愬姛`
- `鍔犺浇TCP客户端 native 模块失败`

这种内容，不是应用里中文写坏了，而是 Windows PowerShell 把 UTF-8 日志按本地代码页错误解码了。

应用源码里的中文本身是正常的，例如日志原文其实是：

- `首页加载成功`
- `加载TCP客户端 native 模块失败`

## 解决方案

已经在 `看TCP日志.ps1` 里加了 UTF-8 控制台设置，脚本启动时会自动执行：

```powershell
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
chcp 65001 > $null
```

所以现在优先用这个脚本看日志，不要直接裸跑 `hdc hilog`。
