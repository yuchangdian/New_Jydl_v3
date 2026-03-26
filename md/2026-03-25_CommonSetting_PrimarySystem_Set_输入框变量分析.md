# CommonSetting_PrimarySystem_Set 输入框变量分析

## 1. 这几个输入框的值都存在哪里

页面没有给每个输入框单独定义一个 `@State` 变量，而是统一放在：

- `formData: CommonSettingPrimarySystemData`

对应位置：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:55`

初始化代码：

```ts
@State formData: CommonSettingPrimarySystemData = createDefaultCommonSettingPrimarySystemData();
```

也就是页面里的输入框，本质上都在读写 `this.formData.xxx`。

## 2. 输入框字段和实际变量的对应关系

### TextInput 输入框

| 输入框 fieldKey | 实际保存字段 |
| --- | --- |
| `bus_pt_primary` | `formData.busPtPrimary` |
| `bus_pt_secondary` | `formData.busPtSecondary` |
| `bus_zero_pt_primary` | `formData.busZeroPtPrimary` |
| `bus_zero_pt_secondary` | `formData.busZeroPtSecondary` |
| `line_pt_primary` | `formData.linePtPrimary` |
| `line_pt_secondary` | `formData.linePtSecondary` |
| `protect_ct_primary` | `formData.protectCtPrimary` |
| `protect_ct_secondary` | `formData.protectCtSecondary` |
| `zero_ct_primary` | `formData.zeroCtPrimary` |
| `zero_ct_secondary` | `formData.zeroCtSecondary` |
| `measure_ct_primary` | `formData.measureCtPrimary` |
| `measure_ct_secondary` | `formData.measureCtSecondary` |
| `rated_power` | `formData.ratedPower` |

对应代码：

- 取值映射：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:153-184`
- 赋值映射：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:186-230`

### 下拉/选择框

虽然你问的是输入框，但这个页面里还有 3 个选择项，它们和输入框共用同一个 `formData`：

| 选择框 fieldKey | 实际保存字段 |
| --- | --- |
| `line_phase` | `formData.linePhase` |
| `ct_connection` | `formData.ctConnectionMode` |
| `zero_current_mode` | `formData.zeroCurrentMode` |

对应代码：

- 取值映射：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:232-243`
- 赋值映射：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:245-259`

## 3. 这些变量最开始怎么赋值

有 3 个来源：

### 3.1 默认值

`formData` 初始化时调用：

```ts
createDefaultCommonSettingPrimarySystemData()
```

它本质上就是：

```ts
return new CommonSettingPrimarySystemData();
```

而默认值都写在 `CommonSettingPrimarySystemData` 类里：

- `entry/src/main/ets/models/CommonSettingPrimarySystemData.ets:2-18`

例如：

- `busPtPrimary = '10.0'`
- `busPtSecondary = '100'`
- `protectCtPrimary = '600'`
- `ratedPower = '1200'`

### 3.2 页面出现时，读取本地保存值覆盖默认值

页面进入时执行：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:93-104`

核心逻辑：

1. `aboutToAppear()` 调用 `loadPersistedData()`
2. `loadPersistedData()` 读取文件 `common_setting_primary_system.json`
3. 用 `deserializeCommonSettingPrimarySystemData(raw)` 反序列化
4. 成功后执行 `this.formData = restored`

对应代码：

- 文件名：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:83`
- 加载逻辑：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:111-125`
- 反序列化逻辑：`entry/src/main/ets/models/CommonSettingPrimarySystemData.ets:85-117`

这意味着：

- 第一次进页面，没有保存文件时，用默认值
- 以前点过“提交”保存过时，下次进页面会优先显示上次保存的值

### 3.3 点击“默认值”按钮时重新赋值

按钮最终调用：

```ts
this.resetDefaults();
```

而 `resetDefaults()` 做的事情是：

```ts
this.formData = createDefaultCommonSettingPrimarySystemData();
```

对应代码：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:319-320`
- 按钮点击：`entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:780-786`

## 4. 输入框里的值是怎么显示出来的

所有文本输入框都走同一个 Builder：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:556-576`

核心代码：

```ts
TextInput({ text: this.getInputValue(fieldKey), placeholder: '' })
```

也就是：

1. 行布局把 `fieldKey` 传进来
2. `InputField(fieldKey)` 调 `getInputValue(fieldKey)`
3. `getInputValue()` 再从 `this.formData.xxx` 里取对应值
4. 这个值显示到输入框里

输入框行是这样传 `fieldKey` 的：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:336-348`
- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:463-486`
- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:531-553`

例如：

```ts
this.StandardRatedRow('母线PT', 'bus_pt_primary', 'kV', 'bus_pt_secondary', 'V');
```

最终就会把：

- 左输入框绑定到 `formData.busPtPrimary`
- 右输入框绑定到 `formData.busPtSecondary`

## 5. 用户输入后，这些变量是怎么被改掉的

还是在统一的 `InputField(fieldKey)` 里处理：

```ts
.onChange((value: string) => {
  this.setInputValue(fieldKey, value);
});
```

对应代码：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:568-570`

然后 `setInputValue(fieldKey, value)` 根据不同的 `fieldKey`，把值写回 `this.formData.xxx`。

例如：

- `fieldKey === 'bus_pt_primary'` 时，执行 `this.formData.busPtPrimary = value`
- `fieldKey === 'rated_power'` 时，执行 `this.formData.ratedPower = value`

对应代码：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:186-230`

所以输入链路是：

`TextInput 输入变化` -> `onChange(value)` -> `setInputValue(fieldKey, value)` -> `this.formData.xxx = value`

## 6. 这些值后面是怎么获取出来使用的

当前这份代码里，主要有 4 种“取值”方式：

### 6.1 页面回显时取值

通过：

- `getInputValue(fieldKey)`
- `getSelectValue(fieldKey)`

把 `formData` 里的值取出来显示到界面上。

### 6.2 点击“提交”时整体取值

点击“提交”按钮后：

1. 调用 `submitCurrentData()`
2. 再调用 `savePersistedData()`
3. 直接把整个 `this.formData` 序列化成 JSON 保存到文件

对应代码：

- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:323-325`
- `entry/src/main/ets/pages/CommonSetting_PrimarySystem_Set.ets:127-140`
- `entry/src/main/ets/models/CommonSettingPrimarySystemData.ets:64-83`

也就是说，提交时不是一个个字段单独取，而是一次性读取整个 `formData`。

### 6.3 下次进入页面时再取值

读取本地文件后，通过反序列化重新装回 `formData`，再由界面回显。

### 6.4 点击默认值时重新取默认对象

也是整对象替换，不是单字段重置。

## 7. 当前代码里，这些输入值有没有传到别的页面或业务逻辑

我在 `entry/src/main/ets` 下搜索过 `CommonSettingPrimarySystemData`、`common_setting_primary_system.json`、序列化/反序列化函数。

当前结果是：

- 这些值只在本页面和它对应的 model 文件里使用
- 主要用途是“显示、编辑、恢复默认、保存到本地、下次加载回来”
- 当前没有看到继续传给别的页面、网络接口、设备通信逻辑的代码

## 8. 一句话总结

这个页面里所有输入框的值，统一存放在 `@State formData` 里。

流程是：

`默认值/本地文件加载` -> `formData` -> `getInputValue()` 回显到 `TextInput` -> `onChange()` 改写回 `formData` -> `提交时 serialize(formData)` 保存到 `common_setting_primary_system.json`。
