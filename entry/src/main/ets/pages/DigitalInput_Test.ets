import router from '@ohos.router';
import display from '@ohos.display';
import {
  DigitalInputTestItem,
  createDefaultDigitalInputTestItems
} from '../models/DigitalInputTestData';

@Observed
class DigitalInputTestVM {
  noticeText: string = '';
  titleLeft: string = '装置测试—';
  titleRight: string = '开入测试';
  closeText: string = '关闭';
  backText: string = '返回';
  timeText: string = '2024/12/30\n12:12:30';
}

class DigitalInputTestFontSize {
  notice: number = 18;
  headerTitle: number = 20;
  headerSubTitle: number = 18;
  footerButton: number = 18;
  timeText: number = 18;
  itemLabel: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  timeLineHeight: number = 20;
}

@Entry
@Component
export struct DigitalInput_Test {
  @State vm: DigitalInputTestVM = new DigitalInputTestVM();
  @State items: DigitalInputTestItem[] = createDefaultDigitalInputTestItems();
  @State uiScale: number = 1;

  private readonly fontSize: DigitalInputTestFontSize = new DigitalInputTestFontSize();
  private readonly pageBaseWidth: number = 1024;
  private readonly pageBaseHeight: number = 600;
  private readonly pageMaxWidth: number = 1024;
  private readonly headerHeight: number = 81;
  private readonly footerHeight: number = 91;
  private readonly bodyHeight: number = 428;
  private readonly indicatorSize: number = 30;
  private readonly itemWidth: number = 280;
  private readonly itemHeight: number = 36;
  private readonly footerButtonWidth: number = 111;
  private readonly footerButtonHeight: number = 61;
  private readonly footerButtonRadius: number = 20;

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
  }

  build() {
    Column() {
      this.HeaderBar();
      this.BodyArea();
      this.FooterBar();
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Stack() {
      Text(this.vm.noticeText)
        .width(this.s(291))
        .height(this.s(61))
        .fontSize(this.s(this.fontSize.notice))
        .minFontSize(this.s(this.fontSize.noticeMin))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .position({ x: this.s(10), y: this.s(10) });

      Text(this.vm.titleLeft)
        .width(this.s(151))
        .height(this.s(61))
        .fontSize(this.s(this.fontSize.headerTitle))
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .position({ x: this.s(370), y: this.s(10) });

      Text(this.vm.titleRight)
        .width(this.s(121))
        .height(this.s(61))
        .fontSize(this.s(this.fontSize.headerSubTitle))
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .position({ x: this.s(500), y: this.s(10) });

      Button() {
        Image($r('app.media.return'))
          .width(this.s(37))
          .height(this.s(40));
      }
      .width(this.s(81))
      .height(this.s(51))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .position({ x: this.s(840), y: this.s(20) })
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(32))
          .height(this.s(40));
      }
      .width(this.s(81))
      .height(this.s(51))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .position({ x: this.s(920), y: this.s(20) })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  BodyArea() {
    Stack() {
      ForEach(this.items, (item: DigitalInputTestItem) => {
        this.InputItem(item);
      }, (item: DigitalInputTestItem) => item.key);
    }
    .width('100%')
    .height(this.s(this.bodyHeight))
    .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  InputItem(item: DigitalInputTestItem) {
    Row() {
      Image(item.checked ? $r('app.media.DI_On') : $r('app.media.DI_Off'))
        .width(this.s(this.indicatorSize))
        .height(this.s(this.indicatorSize))
        .margin({ right: this.s(8) });

      Text(item.label)
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.itemLabel))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start)
        .maxLines(1);
    }
    .width(this.s(this.itemWidth))
    .height(this.s(this.itemHeight))
    .alignItems(VerticalAlign.Center)
    .opacity(item.enabled ? 1 : 0.95)
    .position({ x: this.s(item.x), y: this.s(item.y) });
  }

  @Builder
  FooterBar() {
    Stack() {
      this.FooterButton(this.vm.closeText, this.s(260), () => {
        router.back();
      });

      this.FooterButton(this.vm.backText, this.s(650), () => {
        router.back();
      });

      Text(this.vm.timeText)
        .width(this.s(211))
        .height(this.s(71))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center)
        .position({ x: this.s(830), y: this.s(10) });
    }
    .width('100%')
    .height(this.s(this.footerHeight))
    .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  FooterButton(text: string, left: number, clickAction: () => void) {
    Button() {
      Text(text)
        .fontSize(this.s(this.fontSize.footerButton))
        .fontColor('#000000')
        .fontFamily('STKaiti');
    }
    .width(this.s(this.footerButtonWidth))
    .height(this.s(this.footerButtonHeight))
    .padding(0)
    .backgroundColor('#BEBEBE')
    .border({ width: 0 })
    .borderRadius(this.s(this.footerButtonRadius))
    .position({ x: left, y: this.s(20) })
    .onClick(() => {
      clickAction();
    });
  }
}
