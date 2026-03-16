import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import * as tcpClientModule from 'libentry.so';

const DOMAIN = 0x0000;
const ENTRY_TAG = 'JY_ENTRY';
const TCP_ARK_TAG = 'JY_TCP_ARK';
const TCP_SERVER_HOST = '127.0.0.1';
const TCP_SERVER_PORT = 9000;

interface TcpClientModule {
  startTcpClient: (host: string, port: number) => boolean;
  stopTcpClient: () => void;
  isTcpClientRunning: () => boolean;
}

declare function requireNapi(moduleName: string, isAppModule?: boolean, modulePath?: string): TcpClientModule | undefined;

export default class EntryAbility extends UIAbility {
  private hasLoggedTcpModuleLoaded: boolean = false;
  private cachedTcpClientModule?: TcpClientModule;

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

  private isValidTcpClientModule(module: TcpClientModule | undefined): boolean {
    if (!module) {
      return false;
    }
    return typeof module.startTcpClient === 'function' &&
      typeof module.stopTcpClient === 'function' &&
      typeof module.isTcpClientRunning === 'function';
  }

  private loadTcpClientModule(): TcpClientModule | undefined {
    if (this.cachedTcpClientModule && this.isValidTcpClientModule(this.cachedTcpClientModule)) {
      return this.cachedTcpClientModule;
    }

    if (this.isValidTcpClientModule(tcpClientModule)) {
      this.cachedTcpClientModule = tcpClientModule;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 libentry.so 导入加载TCP客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    const napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidTcpClientModule(napiModuleWithPath)) {
      this.cachedTcpClientModule = napiModuleWithPath;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry, true, bundle/module) 加载TCP客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    const napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidTcpClientModule(napiModuleWithApp)) {
      this.cachedTcpClientModule = napiModuleWithApp;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry, true) 加载TCP客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    const napiModule = requireNapi('entry');
    if (this.isValidTcpClientModule(napiModule)) {
      this.cachedTcpClientModule = napiModule;
      if (!this.hasLoggedTcpModuleLoaded) {
        hilog.info(DOMAIN, TCP_ARK_TAG, '已通过 requireNapi(entry) 加载TCP客户端 native 模块');
        this.hasLoggedTcpModuleLoaded = true;
      }
      return this.cachedTcpClientModule;
    }

    hilog.error(DOMAIN, TCP_ARK_TAG,
      '加载TCP客户端 native 模块失败: import=%{public}s/%{public}s/%{public}s, require1=%{public}s, require2=%{public}s, require3=%{public}s',
      this.getModuleMemberType(tcpClientModule, 'startTcpClient'),
      this.getModuleMemberType(tcpClientModule, 'stopTcpClient'),
      this.getModuleMemberType(tcpClientModule, 'isTcpClientRunning'),
      this.isValidTcpClientModule(napiModuleWithPath) ? 'ok' : 'undefined',
      this.isValidTcpClientModule(napiModuleWithApp) ? 'ok' : 'undefined',
      this.isValidTcpClientModule(napiModule) ? 'ok' : 'undefined');
    return undefined;
  }

  private stopNativeTcpClient(): void {
    const nativeModule = this.loadTcpClientModule();
    if (!nativeModule) {
      return;
    }

    if (!nativeModule.isTcpClientRunning()) {
      return;
    }

    try {
      nativeModule.stopTcpClient();
      hilog.info(DOMAIN, TCP_ARK_TAG, 'TCP客户端已停止');
    } catch (err) {
      hilog.error(DOMAIN, TCP_ARK_TAG, '停止TCP客户端失败: %{public}s', JSON.stringify(err));
    }
  }

  private startNativeTcpClient(): void {
    const nativeModule = this.loadTcpClientModule();
    if (!nativeModule) {
      return;
    }

    if (nativeModule.isTcpClientRunning()) {
      return;
    }

    try {
      const started = nativeModule.startTcpClient(TCP_SERVER_HOST, TCP_SERVER_PORT);
      hilog.info(DOMAIN, TCP_ARK_TAG, 'TCP客户端启动结果: %{public}s, 目标地址: %{public}s:%{public}d',
        started ? 'success' : 'failed', TCP_SERVER_HOST, TCP_SERVER_PORT);
    } catch (err) {
      hilog.error(DOMAIN, TCP_ARK_TAG, '启动TCP客户端失败: %{public}s', JSON.stringify(err));
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, ENTRY_TAG, '设置颜色模式失败: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    this.stopNativeTcpClient();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, ENTRY_TAG, '加载首页失败: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, ENTRY_TAG, '首页加载成功');
      this.startNativeTcpClient();
      window.getLastWindow(this.context).then(async (mainWindow: window.Window) => {
        const systemBars: Array<'status' | 'navigation'> = [];
        await mainWindow.setWindowLayoutFullScreen(true);
        await mainWindow.setWindowSystemBarEnable(systemBars);
        await mainWindow.setSpecificSystemBarEnabled('navigationIndicator', false);
        hilog.info(DOMAIN, ENTRY_TAG, '全屏布局设置完成');
      }).catch((windowError: Error) => {
        hilog.error(DOMAIN, ENTRY_TAG, '设置全屏布局失败: %{public}s', JSON.stringify(windowError));
      });
    });
  }

  onWindowStageDestroy(): void {
    this.stopNativeTcpClient();
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
