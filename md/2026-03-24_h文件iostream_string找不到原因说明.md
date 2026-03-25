# .h 文件里 `iostream` / `string` 找不到的原因说明

## 现象

当前现象是：

- `.cpp` 文件里不报错
- `.h` 文件里报错：
  - `'iostream' file not found`
  - `'string' file not found`

## 这不是头文件本身有问题

头文件不会单独按“一个完整 C++ 源文件”去编译。

编辑器检查 `data.h` 这类头文件时，必须先找到一个“正在参与构建的 `.cpp` 文件”，再借用那个 `.cpp` 的：

- C 还是 C++ 语言模式
- 编译器路径
- sysroot
- 标准库搜索路径
- 宏定义
- include 路径

如果头文件没有挂到一个真实的 C++ 编译单元上，编辑器就容易把它当成：

- 独立文件
- 没有编译参数的文件
- 甚至按 C 文件上下文处理

这时就会出现 `iostream`、`string` 这类 C++ 标准库头“找不到”的假报错。

## 你这个工程里为什么会这样

当前 `CMakeLists.txt` 里真正参与构建的只有：

- `napi_init.cpp`
- `tcp_client.c`

也就是当前 `compile_commands.json` 里只有这两个编译命令。

而 `data.cpp` 现在**还没有被加入 `CMakeLists.txt`**，所以：

- `data.cpp` 没有自己的 C++ 编译命令
- `data.h` 也没有机会挂到 `data.cpp` 这个 C++ 编译单元上

同时，我又确认了当前参与构建的两个源文件：

- `napi_init.cpp`
- `tcp_client.c`

它们都没有引用 `data.h` / `setting.h` / `IEC104.h` 这条链。

结果就是：

- 构建系统根本没有在编译这套头文件
- 编辑器只能“单独猜”怎么解析 `data.h`
- 猜错之后，就会报 `iostream` / `string` not found

## 为什么 `.cpp` 不报错

因为 `.cpp` 文件如果本身已经被编译系统接管，编辑器可以直接拿到它的真实编译命令，例如：

- 用的是 `clang++.exe`
- 目标平台是 `aarch64-linux-ohos`
- 带了 `--sysroot=...`

这些信息一旦齐全，C++ 标准库头就能正常找到。

所以你看到的“`.cpp` 不报错、`.h` 报错”，本质上通常不是代码语法差异，而是：

**头文件缺少正确的编译上下文。**

## 这类报错分两种情况

### 情况 1：编辑器假报错

如果你现在直接构建工程，而构建过程根本没有编译到 `data.cpp` / `data.h`，那这个报错只代表：

编辑器当前没法正确分析这个头文件。

这种情况下：

- IDE 红线存在
- 但不代表真实构建一定会失败

### 情况 2：后面一旦把 `data.cpp` 加进 CMake，真实编译也报错

如果你后面把 `data.cpp` 正式加入 `CMakeLists.txt`，重新生成编译数据库之后，构建仍然报：

- `'iostream' file not found`
- `'string' file not found`

那才说明：

- DevEco / OpenHarmony NDK 的 C++ 标准库路径没有正确带进来
- 或者这个文件被错误地按 C 编译了

但就你当前工程状态看，**更大的概率是第一种：编辑器上下文问题，不是真实编译问题。**

## 你现在应该怎么判断

按下面顺序判断最稳：

1. 先看 `CMakeLists.txt` 里有没有把 `data.cpp` 加入 `add_library(...)`
2. 再看 `compile_commands.json` 里有没有 `data.cpp` 这一条
3. 如果没有，那 `data.h` 的这个报错优先按“编辑器假报错”处理
4. 如果有了，再执行一次完整构建，看是否真实失败

## 你下一步最有效的处理方式

### 方案 A：先接受这是编辑器报错

前提：

- `data.cpp` 还没加入构建
- `compile_commands.json` 里没有 `data.cpp`

这时不要先盯着 `data.h` 的红线。

先把真正的构建链接通更重要。

### 方案 B：把 `data.cpp` 正式接入构建

当你把 `data.cpp` 加进 `CMakeLists.txt` 之后，再重新构建一次，让编译数据库更新。

一旦 `data.cpp` 进入真实 C++ 构建：

- `data.h` 会自动获得正确的 C++ 上下文
- 很多 `iostream` / `string` not found 的假报错会直接消失

## 一句话结论

你现在这个现象，大概率不是 `data.h` 代码本身有问题，而是：

**`data.h` 还没有挂到一个真实参与构建的 C++ 编译单元上，导致编辑器无法正确找到 OpenHarmony 的 C++ 标准库头。**
