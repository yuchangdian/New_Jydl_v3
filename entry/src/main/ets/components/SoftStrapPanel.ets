import router from '@ohos.router';

export type StrapMode = 'in' | 'out';

const FONT_NORMAL: number = 20;      // 普通文字
const FONT_TITLE: number = 24;       // 标题文字（分组标题、页标题）
const CHECKBOX_SIZE: number = 20;    // 普通勾选框
const MODE_CHECKBOX_SIZE: number = 22; // 顶部“投入/退出”勾选框
const TOP_BOTTOM_PERCENT: string = '10%';

@Component
struct CheckLabel {
  @Prop text: string;
  @Prop keyName: string = '';
  @Prop checked: boolean = true;
  @Prop itemWidth: Length = 'auto'; // 不要叫 width，避免和 width() 冲突
  @Prop leftSpace: number = 0;

  getCbName(): string {
    if (this.keyName !== '') {
      return this.keyName;
    }
    return this.text;
  }

  build() {
    Row() {
      Checkbox({ name: this.getCbName() })
        .select(this.checked)
        .width(CHECKBOX_SIZE)
        .height(CHECKBOX_SIZE)
        .selectedColor('#000000')

      Text(this.text)
        .fontSize(FONT_NORMAL)
        .fontColor('#000000')
        .margin({ left: 8 })
    }
    .width(this.itemWidth)
    .margin({ left: this.leftSpace, top: 1, bottom: 1 })
    .alignItems(VerticalAlign.Center)
  }
}

@Component
struct DashLine {
  build() {
    Row()
      .width('100%')
      .height(1)
      .border({
        width: { top: 1 },
        color: { top: '#5d5d5d' },
        style: { top: BorderStyle.Dashed }
      })
      .opacity(0.85)
  }
}

@Builder
function SectionTitle(title: string, titleWidth: Length = 195) {
  Text(title)
    .fontSize(FONT_TITLE)
    .fontWeight(FontWeight.Bold)
    .fontColor('#000000')
    .width(titleWidth)
}

@Component
export struct SoftStrapPanel {
  // ===== 可复用参数（仅基础类型/对象，不传函数）=====
  @Prop panelTitle: string = '运行操作—软压板投退';
  @Prop showBorder: boolean = true;
  @Prop showBottomBar: boolean = true;

  // 控制按钮行为：嵌入其他页面时可关掉自动 back
  @Prop autoBackOnClose: boolean = true;
  @Prop autoBackOnBack: boolean = true;

  @State modeIn: boolean = true;
  @State modeOut: boolean = false;
  @State showDirtyTip: boolean = true;

  @State dateStr: string = '2024/12/30';
  @State timeStr: string = '12:12:30';

  aboutToAppear(): void {
    this.refreshTimeOnce();
  }

  refreshTimeOnce(): void {
    const d = new Date();

    const y: number = d.getFullYear();
    const m: number = d.getMonth() + 1;
    const day: number = d.getDate();
    const hh: number = d.getHours();
    const mm: number = d.getMinutes();
    const ss: number = d.getSeconds();

    const mStr: string = m < 10 ? '0' + m : '' + m;
    const dStr: string = day < 10 ? '0' + day : '' + day;
    const hhStr: string = hh < 10 ? '0' + hh : '' + hh;
    const mmStr: string = mm < 10 ? '0' + mm : '' + mm;
    const ssStr: string = ss < 10 ? '0' + ss : '' + ss;

    this.dateStr = '' + y + '/' + mStr + '/' + dStr;
    this.timeStr = '' + hhStr + ':' + mmStr + ':' + ssStr;
  }

  getCurrentMode(): StrapMode {
    if (this.modeOut) {
      return 'out';
    }
    return 'in';
  }

  build() {
    Column() {
      this.HeaderBar()
/*
      Column() {Column() {
        this.PublicSection()
      }
      .width('100%')
      .constraintSize({ minHeight: TOP_BOTTOM_PERCENT })
      .justifyContent(FlexAlign.Center)
*/
      Column() {
        this.PublicSection()
        DashLine().margin({ top: 1, bottom: 1 })

        this.VerticalSection()
        DashLine().margin({ top: 1, bottom: 1 })

        this.OverCurrentSection()
        DashLine().margin({ top: 1, bottom: 1 })

        this.ZeroCurrentSection()
        DashLine().margin({ top: 1, bottom: 1 })

        this.AdaptiveZeroSection()
        DashLine().margin({ top: 1, bottom: 1 })

        this.MixedProtectionSection()
        DashLine().margin({ top: 1, bottom: 1 })
/*
        Column() {
          this.GOOSESection()
        }
        .width('100%')
        .constraintSize({ minHeight: TOP_BOTTOM_PERCENT })
        .justifyContent(FlexAlign.Center)
*/
        this.GOOSESection()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 10, right: 10, top: 1, bottom: 1 })

      if (this.showBottomBar) {
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .border(this.showBorder ? { width: 2, color: '#000000' } : { width: 0 })
    .backgroundColor('#f8f8f8')
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.showDirtyTip ? '温馨提醒：软压板已被改动!' : ' ')
        .fontColor('#ff0000')
        .fontSize(FONT_NORMAL)
        .fontStyle(FontStyle.Italic)
        .width('35%')

      Text(this.panelTitle)
        .fontSize(FONT_TITLE)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      Row() {
        Row() {
          Checkbox({ name: 'softstrap_mode_in' })
            .select(this.modeIn)
            .width(MODE_CHECKBOX_SIZE)
            .height(MODE_CHECKBOX_SIZE)
            .selectedColor('#000000')
            .onChange((v: boolean) => {
              if (v) {
                this.modeIn = true;
                this.modeOut = false;
                this.showDirtyTip = true;
              } else if (!this.modeOut) {
                this.modeIn = true;
              }
            })

          Text('投入')
            .fontSize(FONT_NORMAL)
            .fontColor('#000000')
            .margin({ left: 6 })
        }
        .alignItems(VerticalAlign.Center)

        Blank().width(10)

        Row() {
          Checkbox({ name: 'softstrap_mode_out' })
            .select(this.modeOut)
            .width(18)
            .height(18)
            .selectedColor('#000000')
            .onChange((v: boolean) => {
              if (v) {
                this.modeOut = true;
                this.modeIn = false;
                this.showDirtyTip = true;
              } else if (!this.modeIn) {
                this.modeOut = true;
              }
            })

          Text('退出')
            .fontSize(FONT_NORMAL)
            .fontColor('#000000')
            .margin({ left: 6 })
        }
        .alignItems(VerticalAlign.Center)

        Blank().width(18)

        Text('↩')
          .fontSize(FONT_TITLE)
          .fontColor('#111111')
          .margin({ right: 18 })
          .onClick(() => {
            this.showDirtyTip = false;
            // 后续你要做真正“撤销”逻辑，再迭代
          })

        Text('╳')
          .fontSize(FONT_TITLE)
          .fontColor('#111111')
          .onClick(() => {
            if (this.autoBackOnClose) {
              router.back();
            }
          })
      }
      .width('30%')
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('12%')
    .padding({ left: 20, right: 20, top: 6, bottom: 6 })
    .backgroundColor('#d0d3d8')
  }

  @Builder
  PublicSection() {
    Row() {
      SectionTitle('公共:')
      CheckLabel({ text: '远方投退软压板', keyName: 'pub_remote_onoff' })
      CheckLabel({ text: '远方修改定值', keyName: 'pub_remote_set', leftSpace: 30 })
      CheckLabel({ text: '远方切换定值区', keyName: 'pub_remote_area', leftSpace: 30 })
      CheckLabel({ text: '遥控', keyName: 'pub_remote_ctrl', leftSpace: 44 })
    }
    .width('100%')
  }

  @Builder
  VerticalSection() {
    Row() {
      SectionTitle('纵联保护:')
      CheckLabel({ text: '分相电流差动保护', keyName: 'ver_phase_diff' })
      CheckLabel({ text: '零序纵联保护', keyName: 'ver_zero_link', leftSpace: 35 })
      CheckLabel({ text: '低频减载保护', keyName: 'ver_lf_shed', leftSpace: 65 })
    }
    .width('100%')
  }

  @Builder
  OverCurrentSection() {
    Row() {
      SectionTitle('过电流保护:')
      CheckLabel({ text: 'I 段', keyName: 'oc_1' })
      CheckLabel({ text: 'II 段', keyName: 'oc_2', leftSpace: 28 })
      CheckLabel({ text: 'III段', keyName: 'oc_3', leftSpace: 28 })
      CheckLabel({ text: '反时限', keyName: 'oc_inv', leftSpace: 28 })
      CheckLabel({ text: 'PT断线相过流', keyName: 'oc_pt', leftSpace: 28 })
      CheckLabel({ text: '加速段', keyName: 'oc_fast', leftSpace: 28 })
    }
    .width('100%')
  }

  @Builder
  ZeroCurrentSection() {
    Row() {
      SectionTitle('零序过流保护:')
      CheckLabel({ text: 'I 段', keyName: 'zoc_1' })
      CheckLabel({ text: 'II 段', keyName: 'zoc_2', leftSpace: 28 })
      CheckLabel({ text: 'III段', keyName: 'zoc_3', leftSpace: 28 })
      CheckLabel({ text: '反时限', keyName: 'zoc_inv', leftSpace: 28 })
      CheckLabel({ text: '加速段', keyName: 'zoc_fast', leftSpace: 28 })
    }
    .width('100%')
  }

  @Builder
  AdaptiveZeroSection() {
    Row() {
      SectionTitle('自适应零序过流保护:', 292)
      CheckLabel({ text: 'I 段', keyName: 'az_1' })
      CheckLabel({ text: 'II 段', keyName: 'az_2', leftSpace: 28 })
      CheckLabel({ text: 'III段', keyName: 'az_3', leftSpace: 28 })
      CheckLabel({ text: '反时限', keyName: 'az_inv', leftSpace: 28 })
      CheckLabel({ text: '加速段', keyName: 'az_fast', leftSpace: 28 })
    }
    .width('100%')
  }

  @Builder
  MixedProtectionSection() {
    Column() {
      Row() {
        CheckLabel({ text: '母线保护', keyName: 'mix_bus', itemWidth: '20%' })
        CheckLabel({ text: '停用重合闸', keyName: 'mix_reclose_off', itemWidth: '20%' })
        CheckLabel({ text: '过负荷保护', keyName: 'mix_overload', itemWidth: '20%' })
        CheckLabel({ text: '低电压保护', keyName: 'mix_uv', itemWidth: '20%' })
        CheckLabel({ text: '过电压保护', keyName: 'mix_ov', itemWidth: '20%' })
      }

      Row() {
        CheckLabel({ text: '低频保护', keyName: 'mix_lf', itemWidth: '20%' })
        CheckLabel({ text: '高频保护', keyName: 'mix_hf', itemWidth: '20%' })
        CheckLabel({ text: '逆功率保护', keyName: 'mix_rev_power', itemWidth: '20%' })
        CheckLabel({ text: '谐波电流保护', keyName: 'mix_harm_i', itemWidth: '20%' })
        CheckLabel({ text: '谐波电压保护', keyName: 'mix_harm_u', itemWidth: '20%' })
      }
      .margin({ top: -10 })
    }
    .width('100%')
  }

  @Builder
  GOOSESection() {
    Column() {
      Row() {
        SectionTitle('GOOSE保护:')
        CheckLabel({ text: '过负荷保护', keyName: 'goose_overload', itemWidth: '19%' })
        CheckLabel({ text: '低电压保护', keyName: 'goose_uv', itemWidth: '19%' })
        CheckLabel({ text: '过电压保护', keyName: 'goose_ov', itemWidth: '19%' })
        CheckLabel({ text: '低频保护', keyName: 'goose_lf', itemWidth: '19%' })
      }

      Row() {
        Blank().width(195)
        CheckLabel({ text: '高频保护', keyName: 'goose_hf', itemWidth: '19%' })
        CheckLabel({ text: '逆功率保护', keyName: 'goose_rev_power', itemWidth: '19%' })
        CheckLabel({ text: '谐波电流保护', keyName: 'goose_harm_i', itemWidth: '19%' })
        CheckLabel({ text: '谐波电压保护', keyName: 'goose_harm_u', itemWidth: '19%' })
      }
      .margin({ top: -12 })
    }
    .width('100%')
  }

  @Builder
  BottomBar() {
    Row() {
      Row() {
        Button('确认')
          .fontSize(FONT_NORMAL)
          .width(140)
          .height(42)
          .backgroundColor('#d0d3d8')
          .fontColor('#000000')
          .margin({ right: 44 })
          .onClick(() => {
            console.info('SoftStrapPanel confirm mode=' + this.getCurrentMode());
          })

        Button('关闭')
          .fontSize(FONT_NORMAL)
          .width(140)
          .height(42)
          .backgroundColor('#d0d3d8')
          .fontColor('#000000')
          .margin({ right: 44 })
          .onClick(() => {
            if (this.autoBackOnClose) {
              router.back();
            }
          })

        Button('返回')
          .fontSize(FONT_NORMAL)
          .width(140)
          .height(42)
          .backgroundColor('#d0d3d8')
          .fontColor('#000000')
          .onClick(() => {
            if (this.autoBackOnBack) {
              router.back();
            }
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.dateStr).fontSize(FONT_NORMAL)
        Text(this.timeStr).fontSize(FONT_NORMAL).margin({ top: 2 })
      }
      .width(160)
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height('12%')
    .padding({ left: 20, right: 20, top: 4, bottom: 4 })
    .backgroundColor('#d0d3d8')
  }
}