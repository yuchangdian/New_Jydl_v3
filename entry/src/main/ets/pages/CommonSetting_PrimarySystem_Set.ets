import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import {
  CommonSettingPrimarySystemData,
  COMMON_SETTING_PRIMARY_SYSTEM_CT_CONNECTION_OPTIONS,
  COMMON_SETTING_PRIMARY_SYSTEM_LINE_PHASE_OPTIONS,
  COMMON_SETTING_PRIMARY_SYSTEM_ZERO_CURRENT_OPTIONS,
  createDefaultCommonSettingPrimarySystemData,
  deserializeCommonSettingPrimarySystemData,
  serializeCommonSettingPrimarySystemData
} from '../models/CommonSettingPrimarySystemData';

interface AbilityFileContext {
  filesDir: string;
}

@Observed
class BottomActionState {
  defaultText: string = '默认值';
  submitText: string = '提交';
  backText: string = '返回';
}

@Observed
class CommonSettingPrimarySystemVM {
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定一次系统参数';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class CommonSettingPrimarySystemFontSize {
  notice: number = 18;
  title: number = 20;
  sectionTitle: number = 18;
  fieldLabel: number = 18;
  inputValue: number = 16;
  fieldUnit: number = 18;
  dialogTitle: number = 18;
  dialogBody: number = 18;
  bottomButton: number = 18;
  timeText: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  arrow: number = 11;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct CommonSetting_PrimarySystem_Set {
  @State vm: CommonSettingPrimarySystemVM = new CommonSettingPrimarySystemVM();
  @State formData: CommonSettingPrimarySystemData = createDefaultCommonSettingPrimarySystemData();
  @State uiScale: number = 1;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '';
  @State selectOverlayFieldKey: string = '';
  @State selectOverlayValue: string = '';
  @State selectOverlayOptions: string[] = [];
  @State feedbackDialogVisible: boolean = false;
  @State feedbackMessage: string = '';

  private readonly fontSize: CommonSettingPrimarySystemFontSize = new CommonSettingPrimarySystemFontSize();
  private readonly rowHeight: number = 54;
  private readonly separatorSpace: number = 12;
  private readonly separatorStroke: number = 3;
  private readonly inputHeight: number = 35;
  private readonly inputWidth: number = 117;
  private readonly bottomButtonHeight: number = 55;
  private readonly bottomButtonRadius: number = 12;
  private readonly pageMaxWidth: number = 1155;
  private readonly titleIconSize: number = 24;
  private readonly linePhaseBoxWidth: number = 96;
  private readonly modeBoxWidth: number = 100;
  private readonly scrollContentRightPadding: number = 78;
  private readonly separatorColor: string = '#9E9E9E';
  private readonly fieldBorderColor: string = '#B8B8B8';
  private readonly fieldBackgroundColor: string = '#FFFFFF';
  private readonly overlayCardWidth: number = 320;
  private readonly overlayCardRadius: number = 10;
  private readonly dataFileName: string = 'common_setting_primary_system.json';

  private readonly linePhaseOptions: string[] = COMMON_SETTING_PRIMARY_SYSTEM_LINE_PHASE_OPTIONS;
  private readonly ctConnectionOptions: string[] = COMMON_SETTING_PRIMARY_SYSTEM_CT_CONNECTION_OPTIONS;
  private readonly zeroCurrentOptions: string[] = COMMON_SETTING_PRIMARY_SYSTEM_ZERO_CURRENT_OPTIONS;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let val = Math.min(sx, sy);
      this.uiScale = val > 0 ? val : 1;
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
      let restored = deserializeCommonSettingPrimarySystemData(raw);
      if (restored) {
        this.formData = restored;
      }
    } catch (error) {
      console.error(`load primary system data failed: ${JSON.stringify(error)}`);
    }
  }

  private savePersistedData(): boolean {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeCommonSettingPrimarySystemData(this.formData), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
      return true;
    } catch (error) {
      console.error(`save primary system data failed: ${JSON.stringify(error)}`);
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

  private getInputValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'bus_pt_primary':
        return this.formData.busPtPrimary;
      case 'bus_pt_secondary':
        return this.formData.busPtSecondary;
      case 'bus_zero_pt_primary':
        return this.formData.busZeroPtPrimary;
      case 'bus_zero_pt_secondary':
        return this.formData.busZeroPtSecondary;
      case 'line_pt_primary':
        return this.formData.linePtPrimary;
      case 'line_pt_secondary':
        return this.formData.linePtSecondary;
      case 'protect_ct_primary':
        return this.formData.protectCtPrimary;
      case 'protect_ct_secondary':
        return this.formData.protectCtSecondary;
      case 'zero_ct_primary':
        return this.formData.zeroCtPrimary;
      case 'zero_ct_secondary':
        return this.formData.zeroCtSecondary;
      case 'measure_ct_primary':
        return this.formData.measureCtPrimary;
      case 'measure_ct_secondary':
        return this.formData.measureCtSecondary;
      case 'rated_power':
        return this.formData.ratedPower;
      default:
        return '';
    }
  }

  private setInputValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'bus_pt_primary':
        this.formData.busPtPrimary = value;
        break;
      case 'bus_pt_secondary':
        this.formData.busPtSecondary = value;
        break;
      case 'bus_zero_pt_primary':
        this.formData.busZeroPtPrimary = value;
        break;
      case 'bus_zero_pt_secondary':
        this.formData.busZeroPtSecondary = value;
        break;
      case 'line_pt_primary':
        this.formData.linePtPrimary = value;
        break;
      case 'line_pt_secondary':
        this.formData.linePtSecondary = value;
        break;
      case 'protect_ct_primary':
        this.formData.protectCtPrimary = value;
        break;
      case 'protect_ct_secondary':
        this.formData.protectCtSecondary = value;
        break;
      case 'zero_ct_primary':
        this.formData.zeroCtPrimary = value;
        break;
      case 'zero_ct_secondary':
        this.formData.zeroCtSecondary = value;
        break;
      case 'measure_ct_primary':
        this.formData.measureCtPrimary = value;
        break;
      case 'measure_ct_secondary':
        this.formData.measureCtSecondary = value;
        break;
      case 'rated_power':
        this.formData.ratedPower = value;
        break;
      default:
        break;
    }
  }

  private getSelectValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'line_phase':
        return this.formData.linePhase;
      case 'ct_connection':
        return this.formData.ctConnectionMode;
      case 'zero_current_mode':
        return this.formData.zeroCurrentMode;
      default:
        return '';
    }
  }

  private setSelectValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'line_phase':
        this.formData.linePhase = value;
        break;
      case 'ct_connection':
        this.formData.ctConnectionMode = value;
        break;
      case 'zero_current_mode':
        this.formData.zeroCurrentMode = value;
        break;
      default:
        break;
    }
  }

  private getSelectOptions(fieldKey: string): string[] {
    switch (fieldKey) {
      case 'line_phase':
        return this.linePhaseOptions;
      case 'ct_connection':
        return this.ctConnectionOptions;
      case 'zero_current_mode':
        return this.zeroCurrentOptions;
      default:
        return [];
    }
  }

  private cycleSelectValue(fieldKey: string): void {
    let currentValue = this.getSelectValue(fieldKey);
    let options = this.getSelectOptions(fieldKey);
    let index = options.findIndex((item: string) => item === currentValue);
    if (options.length === 0) {
      return;
    }
    let nextIndex = index >= 0 && index < options.length - 1 ? index + 1 : 0;
    this.setSelectValue(fieldKey, options[nextIndex]);
  }

  private shouldOpenSelectOverlay(fieldKey: string): boolean {
    return fieldKey === 'line_phase' || fieldKey === 'ct_connection';
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
    if (this.shouldOpenSelectOverlay(fieldKey)) {
      this.openSelectOverlay(fieldKey, label);
      return;
    }
    this.cycleSelectValue(fieldKey);
  }

  private resetDefaults(): void {
    this.formData = createDefaultCommonSettingPrimarySystemData();
  }

  private submitCurrentData(): void {
    let saveSuccess = this.savePersistedData();
    this.showFeedback(saveSuccess ? '提交成功' : '提交失败');
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Column() {
          this.HeaderBar();

          Scroll() {
            Column() {
              this.StandardRatedRow('母线PT', 'bus_pt_primary', 'kV', 'bus_pt_secondary', 'V');
              this.SeparatorRow();
              this.StandardRatedRow('母线零序PT', 'bus_zero_pt_primary', 'kV', 'bus_zero_pt_secondary', 'V');
              this.SeparatorRow();
              this.LinePtRow();
              this.SeparatorRow();
              this.StandardRatedRow('保护CT', 'protect_ct_primary', 'A', 'protect_ct_secondary', 'A');
              this.SeparatorRow();
              this.StandardRatedRow('零序CT', 'zero_ct_primary', 'A', 'zero_ct_secondary', 'A');
              this.SeparatorRow();
              this.StandardRatedRow('测量CT', 'measure_ct_primary', 'A', 'measure_ct_secondary', 'A');
              this.SeparatorRow();
              this.ModeAndCapacityRow();
              Blank().height(this.s(200));
            }
            .width('100%')
            .padding({ right: this.s(this.scrollContentRightPadding) })
            .constraintSize({ minHeight: this.s(700) });
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
        .maxLines(1)
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

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
    .height(this.s(70))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
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
    .height(this.s(this.separatorSpace))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  StandardRatedRow(title: string, primaryField: string, primaryUnit: string, secondaryField: string, secondaryUnit: string) {
    Row() {
      this.TitleBlock(title, 10);
      Blank().layoutWeight(3);
      this.RatedFieldBlock('一次额定值:', primaryField, primaryUnit, 13);
      Blank().layoutWeight(3);
      this.RatedFieldBlock('二次额定值:', secondaryField, secondaryUnit, 13);
      Blank().layoutWeight(10);
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  LinePtRow() {
    Row() {
      this.TitleBlock('线路PT', 10);
      Blank().layoutWeight(3);
      this.RatedFieldBlock('一次额定值:', 'line_pt_primary', 'kV', 13);
      Blank().layoutWeight(3);
      this.RatedFieldBlock('二次额定值:', 'line_pt_secondary', 'V', 13);
      Blank().layoutWeight(3);
      this.SelectFieldBlock('相别:', 'line_phase', 7, this.s(this.linePhaseBoxWidth));
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ModeAndCapacityRow() {
    Row() {
      this.SelectFieldBlock('CT接线方式:', 'ct_connection', 70, this.s(this.modeBoxWidth));
      Blank().layoutWeight(9);
      this.SelectFieldBlock('零序电流采集模式:', 'zero_current_mode', 100, this.s(this.modeBoxWidth));
      Blank().layoutWeight(20);
      this.CapacityFieldBlock();
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  TitleBlock(title: string, blockWeight: number) {
    Row() {
      Image($r('app.media.right_black'))
        .width(this.s(this.titleIconSize))
        .height(this.s(this.titleIconSize))
        .margin({ right: this.s(6) });

      Text(title)
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.sectionTitle))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .textAlign(TextAlign.Start);
    }
    .layoutWeight(blockWeight)
    .height('100%')
    .padding({ left: this.s(6), right: this.s(6) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  RatedFieldBlock(label: string, fieldKey: string, unit: string, blockWeight: number) {
    Row() {
      Text(label)
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .margin({ right: this.s(8) });

      this.InputField(fieldKey);

      Text(unit)
        .width(this.s(28))
        .fontSize(this.s(this.fontSize.fieldUnit))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(6) });
    }
    .layoutWeight(blockWeight)
    .height('100%')
    .alignItems(VerticalAlign.Center);
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
  SelectFieldBlock(label: string, fieldKey: string, blockWeight: number, boxWidth: number) {
    Row() {
      Text(label)
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .maxLines(1)
        .margin({ right: this.s(6) });

      this.ComboField(label, fieldKey, boxWidth);
    }
    .layoutWeight(blockWeight)
    .height('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ComboField(label: string, fieldKey: string, boxWidth: number) {
    Row() {
      Text(this.getSelectValue(fieldKey))
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
    .width(boxWidth)
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
  CapacityFieldBlock() {
    Row() {
      Text('线路额定容量')
        .fontSize(this.s(this.fontSize.fieldLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .margin({ right: this.s(8) });

      this.InputField('rated_power');

      Text('kVA')
        .width(this.s(38))
        .fontSize(this.s(this.fontSize.fieldUnit))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Center)
        .margin({ left: this.s(6) });
    }
    .layoutWeight(100)
    .height('100%')
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
      Blank().layoutWeight(5);

      Button(this.vm.actions.defaultText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.bottomButton))
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

      Blank().layoutWeight(15);

      Button(this.vm.actions.submitText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.bottomButton))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          this.submitCurrentData();
        });

      Blank().layoutWeight(10);

      Button(this.vm.actions.backText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.bottomButton))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(20);

      Text(this.vm.timeText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(70))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
