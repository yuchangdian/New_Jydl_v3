import router from '@ohos.router';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import {
  DigitalOutputTestItem,
  createDefaultDigitalOutputTestItems,
  deserializeDigitalOutputTestItems,
  serializeDigitalOutputTestItems
} from '../models/DigitalOutputTestData';

interface AbilityFileContext {
  filesDir: string;
}

@Observed
class DigitalOutputTestVM {
  noticeText: string = '';
  titleLeft: string = '装置测试—';
  titleRight: string = '开入测试';
  confirmText: string = '确认';
  closeText: string = '关闭';
  backText: string = '返回';
  timeText: string = '2024/12/30\n12:12:30';
}

class DigitalOutputTestFontSize {
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
export struct DigitalOutput_Test {
  @State vm: DigitalOutputTestVM = new DigitalOutputTestVM();
  @State items: DigitalOutputTestItem[] = createDefaultDigitalOutputTestItems();
  @State uiScale: number = 1;

  private readonly fontSize: DigitalOutputTestFontSize = new DigitalOutputTestFontSize();
  private readonly pageBaseWidth: number = 1024;
  private readonly pageBaseHeight: number = 600;
  private readonly pageMaxWidth: number = 1024;
  private readonly headerHeight: number = 81;
  private readonly footerHeight: number = 91;
  private readonly bodyHeight: number = 428;
  private readonly indicatorSize: number = 30;
  private readonly itemWidth: number = 230;
  private readonly itemHeight: number = 36;
  private readonly footerButtonWidth: number = 110;
  private readonly footerButtonHeight: number = 60;
  private readonly footerButtonRadius: number = 20;
  private readonly dataFileName: string = 'digital_output_test.json';

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
      let restored = deserializeDigitalOutputTestItems(raw);
      if (restored) {
        this.items = restored;
      }
    } catch (error) {
      console.error(`load digital output test data failed: ${JSON.stringify(error)}`);
    }
  }

  private savePersistedData(): void {
    try {
      let dataFilePath = this.getDataFilePath();
      let file = fs.openSync(dataFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, serializeDigitalOutputTestItems(this.items), { encoding: 'utf-8' });
      } finally {
        fs.closeSync(file);
      }
    } catch (error) {
      console.error(`save digital output test data failed: ${JSON.stringify(error)}`);
    }
  }

  private toggleItem(item: DigitalOutputTestItem): void {
    item.checked = !item.checked;
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
      ForEach(this.items, (item: DigitalOutputTestItem) => {
        this.OutputItem(item);
      }, (item: DigitalOutputTestItem) => item.key);
    }
    .width('100%')
    .height(this.s(this.bodyHeight))
    .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  OutputItem(item: DigitalOutputTestItem) {
    Row() {
      Image(item.checked ? $r('app.media.checked') : $r('app.media.unchecked'))
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
    .position({ x: this.s(item.x), y: this.s(item.y) })
    .onClick(() => {
      this.toggleItem(item);
    });
  }

  @Builder
  FooterBar() {
    Stack() {
      this.FooterButton(this.vm.confirmText, this.s(245), () => {
        this.savePersistedData();
      });

      this.FooterButton(this.vm.closeText, this.s(450), () => {
        router.back();
      });

      this.FooterButton(this.vm.backText, this.s(655), () => {
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
