import router from '@ohos.router';
import display from '@ohos.display';
import { cloneDigitalInputTestItem, DigitalInputTestItem, createDefaultDigitalInputTestItems } from '../models/DigitalInputTestData';

class DigitalInputTestTextConfig {
  noticeText: string = '';
  titleLeft: string = '装置测试—';
  titleRight: string = '开入测试';
  closeText: string = '关闭';
  backText: string = '返回';
  timeText: string = '2024/12/30\n12:12:30';
}

class DigitalInputTestFontSizeConfig {
  notice: number = 20;
  headerTitle: number = 24;
  headerSubTitle: number = 22;
  footerButton: number = 20;
  timeText: number = 20;
  itemLabel: number = 20;
  checkMark: number = 24;
  titleMin: number = 16;
  noticeMin: number = 14;
  timeLineHeight: number = 22;
}

class DigitalInputTestLayoutConfig {
  pageBaseWidth: number = 1024;
  pageBaseHeight: number = 600;
  pageMaxWidth: number = 1024;
  headerHeight: number = 81;
  footerHeight: number = 91;
  bodyHeight: number = 428;
  checkboxSize: number = 30;
  checkboxRadius: number = 0;
  itemWidth: number = 280;
  itemHeight: number = 40;
  footerButtonWidth: number = 118;
  footerButtonHeight: number = 62;
  footerButtonRadius: number = 24;
}

class DigitalInputTestPageConfig {
  text: DigitalInputTestTextConfig = new DigitalInputTestTextConfig();
  fontSize: DigitalInputTestFontSizeConfig = new DigitalInputTestFontSizeConfig();
  layout: DigitalInputTestLayoutConfig = new DigitalInputTestLayoutConfig();
}

const DIGITAL_INPUT_TEST_PAGE_CONFIG: DigitalInputTestPageConfig = new DigitalInputTestPageConfig();

@Entry
@Component
export struct DigitalInput_Test {
  @State items: DigitalInputTestItem[] = createDefaultDigitalInputTestItems();
  @State uiScale: number = 1;

  private readonly pageConfig: DigitalInputTestPageConfig = DIGITAL_INPUT_TEST_PAGE_CONFIG;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let currentDisplay = display.getDefaultDisplaySync();
      let scaleX = currentDisplay.width / this.pageConfig.layout.pageBaseWidth;
      let scaleY = currentDisplay.height / this.pageConfig.layout.pageBaseHeight;
      let scale = Math.min(scaleX, scaleY);
      this.uiScale = scale > 0 ? scale : 1;
    } catch (error) {
      this.uiScale = 1;
    }
  }

  private setItemChecked(key: string, checked: boolean): void {
    this.items = this.items.map((item: DigitalInputTestItem) => {
      let nextItem = cloneDigitalInputTestItem(item);
      if (nextItem.key === key) {
        nextItem.state.checked = checked;
      }
      return nextItem;
    });
  }

  private toggleItem(key: string): void {
    this.items = this.items.map((item: DigitalInputTestItem) => {
      let nextItem = cloneDigitalInputTestItem(item);
      if (nextItem.key === key) {
        nextItem.state.checked = !nextItem.state.checked;
      }
      return nextItem;
    });
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
      Text(this.pageConfig.text.noticeText)
        .width(this.s(291))
        .height(this.s(61))
        .fontSize(this.s(this.pageConfig.fontSize.notice))
        .minFontSize(this.s(this.pageConfig.fontSize.noticeMin))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .position({ x: this.s(10), y: this.s(10) });

      Text(this.pageConfig.text.titleLeft)
        .width(this.s(151))
        .height(this.s(61))
        .fontSize(this.s(this.pageConfig.fontSize.headerTitle))
        .minFontSize(this.s(this.pageConfig.fontSize.titleMin))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .position({ x: this.s(370), y: this.s(10) });

      Text(this.pageConfig.text.titleRight)
        .width(this.s(121))
        .height(this.s(61))
        .fontSize(this.s(this.pageConfig.fontSize.headerSubTitle))
        .minFontSize(this.s(this.pageConfig.fontSize.titleMin))
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
    .height(this.s(this.pageConfig.layout.headerHeight))
    .constraintSize({ maxWidth: this.s(this.pageConfig.layout.pageMaxWidth) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  BodyArea() {
    Stack() {
      ForEach(this.items, (item: DigitalInputTestItem, index: number) => {
        this.InputItem(item);
      }, (item: DigitalInputTestItem, index: number) => `${item.key}_${item.state.checked ? '1' : '0'}_${index}`);
    }
    .width('100%')
    .height(this.s(this.pageConfig.layout.bodyHeight))
    .constraintSize({ maxWidth: this.s(this.pageConfig.layout.pageMaxWidth) })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  CheckBoxIcon(checked: boolean, key: string) {
    Stack({ alignContent: Alignment.Center }) {
      if (checked) {
        Image($r('app.media.checked_black'))
          .width(this.s(this.pageConfig.fontSize.checkMark))
          .height(this.s(this.pageConfig.fontSize.checkMark));
      }
    }
    .width(this.s(this.pageConfig.layout.checkboxSize))
    .height(this.s(this.pageConfig.layout.checkboxSize))
    .border({ width: this.s(2), color: '#000000' })
    .borderRadius(this.s(this.pageConfig.layout.checkboxRadius))
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      this.toggleItem(key);
    });
  }

  @Builder
  InputItem(item: DigitalInputTestItem) {
    Row() {
      this.CheckBoxIcon(item.state.checked, item.key);

      Text(item.label)
        .layoutWeight(1)
        .fontSize(this.s(this.pageConfig.fontSize.itemLabel))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .margin({ left: this.s(10) })
        .onClick(() => {
          this.toggleItem(item.key);
        });
    }
    .width(this.s(this.pageConfig.layout.itemWidth))
    .height(this.s(this.pageConfig.layout.itemHeight))
    .alignItems(VerticalAlign.Center)
    .position({ x: this.s(item.position.x), y: this.s(item.position.y) });
  }

  @Builder
  FooterBar() {
    Stack() {
      this.FooterButton(this.pageConfig.text.closeText, 260, () => {
        router.back();
      });

      this.FooterButton(this.pageConfig.text.backText, 650, () => {
        router.back();
      });

      Text(this.pageConfig.text.timeText)
        .width(this.s(211))
        .height(this.s(71))
        .fontSize(this.s(this.pageConfig.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.pageConfig.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center)
        .position({ x: this.s(830), y: this.s(10) });
    }
    .width('100%')
    .height(this.s(this.pageConfig.layout.footerHeight))
    .constraintSize({ maxWidth: this.s(this.pageConfig.layout.pageMaxWidth) })
    .backgroundColor('#D3D3D3');
  }

  @Builder
  FooterButton(text: string, left: number, clickAction: () => void) {
    Button() {
      Text(text)
        .fontSize(this.s(this.pageConfig.fontSize.footerButton))
        .fontColor('#000000')
        .fontFamily('STKaiti');
    }
    .width(this.s(this.pageConfig.layout.footerButtonWidth))
    .height(this.s(this.pageConfig.layout.footerButtonHeight))
    .padding(0)
    .backgroundColor('#BEBEBE')
    .border({ width: 0 })
    .borderRadius(this.s(this.pageConfig.layout.footerButtonRadius))
    .position({ x: this.s(left), y: this.s(20) })
    .onClick(() => {
      clickAction();
    });
  }
}
