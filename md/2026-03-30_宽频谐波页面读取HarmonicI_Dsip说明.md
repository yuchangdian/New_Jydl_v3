# 宽频谐波页面读取 HarmonicI_Dsip 说明

## 本次目标

把 `data.cpp` 里的 `YC_HarmonicI_Struct HarmonicI_Dsip` 读取到 ArkTS 页面 `broadband_harmonic.ets`，并在页面打开时赋值给 `sections: HarmonicSectionData[]`，让界面显示最新的谐波电流数据。

## 本次改动

### 1. native 侧增加导出

- 在 `data.h` 中新增 `extern bool HarmonicCurrentDisplayReady;`
- 在 `data.cpp` 中新增 `bool HarmonicCurrentDisplayReady = false;`
- 在 `tcp_client.cpp` 中收到 `RemoteMetry_HarmonicI` 并更新 `HarmonicI_Dsip` 后，把 `HarmonicCurrentDisplayReady` 置为 `true`
- 在 `telemetry_napi.cpp` 中新增 `getHarmonicCurrentDisplayData()`，返回：
  - `ready`
  - `Ia`
  - `Ib`
  - `Ic`
- 在 `napi_init.cpp` 中注册 `getHarmonicCurrentDisplayData`
- 在 `Index.d.ts` 和 `Libentry.mock.ets` 中补齐类型声明和 mock

### 2. ArkTS 页面读取并回填

- `broadband_harmonic.ets` 页面新增 `@State sections`
- 页面 `aboutToAppear()` 时调用 `loadNativeHarmonicCurrentData()`
- 如果 native 返回值满足：
  - `ready === true`
  - `Ia / Ib / Ic` 长度足够
  - 每个元素都是有效数字
  则把 `HarmonicI_Dsip` 映射到 `sections`

### 3. 映射规则

`YC_HarmonicI_Struct` 里每相数组按 3 个一组：

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
- 第 3 个 section 对应谐波分量 2
- 一直到第 10 个 section

每个 section 的三行分别对应：

- A 相 -> `Ia`
- B 相 -> `Ib`
- C 相 -> `Ic`

每行的 `current` 四个字段映射为：

- `frequency` = 频率 + `Hz`
- `amplitude` = 幅值 + `A`
- `phase` = 相位 + `°`
- `ratio` = 当前幅值 / 工频幅值 * 100%

## 说明

这次只接了 `HarmonicI_Dsip`，所以页面右半部分“电流”数据会显示 native 最新值。

页面左半部分“电压”仍保留原页面默认占位数据，因为它对应的应是 `YC_HarmonicU_Struct HarmonicU_Dsip`，这次没有一起接。

## 验证

已执行：

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' --mode module -p module=entry@default -p product=default -p requiredDeviceType=default assembleHap --analyze=normal --parallel --incremental
```

结果：

- `BUILD SUCCESSFUL`
