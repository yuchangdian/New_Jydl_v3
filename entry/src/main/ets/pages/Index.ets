import { TopMenu } from '../components/TopMenu'
import * as telemetryNativeModule from 'libentry.so';

interface PlateItem {
  name: string;
  checked: boolean;
}

interface BaseFreqDisplayValue {
  ready: boolean;
  Ua_Rms: number;
  Ua_Phase: number;
  Ub_Rms: number;
  Ub_Phase: number;
  Uc_Rms: number;
  Uc_Phase: number;
  Uo_Rms: number;
  Uo_Phase: number;
  Ux_Rms: number;
  Ux_Phase: number;
  IA_Rms: number;
  IA_Phase: number;
  IB_Rms: number;
  IB_Phase: number;
  IC_Rms: number;
  IC_Phase: number;
  Io_Rms: number;
  Io_Phase: number;
  Ia_Rms: number;
  Ia_Phase: number;
  Ib_Rms: number;
  Ib_Phase: number;
  Ic_Rms: number;
  Ic_Phase: number;
}

interface BaseFreqNativeModule {
  getBaseFreqDisplayData?: () => BaseFreqDisplayValue | undefined;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): BaseFreqNativeModule | undefined;

const ANGLE_SYMBOL: string = String.fromCharCode(8736);
const DEGREE_SYMBOL: string = String.fromCharCode(176);

function createPhasorPlaceholder(unit: string): string {
  return '**.**' + unit + ANGLE_SYMBOL + '**.**' + DEGREE_SYMBOL;
}

function formatBaseFreqPhasorText(rms: number, phase: number, unit: string): string {
  if (!isValidBaseFreqNumber(rms) || !isValidBaseFreqNumber(phase)) {
    return createPhasorPlaceholder(unit);
  }
  return rms.toFixed(2) + unit + ANGLE_SYMBOL + phase.toFixed(2) + DEGREE_SYMBOL;
}

function isValidBaseFreqNumber(value: number): boolean {
  return typeof value === 'number' && isFinite(value);
}

function isUsableBaseFreqDisplayValue(value: BaseFreqDisplayValue | undefined): boolean {
  if (!value || !value.ready) {
    return false;
  }

  return [
    value.Ua_Rms, value.Ua_Phase,
    value.Ub_Rms, value.Ub_Phase,
    value.Uc_Rms, value.Uc_Phase,
    value.Uo_Rms, value.Uo_Phase,
    value.Ux_Rms, value.Ux_Phase,
    value.IA_Rms, value.IA_Phase,
    value.IB_Rms, value.IB_Phase,
    value.IC_Rms, value.IC_Phase,
    value.Io_Rms, value.Io_Phase,
    value.Ia_Rms, value.Ia_Phase,
    value.Ib_Rms, value.Ib_Phase,
    value.Ic_Rms, value.Ic_Phase
  ].every((item: number) => isValidBaseFreqNumber(item));
}

// @Entry 标记当前页面是可直接作为页面入口加载的组件。
// EntryAbility 在 onWindowStageCreate 中调用 loadContent('pages/Index') 后，最终会进入这个页面。
@Entry
@Component
struct Index {
  @State frequency: string = '**.**Hz';
  @State voltage: string = '10.7kV';
  @State current: string = '**.**A';
  @State power: string = '**.**kW';
  @State reactivePower: string = '**.**kVar';
  @State powerFactor: string = '*.***';
  @State forwardActiveEnergy: string = '**.**kW.h';
  @State forwardReactiveEnergy: string = '**.**kVar.h';
  @State reverseActiveEnergy: string = '**.**kW.h';
  @State reverseReactiveEnergy: string = '**.**kVar.h';

  @State ua: string = '**.**V∠**.**°';
  @State ub: string = '**.**V∠**.**°';
  @State uc: string = '**.**V∠**.**°';
  @State u0: string = '**.**V∠**.**°';
  @State ux: string = '**.**V∠**.**°';
  @State ia: string = '**.**V∠**.**°';
  @State ib: string = '**.**V∠**.**°';
  @State ic: string = '**.**V∠**.**°';
  @State i0: string = '**.**V∠**.**°';
  @State iia: string = '**.**V∠**.**°';
  @State iib: string = '**.**V∠**.**°';
  @State iic: string = '**.**V∠**.**°';

  private baseFreqRefreshTimer: number = -1;
  private cachedBaseFreqNativeModule?: BaseFreqNativeModule;

  @State hardPlates: Array<PlateItem> = [
    { name: '纵联保护', checked: true },
    { name: '低频减载保护', checked: true },
    { name: '低压减载保护', checked: true },
    { name: '停用重合闸', checked: true }
  ];

  @State softPlates: Array<PlateItem> = [
    { name: '远方修改定值', checked: true },
    { name: '远方切换定值区', checked: true },
    { name: '远方投退软压板', checked: true },
    { name: '电流差动保护', checked: true },
    { name: '过电流I段', checked: true },
    { name: '过电流II段', checked: true },
    { name: '过电流III段', checked: true },
    { name: '过电流加速段', checked: true },
    { name: 'PT断线相过流', checked: true },
    { name: '零序纵联保护', checked: true },
    { name: '零序过流I段', checked: true },
    { name: '零序过流II段', checked: true },
    { name: '零序过流III段', checked: true },
    { name: '零序过流加速段', checked: true },
    { name: '母线保护', checked: true },
    { name: '自适应零序过流I段', checked: true },
    { name: '自适应零序过流II段', checked: true },
    { name: '自适应零序过流III段', checked: true },
    { name: '自适应零序过流加速段', checked: true },
    { name: '停用重合闸', checked: true },
    { name: '低频减载保护', checked: true },
    { name: '低压减载保护', checked: true },
    { name: '过负荷保护', checked: true },
    { name: 'GOOSE低频减载', checked: true },
    { name: 'GOOSE低压减载', checked: true },
    { name: 'GOOSE过负荷', checked: true }
  ];

  // build 是页面 UI 树的总入口，所有子区域都从这里组合出来。
  aboutToAppear(): void {
    this.refreshBaseFreqDisplay();
    this.startBaseFreqRefreshTimer();
  }

  aboutToDisappear(): void {
    this.stopBaseFreqRefreshTimer();
  }

  private startBaseFreqRefreshTimer(): void {
    this.stopBaseFreqRefreshTimer();
    this.baseFreqRefreshTimer = setInterval(() => {
      this.refreshBaseFreqDisplay();
    }, 500);
  }

  private stopBaseFreqRefreshTimer(): void {
    if (this.baseFreqRefreshTimer >= 0) {
      clearInterval(this.baseFreqRefreshTimer);
      this.baseFreqRefreshTimer = -1;
    }
  }

  private isValidBaseFreqNativeModule(module: BaseFreqNativeModule | undefined): boolean {
    return !!module && typeof module.getBaseFreqDisplayData === 'function';
  }

  private loadBaseFreqNativeModule(): BaseFreqNativeModule | undefined {
    if (this.isValidBaseFreqNativeModule(this.cachedBaseFreqNativeModule)) {
      return this.cachedBaseFreqNativeModule;
    }
    if (this.isValidBaseFreqNativeModule(telemetryNativeModule)) {
      this.cachedBaseFreqNativeModule = telemetryNativeModule;
      return this.cachedBaseFreqNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidBaseFreqNativeModule(napiModuleWithPath)) {
      this.cachedBaseFreqNativeModule = napiModuleWithPath;
      return this.cachedBaseFreqNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidBaseFreqNativeModule(napiModuleWithApp)) {
      this.cachedBaseFreqNativeModule = napiModuleWithApp;
      return this.cachedBaseFreqNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidBaseFreqNativeModule(napiModule)) {
      this.cachedBaseFreqNativeModule = napiModule;
      return this.cachedBaseFreqNativeModule;
    }

    return undefined;
  }

  private resetBaseFreqDisplay(): void {
    this.ua = createPhasorPlaceholder('V');
    this.ub = createPhasorPlaceholder('V');
    this.uc = createPhasorPlaceholder('V');
    this.u0 = createPhasorPlaceholder('V');
    this.ux = createPhasorPlaceholder('V');
    this.ia = createPhasorPlaceholder('A');
    this.ib = createPhasorPlaceholder('A');
    this.ic = createPhasorPlaceholder('A');
    this.i0 = createPhasorPlaceholder('A');
    this.iia = createPhasorPlaceholder('A');
    this.iib = createPhasorPlaceholder('A');
    this.iic = createPhasorPlaceholder('A');
  }

  private refreshBaseFreqDisplay(): void {
    try {
      let nativeModule = this.loadBaseFreqNativeModule();
      if (!nativeModule || typeof nativeModule.getBaseFreqDisplayData !== 'function') {
        this.resetBaseFreqDisplay();
        return;
      }

      let value = nativeModule.getBaseFreqDisplayData();
      if (!isUsableBaseFreqDisplayValue(value)) {
        this.resetBaseFreqDisplay();
        return;
      }

      let baseFreqValue = value as BaseFreqDisplayValue;
      this.ua = formatBaseFreqPhasorText(baseFreqValue.Ua_Rms, baseFreqValue.Ua_Phase, 'V');
      this.ub = formatBaseFreqPhasorText(baseFreqValue.Ub_Rms, baseFreqValue.Ub_Phase, 'V');
      this.uc = formatBaseFreqPhasorText(baseFreqValue.Uc_Rms, baseFreqValue.Uc_Phase, 'V');
      this.u0 = formatBaseFreqPhasorText(baseFreqValue.Uo_Rms, baseFreqValue.Uo_Phase, 'V');
      this.ux = formatBaseFreqPhasorText(baseFreqValue.Ux_Rms, baseFreqValue.Ux_Phase, 'V');
      this.ia = formatBaseFreqPhasorText(baseFreqValue.IA_Rms, baseFreqValue.IA_Phase, 'A');
      this.ib = formatBaseFreqPhasorText(baseFreqValue.IB_Rms, baseFreqValue.IB_Phase, 'A');
      this.ic = formatBaseFreqPhasorText(baseFreqValue.IC_Rms, baseFreqValue.IC_Phase, 'A');
      this.i0 = formatBaseFreqPhasorText(baseFreqValue.Io_Rms, baseFreqValue.Io_Phase, 'A');
      this.iia = formatBaseFreqPhasorText(baseFreqValue.Ia_Rms, baseFreqValue.Ia_Phase, 'A');
      this.iib = formatBaseFreqPhasorText(baseFreqValue.Ib_Rms, baseFreqValue.Ib_Phase, 'A');
      this.iic = formatBaseFreqPhasorText(baseFreqValue.Ic_Rms, baseFreqValue.Ic_Phase, 'A');
    } catch (error) {
      console.error(`refresh base frequency display failed: ${JSON.stringify(error)}`);
      this.resetBaseFreqDisplay();
    }
  }

  build() {
    Column() {
      TopMenu()
        .zIndex(9999)

      Row() {
        this.LeftPanel()
        this.RightPanel()
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')

  }

  @Builder
  // 左侧信息面板：显示频率、运行状态、版本时间等概览信息。
  LeftPanel() {
    Column() {
      Text(`频率：${this.frequency}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)

      Row() {
        this.SwitchIndicator()
        this.ParamsList()
      }
      .width('100%')
      .margin({ top: 10 })

      Text('运行状态')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 15,bottom:5 })
        .decoration({ type: TextDecorationType.Underline })

      Text('远方控制')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Center)
        .decoration({ type: TextDecorationType.Underline })

      Text('当前定值区号: 01')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 10,bottom:0 })
      Text('软件版本: V1.00')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 10,bottom:10 })
      Text('2024/7/7 12:12:12')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width(220)
    .height('100%')
    .backgroundColor('#e2e6ec')
    .padding(10)
    .border({ width: { top: 1 }, color: '#000000' })
  }

  @Builder
  // 左侧开关示意图区域：通过 Shape/Path 拼装一次系统接线示意。
  SwitchIndicator() {
    Column() {
      Shape() {
        Path()
          .commands('M24 12.5 L56 12.5')
          .stroke('#000000')
          .strokeWidth(1.5)
          .fill('none')

        Path()
          .commands('M40 12.5 L40 20')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M32 20 L48 20')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 40 L32 20')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 40 L40 50')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Rect()
          .width(20)
          .height(25)
          .radius(0)
          .fill('#ff0000')
          .stroke('#000000')
          .strokeWidth(1)
          .offset({ x: 30, y: 48.5 })

        Path()
          .commands('M40 50 L40 52.5')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 77.5 L40 80')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 80 L40 90')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 90 L32 110')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M32 110 L48 110')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Circle()
          .width(12.5)
          .height(12.5)
          .fill('none')
          .stroke('#000000')
          .strokeWidth(1)
          .offset({ x: 29, y: 105.25 })

        Path()
          .commands('M40 110 L40 116.25')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 128.75 L40 135')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M40 135 L40 175')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('none')

        Path()
          .commands('M34 170 L40 180 L46 170 Z')
          .stroke('#000000')
          .strokeWidth(1)
          .fill('#000000')
      }
      .width(80)
      .height(200)
    }
    .margin({ right: 10 })
  }

  @Builder
  // 左侧参数列表：显示电压、电流、功率、电能等关键量测值。
  ParamsList() {
    Column({space:5}) {
      Text(`U=${this.voltage}`)
        .fontSize(16)
        .width(100)
        .textAlign(TextAlign.Start)

      Text(`I=${this.current}`)
        .fontSize(16)
        .width(100)
        .textAlign(TextAlign.Start)

      Text(`P=${this.power}`)
        .fontSize(16)
        .width(100)
        .textAlign(TextAlign.Start)

      Text(`Q=${this.reactivePower}`)
        .fontSize(16)
        .width(100)
        .textAlign(TextAlign.Start)

      Text(`cos=${this.powerFactor}`)
        .fontSize(16)
        .width(100)
        .textAlign(TextAlign.Start)

      Text('正向有功电能')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.forwardActiveEnergy)
        .fontSize(16)
        .width(80)
        .textAlign(TextAlign.Start)

      Text('正向无功电能')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.forwardReactiveEnergy)
        .fontSize(16)
        .width(80)
        .textAlign(TextAlign.Start)

      Text('反向有功电能')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.reverseActiveEnergy)
        .fontSize(16)
        .width(80)
        .textAlign(TextAlign.Start)

      Text('反向无功电能')
        .fontSize(16)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.reverseReactiveEnergy)
        .fontSize(16)
        .width(80)
        .textAlign(TextAlign.Start)
    }
    .layoutWeight(1)
  }

  @Builder
  // 右侧主内容区：显示三相量测值以及软压板、硬压板区域。
  RightPanel() {
    Scroll() {
      Column() {
        Row() {
          Text('电')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)

          Text('压')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 42 })

          Text(`：Uₐ ${this.ua}  Uᵦ ${this.ub}  U꜀ ${this.uc}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')

        Text(`U₀ ${this.u0}  Uₓ ${this.ux}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ left: 205 })

        Text(`保护电流：Iₐ ${this.ia}  Iᵦ ${this.ib}  I꜀ ${this.ic}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 15 })

        Text(`3I₀ ${this.i0}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ left: 195 })

        Text(`测量电流：İₐ ${this.iia}  İᵦ ${this.iib}  İ꜀ ${this.iic}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 15 })

        this.HardPlateSection()
        this.SoftPlateSection()
      }
      .width('100%')
      .padding(10)
    }
    .layoutWeight(1)
  }

  @Builder
  // 硬压板区域：以复选框形式展示硬压板状态。
  HardPlateSection() {
    Column() {
      Row() {
        Text('硬压板：')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)

        ForEach(this.hardPlates, (plate: PlateItem, index: number) => {
          Row() {
            Checkbox()
              .select(plate.checked)
              .selectedColor('#007DFF')
              .onChange((value: boolean) => {
                this.hardPlates[index].checked = value;
              })

            Text(plate.name)
              .fontSize(14)
              .margin({ left: 4 })
          }
          .margin({ left: 10 })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .margin({ top: 15 })
    .border({ width: { top: 1,bottom:1 }, color: '#000000' })
  }

  @Builder
  // 软压板区域：按分组布局展示软压板状态。
  SoftPlateSection() {
    Column() {
      Row() {
        Text('软压板：')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)

        ForEach(this.softPlates.slice(0, 3), (plate: PlateItem, index: number) => {
          Row() {
            Checkbox()
              .select(plate.checked)
              .selectedColor('#007DFF')
              .onChange((value: boolean) => {
                this.softPlates[index].checked = value;
              })
              .margin('4.00px')

            Text(plate.name)
              .fontSize(14)
              .margin({ left: 4 })
          }
          .margin({ left: 10 })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({top:10})
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          ForEach(this.softPlates.slice(3, 9), (plate: PlateItem, index: number) => {
            Row() {
              Checkbox()
                .select(plate.checked)
                .selectedColor('#007DFF')
                .onChange((value: boolean) => {
                  this.softPlates[index + 3].checked = value;
                })
                .margin('8.00px')

              Text(plate.name)
                .fontSize(14)
                .margin({ left: 4 })
            }
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .align(Alignment.TopStart)

        Column() {
          ForEach(this.softPlates.slice(9, 15), (plate: PlateItem, index: number) => {
            Row() {
              Checkbox()
                .select(plate.checked)
                .selectedColor('#007DFF')
                .onChange((value: boolean) => {
                  this.softPlates[index + 9].checked = value;
                })
                .margin('8.00px')

              Text(plate.name)
                .fontSize(14)
                .margin({ left: 4 })
            }
          })
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .alignSelf(ItemAlign.Start)
        .alignItems(HorizontalAlign.Start)

        Column() {
          ForEach(this.softPlates.slice(15, 20), (plate: PlateItem, index: number) => {
            Row() {
              Checkbox()
                .select(plate.checked)
                .selectedColor('#007DFF')
                .onChange((value: boolean) => {
                  this.softPlates[index + 15].checked = value;
                })
                .margin('8.00px')

              Text(plate.name)
                .fontSize(14)
                .margin({ left: 4 })
            }
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 34 })

        Column() {
          ForEach(this.softPlates.slice(20, 26), (plate: PlateItem, index: number) => {
            Row() {
              Checkbox()
                .select(plate.checked)
                .selectedColor('#007DFF')
                .onChange((value: boolean) => {
                  this.softPlates[index + 20].checked = value;
                })
                .margin('8.00px')

              Text(plate.name)
                .fontSize(14)
                .margin({ left: 4 })
            }
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }
}
