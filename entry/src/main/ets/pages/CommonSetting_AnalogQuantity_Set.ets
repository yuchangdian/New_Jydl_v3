import router from '@ohos.router';
import display from '@ohos.display';

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
  columnHeader: number = 18;
  fieldLabel: number = 16;
  inputValue: number = 16;
  unit: number = 16;
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

  private readonly fontSize: CommonSettingAnalogQuantityFontSize = new CommonSettingAnalogQuantityFontSize();
  private readonly pageMaxWidth: number = 1042;
  private readonly pageBaseWidth: number = 1024;
  private readonly pageBaseHeight: number = 600;
  private readonly headerHeight: number = 70;
  private readonly bottomBarHeight: number = 70;
  private readonly contentMinHeight: number = 617;
  private readonly contentBottomPadding: number = 200;
  private readonly columnHeaderHeight: number = 42;
  private readonly rowHeight: number = 48;
  private readonly signalLabelWidth: number = 150;
  private readonly fieldInputWidth: number = 76;
  private readonly fieldHeight: number = 35;
  private readonly fieldUnitWidth: number = 16;
  private readonly fieldSpacing: number = 2;
  private readonly fieldGroupWidth: number = 94;
  private readonly labelColumnWeight: number = 15;
  private readonly fieldColumnWeight: number = 10;
  private readonly gapColumnWeight: number = 1;
  private readonly sectionGapWeight: number = 3;
  private readonly labelCellPadding: number = 6;
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
      this.uiScale = scale > 0 ? scale : 1;
    } catch (error) {
      this.uiScale = 1;
    }
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
}
