import router from '@ohos.router';
import display from '@ohos.display';

@Observed
class StrapFlag {
  id: string;
  label: string;
  checked: boolean;
  enabled: boolean;

  constructor(id: string, label: string, checked: boolean = false, enabled: boolean = true) {
    this.id = id;
    this.label = label;
    this.checked = checked;
    this.enabled = enabled;
  }
}

@Observed
class HeaderModeState {
  inMode: StrapFlag = new StrapFlag('checkBox', '投入', true, true);
  outMode: StrapFlag = new StrapFlag('checkBox_2', '退出', false, true);
}

@Observed
class PublicFlags {
  Box_YT_SoftStrap: StrapFlag = new StrapFlag('Box_YT_SoftStrap', '远方投退软压板');
  Box_YT_ModifyingSetting: StrapFlag = new StrapFlag('Box_YT_ModifyingSetting', '远方修改定值');
  Box_YT_ModifyingSettingZone: StrapFlag = new StrapFlag('Box_YT_ModifyingSettingZone', '远方切换定值区');
  Box_YK: StrapFlag = new StrapFlag('Box_YK', '遥控');
}

@Observed
class PilotFlags {
  Box_Pilot_Current: StrapFlag = new StrapFlag('Box_Pilot_Current', '分相电流差动保护');
  Box_Pilot_Io: StrapFlag = new StrapFlag('Box_Pilot_Io', '零序纵联保护');
}

@Observed
class OverCurrentFlags {
  Box_OverCurrent_Z1: StrapFlag = new StrapFlag('Box_OverCurrent_Z1', 'Ⅰ段');
  Box_OverCurrent_Z2: StrapFlag = new StrapFlag('Box_OverCurrent_Z2', 'Ⅱ段');
  Box_OverCurrent_Z3: StrapFlag = new StrapFlag('Box_OverCurrent_Z3', 'Ⅲ段');
  Box_OverCurrent_Inv: StrapFlag = new StrapFlag('Box_OverCurrent_Inv', '反时限');
  Box_OverCurrent_PTBreak: StrapFlag = new StrapFlag('Box_OverCurrent_PTBreak', 'PT断线相过流');
  Box_OverCurrent_Acc: StrapFlag = new StrapFlag('Box_OverCurrent_Acc', '加速段');
}

@Observed
class ZeroOverCurrentFlags {
  Box_Io_Z1: StrapFlag = new StrapFlag('Box_Io_Z1', 'Ⅰ段');
  Box_Io_Z2: StrapFlag = new StrapFlag('Box_Io_Z2', 'Ⅱ段');
  Box_Io_Z3: StrapFlag = new StrapFlag('Box_Io_Z3', 'Ⅲ段');
  Box_Io_Inv: StrapFlag = new StrapFlag('Box_Io_Inv', '反时限');
  Box_Io_Acc: StrapFlag = new StrapFlag('Box_Io_Acc', '加速段');
}

@Observed
class AdaptiveZeroOverCurrentFlags {
  Box_OverCurrent_Z1_2: StrapFlag = new StrapFlag('Box_OverCurrent_Z1_2', 'Ⅰ段');
  three_checkBox_24: StrapFlag = new StrapFlag('three_checkBox_24', 'Ⅱ段');
  three_checkBox_25: StrapFlag = new StrapFlag('three_checkBox_25', 'Ⅲ段');
  checkBox_17: StrapFlag = new StrapFlag('checkBox_17', '反时限');
  three_checkBox_26: StrapFlag = new StrapFlag('three_checkBox_26', '加速段');
}

@Observed
class MixedProtectionFlags {
  Box_Bus: StrapFlag = new StrapFlag('Box_Bus', '母线保护');
  Box_DisableReclosure: StrapFlag = new StrapFlag('Box_DisableReclosure', '停用重合闸');
  Box_OverLoad: StrapFlag = new StrapFlag('Box_OverLoad', '过负荷保护');
  Box_LowVoltage: StrapFlag = new StrapFlag('Box_LowVoltage', '低电压保护');
  Box_OverVoltage: StrapFlag = new StrapFlag('Box_OverVoltage', '过电压保护');
  Box_LowFrequency: StrapFlag = new StrapFlag('Box_LowFrequency', '低频保护');
  Box_HighFrequency: StrapFlag = new StrapFlag('Box_HighFrequency', '高频保护');
  Box_InversePower: StrapFlag = new StrapFlag('Box_InversePower', '逆功率保护');
  Box_HarmonicCurrent: StrapFlag = new StrapFlag('Box_HarmonicCurrent', '谐波电流保护');
  Box_HarmonicVoltage: StrapFlag = new StrapFlag('Box_HarmonicVoltage', '谐波电压保护');
}

@Observed
class GooseProtectionFlags {
  Box_OverLoad_GOOSE: StrapFlag = new StrapFlag('Box_OverLoad_GOOSE', '过负荷保护');
  Box_LowVoltage_GOOSE: StrapFlag = new StrapFlag('Box_LowVoltage_GOOSE', '低电压保护');
  Box_OverVoltage_GOOSE: StrapFlag = new StrapFlag('Box_OverVoltage_GOOSE', '过电压保护');
  Box_LowFrequency_GOOSE: StrapFlag = new StrapFlag('Box_LowFrequency_GOOSE', '低频保护');
  Box_HighFrequency_GOOSE: StrapFlag = new StrapFlag('Box_HighFrequency_GOOSE', '高频保护');
  Box_InversePower_GOOSE: StrapFlag = new StrapFlag('Box_InversePower_GOOSE', '逆功率保护');
  Box_HarmonicCurrent_GOOSE: StrapFlag = new StrapFlag('Box_HarmonicCurrent_GOOSE', '谐波电流保护');
  Box_HarmonicVoltage_GOOSE: StrapFlag = new StrapFlag('Box_HarmonicVoltage_GOOSE', '谐波电压保护');
}

@Observed
class BottomActionState {
  confirmText: string = '确认';
  closeText: string = '关闭';
  backText: string = '返回';
}

@Observed
class SoftStrapVM {
  headerMode: HeaderModeState = new HeaderModeState();
  noticeText: string = '';
  titleLeft: string = '运行操作';
  titleRight: string = '—软压板投退';

  publicFlags: PublicFlags = new PublicFlags();
  pilotFlags: PilotFlags = new PilotFlags();
  overCurrentFlags: OverCurrentFlags = new OverCurrentFlags();
  zeroOverCurrentFlags: ZeroOverCurrentFlags = new ZeroOverCurrentFlags();
  adaptiveZeroFlags: AdaptiveZeroOverCurrentFlags = new AdaptiveZeroOverCurrentFlags();
  mixedFlags: MixedProtectionFlags = new MixedProtectionFlags();
  gooseFlags: GooseProtectionFlags = new GooseProtectionFlags();

  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

@Component
struct QtCheck {
  @ObjectLink item: StrapFlag;
  @Prop boxSize: number = 30;
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#000000';
  @Prop itemWidth: Length = 'auto';
  @Prop fontFamilyName: string = 'STKaiti';

  private toggle(): void {
    if (!this.item.enabled) {
      return;
    }
    this.item.checked = !this.item.checked;
  }

  build() {
    Row() {
      Stack() {
        Row() {}
        .width(this.boxSize)
        .height(this.boxSize)
        .backgroundColor('#FFFFFF')
        .border({ width: 1.4, color: '#000000' })
        .borderRadius(1);

        if (this.item.checked) {
          Text('✓')
            .fontSize(this.boxSize * 0.82)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .width(this.boxSize)
            .height(this.boxSize)
            .textAlign(TextAlign.Center);
        }
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .margin({ right: 6 });

      Text(this.item.label)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontFamily(this.fontFamilyName)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width(this.itemWidth)
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .opacity(this.item.enabled ? 1 : 0.35)
    .onClick(() => {
      this.toggle();
    });
  }
}


@Component
struct QtStaticCheck {
  @Prop checked: boolean = false;
  @Prop label: string = '';
  @Prop boxSize: number = 30;
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#000000';
  @Prop itemWidth: Length = 'auto';
  @Prop fontFamilyName: string = 'STKaiti';

  build() {
    Row() {
      Stack() {
        Row() {}
        .width(this.boxSize)
        .height(this.boxSize)
        .backgroundColor('#FFFFFF')
        .border({ width: 1.4, color: '#000000' })
        .borderRadius(1);

        if (this.checked) {
          Text('✓')
            .fontSize(this.boxSize * 0.82)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .width(this.boxSize)
            .height(this.boxSize)
            .textAlign(TextAlign.Center);
        }
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .margin({ right: 6 });

      Text(this.label)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontFamily(this.fontFamilyName)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width(this.itemWidth)
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start);
  }
}

@Component
struct DashSeparator {
  @Prop dashHeight: number = 1;
  @Prop dashColor: string = '#8E8E8E';
  private dashList: number[] = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35
  ];

  build() {
    Row() {
      ForEach(this.dashList, (item: number, index: number) => {
        Row() {}
        .layoutWeight(1)
        .height(this.dashHeight)
        .backgroundColor(this.dashColor)
        .opacity(0.9);

        if (index !== this.dashList.length - 1) {
          Blank().width(8);
        }
      }, (item: number) => item.toString())
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }
}

@Builder
function SolidLine() {
  Row() {}
  .width('100%')
  .height(1)
  .backgroundColor('#8E8E8E')
  .opacity(0.95);
}

@Builder
function LabelText(text: string, fontSize: number = 16) {
  Text(text)
    .fontSize(fontSize)
    .fontColor('#000000')
    .fontFamily('STKaiti')
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis });
}

@Entry
@Component
export struct SoftStrapSet {
  @State vm: SoftStrapVM = new SoftStrapVM();
  @State uiScale: number = 1;
  @State modeInSelected: boolean = true;

  private readonly checkBoxSize: number = 28;
  private readonly midFontSize: number = 18;
  private readonly titleFontSize: number = 20;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    this.modeInSelected = this.vm.headerMode.inMode.checked;
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let val = Math.min(sx, sy);
      this.uiScale = val > 0 ? val : 1;
    } catch (e) {
      this.uiScale = 1;
    }
  }

  private setMode(isIn: boolean): void {
    this.modeInSelected = isIn;
    this.vm.headerMode.inMode.checked = isIn;
    this.vm.headerMode.outMode.checked = !isIn;
  }

  build() {
    Column() {
      this.HeaderBar();

      Column() {
        this.PublicRow();
        this.SeparatorRow();
        this.PilotRow();
        this.SeparatorRow();
        this.OverCurrentRow();
        this.SeparatorRow();
        this.ZeroOverCurrentRow();
        this.SeparatorRow();
        this.AdaptiveZeroRow();
        this.SeparatorRow();
        this.MixedGrid();
        this.SeparatorRow();
        this.GooseGrid();
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: this.s(10), right: this.s(10), top: this.s(2), bottom: this.s(2) })
      .backgroundColor('#FFFFFF');

      this.BottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  SeparatorRow() {
    Row() {
      SolidLine()
    }
    .width('100%')
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 0, right: 0 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(240)
        .minFontSize(12)
        .maxLines(1)
        .fontSize(this.s(18))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(50);

      Text(this.vm.titleLeft)
        .layoutWeight(120)
        .fontSize(this.s(this.titleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(140)
        .fontSize(this.s(this.titleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(20);

      Row() {
        QtStaticCheck({ checked: this.modeInSelected, label: this.vm.headerMode.inMode.label, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%', fontFamilyName: 'STKaiti' });
      }
      .layoutWeight(100)
      .height('100%')
      .backgroundColor('#00000000')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.setMode(true);
      });

      Row() {
        QtStaticCheck({ checked: !this.modeInSelected, label: this.vm.headerMode.outMode.label, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%', fontFamilyName: 'STKaiti' });
      }
      .layoutWeight(100)
      .height('100%')
      .backgroundColor('#00000000')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.setMode(false);
      });

      Blank().layoutWeight(20);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(24))
          .height(this.s(24));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(20))
          .height(this.s(20));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(10), right: this.s(10), top: this.s(8), bottom: this.s(8) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  PublicRow() {
    Row() {
      Row() { LabelText('公共：', this.s(this.midFontSize)) }
      .layoutWeight(5)
      .height('100%')
      .alignItems(VerticalAlign.Center);
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.publicFlags.Box_YT_SoftStrap, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(8)
      .height('100%');
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.publicFlags.Box_YT_ModifyingSetting, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(7)
      .height('100%');
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.publicFlags.Box_YT_ModifyingSettingZone, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(7)
      .height('100%');
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.publicFlags.Box_YK, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
    }
    .width('100%')
    .layoutWeight(7)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  PilotRow() {
    Row() {
      Row() { LabelText('纵联保护:', this.s(this.midFontSize)) }
      .layoutWeight(5)
      .height('100%')
      .alignItems(VerticalAlign.Center);
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.pilotFlags.Box_Pilot_Current, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(8)
      .height('100%');
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.pilotFlags.Box_Pilot_Io, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(7)
      .height('100%');
      Blank().layoutWeight(15);
    }
    .width('100%')
    .layoutWeight(7)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  OverCurrentRow() {
    Row() {
      Row() { LabelText('过电流保护:', this.s(this.midFontSize)) }
      .layoutWeight(5)
      .height('100%')
      .alignItems(VerticalAlign.Center);
      Blank().layoutWeight(1);
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_Z1, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(4)
      .height('100%');
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_Z2, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(4)
      .height('100%');
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_Z3, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(4)
      .height('100%');
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_Inv, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_PTBreak, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(8)
      .height('100%');
      Row() { QtCheck({ item: this.vm.overCurrentFlags.Box_OverCurrent_Acc, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
    }
    .width('100%')
    .layoutWeight(7)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  ZeroOverCurrentRow() {
    Row() {
      Row() { LabelText('零序过流保护:', this.s(this.midFontSize)) }
      .layoutWeight(7)
      .height('100%')
      .alignItems(VerticalAlign.Center);
      Blank().layoutWeight(2);
      Row() { QtCheck({ item: this.vm.zeroOverCurrentFlags.Box_Io_Z1, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.zeroOverCurrentFlags.Box_Io_Z2, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.zeroOverCurrentFlags.Box_Io_Z3, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.zeroOverCurrentFlags.Box_Io_Inv, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
      Row() { QtCheck({ item: this.vm.zeroOverCurrentFlags.Box_Io_Acc, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
      Blank().layoutWeight(6);
    }
    .width('100%')
    .layoutWeight(7)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  AdaptiveZeroRow() {
    Row() {
      Row() { LabelText('自适应零序过流保护:', this.s(this.midFontSize)) }
      .layoutWeight(9)
      .height('100%')
      .alignItems(VerticalAlign.Center);
      Row() { QtCheck({ item: this.vm.adaptiveZeroFlags.Box_OverCurrent_Z1_2, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.adaptiveZeroFlags.three_checkBox_24, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.adaptiveZeroFlags.three_checkBox_25, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(5)
      .height('100%');
      Row() { QtCheck({ item: this.vm.adaptiveZeroFlags.checkBox_17, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
      Row() { QtCheck({ item: this.vm.adaptiveZeroFlags.three_checkBox_26, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
      .layoutWeight(6)
      .height('100%');
      Blank().layoutWeight(6);
    }
    .width('100%')
    .layoutWeight(7)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  MixedGrid() {
    Column() {
      Row() {
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_Bus, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_DisableReclosure, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_OverLoad, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_LowVoltage, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_OverVoltage, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center);

      Row() {
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_LowFrequency, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_HighFrequency, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_InversePower, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_HarmonicCurrent, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.mixedFlags.Box_HarmonicVoltage, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .layoutWeight(15);
  }

  @Builder
  GooseGrid() {
    Column() {
      Row() {
        Row() { LabelText('GOOSE保护:', this.s(this.midFontSize)) }
        .layoutWeight(8)
        .height('100%')
        .alignItems(VerticalAlign.Center);
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_OverLoad_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_LowVoltage_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_OverVoltage_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_LowFrequency_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center);

      Row() {
        Blank().layoutWeight(8);
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_HighFrequency_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_InversePower_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(7)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_HarmonicCurrent_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
        Blank().layoutWeight(1);
        Row() { QtCheck({ item: this.vm.gooseFlags.Box_HarmonicVoltage_GOOSE, boxSize: this.s(this.checkBoxSize), fontSize: this.s(this.midFontSize), itemWidth: '100%' }) }
        .layoutWeight(8)
        .height('100%');
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .layoutWeight(14);
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(270);

      Button(this.vm.actions.confirmText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 });

      Blank().layoutWeight(80);

      Button(this.vm.actions.closeText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(80);

      Button(this.vm.actions.backText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(100);

      Text(this.vm.timeText)
        .layoutWeight(160)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .padding({ top: this.s(2), bottom: this.s(2) });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ top: this.s(8), bottom: this.s(6) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
