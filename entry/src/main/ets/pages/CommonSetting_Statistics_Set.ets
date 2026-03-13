import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import {
  CommonSettingStatisticsField,
  COMMON_SETTING_STATISTICS_ENABLE_OPTIONS,
  COMMON_SETTING_STATISTICS_PERIOD_TYPE_OPTIONS,
  createDefaultCommonSettingStatisticsFields,
  deserializeCommonSettingStatisticsFields,
  serializeCommonSettingStatisticsFields
} from '../models/CommonSettingStatisticsData';

interface AbilityFileContext {
  filesDir: string;
}

interface StatisticsToggleConfig {
  title: string;
  titleWidth: number;
  fieldKey: string;
}

interface StatisticsPeriodConfig {
  title: string;
  titleWidth: number;
  enableKey: string;
  periodTypeKey: string;
  periodLengthKey: string;
}

const COMMON_SETTING_STATISTICS_TOP_SECTIONS: StatisticsToggleConfig[] = [
  {
    title: '【母线统计】',
    titleWidth: 140,
    fieldKey: 'C_Box_Stats_En_Bus'
  },
  {
    title: '【线路统计】',
    titleWidth: 140,
    fieldKey: 'C_Box_Stats_En_Line'
  }
];

const COMMON_SETTING_STATISTICS_PERIOD_SECTIONS: StatisticsPeriodConfig[] = [
  {
    title: '【电压极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageMaxValue'
  },
  {
    title: '【电压极小值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageMinValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageMinValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageMinValue'
  },
  {
    title: '【电压整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_VoltageOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageOnTimeValue'
  },
  {
    title: '【电压不平衡极大值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_VoltageImbalanceMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageImbalanceMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageImbalanceMaxValue'
  },
  {
    title: '【电压合格率整点值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_VoltageQualifiedRateOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_VoltageQualifiedRateOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_VoltageQualifiedRateOnTimeValue'
  },
  {
    title: '【电流极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentMaxValue'
  },
  {
    title: '【电流极小值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentMinValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentMinValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentMinValue'
  },
  {
    title: '【电流整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_CurrentOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentOnTimeValue'
  },
  {
    title: '【电流不平衡极大值统计】',
    titleWidth: 280,
    enableKey: 'C_Box_Stats_En_CurrentImbalanceMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_CurrentImbalanceMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_CurrentImbalanceMaxValue'
  },
  {
    title: '【功率极大值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_PowerMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerMaxValue'
  },
  {
    title: '【功率整点值统计】',
    titleWidth: 220,
    enableKey: 'C_Box_Stats_En_PowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerOnTimeValue'
  },
  {
    title: '【功率因数极大值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PowerFactorMaxValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerFactorMaxValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerFactorMaxValue'
  },
  {
    title: '【功率因数整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PowerFactorOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PowerFactorOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PowerFactorOnTimeValue'
  },
  {
    title: '【负载率整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_LoadRateOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_LoadRateOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_LoadRateOnTimeValue'
  },
  {
    title: '【正向有功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PositiveActivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PositiveActivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PositiveActivePowerOnTimeValue'
  },
  {
    title: '【正向无功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_PositiveReactivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_PositiveReactivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_PositiveReactivePowerOnTimeValue'
  },
  {
    title: '【反向有功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_ReverseActivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_ReverseActivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_ReverseActivePowerOnTimeValue'
  },
  {
    title: '【反向无功整点值统计】',
    titleWidth: 260,
    enableKey: 'C_Box_Stats_En_ReverseReactivePowerOnTimeValue',
    periodTypeKey: 'C_Box_Stats_PDType_ReverseReactivePowerOnTimeValue',
    periodLengthKey: 'Edit_Stats_PDLen_ReverseReactivePowerOnTimeValue'
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
class CommonSettingStatisticsVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定统计参数';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingStatisticsFontSize {
  notice: number = 16;
  title: number = 20;
  sectionTitle: number = 18;
  fieldLabel: number = 18;
  inputValue: number = 18;
  button: number = 18;
  timeText: number = 17;
  dialogTitle: number = 18;
  dialogBody: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  arrow: number = 12;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct CommonSetting_Statistics_Set {
  @State vm: CommonSettingStatisticsVM = new CommonSettingStatisticsVM();
  @State formData: CommonSettingStatisticsField[] = createDefaultCommonSettingStatisticsFields();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '';
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayValue: string = '';
  @State selectOverlayOptions: string[] = [];
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';

  private readonly fontSize: CommonSettingStatisticsFontSize = new CommonSettingStatisticsFontSize();
  private readonly enableOptions: string[] = COMMON_SETTING_STATISTICS_ENABLE_OPTIONS;
  private readonly periodTypeOptions: string[] = COMMON_SETTING_STATISTICS_PERIOD_TYPE_OPTIONS;

  private readonly pageMaxWidth: number = 1024;
  private readonly pageBaseWidth: number = 1024;
  private readonly pageBaseHeight: number = 600;
  private readonly headerHeight: number = 80;
  private readonly footerHeight: number = 80;
  private readonly contentMinHeight: number = 1140;
  private readonly contentBottomPadding: number = 200;
  private readonly contentWidth: number = 1000;
  private readonly rowHeight: number = 60;
  private readonly rowContentHeight: number = 40;
  private readonly rowContentTopMargin: number = 5;
  private readonly separatorHeight: number = 20;
  private readonly separatorStroke: number = 2;
  private readonly toggleLabelWidth: number = 80;
  private readonly periodTypeLabelWidth: number = 160;
  private readonly periodLengthLabelWidth: number = 160;
  private readonly toggleFieldWidth: number = 80;
  private readonly periodTypeFieldWidth: number = 100;
  private readonly periodLengthFieldWidth: number = 80;
  private readonly fieldHeight: number = 40;
  private readonly gapWidth: number = 20;
  private readonly bottomButtonWidth: number = 110;
  private readonly bottomButtonHeight: number = 60;
  private readonly bottomButtonRadius: number = 24;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly separatorColor: string = '#A9A9A9';
  private readonly overlayCardWidth: number = 320;
  private readonly overlayCardRadius: number = 10;
  private readonly dataFileName: string = 'common_setting_statistics.json';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let scaleX = d.width / this.pageBaseWidth;
      let scaleY = d.height / this.pageBaseHeight;
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
      let restored = deserializeCommonSettingStatisticsFields(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load statistics data failed: ${JSON.stringify(error)}`);
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingStatisticsFields(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save statistics data failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private findField(fieldKey: string): CommonSettingStatisticsField | undefined {
    return this.formData.find((field: CommonSettingStatisticsField) => field.key === fieldKey);
  }

  private getFieldValue(fieldKey: string): string {
    let field = this.findField(fieldKey);
    return field ? field.value : '';
  }

  private setFieldValue(fieldKey: string, value: string): void {
    let field = this.findField(fieldKey);
    if (field) {
      field.value = value;
    }
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingStatisticsFields();
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

  private cleanSectionTitle(title: string): string {
    return title.replace('【', '').replace('】', '');
  }

  private openSelectOverlay(fieldKey: string, title: string, options: string[]): void {
    this.selectOverlayFieldKey = fieldKey;
    this.selectOverlayTitle = title;
    this.selectOverlayValue = this.getFieldValue(fieldKey);
    this.selectOverlayOptions = options.slice();
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
    this.selectOverlayFieldKey = '';
    this.selectOverlayTitle = '';
  }

  private applySelectOverlayValue(value: string): void {
    if (this.selectOverlayFieldKey.length > 0) {
      this.setFieldValue(this.selectOverlayFieldKey, value);
    }
    this.closeSelectOverlay();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Column() {
          this.HeaderBar();

          Scroll() {
            Column() {
              this.TopToggleRow();

              ForEach(COMMON_SETTING_STATISTICS_PERIOD_SECTIONS, (section: StatisticsPeriodConfig) => {
                this.PeriodSectionRow(section);
              }, (section: StatisticsPeriodConfig) => section.enableKey);

              Blank()
                .height(this.s(this.contentBottomPadding));
            }
            .width(this.s(this.contentWidth))
            .constraintSize({ minHeight: this.s(this.contentMinHeight) })
            .padding({ left: this.s(5), right: this.s(5) });
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
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .maxLines(1)
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
    .padding({ left: this.s(10), right: this.s(10), top: this.s(10), bottom: this.s(10) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  TopToggleRow() {
    Column() {
      Row() {
        this.SectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].title, COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].title)}投/退`,
          COMMON_SETTING_STATISTICS_TOP_SECTIONS[0].fieldKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().width(this.s(200));
        this.SectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].title, COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].title)}投/退`,
          COMMON_SETTING_STATISTICS_TOP_SECTIONS[1].fieldKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().layoutWeight(1);
      }
      .width('100%')
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowContentTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.SeparatorRow();
    }
    .width('100%')
    .height(this.s(this.rowHeight));
  }

  @Builder
  PeriodSectionRow(section: StatisticsPeriodConfig) {
    Column() {
      Row() {
        this.SectionTitle(section.title, section.titleWidth);
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('投/退:', this.toggleLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(section.title)}投/退`,
          section.enableKey,
          this.toggleFieldWidth,
          this.enableOptions
        );
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('统计周期类型:', this.periodTypeLabelWidth);
        this.ComboField(
          `${this.cleanSectionTitle(section.title)}统计周期类型`,
          section.periodTypeKey,
          this.periodTypeFieldWidth,
          this.periodTypeOptions
        );
        Blank().width(this.s(this.gapWidth));
        this.FieldLabel('统计周期长度:', this.periodLengthLabelWidth);
        this.InputField(section.periodLengthKey, this.periodLengthFieldWidth);
        Blank().layoutWeight(1);
      }
      .width('100%')
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowContentTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.SeparatorRow();
    }
    .width('100%')
    .height(this.s(this.rowHeight));
  }

  @Builder
  SectionTitle(title: string, width: number) {
    Text(title)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.sectionTitle))
      .fontColor('#000000')
      .fontFamily('sans-serif')
      .maxLines(1)
      .textAlign(TextAlign.Start);
  }

  @Builder
  FieldLabel(label: string, width: number) {
    Text(label)
      .width(this.s(width))
      .fontSize(this.s(this.fontSize.fieldLabel))
      .fontColor('#000000')
      .fontFamily('sans-serif')
      .maxLines(1)
      .textAlign(TextAlign.Start);
  }

  @Builder
  InputField(fieldKey: string, width: number) {
    Row() {
      TextInput({ text: this.getFieldValue(fieldKey), placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .backgroundColor(this.fieldBackgroundColor)
        .border({ width: 0 })
        .padding({ left: this.s(8), right: this.s(8), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setFieldValue(fieldKey, value);
        });
    }
    .width(this.s(width))
    .height(this.s(this.fieldHeight))
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ComboField(title: string, fieldKey: string, width: number, options: string[]) {
    Row() {
      Text(this.getFieldValue(fieldKey))
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);

      Text('▼')
        .width(this.s(14))
        .fontSize(this.s(this.fontSize.arrow))
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(4) });
    }
    .width(this.s(width))
    .height(this.s(this.fieldHeight))
    .padding({ left: this.s(8), right: this.s(6) })
    .backgroundColor(this.fieldBackgroundColor)
    .border({ width: 1, color: this.fieldBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openSelectOverlay(fieldKey, title, options);
    });
  }

  @Builder
  SeparatorRow() {
    Row() {
      Divider()
        .strokeWidth(this.s(this.separatorStroke))
        .color(this.separatorColor)
        .width('100%');
    }
    .width('100%')
    .height(this.s(this.separatorHeight))
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
  BottomBar() {
    Row() {
      Blank().width(this.s(40));

      Button(this.vm.actions.defaultText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          this.resetDefaults();
        });

      Blank().width(this.s(117));

      Button(this.vm.actions.submitText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          this.submitCurrentData();
        });

      Blank().width(this.s(78));

      Button(this.vm.actions.closeText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().width(this.s(78));

      Button(this.vm.actions.backText)
        .width(this.s(this.bottomButtonWidth))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.button))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().width(this.s(97));

      Text(this.vm.timeText)
        .width(this.s(160))
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.footerHeight))
    .alignItems(VerticalAlign.Center)
    .padding({ top: this.s(10), bottom: this.s(10) })
    .backgroundColor('#D3D3D3');
  }
}
