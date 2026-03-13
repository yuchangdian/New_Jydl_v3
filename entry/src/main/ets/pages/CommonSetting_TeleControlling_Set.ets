import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
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

const STR_DEFAULT: string = '\u9ed8\u8ba4\u503c';
const STR_SUBMIT: string = '\u63d0\u4ea4';
const STR_CLOSE: string = '\u5173\u95ed';
const STR_BACK: string = '\u8fd4\u56de';
const STR_TITLE_LEFT: string = '\u5b9a\u503c\u7ba1\u7406';
const STR_TITLE_RIGHT: string = '\u2014\u6574\u5b9a\u9065\u63a7\u53c2\u6570';
const STR_FEEDBACK_TITLE: string = '\u63d0\u793a';
const STR_FEEDBACK_OK: string = '\u786e\u5b9a';
const STR_CANCEL: string = '\u53d6\u6d88';
const STR_SUBMIT_SUCCESS: string = '\u63d0\u4ea4\u6210\u529f';
const STR_SUBMIT_FAILURE: string = '\u63d0\u4ea4\u5931\u8d25';
const STR_REMOTE_SECTION: string = '\u3010\u9065\u63a7\u53c2\u6570\u3011';
const STR_SYNC_SECTION: string = '\u3010\u540c\u671f\u5408\u95f8\u53c2\u6570\u3011';
const STR_YK1_SELECT: string = '\u9065\u63a71\u9009\u62e9\u4fdd\u6301\u65f6\u95f4:';
const STR_YK2_SELECT: string = '\u9065\u63a72\u9009\u62e9\u4fdd\u6301\u65f6\u95f4:';
const STR_YK1_TRIP: string = '\u9065\u63a71\u5206\u95f8\u4fdd\u6301\u65f6\u95f4:';
const STR_YK2_TRIP: string = '\u9065\u63a72\u5206\u95f8\u4fdd\u6301\u65f6\u95f4:';
const STR_YK1_CLOSE: string = '\u9065\u63a71\u5408\u95f8\u4fdd\u6301\u65f6\u95f4:';
const STR_YK2_CLOSE: string = '\u9065\u63a72\u5408\u95f8\u4fdd\u6301\u65f6\u95f4:';
const STR_NO_VOLTAGE: string = '\u65e0\u538b\u5b9a\u503c:';
const STR_THERE_VOLTAGE: string = '\u6709\u538b\u5b9a\u503c:';
const STR_VOLTAGE_DIFF: string = '\u538b\u5dee\u95ed\u9501\u5b9a\u503c:';
const STR_ANGLE_DIFF: string = '\u89d2\u5dee\u95ed\u9501\u5b9a\u503c:';
const STR_FREQUENCY_DIFF: string = '\u9891\u5dee\u95ed\u9501\u5b9a\u503c:';
const STR_SYNC_DELAY: string = '\u540c\u671f\u7b49\u5f85\u65f6\u95f4:';
const STR_BREAKER_CLOSE_TIME: string = '\u65ad\u8def\u5668\u5408\u95f8\u65f6\u95f4:';
const STR_REMOTE_CLOSE_MODE: string = '\u9065\u63a7\u5408\u95f8\u65b9\u5f0f:';
const TIME_TEXT: string = '2024/12/30\n12:12:30';

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

  private readonly fontSize: CommonSettingTeleControllingFontSize = new CommonSettingTeleControllingFontSize();
  private readonly closeModeOptions: string[] = COMMON_SETTING_TELE_CONTROLLING_CLOSE_MODE_OPTIONS;

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
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let scale = Math.min(sx, sy);
      this.uiScale = scale > 0 ? scale : 1;
    } catch (error) {
      this.uiScale = 1;
    }
    this.loadPersistedData();
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

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    this.feedbackMessage = saveSuccess ? STR_SUBMIT_SUCCESS : STR_SUBMIT_FAILURE;
    this.feedbackDialogVisible = true;
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
        '\u00b0',
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


