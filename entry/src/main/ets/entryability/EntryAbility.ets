import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import * as tcpClientModule from 'libentry.so';

// 日志域和日志标签。
// 这些常量用于区分“应用入口日志”和“ArkTS 调 native TCP 日志”。
const DOMAIN = 0x0000;
const ENTRY_TAG = 'JY_ENTRY';
const TCP_ARK_TAG = 'JY_TCP_ARK';

// 当前默认连接的 TCP 服务器地址。
// EntryAbility 在首屏加载完成后，会把这里的 IP 和端口传给 native TCP 客户端。
const TCP_SERVER_HOST = '192.168.1.102';
const TCP_SERVER_PORT = 2404;

// ArkTS 侧对 native 模块能力的类型声明。
// 只要 so 层返回的对象具备这几个函数，ArkTS 就能统一调用它。
interface TcpClientModule {
  startTcpClient: (host: string, port: number) => boolean;
  stopTcpClient: () => void;
  isTcpClientRunning: () => boolean;
  add?: (a: number, b: number) => number;
}

// requireNapi 是动态加载 native 模块的备用方式。
// 当前文件既尝试直接 import so，也保留 requireNapi 作为回退路径。
declare function requireNapi(moduleName: string, isAppModule?: boolean, modulePath?: string): TcpClientModule | undefined;

// EntryAbility 是应用级入口对象。
// 应用被系统拉起后，会先创建这个 Ability，再按生命周期回调进入各个函数。
export default class EntryAbility extends UIAbility {
  // 这个标志位用于控制“native 模块加载成功”的日志只打印一次。
  private hasLoggedTcpModuleLoaded: boolean = false;

  // 缓存已经验证通过的 native 模块对象，避免重复加载。
  private cachedTcpClientModule?: TcpClientModule;

  // 这个辅助函数只用于调试 native 模块加载状态。
  // 当模块加载失败时，它会返回某个成员当前的类型，方便判断：
  // 是模块本身没拿到，还是某个导出函数缺失。
  private getModuleMemberType(module: TcpClientModule | undefined, memberName: string): string {
    if (!module) {
      return 'undefined';
    }
    if (memberName === 'startTcpClient') {
      return typeof module.startTcpClient;
    }
    if (memberName === 'stopTcpClient') {
      return typeof module.stopTcpClient;
    }
    if (memberName === 'isTcpClientRunning') {
      return typeof module.isTcpClientRunning;
    }
    return 'unknown';
  }

  // 统一检查一个对象是否可以当作“可用的 TCP native 模块”。
  // 这里只要求三个核心函数存在：
  // 1. startTcpClient
  // 2. stopTcpClient
  // 3. isTcpClientRunning
  // add 只是启动时的测试函数，不属于必需能力。
  private isValidTcpClientModule(module: TcpClientModule | undefined): boolean {
    if (!module) {
      return false;
    }
    return typeof module.startTcpClient === 'function' &&
      typeof module.stopTcpClient === 'function' &&
      typeof module.isTcpClientRunning === 'function';
  }

  // 统一封装 native 模块加载逻辑。
  // 当前加载顺序是：
  // 1. 优先使用 import 进来的 libentry.so
  // 2. 失败后尝试 requireNapi('entry', true, bundle/module)
  // 3. 再尝试 requireNapi('entry', true)
  // 4. 最后尝试 requireNapi('entry')
  // 只要某一步拿到的对象通过校验，就缓存并返回。
  private loadTcpClientModule(): TcpClientModule | undefined {
    // 如果之前已经成功加载过，而且缓存对象仍然有效，就直接复用。
    if (this.cachedTcpClientModule && this.isValidTcpClientModule(this.cachedTcpClientModule)) {
      return this.cachedTcpClientModule;
    }

    // 第一优先级：直接使用 import 'libentry.so' 的结果。
    if (this.isValidTcpClientModule(tcpClientModule)) {
      this.cachedTcpClientModule = tcpClientModule;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 libentry.so 导入加载 TCP 客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    // 第二优先级：显式指定 bundle/module 路径加载 NAPI 模块。
    const napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidTcpClientModule(napiModuleWithPath)) {
      this.cachedTcpClientModule = napiModuleWithPath;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry, true, bundle/module) 加载 TCP 客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    // 第三优先级：指定当前是应用模块，但不显式传模块路径。
    const napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidTcpClientModule(napiModuleWithApp)) {
      this.cachedTcpClientModule = napiModuleWithApp;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry, true) 加载 TCP 客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    // 第四优先级：最宽松的默认加载方式。
    const napiModule = requireNapi('entry');
    if (this.isValidTcpClientModule(napiModule)) {
      this.cachedTcpClientModule = napiModule;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry) 加载 TCP 客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    // 走到这里说明四种加载方式都失败了。
    // 这里把 import 和三种 requireNapi 的结果都打印出来，便于定位加载问题。
    hilog.error(DOMAIN, TCP_ARK_TAG,
      '加载 TCP 客户端 native 模块失败: import=%{public}s/%{public}s/%{public}s, require1=%{public}s, require2=%{public}s, require3=%{public}s',
      this.getModuleMemberType(tcpClientModule, 'startTcpClient'),
      this.getModuleMemberType(tcpClientModule, 'stopTcpClient'),
      this.getModuleMemberType(tcpClientModule, 'isTcpClientRunning'),
      this.isValidTcpClientModule(napiModuleWithPath) ? 'ok' : 'undefined',
      this.isValidTcpClientModule(napiModuleWithApp) ? 'ok' : 'undefined',
      this.isValidTcpClientModule(napiModule) ? 'ok' : 'undefined');
    return undefined;
  }

  // 停止 native TCP 客户端。
  // onDestroy 和 onWindowStageDestroy 都会复用这个函数，
  // 这样退出路径只有一份，后续维护更集中。
  private stopNativeTcpClient(): void {
    // 先拿到可用的 native 模块；拿不到就直接返回。
    const nativeModule = this.loadTcpClientModule();
    if (!nativeModule) {
      return;
    }

    // 如果 native 层当前没有在运行，就不需要重复 stop。
    if (!nativeModule.isTcpClientRunning()) {
      return;
    }

    try {
      // 真正调用 so 层导出的 stopTcpClient。
      nativeModule.stopTcpClient();
      hilog.info(DOMAIN, TCP_ARK_TAG, 'TCP 客户端已停止');
    } catch (err) {
      // 这里捕获的是 ArkTS 调 native 过程中抛出的异常。
      hilog.error(DOMAIN, TCP_ARK_TAG, '停止 TCP 客户端失败: %{public}s', JSON.stringify(err));
    }
  }

  // 启动 native TCP 客户端。
  // ArkTS 层不自己操作 socket，而是把地址交给 native 层去创建线程和连接。
  private startNativeTcpClient(): void {
    // 先尝试拿到 native 模块；如果 so 没有正确加载，这里直接结束。
    const nativeModule = this.loadTcpClientModule();
    if (!nativeModule) {
      return;
    }

    // 如果线程已经在运行，就不重复启动，避免出现多个 TCP 线程并发。
    if (nativeModule.isTcpClientRunning()) {
      return;
    }

    try {
      // 这里把固定配置的服务器地址传给 native 层。
      const started = nativeModule.startTcpClient(TCP_SERVER_HOST, TCP_SERVER_PORT);
      hilog.info(DOMAIN, TCP_ARK_TAG, 'TCP 客户端启动结果: %{public}s, 目标地址: %{public}s:%{public}d',
        started ? 'success' : 'failed', TCP_SERVER_HOST, TCP_SERVER_PORT);
    } catch (err) {
      // 这里捕获的是 ArkTS -> native 调用阶段的异常。
      hilog.error(DOMAIN, TCP_ARK_TAG, '启动 TCP 客户端失败: %{public}s', JSON.stringify(err));
    }
  }

  // onCreate 是 Ability 生命周期里最早执行的初始化入口。
  // 当前这里主要做两件事：
  // 1. 检查 native 模块是否可用
  // 2. 设置应用级颜色模式
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 这里先主动加载一次 native 模块，并用 add(2, 3) 做最小能力验证。
    // 这样可以尽早发现 so 导入、模块注册或函数导出是否正常。
    const nativeModule = this.loadTcpClientModule();
    if (nativeModule && typeof nativeModule.add === 'function') {
      hilog.info(DOMAIN, 'testTag', 'Test NAPI 2 + 3 = %{public}d', nativeModule.add(2, 3));
    } else {
      hilog.error(DOMAIN, 'testTag', 'add 测试函数不可用');
    }

    try {
      // 设置全局颜色模式。
      // COLOR_MODE_NOT_SET 表示这里不强制指定明暗模式，交给系统或页面自身处理。
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, ENTRY_TAG, '设置颜色模式失败: %{public}s', JSON.stringify(err));
    }
  }

  // onDestroy 对应 Ability 销毁阶段。
  // 这里只做一件关键事：确保 native TCP 客户端被停掉，避免后台线程泄漏。
  onDestroy(): void {
    this.stopNativeTcpClient();
  }

  // onWindowStageCreate 是界面层真正的启动入口。
  // 只有进入这里之后，页面才会被挂载到窗口上，用户也才会看到首页。
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 加载首页 pages/Index。
    // 如果这里失败，说明页面资源、路由名称或构建产物存在问题。
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, ENTRY_TAG, '加载首页失败: %{public}s', JSON.stringify(err));
        return;
      }

      // 首页加载成功后，再启动 native TCP 客户端。
      // 这样可以保证网络线程是在界面已经建立完成后再启动。
      hilog.info(DOMAIN, ENTRY_TAG, '首页加载成功');
      this.startNativeTcpClient();

      // 拿到当前主窗口，继续配置全屏布局和系统栏显示策略。
      window.getLastWindow(this.context).then(async (mainWindow: window.Window) => {
        // 传空数组给 setWindowSystemBarEnable，表示不启用默认状态栏和导航栏。
        const systemBars: Array<'status' | 'navigation'> = [];

        // 允许内容绘制到全屏区域。
        await mainWindow.setWindowLayoutFullScreen(true);
        // 关闭默认系统栏显示。
        await mainWindow.setWindowSystemBarEnable(systemBars);
        // 进一步关闭底部导航指示条。
        await mainWindow.setSpecificSystemBarEnabled('navigationIndicator', false);
        hilog.info(DOMAIN, ENTRY_TAG, '全屏布局设置完成');
      }).catch((windowError: Error) => {
        // 这里捕获的是窗口配置阶段的异常，不是页面加载异常。
        hilog.error(DOMAIN, ENTRY_TAG, '设置全屏布局失败: %{public}s', JSON.stringify(windowError));
      });
    });
  }

  // onWindowStageDestroy 对应窗口阶段销毁。
  // 当界面窗口被关闭时，这里和 onDestroy 一样，也主动停止 native TCP 客户端。
  onWindowStageDestroy(): void {
    this.stopNativeTcpClient();
  }

  // onForeground 在应用回到前台时触发。
  // 当前先留空；后续如果要做“回前台自动刷新或重连”，就从这里加逻辑。
  onForeground(): void {
  }

  // onBackground 在应用切到后台时触发。
  // 当前先留空；后续如果要做“退后台降频、暂停刷新、上报状态”，可以放这里。
  onBackground(): void {
  }
}
