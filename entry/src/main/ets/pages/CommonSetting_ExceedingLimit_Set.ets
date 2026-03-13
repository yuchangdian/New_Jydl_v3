import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import {
  CommonSettingExceedingLimitData,
  COMMON_SETTING_EXCEEDING_LIMIT_ENABLE_OPTIONS,
  createDefaultCommonSettingExceedingLimitData,
  deserializeCommonSettingExceedingLimitData,
  serializeCommonSettingExceedingLimitData
} from '../models/CommonSettingExceedingLimitData';

interface AbilityFileContext {
  filesDir: string;
}

interface ExceedingLimitRowConfig {
  title: string;
  selectFieldKey: string;
  valueFieldKey: string;
  limitLabel: string;
  unit: string;
  titleWidth: number;
  gapAfterTitle: number;
}

const COMMON_SETTING_EXCEEDING_LIMIT_ROWS: ExceedingLimitRowConfig[] = [
  {
    title: '【线电压越上限报警】',
    selectFieldKey: 'line_voltage_upper_enabled',
    valueFieldKey: 'line_voltage_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
  },
  {
    title: '【线电压越下限报警】',
    selectFieldKey: 'line_voltage_lower_enabled',
    valueFieldKey: 'line_voltage_lower_value',
    limitLabel: '下限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
  },
  {
    title: '【零序电压越上限报警】',
    selectFieldKey: 'zero_sequence_voltage_upper_enabled',
    valueFieldKey: 'zero_sequence_voltage_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 260,
    gapAfterTitle: 60
  },
  {
    title: '【电压不平衡率越上限报警】',
    selectFieldKey: 'voltage_imbalance_rate_upper_enabled',
    valueFieldKey: 'voltage_imbalance_rate_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
  },
  {
    title: '【相电流越上限报警】',
    selectFieldKey: 'phase_current_upper_enabled',
    valueFieldKey: 'phase_current_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
  },
  {
    title: '【零序电流越上限报警】',
    selectFieldKey: 'zero_sequence_current_upper_enabled',
    valueFieldKey: 'zero_sequence_current_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 260,
    gapAfterTitle: 60
  },
  {
    title: '【电流不平衡率越上限报警】',
    selectFieldKey: 'current_imbalance_rate_upper_enabled',
    valueFieldKey: 'current_imbalance_rate_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 260,
    gapAfterTitle: 60
  },
  {
    title: '【相差流越上限报警】',
    selectFieldKey: 'phase_differential_current_upper_enabled',
    valueFieldKey: 'phase_differential_current_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
  },
  {
    title: '【零序差流越上限报警】',
    selectFieldKey: 'zero_sequence_differential_current_upper_enabled',
    valueFieldKey: 'zero_sequence_differential_current_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 260,
    gapAfterTitle: 60
  },
  {
    title: '【负载率越上限报警】',
    selectFieldKey: 'load_rate_upper_enabled',
    valueFieldKey: 'load_rate_upper_value',
    limitLabel: '上限值:',
    unit: 'V',
    titleWidth: 240,
    gapAfterTitle: 80
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
class CommonSettingExceedingLimitVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定越限报警参数';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingExceedingLimitFontSize {
  notice: number = 18;
  title: number = 20;
  fieldLabel: number = 18;
  inputValue: number = 18;
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
export struct CommonSetting_ExceedingLimit_Set {
  @State vm: CommonSettingExceedingLimitVM = new CommonSettingExceedingLimitVM();
  @State formData: CommonSettingExceedingLimitData = createDefaultCommonSettingExceedingLimitData();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayTitle: string = '';
  @State selectOverlayValue: string = '';
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';

  private readonly fontSize: CommonSettingExceedingLimitFontSize = new CommonSettingExceedingLimitFontSize();
  private readonly enableOptions: string[] = COMMON_SETTING_EXCEEDING_LIMIT_ENABLE_OPTIONS;

  private readonly pageBaseWidth: number = 1024;
  private readonly pageBaseHeight: number = 600;
  private readonly pageMaxWidth: number = 1221;
  private readonly contentWidth: number = 980;
  private readonly contentBottomSpace: number = 200;
  private readonly headerHeight: number = 80;
  private readonly footerHeight: number = 80;
  private readonly rowHeight: number = 40;
  private readonly rowContentHeight: number = 30;
  private readonly rowSeparatorHeight: number = 10;
  private readonly inputWidth: number = 90;
  private readonly inputHeight: number = 30;
  private readonly comboWidth: number = 90;
  private readonly actionLabelWidth: number = 80;
  private readonly limitLabelWidth: number = 90;
  private readonly gapAfterCombo: number = 90;
  private readonly unitWidth: number = 30;
  private readonly rowTailGap: number = 190;
  private readonly delayLeadingGap: number = 20;
  private readonly delayLabelWidth: number = 210;
  private readonly delayTrailingGap: number = 630;
  private readonly footerButtonWidth: number = 110;
  private readonly footerButtonHeight: number = 60;
  private readonly footerButtonRadius: number = 22;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly separatorColor: string = '#B8B8B8';
  private readonly overlayCardWidth: number = 300;
  private readonly overlayCardRadius: number = 10;
  private readonly dataFileName: string = 'common_setting_exceeding_limit.json';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let currentDisplay = display.getDefaultDisplaySync();
      let scaleX = currentDisplay.width / this.pageBaseWidth;
      let scaleY = currentDisplay.height / this.pageBaseHeight;
      let scale = Math.min(scaleX, scaleY);
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
      let restored = deserializeCommonSettingExceedingLimitData(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load exceeding limit data failed: ${JSON.stringify(error)}`);
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingExceedingLimitData(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save exceeding limit data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private getInputValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'delay_time':
        return this.formData.delayTime;
      case 'line_voltage_upper_value':
        return this.formData.lineVoltageUpperValue;
      case 'line_voltage_lower_value':
        return this.formData.lineVoltageLowerValue;
      case 'zero_sequence_voltage_upper_value':
        return this.formData.zeroSequenceVoltageUpperValue;
      case 'voltage_imbalance_rate_upper_value':
        return this.formData.voltageImbalanceRateUpperValue;
      case 'phase_current_upper_value':
        return this.formData.phaseCurrentUpperValue;
      case 'zero_sequence_current_upper_value':
        return this.formData.zeroSequenceCurrentUpperValue;
      case 'current_imbalance_rate_upper_value':
        return this.formData.currentImbalanceRateUpperValue;
      case 'phase_differential_current_upper_value':
        return this.formData.phaseDifferentialCurrentUpperValue;
      case 'zero_sequence_differential_current_upper_value':
        return this.formData.zeroSequenceDifferentialCurrentUpperValue;
      case 'load_rate_upper_value':
        return this.formData.loadRateUpperValue;
      default:
        return '';
    }
  }

  private setInputValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'delay_time':
        this.formData.delayTime = value;
        break;
      case 'line_voltage_upper_value':
        this.formData.lineVoltageUpperValue = value;
        break;
      case 'line_voltage_lower_value':
        this.formData.lineVoltageLowerValue = value;
        break;
      case 'zero_sequence_voltage_upper_value':
        this.formData.zeroSequenceVoltageUpperValue = value;
        break;
      case 'voltage_imbalance_rate_upper_value':
        this.formData.voltageImbalanceRateUpperValue = value;
        break;
      case 'phase_current_upper_value':
        this.formData.phaseCurrentUpperValue = value;
        break;
      case 'zero_sequence_current_upper_value':
        this.formData.zeroSequenceCurrentUpperValue = value;
        break;
      case 'current_imbalance_rate_upper_value':
        this.formData.currentImbalanceRateUpperValue = value;
        break;
      case 'phase_differential_current_upper_value':
        this.formData.phaseDifferentialCurrentUpperValue = value;
        break;
      case 'zero_sequence_differential_current_upper_value':
        this.formData.zeroSequenceDifferentialCurrentUpperValue = value;
        break;
      case 'load_rate_upper_value':
        this.formData.loadRateUpperValue = value;
        break;
      default:
        break;
    }
  }

  private getSelectValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'line_voltage_upper_enabled':
        return this.formData.lineVoltageUpperEnabled;
      case 'line_voltage_lower_enabled':
        return this.formData.lineVoltageLowerEnabled;
      case 'zero_sequence_voltage_upper_enabled':
        return this.formData.zeroSequenceVoltageUpperEnabled;
      case 'voltage_imbalance_rate_upper_enabled':
        return this.formData.voltageImbalanceRateUpperEnabled;
      case 'phase_current_upper_enabled':
        return this.formData.phaseCurrentUpperEnabled;
      case 'zero_sequence_current_upper_enabled':
        return this.formData.zeroSequenceCurrentUpperEnabled;
      case 'current_imbalance_rate_upper_enabled':
        return this.formData.currentImbalanceRateUpperEnabled;
      case 'phase_differential_current_upper_enabled':
        return this.formData.phaseDifferentialCurrentUpperEnabled;
      case 'zero_sequence_differential_current_upper_enabled':
        return this.formData.zeroSequenceDifferentialCurrentUpperEnabled;
      case 'load_rate_upper_enabled':
        return this.formData.loadRateUpperEnabled;
      default:
        return '';
    }
  }

  private setSelectValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'line_voltage_upper_enabled':
        this.formData.lineVoltageUpperEnabled = value;
        break;
      case 'line_voltage_lower_enabled':
        this.formData.lineVoltageLowerEnabled = value;
        break;
      case 'zero_sequence_voltage_upper_enabled':
        this.formData.zeroSequenceVoltageUpperEnabled = value;
        break;
      case 'voltage_imbalance_rate_upper_enabled':
        this.formData.voltageImbalanceRateUpperEnabled = value;
        break;
      case 'phase_current_upper_enabled':
        this.formData.phaseCurrentUpperEnabled = value;
        break;
      case 'zero_sequence_current_upper_enabled':
        this.formData.zeroSequenceCurrentUpperEnabled = value;
        break;
      case 'current_imbalance_rate_upper_enabled':
        this.formData.currentImbalanceRateUpperEnabled = value;
        break;
      case 'phase_differential_current_upper_enabled':
        this.formData.phaseDifferentialCurrentUpperEnabled = value;
        break;
      case 'zero_sequence_differential_current_upper_enabled':
        this.formData.zeroSequenceDifferentialCurrentUpperEnabled = value;
        break;
      case 'load_rate_upper_enabled':
        this.formData.loadRateUpperEnabled = value;
        break;
      default:
        break;
    }
  }

  private openSelectOverlay(fieldKey: string, title: string): void {
    this.selectOverlayFieldKey = fieldKey;
    this.selectOverlayTitle = `${title} 投/退`;
    this.selectOverlayValue = this.getSelectValue(fieldKey);
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
      this.setSelectValue(this.selectOverlayFieldKey, value);
    }
    this.closeSelectOverlay();
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingExceedingLimitData();
  }

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    this.feedbackMessage = saveSuccess ? '提交成功' : '提交失败';
    this.feedbackDialogVisible = true;
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
        this.DelayRow();

        ForEach(COMMON_SETTING_EXCEEDING_LIMIT_ROWS, (row: ExceedingLimitRowConfig) => {
          this.AlarmRow(row);
        }, (row: ExceedingLimitRowConfig) => row.selectFieldKey)

        Blank().height(this.s(this.contentBottomSpace));
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF');
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  DelayRow() {
    Column() {
      Row() {
        Blank().width(this.s(this.delayLeadingGap));
        this.FieldLabel('越限报警延时时间:', this.delayLabelWidth);
        this.InputField('delay_time');
        this.UnitLabel('s', this.unitWidth);
        Blank().width(this.s(this.delayTrailingGap));
      }
      .width(this.s(this.contentWidth))
      .height(this.s(this.rowContentHeight))
      .alignItems(VerticalAlign.Center);

      this.RowSeparator();
    }
    .width(this.s(this.contentWidth))
    .height(this.s(this.rowHeight));
  }

  @Builder
  AlarmRow(config: ExceedingLimitRowConfig) {
    Column() {
      Row() {
        Text(config.title)
          .width(this.s(config.titleWidth))
          .fontSize(this.s(this.fontSize.fieldLabel))
          .fontColor('#000000')
          .maxLines(1)
          .textAlign(TextAlign.Start);

        Blank().width(this.s(config.gapAfterTitle));
        this.FieldLabel('投/退:', this.actionLabelWidth);
        this.ComboField(this.getSelectValue(config.selectFieldKey), config.selectFieldKey, config.title);
        Blank().width(this.s(this.gapAfterCombo));
        this.FieldLabel(config.limitLabel, this.limitLabelWidth);
        this.InputField(config.valueFieldKey);
        this.UnitLabel(config.unit, this.unitWidth);
        Blank().width(this.s(this.rowTailGap));
      }
      .width(this.s(this.contentWidth))
      .height(this.s(this.rowContentHeight))
      .alignItems(VerticalAlign.Center);

      this.RowSeparator();
    }
    .width(this.s(this.contentWidth))
    .height(this.s(this.rowHeight));
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
      .fontSize(this.s(this.fontSize.fieldLabel))
      .fontColor('#000000')
      .textAlign(TextAlign.Center);
  }

  @Builder
  InputField(fieldKey: string) {
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
  ComboField(value: string, fieldKey: string, title: string) {
    Row() {
      Text(value)
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .maxLines(1)
        .textAlign(TextAlign.Start);

      Text('▼')
        .width(this.s(14))
        .fontSize(this.s(this.fontSize.arrow))
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(4) });
    }
    .width(this.s(this.comboWidth))
    .height(this.s(this.inputHeight))
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
  RowSeparator() {
    Row() {
      Divider()
        .strokeWidth(this.s(2))
        .color(this.separatorColor)
        .width('100%');
    }
    .width(this.s(this.contentWidth))
    .height(this.s(this.rowSeparatorHeight))
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
        }, (option: string) => option)

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
  BottomBar() {
    Row() {
      Blank().width(this.s(37));

      this.BottomActionButton(this.vm.actions.defaultText, () => {
        this.resetDefaults();
      });

      Blank().width(this.s(117));

      this.BottomActionButton(this.vm.actions.submitText, () => {
        this.submitCurrentData();
      });

      Blank().width(this.s(78));

      this.BottomActionButton(this.vm.actions.closeText, () => {
        router.back();
      });

      Blank().width(this.s(78));

      this.BottomActionButton(this.vm.actions.backText, () => {
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
  BottomActionButton(text: string, onClickEvent: () => void) {
    Button() {
      Text(text)
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontWeight(FontWeight.Medium);
    }
    .width(this.s(this.footerButtonWidth))
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
