import router from '@ohos.router';
import display from '@ohos.display';

interface MetricItem {
  label: string;
  value: string;
  valueMinWidth?: number;
}

class QualityIndexFontSize {
  headerTitle: number = 22;
  headerSubTitle: number = 20;
  sectionTitle: number = 19;
  metricLabel: number = 19;
  metricValue: number = 19;
  bottomButton: number = 18;
  timeText: number = 18;
  headerNotice: number = 18;
}

@Entry
@Component
export struct QualityIndex {
  @State uiScale: number = 1;
  @State timeText: string = '2024/12/30\n12:12:30';

  private readonly fontSize: QualityIndexFontSize = new QualityIndexFontSize();
  private readonly pageMaxWidth: number = 1024;
  private readonly designWidth: number = 1024;
  private readonly designHeight: number = 600;
  private readonly headerHeight: number = 70;
  private readonly bottomHeight: number = 70;
  private readonly rowHeight: number = 60;
  private readonly bottomButtonHeight: number = 55;
  private readonly bottomButtonRadius: number = 18;
  private readonly sectionIconSize: number = 24;
  private readonly headerSideSlotWidth: number = 120;
  private readonly headerButtonGap: number = 8;
  private readonly headerButtonTouchSize: number = 40;
  private readonly scrollContentRightPadding: number = 88;
  private readonly headerBackgroundColor: string = '#D3D3D3';
  private readonly darkRowColor: string = '#888A85';
  private readonly buttonColor: string = '#BEBEBE';
  private readonly pageBackgroundColor: string = '#FFFFFF';

  private readonly frequencySummary: MetricItem[] = [
    { label: '频率偏差值：', value: '0.02Hz' },
    { label: '频率合格率：', value: '99.99%' }
  ];

  private readonly phaseFrequencyDeviation: MetricItem[] = [
    { label: 'A相频率偏差值:', value: '0.02Hz' },
    { label: 'B相频率偏差值:', value: '0.02Hz' },
    { label: 'C相频率偏差值:', value: '0.02Hz' }
  ];

  private readonly phaseFrequencyPassRate: MetricItem[] = [
    { label: 'A相频率合格率:', value: '99.99%' },
    { label: 'B相频率合格率:', value: '99.99%' },
    { label: 'C相频率合格率:', value: '99.99%' }
  ];

  private readonly voltageSummary: MetricItem[] = [
    { label: '电压偏差值：', value: '0.02Hz' },
    { label: '电压合格率:', value: '99.99%' }
  ];

  private readonly phaseVoltageDeviation: MetricItem[] = [
    { label: 'A相电压偏差值:', value: '0.02Hz' },
    { label: 'B相电压偏差值:', value: '0.02Hz' },
    { label: 'C相电压偏差值:', value: '0.02Hz' }
  ];

  private readonly phaseVoltagePassRate: MetricItem[] = [
    { label: 'A相电压合格率:', value: '99.99%' },
    { label: 'B相电压合格率:', value: '99.99%' },
    { label: 'C相电压合格率:', value: '99.99%' }
  ];

  private readonly lineVoltageDeviation: MetricItem[] = [
    { label: 'AB相电压偏差值:', value: '0.02Hz' },
    { label: 'BA相电压偏差值:', value: '0.02Hz' },
    { label: 'CA相电压偏差值:', value: '0.02Hz' }
  ];

  private readonly lineVoltagePassRate: MetricItem[] = [
    { label: 'AB相电压合格率:', value: '99.99%' },
    { label: 'BA相电压合格率:', value: '99.99%' },
    { label: 'CA相电压合格率:', value: '99.99%' }
  ];

  private readonly voltageUnbalance: MetricItem[] = [
    { label: '不平衡度εU2：', value: '10.95%' },
    { label: '不平衡度εU0：', value: '10.95%' }
  ];

  private readonly currentUnbalance: MetricItem[] = [
    { label: '不平衡度εI2：', value: '0.95%' },
    { label: '不平衡度εI0：', value: '10.95%' }
  ];

  private readonly voltageFluctuation: MetricItem[] = [
    { label: '波动值:', value: '0.12%' },
    { label: '波动频率：', value: '10次/日' }
  ];

  private readonly voltageFlicker: MetricItem[] = [
    { label: '长时间闪变值Plt:', value: '', valueMinWidth: 80 },
    { label: '短时间闪变值Plt:', value: '', valueMinWidth: 80 }
  ];

  private readonly voltageSag: MetricItem[] = [
    { label: 'SARFIX:', value: '', valueMinWidth: 100 },
    { label: 'SARFICURVE:', value: '', valueMinWidth: 100 }
  ];

  private readonly harmonicVoltageTop: MetricItem[] = [
    { label: 'A相电压：', value: '0.11%' },
    { label: 'B相电压：', value: '0.11%' },
    { label: 'C相电压：', value: '0.11%' }
  ];

  private readonly harmonicVoltageBottom: MetricItem[] = [
    { label: 'A相电压：', value: '0.11%' },
    { label: 'B相电压：', value: '0.11%' },
    { label: 'C相电压：', value: '0.11%' }
  ];

  private s(value: number): number {
    return Math.round(value * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      const scaleX = defaultDisplay.width / this.designWidth;
      const scaleY = defaultDisplay.height / this.designHeight;
      const scale = Math.min(scaleX, scaleY);
      this.uiScale = scale > 0 ? scale : 1;
    } catch (error) {
      this.uiScale = 1;
    }
  }

  build() {
    Column() {
      Column() {
        this.HeaderBar();

        Scroll() {
          Column() {
            this.MetricsRow('频率偏差:', this.frequencySummary, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('', this.phaseFrequencyDeviation, false, 75, 0, this.darkRowColor);
            this.MetricsRow('', this.phaseFrequencyPassRate, false, 75, 0, this.pageBackgroundColor);

            this.MetricsRow('电压偏差:', this.voltageSummary, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('', this.phaseVoltageDeviation, false, 75, 0, this.darkRowColor);
            this.MetricsRow('', this.phaseVoltagePassRate, false, 75, 0, this.pageBackgroundColor);
            this.MetricsRow('', this.lineVoltageDeviation, false, 75, 0, this.darkRowColor);
            this.MetricsRow('', this.lineVoltagePassRate, false, 75, 0, this.pageBackgroundColor);

            this.MetricsRow('电压不平衡:', this.voltageUnbalance, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('电流不平衡:', this.currentUnbalance, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('电压波动:', this.voltageFluctuation, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('电压闪变:', this.voltageFlicker, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('电压暂降:', this.voltageSag, true, 75, 135, this.pageBackgroundColor);
            this.MetricsRow('谐波总畸变率:', this.harmonicVoltageTop, true, 80, 0, this.pageBackgroundColor);
            this.MetricsRow('', this.harmonicVoltageBottom, false, 80, 0, this.pageBackgroundColor);

            Blank().height(this.s(40));
          }
          .width('100%')
          .padding({ right: this.s(this.scrollContentRightPadding) })
          .constraintSize({ minHeight: this.s(700) });
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(this.pageBackgroundColor);

        this.BottomBar();
      }
      .width('100%')
      .height('100%')
      .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
      .backgroundColor(this.pageBackgroundColor);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.pageBackgroundColor);
  }

  @Builder
  HeaderBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('电能质量—实时指标')
        .width('100%')
        .padding({ left: this.s(this.headerSideSlotWidth), right: this.s(this.headerSideSlotWidth) })
        .fontSize(this.s(this.fontSize.headerTitle))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip });

      Row() {
        Text('')
          .width(this.s(this.headerSideSlotWidth))
          .fontSize(this.s(this.fontSize.headerNotice))
          .fontColor('#EF2929')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .maxLines(1);

        Blank()
          .layoutWeight(1);

        Row({ space: this.s(this.headerButtonGap) }) {
          Button() {
            Image($r('app.media.return'))
              .width(this.s(37))
              .height(this.s(40));
          }
          .width(this.s(this.headerButtonTouchSize))
          .height(this.s(this.headerButtonTouchSize))
          .padding(0)
          .backgroundColor(this.headerBackgroundColor)
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
          .width(this.s(this.headerButtonTouchSize))
          .height(this.s(this.headerButtonTouchSize))
          .padding(0)
          .backgroundColor(this.headerBackgroundColor)
          .border({ width: 0 })
          .borderRadius(0)
          .onClick(() => {
            router.back();
          });
        }
        .width(this.s(this.headerSideSlotWidth))
        .justifyContent(FlexAlign.End);
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.s(12), right: this.s(12) })
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .backgroundColor(this.headerBackgroundColor);
  }

  @Builder
  MetricsRow(title: string, items: MetricItem[], showTitle: boolean, leadingWeight: number, tailWeight: number,
    backgroundColor: string) {
    Row() {
      if (showTitle) {
        this.SectionTitle(title, leadingWeight);
      } else {
        Blank()
          .layoutWeight(leadingWeight)
          .height('100%');
      }

      ForEach(items, (item: MetricItem, index: number) => {
        this.MetricBlock(item);
        if (index < items.length - 1) {
          Blank()
            .layoutWeight(15)
            .height('100%');
        }
      }, (item: MetricItem, index: number) => `${index}-${item.label}`);

      if (tailWeight > 0) {
        Blank()
          .layoutWeight(tailWeight)
          .height('100%');
      }
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(backgroundColor);
  }

  @Builder
  SectionTitle(title: string, blockWeight: number) {
    Row() {
      Image($r('app.media.right_black'))
        .width(this.s(this.sectionIconSize))
        .height(this.s(18))
        .margin({ right: this.s(8) });

      Text(title)
        .layoutWeight(1)
        .fontSize(this.s(this.fontSize.sectionTitle))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.Start)
        .maxLines(1);
    }
    .layoutWeight(blockWeight)
    .height('100%')
    .padding({ left: this.s(10), right: this.s(6) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  MetricBlock(item: MetricItem) {
    Row() {
      Text(item.label)
        .fontSize(this.s(this.fontSize.metricLabel))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .maxLines(1);

      Blank().layoutWeight(1);

      Text(item.value)
        .constraintSize({ minWidth: this.s(item.valueMinWidth ?? 0) })
        .fontSize(this.s(this.fontSize.metricValue))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .textAlign(TextAlign.End)
        .maxLines(1);
    }
    .layoutWeight(120)
    .height('100%')
    .padding({ left: this.s(6), right: this.s(6) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(40);
      Blank().layoutWeight(20);

      Button('关闭')
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.bottomButton))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor(this.buttonColor)
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(20);

      Button('返回')
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.fontSize.bottomButton))
        .fontColor('#000000')
        .fontFamily('Ubuntu')
        .backgroundColor(this.buttonColor)
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .padding(0)
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(20);

      Text(this.timeText)
        .layoutWeight(20)
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.bottomHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.headerBackgroundColor);
  }
}
