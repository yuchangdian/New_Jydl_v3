import router from '@ohos.router';
import display from '@ohos.display';

interface TeleSignalingPairRowSpec {
  leftLabel: string;
  leftFieldKey: string;
  rightLabel: string;
  rightFieldKey: string;
}

@Observed
class CommonSettingTeleSignalingData {
  yx01Time: string = '00.00';
  yx02Time: string = '00.00';
  yx03Time: string = '00.00';
  yx04Time: string = '00.00';
  yx05Time: string = '00.00';
  yx06Time: string = '00.00';
  yx07Time: string = '00.00';
  yx08Time: string = '00.00';
  logicMode: string = '原值';
}

function createDefaultCommonSettingTeleSignalingData(): CommonSettingTeleSignalingData {
  return new CommonSettingTeleSignalingData();
}

const COMMON_SETTING_TELE_SIGNALING_ROW_SPECS: TeleSignalingPairRowSpec[] = [
  {
    leftLabel: '遥信01防抖时限:',
    leftFieldKey: 'yx01Time',
    rightLabel: '遥信02防抖时限:',
    rightFieldKey: 'yx02Time'
  },
  {
    leftLabel: '遥信03防抖时限:',
    leftFieldKey: 'yx03Time',
    rightLabel: '遥信04防抖时限:',
    rightFieldKey: 'yx04Time'
  },
  {
    leftLabel: '遥信05防抖时限:',
    leftFieldKey: 'yx05Time',
    rightLabel: '遥信06防抖时限:',
    rightFieldKey: 'yx06Time'
  },
  {
    leftLabel: '遥信07防抖时限:',
    leftFieldKey: 'yx07Time',
    rightLabel: '遥信08防抖时限:',
    rightFieldKey: 'yx08Time'
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
class CommonSettingTeleSignalingVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定遥信参数';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingTeleSignalingFontSize {
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
export struct CommonSetting_TeleSignaling_Set {
  @State vm: CommonSettingTeleSignalingVM = new CommonSettingTeleSignalingVM();
  @State formData: CommonSettingTeleSignalingData = createDefaultCommonSettingTeleSignalingData();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '';
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayValue: string = '';
  @State selectOverlayOptions: string[] = [];
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';

  private readonly fontSize: CommonSettingTeleSignalingFontSize = new CommonSettingTeleSignalingFontSize();
  private readonly logicOptions: string[] = ['原值', '取反', '屏蔽'];

  private readonly pageMaxWidth: number = 1024;
  private readonly headerHeight: number = 80;
  private readonly footerHeight: number = 80;
  private readonly bodyWidth: number = 980;
  private readonly bodyMinHeight: number = 440;
  private readonly bodyRowHeight: number = 70;
  private readonly bodyBottomSpace: number = 90;
  private readonly rowContentHeight: number = 40;
  private readonly rowTopMargin: number = 10;
  private readonly rowSeparatorHeight: number = 20;
  private readonly inputHeight: number = 40;
  private readonly inputWidth: number = 90;
  private readonly comboWidth: number = 90;
  private readonly fieldLabelWidth: number = 190;
  private readonly unitWidth: number = 40;
  private readonly rowLeadingSpace: number = 47;
  private readonly firstSectionGap: number = 137;
  private readonly rowTrailingSpace: number = 147;
  private readonly logicTrailingSpace: number = 650;
  private readonly bottomButtonRadius: number = 20;
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly separatorColor: string = '#B8B8B8';
  private readonly overlayCardWidth: number = 280;
  private readonly overlayCardRadius: number = 10;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let currentDisplay = display.getDefaultDisplaySync();
      let scaleX = currentDisplay.width / 1024;
      let scaleY = currentDisplay.height / 600;
      let scale = Math.min(scaleX, scaleY);
      this.uiScale = scale > 0 ? scale : 1;
    } catch (error) {
      this.uiScale = 1;
    }
  }

  private getFieldValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'yx01Time':
        return this.formData.yx01Time;
      case 'yx02Time':
        return this.formData.yx02Time;
      case 'yx03Time':
        return this.formData.yx03Time;
      case 'yx04Time':
        return this.formData.yx04Time;
      case 'yx05Time':
        return this.formData.yx05Time;
      case 'yx06Time':
        return this.formData.yx06Time;
      case 'yx07Time':
        return this.formData.yx07Time;
      case 'yx08Time':
        return this.formData.yx08Time;
      default:
        return '';
    }
  }

  private setFieldValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'yx01Time':
        this.formData.yx01Time = value;
        break;
      case 'yx02Time':
        this.formData.yx02Time = value;
        break;
      case 'yx03Time':
        this.formData.yx03Time = value;
        break;
      case 'yx04Time':
        this.formData.yx04Time = value;
        break;
      case 'yx05Time':
        this.formData.yx05Time = value;
        break;
      case 'yx06Time':
        this.formData.yx06Time = value;
        break;
      case 'yx07Time':
        this.formData.yx07Time = value;
        break;
      case 'yx08Time':
        this.formData.yx08Time = value;
        break;
      default:
        break;
    }
  }

  private getSelectValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'logic_mode':
        return this.formData.logicMode;
      default:
        return '';
    }
  }

  private setSelectValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'logic_mode':
        this.formData.logicMode = value;
        break;
      default:
        break;
    }
  }

  private getSelectOptions(fieldKey: string): string[] {
    switch (fieldKey) {
      case 'logic_mode':
        return this.logicOptions;
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

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingTeleSignalingData();
  }

  private submitCurrentData(): void {
    this.feedbackMessage = '提交成功';
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
        .fontFamily('STKaiti')
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
    Column() {
      ForEach(COMMON_SETTING_TELE_SIGNALING_ROW_SPECS, (row: TeleSignalingPairRowSpec) => {
        this.PairRow(row);
      }, (row: TeleSignalingPairRowSpec) => row.leftFieldKey)

      this.LogicRow();
      Blank().height(this.s(this.bodyBottomSpace));
    }
    .layoutWeight(1)
    .width('100%')
    .constraintSize({ minHeight: this.s(this.bodyMinHeight) })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  PairRow(config: TeleSignalingPairRowSpec) {
    Column() {
      Row() {
        Blank().width(this.s(this.rowLeadingSpace));
        this.FieldLabel(config.leftLabel, this.fieldLabelWidth);
        this.InputField(this.getFieldValue(config.leftFieldKey), (value: string) => {
          this.setFieldValue(config.leftFieldKey, value);
        });
        this.UnitLabel('ms', this.unitWidth);
        Blank().width(this.s(this.firstSectionGap));
        this.FieldLabel(config.rightLabel, this.fieldLabelWidth);
        this.InputField(this.getFieldValue(config.rightFieldKey), (value: string) => {
          this.setFieldValue(config.rightFieldKey, value);
        });
        this.UnitLabel('ms', this.unitWidth);
        Blank().width(this.s(this.rowTrailingSpace));
      }
      .width(this.s(this.bodyWidth))
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.RowSeparator();
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(this.bodyRowHeight));
  }

  @Builder
  LogicRow() {
    Column() {
      Row() {
        Blank().width(this.s(this.rowLeadingSpace));
        this.FieldLabel('开入量采集逻辑:', this.fieldLabelWidth);
        this.ComboField('开入量采集逻辑:', 'logic_mode', this.comboWidth);
        Blank().width(this.s(this.logicTrailingSpace));
      }
      .width(this.s(this.bodyWidth))
      .height(this.s(this.rowContentHeight))
      .margin({ top: this.s(this.rowTopMargin) })
      .alignItems(VerticalAlign.Center);

      this.RowSeparator();
    }
    .width(this.s(this.bodyWidth))
    .height(this.s(this.bodyRowHeight));
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
  InputField(value: string, onChangeEvent: (value: string) => void) {
    Row() {
      TextInput({ text: value, placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.inputValue))
        .fontColor('#111111')
        .fontFamily('Ubuntu')
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
    .borderRadius(0)
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
        .textOverflow({ overflow: TextOverflow.Clip })
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
    .borderRadius(0)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.handleSelectFieldClick(fieldKey, label);
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
    .width(this.s(this.bodyWidth))
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
    Button(text)
      .width(this.s(110))
      .height(this.s(60))
      .fontSize(this.s(this.fontSize.button))
      .fontColor('#000000')
      .fontFamily(text === this.vm.actions.defaultText ? 'sans-serif-condensed' : 'Ubuntu')
      .fontWeight(text === this.vm.actions.defaultText ? FontWeight.Bold : FontWeight.Regular)
      .backgroundColor('#BEBEBE')
      .border({ width: 0 })
      .borderRadius(this.s(this.bottomButtonRadius))
      .padding(0)
      .onClick(() => {
        onClickEvent();
      });
  }
}





