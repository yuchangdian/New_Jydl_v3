import { window } from '@kit.ArkUI'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import { WidebandContent } from './WidebandContent';
import { harmonicContent } from './harmonic';
import { interHarmonicContent } from './interHarmonic';
import { VoltageMonitoring } from './VoltageMonitoring';
import { SequenceMonitoring } from './SequenceMonitoring';
import { VoltageFlickerMonitoring } from './VoltageFlickerMonitoring';
import { PowerQualityReport } from './PowerQualityReport';
import display from '@ohos.display';

@Entry
@Component
struct WidebandPhasorPage {
  windowClass?: window.Window

  @State uiScale: number = 1;
  readonly designWidth: number = 720;

  @State selectedMenuItem: string = "宽频相量";
  @State showContent: boolean = false;

  async initUIScale() {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
  }

  aboutToAppear() {
    this.initUIScale();

    setTimeout(() => {
      this.showContent = true;
    }, 100);
  }

  onPageShow(): void {
  }

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Image($rawfile("icon/icon01.png"))
              .width(18 * this.uiScale)
              .height(18 * this.uiScale)

            Text("实时指标")
              .fontSize(18 * this.uiScale)
              .fontColor('#ffffff')
              .margin({ left: 5 * this.uiScale })
          }
          .width(100 * this.uiScale)
          .backgroundColor('#ff167fff')
          .height(40 * this.uiScale)
          .justifyContent(FlexAlign.Center)

          Column() {
            this.menuItem("宽频相量")
            this.menuItem("谐波")
            this.menuItem("间谐波")
            this.menuItem("偏差")
            this.menuItem("不平衡")
            this.menuItem("波动与闪变")
            this.menuItem("合格率")
          }
          .width(100 * this.uiScale)
        }
        .height('100%')
        .backgroundColor('#F5F5F5')
        // ========== 你原版写法 ==========
        .border({ width: { right: 1 * this.uiScale }, color: '#333333' })

        this.getContent()
      }
      .layoutWeight(1)

      CommonTitleBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  @Builder
  menuItem(name: string) {
    Text(name)
      .width('100%')
      .height(38 * this.uiScale)
      .textAlign(TextAlign.Center)
      .fontSize(18 * this.uiScale)
      .fontColor(this.selectedMenuItem === name ? '#ffff0000' : '#ff0a0a0a')
      // ========== 你原版写法 ==========
      .border({ width: { bottom: 1 * this.uiScale }, color: '#ffc4c4c4' })
      .onClick(() => {
        this.showContent = false;
        this.selectedMenuItem = name;

        setTimeout(() => {
          this.showContent = true;
        }, 0);
      })
  }

  @Builder
  getContent() {
    Column() {
      if (this.showContent) {
        if (this.selectedMenuItem === "宽频相量") {
          WidebandContent()
        } else if (this.selectedMenuItem === "谐波") {
          harmonicContent()
        } else if (this.selectedMenuItem === "间谐波") {
          interHarmonicContent()
        } else if (this.selectedMenuItem === "偏差") {
          VoltageMonitoring()
        } else if (this.selectedMenuItem === "不平衡") {
          SequenceMonitoring()
        } else if (this.selectedMenuItem === "波动与闪变") {
          VoltageFlickerMonitoring()
        } else if (this.selectedMenuItem === "合格率") {
          PowerQualityReport()
        }
      }
    }
    .layoutWeight(1)
    .backgroundColor(Color.White)
  }
}