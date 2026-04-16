import router from '@ohos.router';
import display from '@ohos.display';
import * as analogQuantityNativeModule from 'libentry.so';

interface AnalogSignalConfig {
  label: string;
  referenceKey: string;
  correctionKey: string;
  zeroDriftKey: string;
  unit: string;
}

interface AnalogRowConfig {
  left: AnalogSignalConfig;
  right: AnalogSignalConfig;
  gaps: number[];
}

interface CommonSettingAnalogQuantityParameterStructValue {
  Ua: number;
  Ub: number;
  Uc: number;
  Uo: number;
  IA: number;
  IB: number;
  IC: number;
  Io: number;
  Ia: number;
  Ib: number;
  Ic: number;
  Is: number;
  Ux: number;
  Iby1: number;
  Iby2: number;
  Iby3: number;
}

interface CommonSettingAnalogQuantityStructValue {
  ready: boolean;
  Reference: CommonSettingAnalogQuantityParameterStructValue;
  Correction: CommonSettingAnalogQuantityParameterStructValue;
  ZeroDrift: CommonSettingAnalogQuantityParameterStructValue;
  CRC: number;
}

interface CommonSettingAnalogQuantityWriteParameterValue {
  Ua: number;
  Ub: number;
  Uc: number;
  Uo: number;
  IA: number;
  IB: number;
  IC: number;
  Io: number;
  Ia: number;
  Ib: number;
  Ic: number;
  Is: number;
  Ux: number;
  Iby1: number;
  Iby2: number;
  Iby3: number;
}

interface CommonSettingAnalogQuantityWriteValue {
  Reference: CommonSettingAnalogQuantityWriteParameterValue;
  Correction: CommonSettingAnalogQuantityWriteParameterValue;
  ZeroDrift: CommonSettingAnalogQuantityWriteParameterValue;
}

interface AnalogQuantityNativeModule {
  getAnalogQuantitySetting?: () => CommonSettingAnalogQuantityStructValue | undefined;
  updateAnalogQuantitySetting?: (value: CommonSettingAnalogQuantityWriteValue) => boolean;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): AnalogQuantityNativeModule | undefined;

@Observed
class CommonSettingAnalogQuantityData {
  Edit_Analog_Reference_Ua: string = '100.00';
  Edit_Analog_Correction_Ua: string = '100.00';
  Edit_Analog_ZeroDrift_Ua: string = '800.00';
  Edit_Analog_Reference_Ia: string = '5.00';
  Edit_Analog_Correction_Ia: string = '5.00';
  Edit_Analog_ZeroDrift_Ia: string = '5.00';
  Edit_Analog_Reference_Ub: string = '100.00';
  Edit_Analog_Correction_Ub: string = '100.00';
  Edit_Analog_ZeroDrift_Ub: string = '100.00';
  Edit_Analog_Reference_Ib: string = '5.00';
  Edit_Analog_Correction_Ib: string = '5.00';
  Edit_Analog_ZeroDrift_Ib: string = '5.00';
  Edit_Analog_Reference_Uc: string = '100.00';
  Edit_Analog_Correction_Uc: string = '100.00';
  Edit_Analog_ZeroDrift_Uc: string = '100.00';
  Edit_Analog_Reference_Ic: string = '5.00';
  Edit_Analog_Correction_Ic: string = '5.00';
  Edit_Analog_ZeroDrift_Ic: string = '5.00';
  Edit_Analog_Reference_Uo: string = '100.00';
  Edit_Analog_Correction_Uo: string = '100.00';
  Edit_Analog_ZeroDrift_Uo: string = '100.00';
  Edit_Analog_Reference_Is: string = '5.00';
  Edit_Analog_Correction_Is: string = '5.00';
  Edit_Analog_ZeroDrift_Is: string = '5.00';
  Edit_Analog_Reference_IA: string = '5.00';
  Edit_Analog_Correction_IA: string = '5.00';
  Edit_Analog_ZeroDrift_IA: string = '5.00';
  Edit_Analog_Reference_Ux: string = '100.00';
  Edit_Analog_Correction_Ux: string = '100.00';
  Edit_Analog_ZeroDrift_Ux: string = '100.00';
  Edit_Analog_Reference_IB: string = '5.00';
  Edit_Analog_Correction_IB: string = '5.00';
  Edit_Analog_ZeroDrift_IB: string = '5.00';
  Edit_Analog_Reference_Iby1: string = '5.00';
  Edit_Analog_Correction_Iby1: string = '5.00';
  Edit_Analog_ZeroDrift_Iby1: string = '5.00';
  Edit_Analog_Reference_IC: string = '5.00';
  Edit_Analog_Correction_IC: string = '5.00';
  Edit_Analog_ZeroDrift_IC: string = '5.00';
  Edit_Analog_Reference_Iby2: string = '5.00';
  Edit_Analog_Correction_Iby2: string = '5.00';
  Edit_Analog_ZeroDrift_Iby2: string = '5.00';
  Edit_Analog_Reference_Io: string = '5.00';
  Edit_Analog_Correction_Io: string = '5.00';
  Edit_Analog_ZeroDrift_Io: string = '5.00';
  Edit_Analog_Reference_Iby3: string = '5.00';
  Edit_Analog_Correction_Iby3: string = '5.00';
  Edit_Analog_ZeroDrift_Iby3: string = '5.00';
}

function formatAnalogQuantityNumber(value: number): string {
  if (typeof value !== 'number' || !isFinite(value)) {
    return '';
  }
  return value.toFixed(2);
}

function isValidAnalogQuantityNumber(value: number): boolean {
  return typeof value === 'number' && isFinite(value);
}

function isUsableAnalogQuantityParameterValue(
  value: CommonSettingAnalogQuantityParameterStructValue | undefined
): boolean {
  if (!value) {
    return false;
  }

  return isValidAnalogQuantityNumber(value.Ua) &&
    isValidAnalogQuantityNumber(value.Ub) &&
    isValidAnalogQuantityNumber(value.Uc) &&
    isValidAnalogQuantityNumber(value.Uo) &&
    isValidAnalogQuantityNumber(value.IA) &&
    isValidAnalogQuantityNumber(value.IB) &&
    isValidAnalogQuantityNumber(value.IC) &&
    isValidAnalogQuantityNumber(value.Io) &&
    isValidAnalogQuantityNumber(value.Ia) &&
    isValidAnalogQuantityNumber(value.Ib) &&
    isValidAnalogQuantityNumber(value.Ic) &&
    isValidAnalogQuantityNumber(value.Is) &&
    isValidAnalogQuantityNumber(value.Ux) &&
    isValidAnalogQuantityNumber(value.Iby1) &&
    isValidAnalogQuantityNumber(value.Iby2) &&
    isValidAnalogQuantityNumber(value.Iby3);
}

function isUsableCommonSettingAnalogQuantityStructValue(
  value: CommonSettingAnalogQuantityStructValue | undefined
): boolean {
  if (!value || !value.ready) {
    return false;
  }

  return isUsableAnalogQuantityParameterValue(value.Reference) &&
    isUsableAnalogQuantityParameterValue(value.Correction) &&
    isUsableAnalogQuantityParameterValue(value.ZeroDrift);
}

function createCommonSettingAnalogQuantityValuesFromStruct(
  source: CommonSettingAnalogQuantityStructValue
): CommonSettingAnalogQuantityData {
  let data = createDefaultCommonSettingAnalogQuantityValues();

  data.Edit_Analog_Reference_Ua = formatAnalogQuantityNumber(source.Reference.Ua);
  data.Edit_Analog_Correction_Ua = formatAnalogQuantityNumber(source.Correction.Ua);
  data.Edit_Analog_ZeroDrift_Ua = formatAnalogQuantityNumber(source.ZeroDrift.Ua);
  data.Edit_Analog_Reference_Ia = formatAnalogQuantityNumber(source.Reference.Ia);
  data.Edit_Analog_Correction_Ia = formatAnalogQuantityNumber(source.Correction.Ia);
  data.Edit_Analog_ZeroDrift_Ia = formatAnalogQuantityNumber(source.ZeroDrift.Ia);
  data.Edit_Analog_Reference_Ub = formatAnalogQuantityNumber(source.Reference.Ub);
  data.Edit_Analog_Correction_Ub = formatAnalogQuantityNumber(source.Correction.Ub);
  data.Edit_Analog_ZeroDrift_Ub = formatAnalogQuantityNumber(source.ZeroDrift.Ub);
  data.Edit_Analog_Reference_Ib = formatAnalogQuantityNumber(source.Reference.Ib);
  data.Edit_Analog_Correction_Ib = formatAnalogQuantityNumber(source.Correction.Ib);
  data.Edit_Analog_ZeroDrift_Ib = formatAnalogQuantityNumber(source.ZeroDrift.Ib);
  data.Edit_Analog_Reference_Uc = formatAnalogQuantityNumber(source.Reference.Uc);
  data.Edit_Analog_Correction_Uc = formatAnalogQuantityNumber(source.Correction.Uc);
  data.Edit_Analog_ZeroDrift_Uc = formatAnalogQuantityNumber(source.ZeroDrift.Uc);
  data.Edit_Analog_Reference_Ic = formatAnalogQuantityNumber(source.Reference.Ic);
  data.Edit_Analog_Correction_Ic = formatAnalogQuantityNumber(source.Correction.Ic);
  data.Edit_Analog_ZeroDrift_Ic = formatAnalogQuantityNumber(source.ZeroDrift.Ic);
  data.Edit_Analog_Reference_Uo = formatAnalogQuantityNumber(source.Reference.Uo);
  data.Edit_Analog_Correction_Uo = formatAnalogQuantityNumber(source.Correction.Uo);
  data.Edit_Analog_ZeroDrift_Uo = formatAnalogQuantityNumber(source.ZeroDrift.Uo);
  data.Edit_Analog_Reference_Is = formatAnalogQuantityNumber(source.Reference.Is);
  data.Edit_Analog_Correction_Is = formatAnalogQuantityNumber(source.Correction.Is);
  data.Edit_Analog_ZeroDrift_Is = formatAnalogQuantityNumber(source.ZeroDrift.Is);
  data.Edit_Analog_Reference_IA = formatAnalogQuantityNumber(source.Reference.IA);
  data.Edit_Analog_Correction_IA = formatAnalogQuantityNumber(source.Correction.IA);
  data.Edit_Analog_ZeroDrift_IA = formatAnalogQuantityNumber(source.ZeroDrift.IA);
  data.Edit_Analog_Reference_Ux = formatAnalogQuantityNumber(source.Reference.Ux);
  data.Edit_Analog_Correction_Ux = formatAnalogQuantityNumber(source.Correction.Ux);
  data.Edit_Analog_ZeroDrift_Ux = formatAnalogQuantityNumber(source.ZeroDrift.Ux);
  data.Edit_Analog_Reference_IB = formatAnalogQuantityNumber(source.Reference.IB);
  data.Edit_Analog_Correction_IB = formatAnalogQuantityNumber(source.Correction.IB);
  data.Edit_Analog_ZeroDrift_IB = formatAnalogQuantityNumber(source.ZeroDrift.IB);
  data.Edit_Analog_Reference_Iby1 = formatAnalogQuantityNumber(source.Reference.Iby1);
  data.Edit_Analog_Correction_Iby1 = formatAnalogQuantityNumber(source.Correction.Iby1);
  data.Edit_Analog_ZeroDrift_Iby1 = formatAnalogQuantityNumber(source.ZeroDrift.Iby1);
  data.Edit_Analog_Reference_IC = formatAnalogQuantityNumber(source.Reference.IC);
  data.Edit_Analog_Correction_IC = formatAnalogQuantityNumber(source.Correction.IC);
  data.Edit_Analog_ZeroDrift_IC = formatAnalogQuantityNumber(source.ZeroDrift.IC);
  data.Edit_Analog_Reference_Iby2 = formatAnalogQuantityNumber(source.Reference.Iby2);
  data.Edit_Analog_Correction_Iby2 = formatAnalogQuantityNumber(source.Correction.Iby2);
  data.Edit_Analog_ZeroDrift_Iby2 = formatAnalogQuantityNumber(source.ZeroDrift.Iby2);
  data.Edit_Analog_Reference_Io = formatAnalogQuantityNumber(source.Reference.Io);
  data.Edit_Analog_Correction_Io = formatAnalogQuantityNumber(source.Correction.Io);
  data.Edit_Analog_ZeroDrift_Io = formatAnalogQuantityNumber(source.ZeroDrift.Io);
  data.Edit_Analog_Reference_Iby3 = formatAnalogQuantityNumber(source.Reference.Iby3);
  data.Edit_Analog_Correction_Iby3 = formatAnalogQuantityNumber(source.Correction.Iby3);
  data.Edit_Analog_ZeroDrift_Iby3 = formatAnalogQuantityNumber(source.ZeroDrift.Iby3);

  return data;
}

function createDefaultCommonSettingAnalogQuantityValues(): CommonSettingAnalogQuantityData {
  return new CommonSettingAnalogQuantityData();
}

const COMMON_SETTING_ANALOG_QUANTITY_ROWS: AnalogRowConfig[] = [
  {
    left: {
      label: 'A相电压：',
      referenceKey: 'Edit_Analog_Reference_Ua',
      correctionKey: 'Edit_Analog_Correction_Ua',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ua',
      unit: 'V'
    },
    right: {
      label: 'A相测量电流：',
      referenceKey: 'Edit_Analog_Reference_Ia',
      correctionKey: 'Edit_Analog_Correction_Ia',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ia',
      unit: 'A'
    },
    gaps: [13, 13, 14, 13, 13]
  },
  {
    left: {
      label: 'B相电压：',
      referenceKey: 'Edit_Analog_Reference_Ub',
      correctionKey: 'Edit_Analog_Correction_Ub',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ub',
      unit: 'V'
    },
    right: {
      label: 'B相测量电流：',
      referenceKey: 'Edit_Analog_Reference_Ib',
      correctionKey: 'Edit_Analog_Correction_Ib',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ib',
      unit: 'A'
    },
    gaps: [13, 13, 14, 13, 13]
  },
  {
    left: {
      label: 'C相电压：',
      referenceKey: 'Edit_Analog_Reference_Uc',
      correctionKey: 'Edit_Analog_Correction_Uc',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Uc',
      unit: 'V'
    },
    right: {
      label: 'C相测量电流：',
      referenceKey: 'Edit_Analog_Reference_Ic',
      correctionKey: 'Edit_Analog_Correction_Ic',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ic',
      unit: 'A'
    },
    gaps: [14, 13, 14, 13, 14]
  },
  {
    left: {
      label: '零序电压：',
      referenceKey: 'Edit_Analog_Reference_Uo',
      correctionKey: 'Edit_Analog_Correction_Uo',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Uo',
      unit: 'V'
    },
    right: {
      label: '电缆护套电流：',
      referenceKey: 'Edit_Analog_Reference_Is',
      correctionKey: 'Edit_Analog_Correction_Is',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Is',
      unit: 'A'
    },
    gaps: [10, 10, 10, 10, 10]
  },
  {
    left: {
      label: 'A相保护电流：',
      referenceKey: 'Edit_Analog_Reference_IA',
      correctionKey: 'Edit_Analog_Correction_IA',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_IA',
      unit: 'A'
    },
    right: {
      label: '线路电压：',
      referenceKey: 'Edit_Analog_Reference_Ux',
      correctionKey: 'Edit_Analog_Correction_Ux',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Ux',
      unit: 'V'
    },
    gaps: [12, 11, 12, 11, 12]
  },
  {
    left: {
      label: 'B相保护电流：',
      referenceKey: 'Edit_Analog_Reference_IB',
      correctionKey: 'Edit_Analog_Correction_IB',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_IB',
      unit: 'A'
    },
    right: {
      label: '备用电流1：',
      referenceKey: 'Edit_Analog_Reference_Iby1',
      correctionKey: 'Edit_Analog_Correction_Iby1',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Iby1',
      unit: 'A'
    },
    gaps: [9, 9, 8, 9, 9]
  },
  {
    left: {
      label: 'C相保护电流：',
      referenceKey: 'Edit_Analog_Reference_IC',
      correctionKey: 'Edit_Analog_Correction_IC',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_IC',
      unit: 'A'
    },
    right: {
      label: '备用电流2：',
      referenceKey: 'Edit_Analog_Reference_Iby2',
      correctionKey: 'Edit_Analog_Correction_Iby2',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Iby2',
      unit: 'A'
    },
    gaps: [9, 9, 9, 9, 9]
  },
  {
    left: {
      label: '零序电流：',
      referenceKey: 'Edit_Analog_Reference_Io',
      correctionKey: 'Edit_Analog_Correction_Io',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Io',
      unit: 'A'
    },
    right: {
      label: '备用电流3：',
      referenceKey: 'Edit_Analog_Reference_Iby3',
      correctionKey: 'Edit_Analog_Correction_Iby3',
      zeroDriftKey: 'Edit_Analog_ZeroDrift_Iby3',
      unit: 'A'
    },
    gaps: [29, 29, 30, 29, 29]
  }
];

@Observed
class CommonSettingAnalogQuantityVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定模拟量参数';
  defaultText: string = '默认值';
  submitText: string = '提交';
  backText: string = '返回';
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingAnalogQuantityFontSize {
  notice: number = 15;
  title: number = 20;
  subtitle: number = 18;
  columnHeader: number = 19;
  fieldLabel: number = 17;
  inputValue: number = 17;
  unit: number = 17;
  button: number = 18;
  time: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct CommonSetting_AnalogQuantity_Set {
  @State vm: CommonSettingAnalogQuantityVM = new CommonSettingAnalogQuantityVM();
  @State fieldValues: CommonSettingAnalogQuantityData = createDefaultCommonSettingAnalogQuantityValues();
  @State uiScale: number = 1;
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';
  @State submitWaitingDialogVisible: boolean = false;
  @State submitWaitingMessage: string = '';
  private cachedAnalogQuantityNativeModule?: AnalogQuantityNativeModule;

  private readonly fontSize: CommonSettingAnalogQuantityFontSize = new CommonSettingAnalogQuantityFontSize();
  private readonly pageMaxWidth: number = 1042;
  private readonly pageBaseWidth: number = 1280;
  private readonly pageBaseHeight: number = 720;
  private readonly layoutZoom: number = 1.2;
  private readonly headerHeight: number = 70;
  private readonly bottomBarHeight: number = 70;
  private readonly contentMinHeight: number = 450;
  private readonly contentBottomPadding: number = 10;
  private readonly columnHeaderHeight: number = 40;
  private readonly rowHeight: number = 50;
  private readonly signalLabelWidth: number = 150;
  private readonly fieldInputWidth: number = 80;
  private readonly fieldHeight: number = 36;
  private readonly fieldUnitWidth: number = 18;
  private readonly fieldSpacing: number = 3;
  private readonly fieldGroupWidth: number = 101;
  private readonly labelColumnWeight: number = 15;
  private readonly fieldColumnWeight: number = 10;
  private readonly gapColumnWeight: number = 1;
  private readonly sectionGapWeight: number = 3;
  private readonly labelCellPadding: number = 7;
  private readonly columnHeaderLeadingWidth: number = 150;
  private readonly columnHeaderMiddleWidth: number = 150;
  private readonly columnHeaderGapWidth: number = 35;
  private readonly buttonHeight: number = 55;
  private readonly buttonRadius: number = 10;
  private readonly titleIconHeight: number = 40;
  private readonly titleIconBackWidth: number = 37;
  private readonly titleIconCloseWidth: number = 32;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';

  private s(value: number): number {
    return Math.round(value * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let currentDisplay = display.getDefaultDisplaySync();
      let scaleX = currentDisplay.width / this.pageBaseWidth;
      let scaleY = currentDisplay.height / this.pageBaseHeight;
      let scale = Math.min(scaleX, scaleY);
      this.uiScale = (scale > 0 ? scale : 1) * this.layoutZoom;
    } catch (error) {
      this.uiScale = this.layoutZoom;
    }
    this.loadNativeAnalogQuantityData();
  }

  private isValidAnalogQuantityNativeModule(module: AnalogQuantityNativeModule | undefined): boolean {
    return !!module && typeof module.getAnalogQuantitySetting === 'function';
  }

  private loadAnalogQuantityNativeModule(): AnalogQuantityNativeModule | undefined {
    if (this.isValidAnalogQuantityNativeModule(this.cachedAnalogQuantityNativeModule)) {
      return this.cachedAnalogQuantityNativeModule;
    }
    if (this.isValidAnalogQuantityNativeModule(analogQuantityNativeModule)) {
      this.cachedAnalogQuantityNativeModule = analogQuantityNativeModule;
      return this.cachedAnalogQuantityNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidAnalogQuantityNativeModule(napiModuleWithPath)) {
      this.cachedAnalogQuantityNativeModule = napiModuleWithPath;
      return this.cachedAnalogQuantityNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidAnalogQuantityNativeModule(napiModuleWithApp)) {
      this.cachedAnalogQuantityNativeModule = napiModuleWithApp;
      return this.cachedAnalogQuantityNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidAnalogQuantityNativeModule(napiModule)) {
      this.cachedAnalogQuantityNativeModule = napiModule;
      return this.cachedAnalogQuantityNativeModule;
    }

    return undefined;
  }

  private loadNativeAnalogQuantityData(): boolean {
    try {
      let nativeModule = this.loadAnalogQuantityNativeModule();
      if (!nativeModule || typeof nativeModule.getAnalogQuantitySetting !== 'function') {
        return false;
      }

      let structValue = nativeModule.getAnalogQuantitySetting();
      if (!isUsableCommonSettingAnalogQuantityStructValue(structValue)) {
        return false;
      }

      this.fieldValues = createCommonSettingAnalogQuantityValuesFromStruct(
        structValue as CommonSettingAnalogQuantityStructValue
      );
      return true;
    } catch (error) {
      console.error(`load native analog quantity data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private showFeedback(message: string): void {
    this.feedbackMessage = message;
    this.feedbackDialogVisible = true;
  }

  private closeFeedback(): void {
    this.feedbackDialogVisible = false;
    this.feedbackMessage = '';
  }

  private showSubmitWaiting(message: string): void {
    this.submitWaitingMessage = message;
    this.submitWaitingDialogVisible = true;
  }

  private closeSubmitWaiting(): void {
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
  }

  private parseAnalogQuantityFieldNumber(value: string, fallbackValue: number): number {
    let parsedValue = Number(value);
    if (typeof parsedValue === 'number' && isFinite(parsedValue)) {
      return parsedValue;
    }
    return typeof fallbackValue === 'number' && isFinite(fallbackValue) ? fallbackValue : 0;
  }

  private createAnalogQuantityReferenceWriteValue(
    fallbackValue?: CommonSettingAnalogQuantityParameterStructValue
  ): CommonSettingAnalogQuantityWriteParameterValue {
    return {
      Ua: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ua, fallbackValue?.Ua ?? 100),
      Ub: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ub, fallbackValue?.Ub ?? 100),
      Uc: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Uc, fallbackValue?.Uc ?? 100),
      Uo: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Uo, fallbackValue?.Uo ?? 100),
      IA: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_IA, fallbackValue?.IA ?? 5),
      IB: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_IB, fallbackValue?.IB ?? 5),
      IC: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_IC, fallbackValue?.IC ?? 5),
      Io: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Io, fallbackValue?.Io ?? 5),
      Ia: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ia, fallbackValue?.Ia ?? 5),
      Ib: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ib, fallbackValue?.Ib ?? 5),
      Ic: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ic, fallbackValue?.Ic ?? 5),
      Is: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Is, fallbackValue?.Is ?? 5),
      Ux: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Ux, fallbackValue?.Ux ?? 100),
      Iby1: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Iby1, fallbackValue?.Iby1 ?? 5),
      Iby2: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Iby2, fallbackValue?.Iby2 ?? 5),
      Iby3: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Reference_Iby3, fallbackValue?.Iby3 ?? 5)
    };
  }

  private createAnalogQuantityCorrectionWriteValue(
    fallbackValue?: CommonSettingAnalogQuantityParameterStructValue
  ): CommonSettingAnalogQuantityWriteParameterValue {
    return {
      Ua: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ua, fallbackValue?.Ua ?? 100),
      Ub: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ub, fallbackValue?.Ub ?? 100),
      Uc: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Uc, fallbackValue?.Uc ?? 100),
      Uo: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Uo, fallbackValue?.Uo ?? 100),
      IA: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_IA, fallbackValue?.IA ?? 5),
      IB: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_IB, fallbackValue?.IB ?? 5),
      IC: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_IC, fallbackValue?.IC ?? 5),
      Io: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Io, fallbackValue?.Io ?? 5),
      Ia: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ia, fallbackValue?.Ia ?? 5),
      Ib: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ib, fallbackValue?.Ib ?? 5),
      Ic: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ic, fallbackValue?.Ic ?? 5),
      Is: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Is, fallbackValue?.Is ?? 5),
      Ux: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Ux, fallbackValue?.Ux ?? 100),
      Iby1: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Iby1, fallbackValue?.Iby1 ?? 5),
      Iby2: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Iby2, fallbackValue?.Iby2 ?? 5),
      Iby3: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_Correction_Iby3, fallbackValue?.Iby3 ?? 5)
    };
  }

  private createAnalogQuantityZeroDriftWriteValue(
    fallbackValue?: CommonSettingAnalogQuantityParameterStructValue
  ): CommonSettingAnalogQuantityWriteParameterValue {
    return {
      Ua: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ua, fallbackValue?.Ua ?? 800),
      Ub: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ub, fallbackValue?.Ub ?? 100),
      Uc: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Uc, fallbackValue?.Uc ?? 100),
      Uo: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Uo, fallbackValue?.Uo ?? 100),
      IA: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_IA, fallbackValue?.IA ?? 5),
      IB: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_IB, fallbackValue?.IB ?? 5),
      IC: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_IC, fallbackValue?.IC ?? 5),
      Io: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Io, fallbackValue?.Io ?? 5),
      Ia: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ia, fallbackValue?.Ia ?? 5),
      Ib: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ib, fallbackValue?.Ib ?? 5),
      Ic: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ic, fallbackValue?.Ic ?? 5),
      Is: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Is, fallbackValue?.Is ?? 5),
      Ux: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Ux, fallbackValue?.Ux ?? 100),
      Iby1: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Iby1, fallbackValue?.Iby1 ?? 5),
      Iby2: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Iby2, fallbackValue?.Iby2 ?? 5),
      Iby3: this.parseAnalogQuantityFieldNumber(this.fieldValues.Edit_Analog_ZeroDrift_Iby3, fallbackValue?.Iby3 ?? 5)
    };
  }

  private createAnalogQuantityWriteValue(
    fallbackSource?: CommonSettingAnalogQuantityStructValue
  ): CommonSettingAnalogQuantityWriteValue {
    return {
      Reference: this.createAnalogQuantityReferenceWriteValue(fallbackSource?.Reference),
      Correction: this.createAnalogQuantityCorrectionWriteValue(fallbackSource?.Correction),
      ZeroDrift: this.createAnalogQuantityZeroDriftWriteValue(fallbackSource?.ZeroDrift)
    };
  }

  private writeNativeAnalogQuantityData(): boolean {
    try {
      let nativeModule = this.loadAnalogQuantityNativeModule();
      if (!nativeModule || typeof nativeModule.updateAnalogQuantitySetting !== 'function') {
        return false;
      }

      let currentStructValue: CommonSettingAnalogQuantityStructValue | undefined = undefined;
      if (typeof nativeModule.getAnalogQuantitySetting === 'function') {
        currentStructValue = nativeModule.getAnalogQuantitySetting();
      }

      let writeValue = this.createAnalogQuantityWriteValue(currentStructValue);
      let writeSuccess = nativeModule.updateAnalogQuantitySetting(writeValue);
      if (writeSuccess) {
        this.loadNativeAnalogQuantityData();
      }
      return writeSuccess;
    } catch (error) {
      console.error(`write native analog quantity data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private submitCurrentData(): void {
    let writeSuccess = this.writeNativeAnalogQuantityData();
    if (!writeSuccess) {
      this.showFeedback('提交失败，请检查模拟量参数结构体写入。');
      return;
    }
    this.showSubmitWaiting('界面参数已写入模拟量参数结构体，等待装置回应...');
  }

  private getFieldValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'Edit_Analog_Reference_Ua':
        return this.fieldValues.Edit_Analog_Reference_Ua;
      case 'Edit_Analog_Correction_Ua':
        return this.fieldValues.Edit_Analog_Correction_Ua;
      case 'Edit_Analog_ZeroDrift_Ua':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ua;
      case 'Edit_Analog_Reference_Ia':
        return this.fieldValues.Edit_Analog_Reference_Ia;
      case 'Edit_Analog_Correction_Ia':
        return this.fieldValues.Edit_Analog_Correction_Ia;
      case 'Edit_Analog_ZeroDrift_Ia':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ia;
      case 'Edit_Analog_Reference_Ub':
        return this.fieldValues.Edit_Analog_Reference_Ub;
      case 'Edit_Analog_Correction_Ub':
        return this.fieldValues.Edit_Analog_Correction_Ub;
      case 'Edit_Analog_ZeroDrift_Ub':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ub;
      case 'Edit_Analog_Reference_Ib':
        return this.fieldValues.Edit_Analog_Reference_Ib;
      case 'Edit_Analog_Correction_Ib':
        return this.fieldValues.Edit_Analog_Correction_Ib;
      case 'Edit_Analog_ZeroDrift_Ib':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ib;
      case 'Edit_Analog_Reference_Uc':
        return this.fieldValues.Edit_Analog_Reference_Uc;
      case 'Edit_Analog_Correction_Uc':
        return this.fieldValues.Edit_Analog_Correction_Uc;
      case 'Edit_Analog_ZeroDrift_Uc':
        return this.fieldValues.Edit_Analog_ZeroDrift_Uc;
      case 'Edit_Analog_Reference_Ic':
        return this.fieldValues.Edit_Analog_Reference_Ic;
      case 'Edit_Analog_Correction_Ic':
        return this.fieldValues.Edit_Analog_Correction_Ic;
      case 'Edit_Analog_ZeroDrift_Ic':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ic;
      case 'Edit_Analog_Reference_Uo':
        return this.fieldValues.Edit_Analog_Reference_Uo;
      case 'Edit_Analog_Correction_Uo':
        return this.fieldValues.Edit_Analog_Correction_Uo;
      case 'Edit_Analog_ZeroDrift_Uo':
        return this.fieldValues.Edit_Analog_ZeroDrift_Uo;
      case 'Edit_Analog_Reference_Is':
        return this.fieldValues.Edit_Analog_Reference_Is;
      case 'Edit_Analog_Correction_Is':
        return this.fieldValues.Edit_Analog_Correction_Is;
      case 'Edit_Analog_ZeroDrift_Is':
        return this.fieldValues.Edit_Analog_ZeroDrift_Is;
      case 'Edit_Analog_Reference_IA':
        return this.fieldValues.Edit_Analog_Reference_IA;
      case 'Edit_Analog_Correction_IA':
        return this.fieldValues.Edit_Analog_Correction_IA;
      case 'Edit_Analog_ZeroDrift_IA':
        return this.fieldValues.Edit_Analog_ZeroDrift_IA;
      case 'Edit_Analog_Reference_Ux':
        return this.fieldValues.Edit_Analog_Reference_Ux;
      case 'Edit_Analog_Correction_Ux':
        return this.fieldValues.Edit_Analog_Correction_Ux;
      case 'Edit_Analog_ZeroDrift_Ux':
        return this.fieldValues.Edit_Analog_ZeroDrift_Ux;
      case 'Edit_Analog_Reference_IB':
        return this.fieldValues.Edit_Analog_Reference_IB;
      case 'Edit_Analog_Correction_IB':
        return this.fieldValues.Edit_Analog_Correction_IB;
      case 'Edit_Analog_ZeroDrift_IB':
        return this.fieldValues.Edit_Analog_ZeroDrift_IB;
      case 'Edit_Analog_Reference_Iby1':
        return this.fieldValues.Edit_Analog_Reference_Iby1;
      case 'Edit_Analog_Correction_Iby1':
        return this.fieldValues.Edit_Analog_Correction_Iby1;
      case 'Edit_Analog_ZeroDrift_Iby1':
        return this.fieldValues.Edit_Analog_ZeroDrift_Iby1;
      case 'Edit_Analog_Reference_IC':
        return this.fieldValues.Edit_Analog_Reference_IC;
      case 'Edit_Analog_Correction_IC':
        return this.fieldValues.Edit_Analog_Correction_IC;
      case 'Edit_Analog_ZeroDrift_IC':
        return this.fieldValues.Edit_Analog_ZeroDrift_IC;
      case 'Edit_Analog_Reference_Iby2':
        return this.fieldValues.Edit_Analog_Reference_Iby2;
      case 'Edit_Analog_Correction_Iby2':
        return this.fieldValues.Edit_Analog_Correction_Iby2;
      case 'Edit_Analog_ZeroDrift_Iby2':
        return this.fieldValues.Edit_Analog_ZeroDrift_Iby2;
      case 'Edit_Analog_Reference_Io':
        return this.fieldValues.Edit_Analog_Reference_Io;
      case 'Edit_Analog_Correction_Io':
        return this.fieldValues.Edit_Analog_Correction_Io;
      case 'Edit_Analog_ZeroDrift_Io':
        return this.fieldValues.Edit_Analog_ZeroDrift_Io;
      case 'Edit_Analog_Reference_Iby3':
        return this.fieldValues.Edit_Analog_Reference_Iby3;
      case 'Edit_Analog_Correction_Iby3':
        return this.fieldValues.Edit_Analog_Correction_Iby3;
      case 'Edit_Analog_ZeroDrift_Iby3':
        return this.fieldValues.Edit_Analog_ZeroDrift_Iby3;
      default:
        return '';
    }
  }

  private setFieldValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'Edit_Analog_Reference_Ua':
        this.fieldValues.Edit_Analog_Reference_Ua = value;
        break;
      case 'Edit_Analog_Correction_Ua':
        this.fieldValues.Edit_Analog_Correction_Ua = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ua':
        this.fieldValues.Edit_Analog_ZeroDrift_Ua = value;
        break;
      case 'Edit_Analog_Reference_Ia':
        this.fieldValues.Edit_Analog_Reference_Ia = value;
        break;
      case 'Edit_Analog_Correction_Ia':
        this.fieldValues.Edit_Analog_Correction_Ia = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ia':
        this.fieldValues.Edit_Analog_ZeroDrift_Ia = value;
        break;
      case 'Edit_Analog_Reference_Ub':
        this.fieldValues.Edit_Analog_Reference_Ub = value;
        break;
      case 'Edit_Analog_Correction_Ub':
        this.fieldValues.Edit_Analog_Correction_Ub = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ub':
        this.fieldValues.Edit_Analog_ZeroDrift_Ub = value;
        break;
      case 'Edit_Analog_Reference_Ib':
        this.fieldValues.Edit_Analog_Reference_Ib = value;
        break;
      case 'Edit_Analog_Correction_Ib':
        this.fieldValues.Edit_Analog_Correction_Ib = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ib':
        this.fieldValues.Edit_Analog_ZeroDrift_Ib = value;
        break;
      case 'Edit_Analog_Reference_Uc':
        this.fieldValues.Edit_Analog_Reference_Uc = value;
        break;
      case 'Edit_Analog_Correction_Uc':
        this.fieldValues.Edit_Analog_Correction_Uc = value;
        break;
      case 'Edit_Analog_ZeroDrift_Uc':
        this.fieldValues.Edit_Analog_ZeroDrift_Uc = value;
        break;
      case 'Edit_Analog_Reference_Ic':
        this.fieldValues.Edit_Analog_Reference_Ic = value;
        break;
      case 'Edit_Analog_Correction_Ic':
        this.fieldValues.Edit_Analog_Correction_Ic = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ic':
        this.fieldValues.Edit_Analog_ZeroDrift_Ic = value;
        break;
      case 'Edit_Analog_Reference_Uo':
        this.fieldValues.Edit_Analog_Reference_Uo = value;
        break;
      case 'Edit_Analog_Correction_Uo':
        this.fieldValues.Edit_Analog_Correction_Uo = value;
        break;
      case 'Edit_Analog_ZeroDrift_Uo':
        this.fieldValues.Edit_Analog_ZeroDrift_Uo = value;
        break;
      case 'Edit_Analog_Reference_Is':
        this.fieldValues.Edit_Analog_Reference_Is = value;
        break;
      case 'Edit_Analog_Correction_Is':
        this.fieldValues.Edit_Analog_Correction_Is = value;
        break;
      case 'Edit_Analog_ZeroDrift_Is':
        this.fieldValues.Edit_Analog_ZeroDrift_Is = value;
        break;
      case 'Edit_Analog_Reference_IA':
        this.fieldValues.Edit_Analog_Reference_IA = value;
        break;
      case 'Edit_Analog_Correction_IA':
        this.fieldValues.Edit_Analog_Correction_IA = value;
        break;
      case 'Edit_Analog_ZeroDrift_IA':
        this.fieldValues.Edit_Analog_ZeroDrift_IA = value;
        break;
      case 'Edit_Analog_Reference_Ux':
        this.fieldValues.Edit_Analog_Reference_Ux = value;
        break;
      case 'Edit_Analog_Correction_Ux':
        this.fieldValues.Edit_Analog_Correction_Ux = value;
        break;
      case 'Edit_Analog_ZeroDrift_Ux':
        this.fieldValues.Edit_Analog_ZeroDrift_Ux = value;
        break;
      case 'Edit_Analog_Reference_IB':
        this.fieldValues.Edit_Analog_Reference_IB = value;
        break;
      case 'Edit_Analog_Correction_IB':
        this.fieldValues.Edit_Analog_Correction_IB = value;
        break;
      case 'Edit_Analog_ZeroDrift_IB':
        this.fieldValues.Edit_Analog_ZeroDrift_IB = value;
        break;
      case 'Edit_Analog_Reference_Iby1':
        this.fieldValues.Edit_Analog_Reference_Iby1 = value;
        break;
      case 'Edit_Analog_Correction_Iby1':
        this.fieldValues.Edit_Analog_Correction_Iby1 = value;
        break;
      case 'Edit_Analog_ZeroDrift_Iby1':
        this.fieldValues.Edit_Analog_ZeroDrift_Iby1 = value;
        break;
      case 'Edit_Analog_Reference_IC':
        this.fieldValues.Edit_Analog_Reference_IC = value;
        break;
      case 'Edit_Analog_Correction_IC':
        this.fieldValues.Edit_Analog_Correction_IC = value;
        break;
      case 'Edit_Analog_ZeroDrift_IC':
        this.fieldValues.Edit_Analog_ZeroDrift_IC = value;
        break;
      case 'Edit_Analog_Reference_Iby2':
        this.fieldValues.Edit_Analog_Reference_Iby2 = value;
        break;
      case 'Edit_Analog_Correction_Iby2':
        this.fieldValues.Edit_Analog_Correction_Iby2 = value;
        break;
      case 'Edit_Analog_ZeroDrift_Iby2':
        this.fieldValues.Edit_Analog_ZeroDrift_Iby2 = value;
        break;
      case 'Edit_Analog_Reference_Io':
        this.fieldValues.Edit_Analog_Reference_Io = value;
        break;
      case 'Edit_Analog_Correction_Io':
        this.fieldValues.Edit_Analog_Correction_Io = value;
        break;
      case 'Edit_Analog_ZeroDrift_Io':
        this.fieldValues.Edit_Analog_ZeroDrift_Io = value;
        break;
      case 'Edit_Analog_Reference_Iby3':
        this.fieldValues.Edit_Analog_Reference_Iby3 = value;
        break;
      case 'Edit_Analog_Correction_Iby3':
        this.fieldValues.Edit_Analog_Correction_Iby3 = value;
        break;
      case 'Edit_Analog_ZeroDrift_Iby3':
        this.fieldValues.Edit_Analog_ZeroDrift_Iby3 = value;
        break;
      default:
        break;
    }
  }

  private resetDefaults(): void {
    this.fieldValues = createDefaultCommonSettingAnalogQuantityValues();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Column() {
          this.HeaderBar();

          Scroll() {
            Column() {
              this.ColumnHeaderRow();

              ForEach(COMMON_SETTING_ANALOG_QUANTITY_ROWS, (row: AnalogRowConfig) => {
                this.AnalogPairRow(row);
              }, (row: AnalogRowConfig) => row.left.referenceKey)
            }
            .width('100%')
            .constraintSize({ minHeight: this.s(this.contentMinHeight) })
            .padding({ bottom: this.s(this.contentBottomPadding) });
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor('#FFFFFF');

          this.BottomBar();
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
        .backgroundColor('#FFFFFF');
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF');

      if (this.submitWaitingDialogVisible) {
        this.SubmitWaitingOverlay();
      }

      if (this.feedbackDialogVisible) {
        this.FeedbackOverlay();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.noticeMin))
        .maxLines(1)
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#FF0000')
        .textAlign(TextAlign.Start)
        .padding({ left: this.s(8) });

      Text(this.vm.titleLeft)
        .layoutWeight(3)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.subtitle))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(this.titleIconBackWidth))
          .height(this.s(this.titleIconHeight));
      }
      .layoutWeight(2)
      .height(this.s(this.titleIconHeight))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(this.titleIconCloseWidth))
          .height(this.s(this.titleIconHeight));
      }
      .layoutWeight(2)
      .height(this.s(this.titleIconHeight))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  ColumnHeaderRow() {
    Row() {
      this.HeaderPlaceholder(this.labelColumnWeight);
      this.ColumnHeaderCell('基准值', this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.ColumnHeaderCell('修正值', this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.ColumnHeaderCell('零漂值', this.fieldColumnWeight);
      this.HeaderPlaceholder(this.sectionGapWeight + this.labelColumnWeight);
      this.ColumnHeaderCell('基准值', this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.ColumnHeaderCell('修正值', this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.ColumnHeaderCell('零漂值', this.fieldColumnWeight);
    }
    .width('100%')
    .height(this.s(this.columnHeaderHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  HeaderPlaceholder(weight: number) {
    Blank().layoutWeight(weight);
  }

  @Builder
  GridSpacer(weight: number) {
    Blank().layoutWeight(weight);
  }

  @Builder
  ColumnHeaderCell(text: string, weight: number) {
    Row() {
      Text(text)
        .width(this.s(this.fieldGroupWidth))
        .fontSize(this.s(this.fontSize.columnHeader))
        .fontColor('#000000')
        .textAlign(TextAlign.Center);
    }
    .layoutWeight(weight)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  AnalogPairRow(config: AnalogRowConfig) {
    Row() {
      this.SignalLabelCell(config.left.label);
      this.FieldCell(config.left.referenceKey, config.left.unit, this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.FieldCell(config.left.correctionKey, config.left.unit, this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.FieldCell(config.left.zeroDriftKey, config.left.unit, this.fieldColumnWeight);
      this.GridSpacer(this.sectionGapWeight);
      this.SignalLabelCell(config.right.label);
      this.FieldCell(config.right.referenceKey, config.right.unit, this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.FieldCell(config.right.correctionKey, config.right.unit, this.fieldColumnWeight);
      this.GridSpacer(this.gapColumnWeight);
      this.FieldCell(config.right.zeroDriftKey, config.right.unit, this.fieldColumnWeight);
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SignalLabelCell(text: string) {
    Row() {
      Text(text)
        .width('100%')
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .maxLines(1)
        .textAlign(TextAlign.Start);
    }
    .layoutWeight(this.labelColumnWeight)
    .height('100%')
    .padding({ left: this.s(this.labelCellPadding), right: this.s(this.labelCellPadding) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  FieldCell(fieldKey: string, unit: string, weight: number) {
    Row() {
      this.FieldBlock(fieldKey, unit);
    }
    .layoutWeight(weight)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  FieldBlock(fieldKey: string, unit: string) {
    Row() {
      TextInput({ text: this.getFieldValue(fieldKey), placeholder: '' })
        .width(this.s(this.fieldInputWidth))
        .height(this.s(this.fieldHeight))
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .backgroundColor(this.fieldBackgroundColor)
        .border({ width: 1, color: this.fieldBorderColor })
        .borderRadius(0)
        .padding({ left: this.s(4), right: this.s(4), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setFieldValue(fieldKey, value);
        });

      Blank().width(this.s(this.fieldSpacing));

      Text(unit)
        .width(this.s(this.fieldUnitWidth))
        .fontSize(this.s(this.fontSize.unit))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Center);
    }
    .width(this.s(this.fieldGroupWidth))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(5);

      Button(this.vm.defaultText)
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.buttonRadius))
        .padding(0)
        .onClick(() => {
          this.resetDefaults();
        });

      Blank().layoutWeight(15);

      Button(this.vm.submitText)
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.buttonRadius))
        .padding(0)
        .onClick(() => {
          this.submitCurrentData();
        });

      Blank().layoutWeight(10);

      Button(this.vm.backText)
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.buttonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(20);

      Text(this.vm.timeText)
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
        .fontSize(this.s(this.fontSize.time))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.bottomBarHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  SubmitWaitingOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeSubmitWaiting();
      });

      Column() {
        Text('等待回应')
          .width('100%')
          .fontSize(this.s(18))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.submitWaitingMessage)
          .width('100%')
          .fontSize(this.s(18))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('关闭')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(18))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeSubmitWaiting();
          });
      }
      .width(this.s(320))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(10));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  FeedbackOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeFeedback();
      });

      Column() {
        Text('提示')
          .width('100%')
          .fontSize(this.s(18))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.feedbackMessage)
          .width('100%')
          .fontSize(this.s(18))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('关闭')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(18))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeFeedback();
          });
      }
      .width(this.s(320))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(10));
    }
    .width('100%')
    .height('100%');
  }
}
