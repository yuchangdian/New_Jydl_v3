# 宽频谐波页面读取 HarmonicU_Dsip 说明

## 本次目标

把 `data.cpp` 里的 `YC_HarmonicU_Struct HarmonicU_Dsip` 接到 `broadband_harmonic.ets` 的 `sections: HarmonicSectionData[]`，让页面打开时能显示最新的谐波电压数据。

## 本次改动

### 1. native 侧补电压 ready 标志

- 在 `data.h` 中新增 `extern bool HarmonicVoltageDisplayReady;`
- 在 `data.cpp` 中新增 `bool HarmonicVoltageDisplayReady = false;`
- 在 `tcp_client.cpp` 中收到 `RemoteMetry_HarmonicU` 且长度正确后，更新 `HarmonicU_Dsip` 并置 `HarmonicVoltageDisplayReady = true`

### 2. NAPI 导出谐波电压

- 在 `telemetry_napi.cpp` 中新增 `getHarmonicVoltageDisplayData()`
- 返回字段：
  - `ready`
  - `Ua`
  - `Ub`
  - `Uc`
- 在 `napi_init.cpp` 中注册 `getHarmonicVoltageDisplayData`
- 在 `Index.d.ts` 和 `Libentry.mock.ets` 中补齐类型声明和 mock

### 3. 页面打开时同时读取电压和电流

`broadband_harmonic.ets` 现在在页面 `aboutToAppear()` 时调用 `loadNativeHarmonicDisplayData()`：

- 先尝试读取 `getHarmonicVoltageDisplayData()`
- 再尝试读取 `getHarmonicCurrentDisplayData()`
- 电压有效时回填 `sections[].rows[].voltage`
- 电流有效时回填 `sections[].rows[].current`

这样页面最终会同时显示：

- 左半边电压：来自 `HarmonicU_Dsip`
- 右半边电流：来自 `HarmonicI_Dsip`

## 映射规则

`YC_HarmonicU_Struct` 的每相数组按 3 个一组：

- `[0]` 工频频率
- `[1]` 工频幅值
- `[2]` 工频相位
- `[3]` 谐波 1 频率
- `[4]` 谐波 1 幅值
- `[5]` 谐波 1 相位
- 以此类推

页面中：

- 第 1 个 section 对应工频分量
- 第 2 个 section 对应谐波分量 1
- 一直到第 10 个 section

每个 section 的三行分别对应：

- A 相 -> `Ua`
- B 相 -> `Ub`
- C 相 -> `Uc`

每行 `voltage` 四个字段映射为：

- `frequency` = 频率 + `Hz`
- `amplitude` = 幅值 + `V`
- `phase` = 相位 + `°`
- `ratio` = 当前幅值 / 工频幅值 * 100%

## 验证

已执行整包构建验证，结果：

- `BUILD SUCCESSFUL`
