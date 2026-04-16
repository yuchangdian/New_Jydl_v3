import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import * as teleControllingNativeModule from 'libentry.so';
import {
  CommonSettingTeleControllingData,
  COMMON_SETTING_TELE_CONTROLLING_CLOSE_MODE_OPTIONS,
  createDefaultCommonSettingTeleControllingData,
  deserializeCommonSettingTeleControllingData,
  serializeCommonSettingTeleControllingData
} from '../models/CommonSettingTeleControllingData';

interface AbilityFileContext {
  filesDir: string;
}

interface CommonSettingTeleControllingStructValue {
  ready: boolean;
  HoldingTime_YK1_XZ: number;
  HoldingTime_YK1_TZ: number;
  HoldingTime_YK1_HZ: number;
  HoldingTime_YK2_XZ: number;
  HoldingTime_YK2_TZ: number;
  HoldingTime_YK2_HZ: number;
  Sync_NoVoltage: number;
  Sync_ThereVoltage: number;
  Sync_Volue_VoltageDifferenceBlock: number;
  Sync_Volue_AngleDifferenceBlock: number;
  Sync_Volue_FrequencyDifferenceBlock: number;
  Sync_DelayTime: number;
  Sync_BreakerCloseTime: number;
  Sync_Enable_CloseMode_YK: number;
  CRC: number;
}

interface CommonSettingTeleControllingWriteValue {
  HoldingTime_YK1_XZ: number;
  HoldingTime_YK1_TZ: number;
  HoldingTime_YK1_HZ: number;
  HoldingTime_YK2_XZ: number;
  HoldingTime_YK2_TZ: number;
  HoldingTime_YK2_HZ: number;
  Sync_NoVoltage: number;
  Sync_ThereVoltage: number;
  Sync_Volue_VoltageDifferenceBlock: number;
  Sync_Volue_AngleDifferenceBlock: number;
  Sync_Volue_FrequencyDifferenceBlock: number;
  Sync_DelayTime: number;
  Sync_BreakerCloseTime: number;
  Sync_Enable_CloseMode_YK: number;
}

interface TeleControllingNativeModule {
  getTeleControllingSetting?: () => CommonSettingTeleControllingStructValue | undefined;
  updateTeleControllingSetting?: (value: CommonSettingTeleControllingWriteValue) => boolean;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): TeleControllingNativeModule | undefined;

const STR_DEFAULT: string = '默认值';
const STR_SUBMIT: string = '提交';
const STR_CLOSE: string = '关闭';
const STR_BACK: string = '返回';
const STR_TITLE_LEFT: string = '定值管理';
const STR_TITLE_RIGHT: string = '—整定遥控参数';
const STR_FEEDBACK_TITLE: string = '提示';
const STR_FEEDBACK_OK: string = '确定';
const STR_CANCEL: string = '取消';
const STR_SUBMIT_SUCCESS: string = '提交成功';
const STR_SUBMIT_FAILURE: string = '提交失败';
const STR_SUBMIT_WRITE_FAILURE: string = '提交失败，请检查遥控参数结构体写入。';
const STR_WAITING_TITLE: string = '等待回应';
const STR_WAITING_BODY: string = '界面参数已写入遥控参数结构体，等待装置回应...';
const STR_REMOTE_SECTION: string = '【遥控参数】';
const STR_SYNC_SECTION: string = '【同期合闸参数】';
const STR_YK1_SELECT: string = '遥控1选择保持时间:';
const STR_YK2_SELECT: string = '遥控2选择保持时间:';
const STR_YK1_TRIP: string = '遥控1分闸保持时间:';
const STR_YK2_TRIP: string = '遥控2分闸保持时间:';
const STR_YK1_CLOSE: string = '遥控1合闸保持时间:';
const STR_YK2_CLOSE: string = '遥控2合闸保持时间:';
const STR_NO_VOLTAGE: string = '无压定值:';
const STR_THERE_VOLTAGE: string = '有压定值:';
const STR_VOLTAGE_DIFF: string = '压差闭锁定值:';
const STR_ANGLE_DIFF: string = '角差闭锁定值:';
const STR_FREQUENCY_DIFF: string = '频差闭锁定值:';
const STR_SYNC_DELAY: string = '同期等待时间:';
const STR_BREAKER_CLOSE_TIME: string = '断路器合闸时间:';
const STR_REMOTE_CLOSE_MODE: string = '遥控合闸方式:';
const TIME_TEXT: string = '2024/12/30\n12:12:30';

function isValidTeleControllingNumber(value: number): boolean {
  return typeof value === 'number' && isFinite(value) && value >= 0;
}

function formatTeleControllingNumber(value: number): string {
  if (!isValidTeleControllingNumber(value)) {
    return '';
  }
  return value.toFixed(2);
}

function getTeleControllingCloseModeText(value: number): string {
  switch (value) {
    case 0:
      return '闭锁';
    case 1:
      return '普通';
    case 2:
      return '检同期';
    case 3:
      return '检线无压且母有压';
    case 4:
      return '检线有压且母无压';
    case 5:
      return '检线无压且母无压';
    case 6:
      return '检线无压或母无压';
    default:
      return '';
  }
}

function isUsableCommonSettingTeleControllingStructValue(
  value: CommonSettingTeleControllingStructValue | undefined
): boolean {
  if (!value || !value.ready) {
    return false;
  }

  return isValidTeleControllingNumber(value.HoldingTime_YK1_XZ) &&
    isValidTeleControllingNumber(value.HoldingTime_YK1_TZ) &&
    isValidTeleControllingNumber(value.HoldingTime_YK1_HZ) &&
    isValidTeleControllingNumber(value.HoldingTime_YK2_XZ) &&
    isValidTeleControllingNumber(value.HoldingTime_YK2_TZ) &&
    isValidTeleControllingNumber(value.HoldingTime_YK2_HZ) &&
    isValidTeleControllingNumber(value.Sync_NoVoltage) &&
    isValidTeleControllingNumber(value.Sync_ThereVoltage) &&
    isValidTeleControllingNumber(value.Sync_Volue_VoltageDifferenceBlock) &&
    isValidTeleControllingNumber(value.Sync_Volue_AngleDifferenceBlock) &&
    isValidTeleControllingNumber(value.Sync_Volue_FrequencyDifferenceBlock) &&
    isValidTeleControllingNumber(value.Sync_DelayTime) &&
    isValidTeleControllingNumber(value.Sync_BreakerCloseTime) &&
    value.Sync_Enable_CloseMode_YK >= 0 &&
    value.Sync_Enable_CloseMode_YK <= 6;
}

function createCommonSettingTeleControllingDataFromStruct(
  source: CommonSettingTeleControllingStructValue
): CommonSettingTeleControllingData {
  let data = createDefaultCommonSettingTeleControllingData();
  data.yk1SelectHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK1_XZ);
  data.yk2SelectHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK2_XZ);
  data.yk1TripHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK1_TZ);
  data.yk2TripHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK2_TZ);
  data.yk1CloseHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK1_HZ);
  data.yk2CloseHoldingTime = formatTeleControllingNumber(source.HoldingTime_YK2_HZ);
  data.syncNoVoltage = formatTeleControllingNumber(source.Sync_NoVoltage);
  data.syncThereVoltage = formatTeleControllingNumber(source.Sync_ThereVoltage);
  data.syncVoltageDifferenceBlock = formatTeleControllingNumber(source.Sync_Volue_VoltageDifferenceBlock);
  data.syncAngleDifferenceBlock = formatTeleControllingNumber(source.Sync_Volue_AngleDifferenceBlock);
  data.syncFrequencyDifferenceBlock = formatTeleControllingNumber(source.Sync_Volue_FrequencyDifferenceBlock);
  data.syncDelayTime = formatTeleControllingNumber(source.Sync_DelayTime);
  data.syncBreakerCloseTime = formatTeleControllingNumber(source.Sync_BreakerCloseTime);
  data.remoteCloseMode = getTeleControllingCloseModeText(source.Sync_Enable_CloseMode_YK);
  return data;
}

@Observed
class BottomActionState {
  defaultText: string = STR_DEFAULT;
  submitText: string = STR_SUBMIT;
  closeText: string = STR_CLOSE;
  backText: string = STR_BACK;
}

@Observed
class CommonSettingTeleControllingVM {
  noticeText: string = '';
  titleLeft: string = STR_TITLE_LEFT;
  titleRight: string = STR_TITLE_RIGHT;
  actions: BottomActionState = new BottomActionState();
  timeText: string = TIME_TEXT;
}

class CommonSettingTeleControllingFontSize {
  notice: number = 18;
  title: number = 20;
  sectionTitle: number = 18;
  fieldLabel: number = 18;
  inputValue: number = 18;
  unit: number = 18;
  button: number = 18;
  timeText: number = 17;
  dialogTitle: number = 18;
  dialogBody: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  arrow: number = 11;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct CommonSetting_TeleControlling_Set {
  @State vm: CommonSettingTeleControllingVM = new CommonSettingTeleControllingVM();
  @State formData: CommonSettingTeleControllingData = createDefaultCommonSettingTeleControllingData();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '';
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayValue: string = '';
  @State selectOverlayOptions: string[] = [];
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';
  @State submitWaitingDialogVisible: boolean = false;
  @State submitWaitingMessage: string = '';

  private readonly fontSize: CommonSettingTeleControllingFontSize = new CommonSettingTeleControllingFontSize();
  private readonly closeModeOptions: string[] = COMMON_SETTING_TELE_CONTROLLING_CLOSE_MODE_OPTIONS;
  private cachedTeleControllingNativeModule?: TeleControllingNativeModule;

  private readonly pageBaseWidth: number = 1280;
  private readonly pageBaseHeight: number = 720;
  private readonly layoutZoom: number = 1.2;
  private readonly pageMaxWidth: number = 1024;
  private readonly bodyWidth: number = 980;
  private readonly headerHeight: number = 80;
  private readonly footerHeight: number = 80;
  private readonly sectionTitleHeight: number = 40;
  private readonly inputRowHeight: number = 40;
  private readonly inputRowGap: number = 10;
  private readonly inputHeight: number = 40;
  private readonly inputWidth: number = 90;
  private readonly closeModeWidth: number = 220;
  private readonly footerButtonWidth: number = 110;
  private readonly footerButtonHeight: number = 60;
  private readonly footerButtonRadius: number = 18;
  private readonly fieldRadius: number = 0;
  private readonly overlayCardWidth: number = 360;
  private readonly overlayCardRadius: number = 10;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly separatorColor: string = '#B8B8B8';
  private readonly dataFileName: string = 'common_setting_tele_controlling.json';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / this.pageBaseWidth;
      let sy = d.height / this.pageBaseHeight;
      let scale = Math.min(sx, sy);
      this.uiScale = (scale > 0 ? scale : 1) * this.layoutZoom;
    } catch (error) {
      this.uiScale = this.layoutZoom;
    }
    if (!this.loadNativeTeleControllingData()) {
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
      let restored = deserializeCommonSettingTeleControllingData(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load tele controlling data failed: ${JSON.stringify(error)}`);
    }
  }

  private isValidTeleControllingNativeModule(module: TeleControllingNativeModule | undefined): boolean {
    return !!module && typeof module.getTeleControllingSetting === 'function';
  }

  private loadTeleControllingNativeModule(): TeleControllingNativeModule | undefined {
    if (this.isValidTeleControllingNativeModule(this.cachedTeleControllingNativeModule)) {
      return this.cachedTeleControllingNativeModule;
    }
    if (this.isValidTeleControllingNativeModule(teleControllingNativeModule)) {
      this.cachedTeleControllingNativeModule = teleControllingNativeModule;
      return this.cachedTeleControllingNativeModule;
    }

    let napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidTeleControllingNativeModule(napiModuleWithPath)) {
      this.cachedTeleControllingNativeModule = napiModuleWithPath;
      return this.cachedTeleControllingNativeModule;
    }

    let napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidTeleControllingNativeModule(napiModuleWithApp)) {
      this.cachedTeleControllingNativeModule = napiModuleWithApp;
      return this.cachedTeleControllingNativeModule;
    }

    let napiModule = requireNapi('entry');
    if (this.isValidTeleControllingNativeModule(napiModule)) {
      this.cachedTeleControllingNativeModule = napiModule;
      return this.cachedTeleControllingNativeModule;
    }

    return undefined;
  }

  private loadNativeTeleControllingData(): boolean {
    try {
      let nativeModule = this.loadTeleControllingNativeModule();
      if (!nativeModule || typeof nativeModule.getTeleControllingSetting !== 'function') {
        return false;
      }

      let structValue = nativeModule.getTeleControllingSetting();
      if (!isUsableCommonSettingTeleControllingStructValue(structValue)) {
        return false;
      }

      this.formData = createCommonSettingTeleControllingDataFromStruct(
        structValue as CommonSettingTeleControllingStructValue
      );
      return true;
    } catch (error) {
      console.error(`load native tele controlling data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingTeleControllingData(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save tele controlling data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingTeleControllingData();
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

  private parseTeleControllingFieldNumber(value: string, fallbackValue: number): number {
    let parsed = Number.parseFloat(value);
    if (!Number.isFinite(parsed) || parsed < 0) {
      return fallbackValue;
    }
    return parsed;
  }

  private parseTeleControllingFieldUint(value: string, fallbackValue: number): number {
    return Math.max(0, Math.round(this.parseTeleControllingFieldNumber(value, fallbackValue)));
  }

  private getRemoteCloseModeCode(value: string, fallbackValue: number): number {
    switch (value) {
      case '闭锁':
        return 0;
      case '普通':
        return 1;
      case '检同期':
        return 2;
      case '检线无压且母有压':
        return 3;
      case '检线有压且母无压':
        return 4;
      case '检线无压且母无压':
        return 5;
      case '检线无压或母无压':
        return 6;
      default:
        if (fallbackValue >= 0 && fallbackValue <= 6) {
          return fallbackValue;
        }
        return 2;
    }
  }

  private createTeleControllingWriteValue(
    fallbackSource?: CommonSettingTeleControllingStructValue
  ): CommonSettingTeleControllingWriteValue {
    return {
      HoldingTime_YK1_XZ: this.parseTeleControllingFieldUint(
        this.formData.yk1SelectHoldingTime,
        fallbackSource?.HoldingTime_YK1_XZ ?? 0
      ),
      HoldingTime_YK1_TZ: this.parseTeleControllingFieldUint(
        this.formData.yk1TripHoldingTime,
        fallbackSource?.HoldingTime_YK1_TZ ?? 0
      ),
      HoldingTime_YK1_HZ: this.parseTeleControllingFieldUint(
        this.formData.yk1CloseHoldingTime,
        fallbackSource?.HoldingTime_YK1_HZ ?? 0
      ),
      HoldingTime_YK2_XZ: this.parseTeleControllingFieldUint(
        this.formData.yk2SelectHoldingTime,
        fallbackSource?.HoldingTime_YK2_XZ ?? 0
      ),
      HoldingTime_YK2_TZ: this.parseTeleControllingFieldUint(
        this.formData.yk2TripHoldingTime,
        fallbackSource?.HoldingTime_YK2_TZ ?? 0
      ),
      HoldingTime_YK2_HZ: this.parseTeleControllingFieldUint(
        this.formData.yk2CloseHoldingTime,
        fallbackSource?.HoldingTime_YK2_HZ ?? 0
      ),
      Sync_NoVoltage: this.parseTeleControllingFieldNumber(
        this.formData.syncNoVoltage,
        fallbackSource?.Sync_NoVoltage ?? 0
      ),
      Sync_ThereVoltage: this.parseTeleControllingFieldNumber(
        this.formData.syncThereVoltage,
        fallbackSource?.Sync_ThereVoltage ?? 0
      ),
      Sync_Volue_VoltageDifferenceBlock: this.parseTeleControllingFieldNumber(
        this.formData.syncVoltageDifferenceBlock,
        fallbackSource?.Sync_Volue_VoltageDifferenceBlock ?? 0
      ),
      Sync_Volue_AngleDifferenceBlock: this.parseTeleControllingFieldNumber(
        this.formData.syncAngleDifferenceBlock,
        fallbackSource?.Sync_Volue_AngleDifferenceBlock ?? 0
      ),
      Sync_Volue_FrequencyDifferenceBlock: this.parseTeleControllingFieldNumber(
        this.formData.syncFrequencyDifferenceBlock,
        fallbackSource?.Sync_Volue_FrequencyDifferenceBlock ?? 0
      ),
      Sync_DelayTime: this.parseTeleControllingFieldUint(
        this.formData.syncDelayTime,
        fallbackSource?.Sync_DelayTime ?? 0
      ),
      Sync_BreakerCloseTime: this.parseTeleControllingFieldUint(
        this.formData.syncBreakerCloseTime,
        fallbackSource?.Sync_BreakerCloseTime ?? 0
      ),
      Sync_Enable_CloseMode_YK: this.getRemoteCloseModeCode(
        this.formData.remoteCloseMode,
        fallbackSource?.Sync_Enable_CloseMode_YK ?? 2
      )
    };
  }

  private writeNativeTeleControllingData(): boolean {
    try {
      let nativeModule = this.loadTeleControllingNativeModule();
      if (!nativeModule || typeof nativeModule.updateTeleControllingSetting !== 'function') {
        return false;
      }

      let currentStructValue: CommonSettingTeleControllingStructValue | undefined = undefined;
      if (typeof nativeModule.getTeleControllingSetting === 'function') {
        currentStructValue = nativeModule.getTeleControllingSetting();
      }

      let writeValue = this.createTeleControllingWriteValue(currentStructValue);
      let writeSuccess = nativeModule.updateTeleControllingSetting(writeValue);
      if (writeSuccess) {
        this.loadNativeTeleControllingData();
      }
      return writeSuccess;
    } catch (error) {
      console.error(`write native tele controlling data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    if (!saveSuccess) {
      this.showFeedback(STR_SUBMIT_FAILURE);
      return;
    }
    let writeSuccess = this.writeNativeTeleControllingData();
    if (!writeSuccess) {
      this.showFeedback(STR_SUBMIT_WRITE_FAILURE);
      return;
    }
    this.showSubmitWaiting(STR_WAITING_BODY);
  }

  private closeFeedback(): void {
    this.feedbackDialogVisible = false;
    this.feedbackMessage = '';
  }

  private getSelectValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'remote_close_mode':
        return this.formData.remoteCloseMode;
      default:
        return '';
    }
  }

  private setSelectValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'remote_close_mode':
        this.formData.remoteCloseMode = value;
        break;
      default:
        break;
    }
  }

  private getSelectOptions(fieldKey: string): string[] {
    switch (fieldKey) {
      case 'remote_close_mode':
        return this.closeModeOptions;
      default:
        return [];
    }
  }

  private openSelectOverlay(fieldKey: string, title: string): void {
    this.selectOverlayFieldKey = fieldKey;
    this.selectOverlayTitle = title.endsWith(':') ? title.substring(0, title.length - 1) : title;
    this.selectOverlayValue = this.getSelectValue(fieldKey);
    this.selectOverlayOptions = this.getSelectOptions(fieldKey).slice();
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
    this.selectOverlayFieldKey = '';
    this.selectOverlayTitle = '';
  }

  private applySelectOverlayValue(value: string): void {
    if (this.selectOverlayFieldKey.length > 0) {
      this.setSelectValue(this.selectOverlayFieldKey, value);
    }
    this.selectOverlayValue = value;
    this.closeSelectOverlay();
  }

  private handleSelectFieldClick(fieldKey: string, label: string): void {
    this.openSelectOverlay(fieldKey, label);
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
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start)
        .padding({ left: this.s(10) });

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
      .height(this.s(60))
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
      .height(this.s(60))
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
      Column() {
        this.SectionTitle(STR_REMOTE_SECTION, 150);
        this.RemoteControllingSection();
        this.SectionTitle(STR_SYNC_SECTION, 200);
        this.SyncClosingSection();
        Blank().height(this.s(200));
      }
      .width('100%')
      .padding({ left: this.s(10), right: this.s(10) })
      .alignItems(HorizontalAlign.Center);
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  SectionTitle(text: string, width: number) {
    Row() {
      Text(text)
        .width(this.s(width))
        .height(this.s(this.sectionTitleHeight))
        .fontSize(this.s(this.fontSize.sectionTitle))
        .fontColor('#000000')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(1);
    }
    .width(this.s(this.bodyWidth));
  }

  @Builder
  RemoteControllingSection() {
    Column({ space: this.s(this.inputRowGap) }) {
      this.RemoteHoldingRow(
        STR_YK1_SELECT,
        this.formData.yk1SelectHoldingTime,
        (value: string) => {
          this.formData.yk1SelectHoldingTime = value;
        },
        STR_YK2_SELECT,
        this.formData.yk2SelectHoldingTime,
        (value: string) => {
          this.formData.yk2SelectHoldingTime = value;
        }
      );

      this.RemoteHoldingRow(
        STR_YK1_TRIP,
        this.formData.yk1TripHoldingTime,
        (value: string) => {
          this.formData.yk1TripHoldingTime = value;
        },
        STR_YK2_TRIP,
        this.formData.yk2TripHoldingTime,
        (value: string) => {
          this.formData.yk2TripHoldingTime = value;
        }
      );

      this.RemoteHoldingRow(
        STR_YK1_CLOSE,
        this.formData.yk1CloseHoldingTime,
        (value: string) => {
          this.formData.yk1CloseHoldingTime = value;
        },
        STR_YK2_CLOSE,
        this.formData.yk2CloseHoldingTime,
        (value: string) => {
          this.formData.yk2CloseHoldingTime = value;
        }
      );

      this.SectionDivider();
    }
    .width(this.s(this.bodyWidth))
    .margin({ bottom: this.s(10) });
  }

  @Builder
  RemoteHoldingRow(
    leftLabel: string,
    leftValue: string,
    leftOnChange: (value: string) => void,
    rightLabel: string,
    rightValue: string,
    rightOnChange: (value: string) => void
  ) {
    Row() {
      Blank().width(this.s(150));
      this.FieldLabel(leftLabel, 220);
      this.InputField(leftValue, leftOnChange);
      this.UnitLabel('ms', 40);
      Blank().width(this.s(50));
      this.FieldLabel(rightLabel, 220);
      this.InputField(rightValue, rightOnChange);
      this.UnitLabel('ms', 40);
      Blank().width(this.s(80));
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(this.inputRowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SyncClosingSection() {
    Column({ space: this.s(this.inputRowGap) }) {
      this.SyncDualInputRow(
        150,
        STR_NO_VOLTAGE,
        110,
        this.formData.syncNoVoltage,
        (value: string) => {
          this.formData.syncNoVoltage = value;
        },
        'V',
        30,
        170,
        STR_THERE_VOLTAGE,
        110,
        this.formData.syncThereVoltage,
        (value: string) => {
          this.formData.syncThereVoltage = value;
        },
        'V',
        30,
        200
      );

      this.SyncDualInputRow(
        150,
        STR_VOLTAGE_DIFF,
        160,
        this.formData.syncVoltageDifferenceBlock,
        (value: string) => {
          this.formData.syncVoltageDifferenceBlock = value;
        },
        'V',
        30,
        120,
        STR_ANGLE_DIFF,
        160,
        this.formData.syncAngleDifferenceBlock,
        (value: string) => {
          this.formData.syncAngleDifferenceBlock = value;
        },
        '°',
        30,
        150
      );

      this.SyncDualInputRow(
        150,
        STR_FREQUENCY_DIFF,
        160,
        this.formData.syncFrequencyDifferenceBlock,
        (value: string) => {
          this.formData.syncFrequencyDifferenceBlock = value;
        },
        'Hz',
        40,
        110,
        STR_SYNC_DELAY,
        160,
        this.formData.syncDelayTime,
        (value: string) => {
          this.formData.syncDelayTime = value;
        },
        's',
        30,
        150
      );

      this.SyncModeRow();
    }
    .width(this.s(this.bodyWidth));
  }

  @Builder
  SyncDualInputRow(
    startGap: number,
    leftLabel: string,
    leftLabelWidth: number,
    leftValue: string,
    leftOnChange: (value: string) => void,
    leftUnit: string,
    leftUnitWidth: number,
    middleGap: number,
    rightLabel: string,
    rightLabelWidth: number,
    rightValue: string,
    rightOnChange: (value: string) => void,
    rightUnit: string,
    rightUnitWidth: number,
    endGap: number
  ) {
    Row() {
      Blank().width(this.s(startGap));
      this.FieldLabel(leftLabel, leftLabelWidth);
      this.InputField(leftValue, leftOnChange);
      this.UnitLabel(leftUnit, leftUnitWidth);
      Blank().width(this.s(middleGap));
      this.FieldLabel(rightLabel, rightLabelWidth);
      this.InputField(rightValue, rightOnChange);
      this.UnitLabel(rightUnit, rightUnitWidth);
      Blank().width(this.s(endGap));
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(this.inputRowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SyncModeRow() {
    Row() {
      Blank().width(this.s(150));
      this.FieldLabel(STR_BREAKER_CLOSE_TIME, 180);
      this.InputField(this.formData.syncBreakerCloseTime, (value: string) => {
        this.formData.syncBreakerCloseTime = value;
      });
      this.UnitLabel('ms', 40);
      Blank().width(this.s(90));
      this.FieldLabel(STR_REMOTE_CLOSE_MODE, 160);
      this.ComboField(STR_REMOTE_CLOSE_MODE, 'remote_close_mode', this.closeModeWidth);
      Blank().width(this.s(50));
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(this.inputRowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  FieldLabel(text: string, width: number) {
    Text(text)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.fieldLabel))
      .fontColor('#000000')
      .textAlign(TextAlign.Start);
  }

  @Builder
  UnitLabel(text: string, width: number) {
    Text(text)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.unit))
      .fontColor('#000000')
      .textAlign(TextAlign.Center);
  }

  @Builder
  InputField(value: string, onChangeEvent: (value: string) => void) {
    Row() {
      TextInput({ text: value, placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .backgroundColor(this.fieldBackgroundColor)
        .border({ width: 0 })
        .padding({ left: this.s(6), right: this.s(6), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .onChange((text: string) => {
          onChangeEvent(text);
        });
    }
    .width(this.s(this.inputWidth))
    .height(this.s(this.inputHeight))
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(this.s(this.fieldRadius))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ComboField(label: string, fieldKey: string, boxWidth: number) {
    Row() {
      Text(this.getSelectValue(fieldKey))
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start);

      Text('▼')
        .width(this.s(14))
        .fontSize(this.s(this.fontSize.arrow))
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(4) });
    }
    .width(this.s(boxWidth))
    .height(this.s(this.inputHeight))
    .padding({ left: this.s(6), right: this.s(4) })
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(this.s(this.fieldRadius))
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.handleSelectFieldClick(fieldKey, label);
    });
  }

  @Builder
  SectionDivider() {
    Row() {
      Divider()
        .strokeWidth(this.s(2))
        .color(this.separatorColor)
        .width('100%');
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(10))
    .alignItems(VerticalAlign.Center);
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

        ForEach(this.selectOverlayOptions, (option: string) => {
          Button() {
            Text(option)
              .width('100%')
              .fontSize(this.s(this.fontSize.dialogBody))
              .fontColor('#000000')
              .fontFamily('STKaiti')
              .maxLines(2)
              .textAlign(TextAlign.Center);
          }
          .width('100%')
          .height(this.s(48))
          .margin({ bottom: this.s(6) })
          .backgroundColor(option === this.selectOverlayValue ? '#D9E9F8' : '#FFFFFF')
          .border({ width: 1, color: option === this.selectOverlayValue ? '#7A9CC0' : '#BEBEBE' })
          .borderRadius(this.s(8))
          .onClick(() => {
            this.applySelectOverlayValue(option);
          });
        }, (option: string) => option)

        Button(STR_CANCEL)
          .width('100%')
          .height(this.s(42))
          .margin({ top: this.s(4) })
          .fontSize(this.s(this.fontSize.dialogBody))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .borderRadius(this.s(8))
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
        Text(STR_WAITING_TITLE)
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

        Button(STR_CLOSE)
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
        Text(STR_FEEDBACK_TITLE)
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

        Button(STR_FEEDBACK_OK)
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
  BottomBar() {
    Row() {
      Blank().width(this.s(37));

      this.BottomActionButton(this.vm.actions.defaultText, 'sans-serif-condensed', FontWeight.Bold, () => {
        this.resetDefaults();
      });

      Blank().width(this.s(117));

      this.BottomActionButton(this.vm.actions.submitText, 'Ubuntu', FontWeight.Normal, () => {
        this.submitCurrentData();
      });

      Blank().width(this.s(78));

      this.BottomActionButton(this.vm.actions.closeText, 'Ubuntu', FontWeight.Normal, () => {
        router.back();
      });

      Blank().width(this.s(78));

      this.BottomActionButton(this.vm.actions.backText, 'Ubuntu', FontWeight.Normal, () => {
        router.back();
      });

      Blank().width(this.s(97));

      Text(this.vm.timeText)
        .width(this.s(160))
        .height(this.s(60))
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
  BottomActionButton(
    text: string,
    fontFamily: string,
    fontWeight: FontWeight,
    onClickEvent: () => void
  ) {
    Button(text)
      .width(this.s(this.footerButtonWidth))
      .height(this.s(this.footerButtonHeight))
      .fontSize(this.s(this.fontSize.button))
      .fontColor('#000000')
      .fontFamily(fontFamily)
      .fontWeight(fontWeight)
      .backgroundColor('#BEBEBE')
      .border({ width: 0 })
      .borderRadius(this.s(this.footerButtonRadius))
      .padding(0)
      .onClick(() => {
        onClickEvent();
      });
  }
}


