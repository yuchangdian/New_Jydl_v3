import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import * as powerQualityNativeModule from 'libentry.so';
import {
  CommonSettingPowerQualityData,
  COMMON_SETTING_POWER_QUALITY_ENABLE_OPTIONS,
  createDefaultCommonSettingPowerQualityData,
  deserializeCommonSettingPowerQualityData,
  serializeCommonSettingPowerQualityData
} from '../models/CommonSettingPowerQualityData';

interface AbilityFileContext {
  filesDir: string;
}

interface CommonSettingPowerQualityStructValue {
  ready: boolean;
  Enable_FrequencyDeviation: number;
  Value_FrequencyDeviation: number;
  Enable_VoltageDeviation: number;
  Value_VoltageDeviation: number;
  Enable_VoltageUnbalance: number;
  Value_VoltageUnbalance: number;
  Enable_VoltageFluct: number;
  Value_VoltageFluct: number;
  Enable_VoltageFlicke: number;
  Value_VoltageFlicke: number;
  Enable_VoltageSeg: number;
  Value_VoltageSeg: number;
  Enable_VoltageTHD: number;
  Value_VoltageTHD: number;
  Enable_VoltageHAR: number;
  Value_VoltageHAR: number;
  Enable_CurrentUnbalance: number;
  Value_CurrentUnbalance: number;
  Enable_CurrentTHD: number;
  Value_CurrentTHD: number;
  Enable_CurrentHAR: number;
  Value_CurrentHAR: number;
  CRC: number;
}

interface CommonSettingPowerQualityWriteValue {
  Enable_FrequencyDeviation: number;
  Value_FrequencyDeviation: number;
  Enable_VoltageDeviation: number;
  Value_VoltageDeviation: number;
  Enable_VoltageUnbalance: number;
  Value_VoltageUnbalance: number;
  Enable_VoltageFluct: number;
  Value_VoltageFluct: number;
  Enable_VoltageFlicke: number;
  Value_VoltageFlicke: number;
  Enable_VoltageSeg: number;
  Value_VoltageSeg: number;
  Enable_VoltageTHD: number;
  Value_VoltageTHD: number;
  Enable_VoltageHAR: number;
  Value_VoltageHAR: number;
  Enable_CurrentUnbalance: number;
  Value_CurrentUnbalance: number;
  Enable_CurrentTHD: number;
  Value_CurrentTHD: number;
  Enable_CurrentHAR: number;
  Value_CurrentHAR: number;
}

interface PowerQualityNativeModule {
  getPowerQualitySetting?: () => CommonSettingPowerQualityStructValue | undefined;
  updatePowerQualitySetting?: (value: CommonSettingPowerQualityWriteValue) => boolean;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): PowerQualityNativeModule | undefined;

type PowerQualityEnabledFieldKey =
  | 'frequencyDeviationEnabled'
  | 'voltageDeviationEnabled'
  | 'voltageUnbalanceEnabled'
  | 'voltageFluctuationEnabled'
  | 'voltageFlickerEnabled'
  | 'voltageSagEnabled'
  | 'voltageThdEnabled'
  | 'voltageHarEnabled'
  | 'currentUnbalanceEnabled'
  | 'currentThdEnabled'
  | 'currentHarEnabled';

type PowerQualityValueFieldKey =
  | 'frequencyDeviationValue'
  | 'voltageDeviationValue'
  | 'voltageUnbalanceValue'
  | 'voltageFluctuationValue'
  | 'voltageFlickerValue'
  | 'voltageSagValue'
  | 'voltageThdValue'
  | 'voltageHarValue'
  | 'currentUnbalanceValue'
  | 'currentThdValue'
  | 'currentHarValue';

interface PowerQualityRowConfig {
  title: string;
  enabledFieldKey: PowerQualityEnabledFieldKey;
  valueFieldKey: PowerQualityValueFieldKey;
  unit: string;
}

const COMMON_SETTING_POWER_QUALITY_ROWS: PowerQualityRowConfig[] = [
  {
    title: '>频率偏差告警:',
    enabledFieldKey: 'frequencyDeviationEnabled',
    valueFieldKey: 'frequencyDeviationValue',
    unit: 'Hz'
  },
  {
    title: '>电压偏差告警:',
    enabledFieldKey: 'voltageDeviationEnabled',
    valueFieldKey: 'voltageDeviationValue',
    unit: '%'
  },
  {
    title: '>电压不平衡告警:',
    enabledFieldKey: 'voltageUnbalanceEnabled',
    valueFieldKey: 'voltageUnbalanceValue',
    unit: '%'
  },
  {
    title: '>电压波动告警:',
    enabledFieldKey: 'voltageFluctuationEnabled',
    valueFieldKey: 'voltageFluctuationValue',
    unit: '%'
  },
  {
    title: '>电压闪变告警:',
    enabledFieldKey: 'voltageFlickerEnabled',
    valueFieldKey: 'voltageFlickerValue',
    unit: ''
  },
  {
    title: '>电压暂降告警:',
    enabledFieldKey: 'voltageSagEnabled',
    valueFieldKey: 'voltageSagValue',
    unit: 'V'
  },
  {
    title: '>电压总谐波含量告警:',
    enabledFieldKey: 'voltageThdEnabled',
    valueFieldKey: 'voltageThdValue',
    unit: '%'
  },
  {
    title: '>电压单次谐波含量告警:',
    enabledFieldKey: 'voltageHarEnabled',
    valueFieldKey: 'voltageHarValue',
    unit: '%'
  },
  {
    title: '>电流不平衡告警:',
    enabledFieldKey: 'currentUnbalanceEnabled',
    valueFieldKey: 'currentUnbalanceValue',
    unit: '%'
  },
  {
    title: '>电流总谐波含量告警:',
    enabledFieldKey: 'currentThdEnabled',
    valueFieldKey: 'currentThdValue',
    unit: '%'
  },
  {
    title: '>电流单次谐波含量告警:',
    enabledFieldKey: 'currentHarEnabled',
    valueFieldKey: 'currentHarValue',
    unit: '%'
  }
];

@Observed
class BottomActionState {
  defaultText: string = '默认值';
  submitText: string = '提交';
  closeText: string = '关闭';
  backText: string = '返回';
}

@Observed
class CommonSettingPowerQualityVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定电能质量';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingPowerQualityFontSize {
  notice: number = 20;
  title: number = 22;
  fieldLabel: number = 18;
  inputValue: number = 18;
  button: number = 20;
  timeText: number = 19;
  dialogTitle: number = 20;
  dialogBody: number = 20;
  titleMin: number = 16;
  noticeMin: number = 14;
  arrow: number = 14;
  timeLineHeight: number = 22;
}

@Entry
@Component
export struct CommonSetting_PowerQuality_Set {
  @State vm: CommonSettingPowerQualityVM = new CommonSettingPowerQualityVM();
  @State formData: CommonSettingPowerQualityData = createDefaultCommonSettingPowerQualityData();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayFieldKey: PowerQualityEnabledFieldKey | '' = '';
  @State selectOverlayTitle: string = '';
  @State selectOverlayValue: string = '';
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';
  @State submitWaitingDialogVisible: boolean = false;
  @State submitWaitingMessage: string = '';

  private readonly fontSize: CommonSettingPowerQualityFontSize = new CommonSettingPowerQualityFontSize();
  private readonly enableOptions: string[] = COMMON_SETTING_POWER_QUALITY_ENABLE_OPTIONS;
  private cachedPowerQualityNativeModule?: PowerQualityNativeModule;
  private readonly pageBaseWidth: number = 1280;
  private readonly pageBaseHeight: number = 720;
  private readonly layoutZoom: number = 1.2;
  private readonly pageMaxWidth: number = 1024;
  private readonly headerHeight: number = 70;
  private readonly footerHeight: number = 70;
  private readonly rowHeight: number = 44;
  private readonly rowSpacing: number = 6;
  private readonly inputWidth: number = 117;
  private readonly inputHeight: number = 35;
  private readonly comboWidth: number = 96;
  private readonly comboHeight: number = 35;
  private readonly unitWidth: number = 24;
  private readonly footerButtonHeight: number = 50;
  private readonly footerButtonRadius: number = 24;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly overlayCardWidth: number = 320;
  private readonly overlayCardRadius: number = 10;
  private readonly contentTopPadding: number = 9;
  private readonly contentLeftPadding: number = 15;
  private readonly contentRightPadding: number = 9;
  private readonly contentBottomPadding: number = 200;
  private readonly contentMinHeight: number = 880;
  private readonly dataFileName: string = 'common_setting_power_quality.json';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
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
    if (!this.loadNativePowerQualityData()) {
      this.loadPersistedData();
    }
  }

  private getDataFilePath(): string {
    let context = getContext(this) as AbilityFileContext;
    return `${context.filesDir}/${this.dataFileName}`;
  }

  private loadPersistedData(): void {
    try {
      let dataFilePath = this.getDataFilePath();
      if (!fs.accessSync(dataFilePath)) {
        return;
      }
      let raw = fs.readTextSync(dataFilePath);
      let restored = deserializeCommonSettingPowerQualityData(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load power quality data failed: ${JSON.stringify(error)}`);
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingPowerQualityData(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save power quality data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private isValidPowerQualityNativeModule(module: PowerQualityNativeModule | undefined): boolean {
    return !!module &&
      (typeof module.getPowerQualitySetting === 'function' ||
        typeof module.updatePowerQualitySetting === 'function');
  }

  private loadPowerQualityNativeModule(): PowerQualityNativeModule | undefined {
    if (this.isValidPowerQualityNativeModule(this.cachedPowerQualityNativeModule)) {
      return this.cachedPowerQualityNativeModule;
    }
    if (this.isValidPowerQualityNativeModule(powerQualityNativeModule)) {
      this.cachedPowerQualityNativeModule = powerQualityNativeModule;
      return this.cachedPowerQualityNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidPowerQualityNativeModule(napiModuleWithPath)) {
      this.cachedPowerQualityNativeModule = napiModuleWithPath;
      return this.cachedPowerQualityNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidPowerQualityNativeModule(napiModuleWithApp)) {
      this.cachedPowerQualityNativeModule = napiModuleWithApp;
      return this.cachedPowerQualityNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidPowerQualityNativeModule(napiModule)) {
      this.cachedPowerQualityNativeModule = napiModule;
      return this.cachedPowerQualityNativeModule;
    }

    return undefined;
  }

  private isPowerQualityEnabledCode(value: number): boolean {
    return value === 0 || value === 1;
  }

  private isUsablePowerQualityStructValue(value: CommonSettingPowerQualityStructValue | undefined): boolean {
    if (!value || !value.ready) {
      return false;
    }

    return this.isPowerQualityEnabledCode(value.Enable_FrequencyDeviation) &&
      Number.isFinite(value.Value_FrequencyDeviation) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageDeviation) &&
      Number.isFinite(value.Value_VoltageDeviation) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageUnbalance) &&
      Number.isFinite(value.Value_VoltageUnbalance) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageFluct) &&
      Number.isFinite(value.Value_VoltageFluct) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageFlicke) &&
      Number.isFinite(value.Value_VoltageFlicke) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageSeg) &&
      Number.isFinite(value.Value_VoltageSeg) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageTHD) &&
      Number.isFinite(value.Value_VoltageTHD) &&
      this.isPowerQualityEnabledCode(value.Enable_VoltageHAR) &&
      Number.isFinite(value.Value_VoltageHAR) &&
      this.isPowerQualityEnabledCode(value.Enable_CurrentUnbalance) &&
      Number.isFinite(value.Value_CurrentUnbalance) &&
      this.isPowerQualityEnabledCode(value.Enable_CurrentTHD) &&
      Number.isFinite(value.Value_CurrentTHD) &&
      this.isPowerQualityEnabledCode(value.Enable_CurrentHAR) &&
      Number.isFinite(value.Value_CurrentHAR);
  }

  private getPowerQualityEnableText(value: number): string {
    if (value === 1) {
      return this.enableOptions[0] ?? '投入';
    }
    if (value === 0) {
      return this.enableOptions[1] ?? '退出';
    }
    return '';
  }

  private getPowerQualityEnableCode(value: string, fallbackValue: number): number {
    const enabledText = this.enableOptions[0] ?? '投入';
    const disabledText = this.enableOptions[1] ?? '退出';
    if (value === enabledText || value === '投入') {
      return 1;
    }
    if (value === disabledText || value === '退出') {
      return 0;
    }
    if (fallbackValue === 0 || fallbackValue === 1) {
      return fallbackValue;
    }
    return 1;
  }

  private formatPowerQualityValue(value: number): string {
    if (!Number.isFinite(value)) {
      return '';
    }
    return value.toFixed(2);
  }

  private createPowerQualityDataFromStruct(
    source: CommonSettingPowerQualityStructValue
  ): CommonSettingPowerQualityData {
    let data = createDefaultCommonSettingPowerQualityData();
    data.frequencyDeviationEnabled = this.getPowerQualityEnableText(source.Enable_FrequencyDeviation);
    data.frequencyDeviationValue = this.formatPowerQualityValue(source.Value_FrequencyDeviation);
    data.voltageDeviationEnabled = this.getPowerQualityEnableText(source.Enable_VoltageDeviation);
    data.voltageDeviationValue = this.formatPowerQualityValue(source.Value_VoltageDeviation);
    data.voltageUnbalanceEnabled = this.getPowerQualityEnableText(source.Enable_VoltageUnbalance);
    data.voltageUnbalanceValue = this.formatPowerQualityValue(source.Value_VoltageUnbalance);
    data.voltageFluctuationEnabled = this.getPowerQualityEnableText(source.Enable_VoltageFluct);
    data.voltageFluctuationValue = this.formatPowerQualityValue(source.Value_VoltageFluct);
    data.voltageFlickerEnabled = this.getPowerQualityEnableText(source.Enable_VoltageFlicke);
    data.voltageFlickerValue = this.formatPowerQualityValue(source.Value_VoltageFlicke);
    data.voltageSagEnabled = this.getPowerQualityEnableText(source.Enable_VoltageSeg);
    data.voltageSagValue = this.formatPowerQualityValue(source.Value_VoltageSeg);
    data.voltageThdEnabled = this.getPowerQualityEnableText(source.Enable_VoltageTHD);
    data.voltageThdValue = this.formatPowerQualityValue(source.Value_VoltageTHD);
    data.voltageHarEnabled = this.getPowerQualityEnableText(source.Enable_VoltageHAR);
    data.voltageHarValue = this.formatPowerQualityValue(source.Value_VoltageHAR);
    data.currentUnbalanceEnabled = this.getPowerQualityEnableText(source.Enable_CurrentUnbalance);
    data.currentUnbalanceValue = this.formatPowerQualityValue(source.Value_CurrentUnbalance);
    data.currentThdEnabled = this.getPowerQualityEnableText(source.Enable_CurrentTHD);
    data.currentThdValue = this.formatPowerQualityValue(source.Value_CurrentTHD);
    data.currentHarEnabled = this.getPowerQualityEnableText(source.Enable_CurrentHAR);
    data.currentHarValue = this.formatPowerQualityValue(source.Value_CurrentHAR);
    return data;
  }

  private loadNativePowerQualityData(): boolean {
    try {
      let nativeModule = this.loadPowerQualityNativeModule();
      if (!nativeModule || typeof nativeModule.getPowerQualitySetting !== 'function') {
        return false;
      }

      let structValue = nativeModule.getPowerQualitySetting();
      if (!this.isUsablePowerQualityStructValue(structValue)) {
        return false;
      }

      this.formData = this.createPowerQualityDataFromStruct(
        structValue as CommonSettingPowerQualityStructValue
      );
      return true;
    } catch (error) {
      console.error(`load native power quality data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private getEnabledValue(fieldKey: PowerQualityEnabledFieldKey): string {
    switch (fieldKey) {
      case 'frequencyDeviationEnabled':
        return this.formData.frequencyDeviationEnabled;
      case 'voltageDeviationEnabled':
        return this.formData.voltageDeviationEnabled;
      case 'voltageUnbalanceEnabled':
        return this.formData.voltageUnbalanceEnabled;
      case 'voltageFluctuationEnabled':
        return this.formData.voltageFluctuationEnabled;
      case 'voltageFlickerEnabled':
        return this.formData.voltageFlickerEnabled;
      case 'voltageSagEnabled':
        return this.formData.voltageSagEnabled;
      case 'voltageThdEnabled':
        return this.formData.voltageThdEnabled;
      case 'voltageHarEnabled':
        return this.formData.voltageHarEnabled;
      case 'currentUnbalanceEnabled':
        return this.formData.currentUnbalanceEnabled;
      case 'currentThdEnabled':
        return this.formData.currentThdEnabled;
      case 'currentHarEnabled':
        return this.formData.currentHarEnabled;
      default:
        return '';
    }
  }

  private setEnabledValue(fieldKey: PowerQualityEnabledFieldKey, value: string): void {
    switch (fieldKey) {
      case 'frequencyDeviationEnabled':
        this.formData.frequencyDeviationEnabled = value;
        break;
      case 'voltageDeviationEnabled':
        this.formData.voltageDeviationEnabled = value;
        break;
      case 'voltageUnbalanceEnabled':
        this.formData.voltageUnbalanceEnabled = value;
        break;
      case 'voltageFluctuationEnabled':
        this.formData.voltageFluctuationEnabled = value;
        break;
      case 'voltageFlickerEnabled':
        this.formData.voltageFlickerEnabled = value;
        break;
      case 'voltageSagEnabled':
        this.formData.voltageSagEnabled = value;
        break;
      case 'voltageThdEnabled':
        this.formData.voltageThdEnabled = value;
        break;
      case 'voltageHarEnabled':
        this.formData.voltageHarEnabled = value;
        break;
      case 'currentUnbalanceEnabled':
        this.formData.currentUnbalanceEnabled = value;
        break;
      case 'currentThdEnabled':
        this.formData.currentThdEnabled = value;
        break;
      case 'currentHarEnabled':
        this.formData.currentHarEnabled = value;
        break;
      default:
        break;
    }
  }

  private getInputValue(fieldKey: PowerQualityValueFieldKey): string {
    switch (fieldKey) {
      case 'frequencyDeviationValue':
        return this.formData.frequencyDeviationValue;
      case 'voltageDeviationValue':
        return this.formData.voltageDeviationValue;
      case 'voltageUnbalanceValue':
        return this.formData.voltageUnbalanceValue;
      case 'voltageFluctuationValue':
        return this.formData.voltageFluctuationValue;
      case 'voltageFlickerValue':
        return this.formData.voltageFlickerValue;
      case 'voltageSagValue':
        return this.formData.voltageSagValue;
      case 'voltageThdValue':
        return this.formData.voltageThdValue;
      case 'voltageHarValue':
        return this.formData.voltageHarValue;
      case 'currentUnbalanceValue':
        return this.formData.currentUnbalanceValue;
      case 'currentThdValue':
        return this.formData.currentThdValue;
      case 'currentHarValue':
        return this.formData.currentHarValue;
      default:
        return '';
    }
  }

  private setInputValue(fieldKey: PowerQualityValueFieldKey, value: string): void {
    switch (fieldKey) {
      case 'frequencyDeviationValue':
        this.formData.frequencyDeviationValue = value;
        break;
      case 'voltageDeviationValue':
        this.formData.voltageDeviationValue = value;
        break;
      case 'voltageUnbalanceValue':
        this.formData.voltageUnbalanceValue = value;
        break;
      case 'voltageFluctuationValue':
        this.formData.voltageFluctuationValue = value;
        break;
      case 'voltageFlickerValue':
        this.formData.voltageFlickerValue = value;
        break;
      case 'voltageSagValue':
        this.formData.voltageSagValue = value;
        break;
      case 'voltageThdValue':
        this.formData.voltageThdValue = value;
        break;
      case 'voltageHarValue':
        this.formData.voltageHarValue = value;
        break;
      case 'currentUnbalanceValue':
        this.formData.currentUnbalanceValue = value;
        break;
      case 'currentThdValue':
        this.formData.currentThdValue = value;
        break;
      case 'currentHarValue':
        this.formData.currentHarValue = value;
        break;
      default:
        break;
    }
  }

  private openSelectOverlay(fieldKey: PowerQualityEnabledFieldKey, title: string): void {
    let normalizedTitle = title.startsWith('>') ? title.substring(1) : title;
    if (normalizedTitle.endsWith(':')) {
      normalizedTitle = normalizedTitle.substring(0, normalizedTitle.length - 1);
    }
    this.selectOverlayFieldKey = fieldKey;
    this.selectOverlayTitle = `${normalizedTitle} 投退`;
    this.selectOverlayValue = this.getEnabledValue(fieldKey);
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
    this.selectOverlayFieldKey = '';
    this.selectOverlayTitle = '';
    this.selectOverlayValue = '';
  }

  private applySelectOverlayValue(value: string): void {
    if (this.selectOverlayFieldKey.length > 0) {
      let fieldKey = this.selectOverlayFieldKey as PowerQualityEnabledFieldKey;
      this.setEnabledValue(fieldKey, value);
    }
    this.closeSelectOverlay();
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingPowerQualityData();
  }

  private showFeedback(message: string): void {
    this.feedbackMessage = message;
    this.feedbackDialogVisible = true;
  }

  private showSubmitWaiting(message: string): void {
    this.submitWaitingMessage = message;
    this.submitWaitingDialogVisible = true;
  }

  private closeSubmitWaiting(): void {
    this.submitWaitingDialogVisible = false;
    this.submitWaitingMessage = '';
  }

  private parsePowerQualityFieldNumber(value: string, fallbackValue: number): number {
    let parsed = Number.parseFloat(value);
    if (!Number.isFinite(parsed) || parsed < 0) {
      return fallbackValue;
    }
    return parsed;
  }

  private createPowerQualityWriteValue(
    fallbackSource?: CommonSettingPowerQualityStructValue
  ): CommonSettingPowerQualityWriteValue {
    return {
      Enable_FrequencyDeviation: this.getPowerQualityEnableCode(
        this.formData.frequencyDeviationEnabled,
        fallbackSource?.Enable_FrequencyDeviation ?? 1
      ),
      Value_FrequencyDeviation: this.parsePowerQualityFieldNumber(
        this.formData.frequencyDeviationValue,
        fallbackSource?.Value_FrequencyDeviation ?? 0
      ),
      Enable_VoltageDeviation: this.getPowerQualityEnableCode(
        this.formData.voltageDeviationEnabled,
        fallbackSource?.Enable_VoltageDeviation ?? 1
      ),
      Value_VoltageDeviation: this.parsePowerQualityFieldNumber(
        this.formData.voltageDeviationValue,
        fallbackSource?.Value_VoltageDeviation ?? 0
      ),
      Enable_VoltageUnbalance: this.getPowerQualityEnableCode(
        this.formData.voltageUnbalanceEnabled,
        fallbackSource?.Enable_VoltageUnbalance ?? 1
      ),
      Value_VoltageUnbalance: this.parsePowerQualityFieldNumber(
        this.formData.voltageUnbalanceValue,
        fallbackSource?.Value_VoltageUnbalance ?? 0
      ),
      Enable_VoltageFluct: this.getPowerQualityEnableCode(
        this.formData.voltageFluctuationEnabled,
        fallbackSource?.Enable_VoltageFluct ?? 1
      ),
      Value_VoltageFluct: this.parsePowerQualityFieldNumber(
        this.formData.voltageFluctuationValue,
        fallbackSource?.Value_VoltageFluct ?? 0
      ),
      Enable_VoltageFlicke: this.getPowerQualityEnableCode(
        this.formData.voltageFlickerEnabled,
        fallbackSource?.Enable_VoltageFlicke ?? 1
      ),
      Value_VoltageFlicke: this.parsePowerQualityFieldNumber(
        this.formData.voltageFlickerValue,
        fallbackSource?.Value_VoltageFlicke ?? 0
      ),
      Enable_VoltageSeg: this.getPowerQualityEnableCode(
        this.formData.voltageSagEnabled,
        fallbackSource?.Enable_VoltageSeg ?? 1
      ),
      Value_VoltageSeg: this.parsePowerQualityFieldNumber(
        this.formData.voltageSagValue,
        fallbackSource?.Value_VoltageSeg ?? 0
      ),
      Enable_VoltageTHD: this.getPowerQualityEnableCode(
        this.formData.voltageThdEnabled,
        fallbackSource?.Enable_VoltageTHD ?? 1
      ),
      Value_VoltageTHD: this.parsePowerQualityFieldNumber(
        this.formData.voltageThdValue,
        fallbackSource?.Value_VoltageTHD ?? 0
      ),
      Enable_VoltageHAR: this.getPowerQualityEnableCode(
        this.formData.voltageHarEnabled,
        fallbackSource?.Enable_VoltageHAR ?? 1
      ),
      Value_VoltageHAR: this.parsePowerQualityFieldNumber(
        this.formData.voltageHarValue,
        fallbackSource?.Value_VoltageHAR ?? 0
      ),
      Enable_CurrentUnbalance: this.getPowerQualityEnableCode(
        this.formData.currentUnbalanceEnabled,
        fallbackSource?.Enable_CurrentUnbalance ?? 1
      ),
      Value_CurrentUnbalance: this.parsePowerQualityFieldNumber(
        this.formData.currentUnbalanceValue,
        fallbackSource?.Value_CurrentUnbalance ?? 0
      ),
      Enable_CurrentTHD: this.getPowerQualityEnableCode(
        this.formData.currentThdEnabled,
        fallbackSource?.Enable_CurrentTHD ?? 1
      ),
      Value_CurrentTHD: this.parsePowerQualityFieldNumber(
        this.formData.currentThdValue,
        fallbackSource?.Value_CurrentTHD ?? 0
      ),
      Enable_CurrentHAR: this.getPowerQualityEnableCode(
        this.formData.currentHarEnabled,
        fallbackSource?.Enable_CurrentHAR ?? 1
      ),
      Value_CurrentHAR: this.parsePowerQualityFieldNumber(
        this.formData.currentHarValue,
        fallbackSource?.Value_CurrentHAR ?? 0
      )
    };
  }

  private writeNativePowerQualityData(): boolean {
    try {
      let nativeModule = this.loadPowerQualityNativeModule();
      if (!nativeModule || typeof nativeModule.updatePowerQualitySetting !== 'function') {
        return false;
      }

      let currentStructValue: CommonSettingPowerQualityStructValue | undefined = undefined;
      if (typeof nativeModule.getPowerQualitySetting === 'function') {
        currentStructValue = nativeModule.getPowerQualitySetting();
      }

      let writeValue = this.createPowerQualityWriteValue(currentStructValue);
      let writeSuccess = nativeModule.updatePowerQualitySetting(writeValue);
      if (writeSuccess) {
        this.loadNativePowerQualityData();
      }
      return writeSuccess;
    } catch (error) {
      console.error(`write native power quality data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    if (!saveSuccess) {
      this.showFeedback('提交失败');
      return;
    }

    let writeSuccess = this.writeNativePowerQualityData();
    if (!writeSuccess) {
      this.showFeedback('提交失败，请检查电能质量参数结构体写入。');
      return;
    }

    this.showSubmitWaiting('界面参数已写入电能质量参数结构体，等待装置回应...');
  }

  private closeFeedback(): void {
    this.feedbackDialogVisible = false;
    this.feedbackMessage = '';
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Column() {
          this.HeaderBar();
          this.BodyArea();
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

      if (this.selectOverlayVisible) {
        this.SelectOverlay();
      }

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
        .fontColor('#EF2929')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Center);

      Text(this.vm.titleLeft)
        .layoutWeight(4)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(37))
          .height(this.s(40));
      }
      .layoutWeight(2)
      .height(this.s(40))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(32))
          .height(this.s(40));
      }
      .layoutWeight(2)
      .height(this.s(40))
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
  BodyArea() {
    Scroll() {
      Column({ space: this.s(this.rowSpacing) }) {
        ForEach(COMMON_SETTING_POWER_QUALITY_ROWS, (row: PowerQualityRowConfig) => {
          this.AlarmRow(row);
        }, (row: PowerQualityRowConfig) => row.enabledFieldKey);
      }
      .width('100%')
      .padding({
        left: this.s(this.contentLeftPadding),
        right: this.s(this.contentRightPadding),
        top: this.s(this.contentTopPadding),
        bottom: this.s(this.contentBottomPadding)
      })
      .constraintSize({ minHeight: this.s(this.contentMinHeight) })
      .backgroundColor('#FFFFFF');
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  AlarmRow(config: PowerQualityRowConfig) {
    Row() {
      Text(config.title)
        .layoutWeight(6)
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .padding({ right: this.s(6) });

      Blank().layoutWeight(2);
      this.EnableBlock(config.title, config.enabledFieldKey);
      Blank().layoutWeight(2);
      this.ValueBlock(config.valueFieldKey, config.unit);
      Blank().layoutWeight(3);
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  EnableBlock(title: string, fieldKey: PowerQualityEnabledFieldKey) {
    Row() {
      Text('投退:')
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .margin({ right: this.s(8) });

      this.ComboField(fieldKey, title);
    }
    .layoutWeight(4)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ValueBlock(fieldKey: PowerQualityValueFieldKey, unit: string) {
    Row() {
      Text('动作值:')
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .margin({ right: this.s(8) });

      this.InputField(fieldKey);

      if (unit.length > 0) {
        Text(unit)
          .width(this.s(this.unitWidth))
          .fontSize(this.s(this.fontSize.fieldLabel))
          .fontColor('#000000')
          .fontFamily('Ubuntu')
          .textAlign(TextAlign.Center)
          .margin({ left: this.s(6) });
      } else {
        Blank().width(this.s(this.unitWidth + 6));
      }
    }
    .layoutWeight(6)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  InputField(fieldKey: PowerQualityValueFieldKey) {
    Row() {
      TextInput({ text: this.getInputValue(fieldKey), placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .backgroundColor(this.fieldBackgroundColor)
        .border({ width: 0 })
        .padding({ left: this.s(6), right: this.s(6), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setInputValue(fieldKey, value);
        });
    }
    .width(this.s(this.inputWidth))
    .height(this.s(this.inputHeight))
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ComboField(fieldKey: PowerQualityEnabledFieldKey, title: string) {
    Row() {
      Text(this.getEnabledValue(fieldKey))
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .textAlign(TextAlign.Start);

      Text('▼')
        .width(this.s(16))
        .fontSize(this.s(this.fontSize.arrow))
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(4) });
    }
    .width(this.s(this.comboWidth))
    .height(this.s(this.comboHeight))
    .padding({ left: this.s(6), right: this.s(4) })
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openSelectOverlay(fieldKey, title);
    });
  }

  @Builder
  SelectOverlay() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
      .onClick(() => {
        this.closeSelectOverlay();
      });

      Column() {
        Text(this.selectOverlayTitle)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        ForEach(this.enableOptions, (option: string) => {
          Button() {
            Text(option)
              .fontSize(this.s(this.fontSize.dialogBody))
              .fontColor('#000000')
              .fontFamily('STKaiti');
          }
          .width('100%')
          .height(this.s(42))
          .margin({ bottom: this.s(6) })
          .backgroundColor(option === this.selectOverlayValue ? '#D9E9F8' : '#FFFFFF')
          .border({ width: 1, color: option === this.selectOverlayValue ? '#7A9CC0' : '#BEBEBE' })
          .borderRadius(this.s(6))
          .onClick(() => {
            this.applySelectOverlayValue(option);
          });
        }, (option: string) => option);

        Button('取消')
          .width('100%')
          .height(this.s(40))
          .margin({ top: this.s(4) })
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(6))
          .onClick(() => {
            this.closeSelectOverlay();
          });
      }
      .width(this.s(this.overlayCardWidth))
      .padding({ left: this.s(14), right: this.s(14), top: this.s(14), bottom: this.s(14) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
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
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.feedbackMessage)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('确定')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeFeedback();
          });
      }
      .width(this.s(280))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
    }
    .width('100%')
    .height('100%');
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
          .fontSize(this.s(this.fontSize.dialogTitle))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        Text(this.submitWaitingMessage)
          .width('100%')
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(18) });

        Button('关闭')
          .width('100%')
          .height(this.s(40))
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.closeSubmitWaiting();
          });
      }
      .width(this.s(280))
      .padding({ left: this.s(16), right: this.s(16), top: this.s(16), bottom: this.s(16) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(this.s(this.overlayCardRadius));
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(5);

      this.BottomActionButton(this.vm.actions.defaultText, () => {
        this.resetDefaults();
      }, 20);

      Blank().layoutWeight(10);

      this.BottomActionButton(this.vm.actions.submitText, () => {
        this.submitCurrentData();
      }, 20);

      Blank().layoutWeight(5);

      this.BottomActionButton(this.vm.actions.closeText, () => {
        router.back();
      }, 20);

      Blank().layoutWeight(5);

      this.BottomActionButton(this.vm.actions.backText, () => {
        router.back();
      }, 20);

      Blank().layoutWeight(10);

      Text(this.vm.timeText)
        .layoutWeight(25)
        .height(this.s(this.footerButtonHeight))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.footerHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  BottomActionButton(text: string, onClickEvent: () => void, weight: number) {
    Button() {
      Text(text)
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily(text === '默认值' ? 'sans-serif-condensed' : 'Ubuntu')
        .fontWeight(text === '默认值' ? FontWeight.Bold : FontWeight.Medium);
    }
    .layoutWeight(weight)
    .height(this.s(this.footerButtonHeight))
    .padding(0)
    .backgroundColor('#BEBEBE')
    .border({ width: 0 })
    .borderRadius(this.s(this.footerButtonRadius))
    .onClick(() => {
      onClickEvent();
    });
  }
}
