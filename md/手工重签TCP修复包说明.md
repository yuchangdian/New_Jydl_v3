# 手工重签 TCP 修复包说明

## 结论

这次真正需要你重签的不是旧包，而是我已经重新打好的 `unsigned hap`：

- 待重签文件：`E:\baidu\arkTS_code\New_Jydl_v3\entry\build\default\outputs\default\entry-default-unsigned.hap`

这个 `unsigned hap` 里我已经替换成了新的 `libentry.so`：

- 新 native so：`E:\baidu\arkTS_code\New_Jydl_v3\entry\build\default\intermediates\cmake\default\obj\arm64-v8a\libentry.so`

我已经确认新的 `unsigned hap` 内部 `libs/arm64-v8a/libentry.so` 大小是 `33616` 字节，不再是旧版的 `66376` 字节。

## 你在签名软件里要做什么

如果你的签名软件支持直接对 `unsigned hap` 重签，那就按下面做：

1. 选择输入文件：
   `E:\baidu\arkTS_code\New_Jydl_v3\entry\build\default\outputs\default\entry-default-unsigned.hap`

2. 选择输出文件：
   建议仍然输出到
   `E:\baidu\arkTS_code\New_Jydl_v3\entry\build\default\outputs\default\entry-default-signed.hap`

3. 使用你原来给这个应用签名的同一套签名材料。

4. 签完后，把新的 `entry-default-signed.hap` 安装到设备。

## 如果你的签名软件不是直接签 hap，而是先看包内容

你需要确认 `hap` 里这条文件已经是新版本：

- `libs/arm64-v8a/libentry.so`

它应该对应本地这个文件：

- `E:\baidu\arkTS_code\New_Jydl_v3\entry\build\default\intermediates\cmake\default\obj\arm64-v8a\libentry.so`

不要再拿旧的 `66376` 字节版本去签。

## 重签后怎么验证

安装新包后，运行：

```powershell
.\看TCP日志.ps1
```

重点看这几个 tag：

- `JY_ENTRY`
- `JY_TCP_ARK`
- `JY_TCP_NATIVE`

## 预期结果

正常情况下，不应该再出现这一句：

```text
加载TCP客户端 native 模块失败: import=undefined/undefined/undefined, require1=undefined, require2=undefined, require3=undefined
```

更合理的结果应该是下面这类日志之一：

```text
JY_TCP_ARK: 已通过 libentry.so 导入加载TCP客户端 native 模块
JY_TCP_ARK: TCP客户端启动结果: success, 目标地址: 127.0.0.1:9000
```

或者 native 侧继续输出连接日志：

```text
JY_TCP_NATIVE: connected ...
```

## 如果重签后还是失败

把以下两样发我：

1. 重新安装后的 `看TCP日志.ps1` 输出
2. 你签名后的最终包路径

如果需要，我下一步再继续指导你核对签名软件里是否把 `unsigned hap` 换成了我这次更新过的那一份。
