# 越限报警提交写回 ExceedingLimitSetting（2026-04-03）

## 目标
- 在 `CommonSetting_ExceedingLimit_Set.ets` 页面点击“提交”后：
  - 弹出“等待回应”提示弹窗（仅提示，不实现回应处理）
  - 将界面值写入 native 的 `CommonSetting_ExceedingLimit_Struct ExceedingLimitSetting`

## 本次处理
- 修复并重建了以下文件（原文件存在乱码和字符串未闭合，导致 ArkTS 编译失败）：
  - `entry/src/main/ets/pages/CommonSetting_ExceedingLimit_Set.ets`
  - `entry/src/main/ets/models/CommonSettingExceedingLimitData.ets`

- 页面侧实现：
  - 页面打开优先从 native `getExceedingLimitSetting()` 读取并回填界面。
  - 读取失败时回退读取本地持久化 JSON。
  - 点击提交时：
    1. 先保存本地 JSON；
    2. 再调用 native `updateExceedingLimitSetting(...)` 写回结构体；
    3. 成功后弹出“等待回应”弹窗；
    4. 失败时弹“提交失败”提示。

- 数据映射：
  - 投退：`投入 -> 1`，`退出 -> 0`。
  - 数值字段统一做非负数校验与回退。
  - 延时字段使用无符号整数写回。

## 验证结果
- 已执行增量构建：
  - 命令：`assembleHap --incremental`
  - 结果：`BUILD SUCCESSFUL`
- 当前仅有项目内既有的 deprecated 警告，不影响本次功能。
