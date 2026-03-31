import router from '@ohos.router';
import display from '@ohos.display';
import * as harmonicTelemetryNativeModule from 'libentry.so';

interface HarmonicMetricData {
  frequency: string;
  amplitude: string;
  phase: string;
  ratio: string;
}

interface HarmonicPhaseRowData {
  phaseLabel: string;
  voltage: HarmonicMetricData;
  current: HarmonicMetricData;
  darkBackground: boolean;
}

interface HarmonicSectionData {
  title: string;
  rows: HarmonicPhaseRowData[];
}

interface HarmonicCurrentDisplayValue {
  ready: boolean;
  Ia: number[];
  Ib: number[];
  Ic: number[];
}

interface HarmonicCurrentNativeModule {
  getHarmonicCurrentDisplayData?: () => HarmonicCurrentDisplayValue | undefined;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): HarmonicCurrentNativeModule | undefined;

const HARMONIC_DEGREE_SYMBOL: string = String.fromCharCode(176);
const HARMONIC_COMPONENT_COUNT: number = 10;

function createMetricData(unit: string, ratio: string): HarmonicMetricData {
  return {
    frequency: '00.02Hz',
    amplitude: `00.02${unit}`,
    phase: '00.00°',
    ratio: ratio
  };
}

function createPhaseRowData(phaseLabel: string, ratio: string, darkBackground: boolean): HarmonicPhaseRowData {
  return {
    phaseLabel: phaseLabel,
    voltage: createMetricData('V', ratio),
    current: createMetricData('A', ratio),
    darkBackground: darkBackground
  };
}

function createSectionData(title: string, ratio: string): HarmonicSectionData {
  return {
    title: title,
    rows: [
      createPhaseRowData('A相:', ratio, false),
      createPhaseRowData('B相:', ratio, true),
      createPhaseRowData('C相:', ratio, false)
    ]
  };
}

const BROADBAND_HARMONIC_SECTIONS: HarmonicSectionData[] = [
  createSectionData('工频分量:', '00.00%'),
  createSectionData('谐波分量1:', '00.00%'),
  createSectionData('谐波分量2:', '0.00%'),
  createSectionData('谐波分量3:', '0.00%'),
  createSectionData('谐波分量4:', '0.00%'),
  createSectionData('谐波分量5:', '0.00%'),
  createSectionData('谐波分量6:', '0.00%'),
  createSectionData('谐波分量7:', '0.00%'),
  createSectionData('谐波分量8:', '0.00%'),
  createSectionData('谐波分量9:', '0.00%')
];

function cloneHarmonicMetricData(metric: HarmonicMetricData): HarmonicMetricData {
  const nextMetric: HarmonicMetricData = {
    frequency: metric.frequency,
    amplitude: metric.amplitude,
    phase: metric.phase,
    ratio: metric.ratio
  };
  return nextMetric;
}

function cloneBroadbandHarmonicSections(): HarmonicSectionData[] {
  return BROADBAND_HARMONIC_SECTIONS.map((section: HarmonicSectionData) => {
    const nextRows: HarmonicPhaseRowData[] = section.rows.map((row: HarmonicPhaseRowData) => {
      const nextRow: HarmonicPhaseRowData = {
        phaseLabel: row.phaseLabel,
        voltage: cloneHarmonicMetricData(row.voltage),
        current: cloneHarmonicMetricData(row.current),
        darkBackground: row.darkBackground
      };
      return nextRow;
    });
    const nextSection: HarmonicSectionData = {
      title: section.title,
      rows: nextRows
    };
    return nextSection;
  });
}

function formatHarmonicFrequency(value: number): string {
  return `${value.toFixed(2)}Hz`;
}

function formatHarmonicAmplitude(value: number): string {
  return `${value.toFixed(2)}A`;
}

function formatHarmonicPhase(value: number): string {
  return `${value.toFixed(2)}${HARMONIC_DEGREE_SYMBOL}`;
}

function formatHarmonicRatio(amplitude: number, fundamentalAmplitude: number): string {
  if (!isFinite(fundamentalAmplitude) || Math.abs(fundamentalAmplitude) < 0.000001) {
    return '0.00%';
  }
  return `${((amplitude / fundamentalAmplitude) * 100).toFixed(2)}%`;
}

function createCurrentMetricFromValues(values: number[], componentIndex: number): HarmonicMetricData {
  const baseIndex = componentIndex * 3;
  const fundamentalAmplitude = values[1];
  const amplitude = values[baseIndex + 1];
  const nextMetric: HarmonicMetricData = {
    frequency: formatHarmonicFrequency(values[baseIndex]),
    amplitude: formatHarmonicAmplitude(amplitude),
    phase: formatHarmonicPhase(values[baseIndex + 2]),
    ratio: formatHarmonicRatio(amplitude, fundamentalAmplitude)
  };
  return nextMetric;
}

function isUsableHarmonicCurrentDisplayValue(value: HarmonicCurrentDisplayValue | undefined): boolean {
  if (!value || !value.ready) {
    return false;
  }

  const phases = [value.Ia, value.Ib, value.Ic];
  return phases.every((phaseValues: number[]) => {
    return Array.isArray(phaseValues) &&
      phaseValues.length >= HARMONIC_COMPONENT_COUNT * 3 &&
      phaseValues.every((item: number) => typeof item === 'number' && isFinite(item));
  });
}

function createSectionsFromHarmonicCurrentDisplay(value: HarmonicCurrentDisplayValue): HarmonicSectionData[] {
  const sections = cloneBroadbandHarmonicSections();
  const phaseValues = [value.Ia, value.Ib, value.Ic];

  return sections.map((section: HarmonicSectionData, sectionIndex: number) => {
    const nextRows: HarmonicPhaseRowData[] = section.rows.map((row: HarmonicPhaseRowData, rowIndex: number) => {
      const nextRow: HarmonicPhaseRowData = {
        phaseLabel: row.phaseLabel,
        voltage: cloneHarmonicMetricData(row.voltage),
        current: createCurrentMetricFromValues(phaseValues[rowIndex], sectionIndex),
        darkBackground: row.darkBackground
      };
      return nextRow;
    });
    const nextSection: HarmonicSectionData = {
      title: section.title,
      rows: nextRows
    };
    return nextSection;
  });
}

class BroadbandHarmonicFontSize {
  notice: number = 18;
  title: number = 20;
  subTitle: number = 20;
  sectionTitle: number = 20;
  sectionHeader: number = 20;
  tableHeader: number = 19;
  rowLabel: number = 20;
  rowValue: number = 18;
  bottomButton: number = 18;
  timeText: number = 18;
  titleMin: number = 14;
  noticeMin: number = 12;
  timeLineHeight: number = 22;
}

@Entry
@Component
export struct Broadband_Harmonic {
  @State uiScale: number = 1;
  @State timeText: string = '2024/12/30\n12:12:30';
  @State sections: HarmonicSectionData[] = cloneBroadbandHarmonicSections();

  private readonly fontSize: BroadbandHarmonicFontSize = new BroadbandHarmonicFontSize();
  private readonly pageMaxWidth: number = 1024;
  private readonly designWidth: number = 1024;
  private readonly designHeight: number = 600;
  private readonly headerHeight: number = 70;
  private readonly bottomHeight: number = 70;
  private readonly buttonHeight: number = 55;
  private readonly bottomButtonRadius: number = 24;
  private readonly sectionHeaderHeight: number = 46;
  private readonly tableHeaderHeight: number = 46;
  private readonly rowHeight: number = 54;
  private readonly sectionDividerHeight: number = 12;
  private readonly sectionTitleIconSize: number = 28;
  private readonly sectionPadding: number = 9;
  private readonly rowPaddingX: number = 6;
  private readonly headerButtonHeight: number = 40;
  private readonly headerPadding: number = 9;
  private readonly phaseLabelWeight: number = 12;
  private readonly metricWeight: number = 11;
  private readonly headerBackgroundColor: string = '#D3D3D3';
  private readonly highlightedRowColor: string = '#888A85';
  private readonly buttonColor: string = '#BEBEBE';
  private readonly pageBackgroundColor: string = '#FFFFFF';
  private readonly dividerColor: string = '#A7A7A7';
  private cachedHarmonicCurrentNativeModule?: HarmonicCurrentNativeModule;

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

    this.loadNativeHarmonicCurrentData();
  }

  private isValidHarmonicCurrentNativeModule(module: HarmonicCurrentNativeModule | undefined): boolean {
    return !!module && typeof module.getHarmonicCurrentDisplayData === 'function';
  }

  private loadHarmonicCurrentNativeModule(): HarmonicCurrentNativeModule | undefined {
    if (this.isValidHarmonicCurrentNativeModule(this.cachedHarmonicCurrentNativeModule)) {
      return this.cachedHarmonicCurrentNativeModule;
    }
    if (this.isValidHarmonicCurrentNativeModule(harmonicTelemetryNativeModule)) {
      this.cachedHarmonicCurrentNativeModule = harmonicTelemetryNativeModule;
      return this.cachedHarmonicCurrentNativeModule;
    }

    const napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidHarmonicCurrentNativeModule(napiModuleWithPath)) {
      this.cachedHarmonicCurrentNativeModule = napiModuleWithPath;
      return this.cachedHarmonicCurrentNativeModule;
    }

    const napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidHarmonicCurrentNativeModule(napiModuleWithApp)) {
      this.cachedHarmonicCurrentNativeModule = napiModuleWithApp;
      return this.cachedHarmonicCurrentNativeModule;
    }

    const napiModule = requireNapi('entry');
    if (this.isValidHarmonicCurrentNativeModule(napiModule)) {
      this.cachedHarmonicCurrentNativeModule = napiModule;
      return this.cachedHarmonicCurrentNativeModule;
    }

    return undefined;
  }

  private loadNativeHarmonicCurrentData(): void {
    try {
      const nativeModule = this.loadHarmonicCurrentNativeModule();
      if (!nativeModule || typeof nativeModule.getHarmonicCurrentDisplayData !== 'function') {
        return;
      }

      const value = nativeModule.getHarmonicCurrentDisplayData();
      if (!isUsableHarmonicCurrentDisplayValue(value)) {
        return;
      }

      this.sections = createSectionsFromHarmonicCurrentDisplay(value as HarmonicCurrentDisplayValue);
    } catch (error) {
      console.error(`load harmonic current display failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column() {
      Column() {
        this.HeaderBar();

        Scroll() {
          Column() {
            ForEach(this.sections, (section: HarmonicSectionData, index: number) => {
              this.SectionBlock(section);
              if (index < this.sections.length - 1) {
                this.SectionDivider();
              }
            }, (section: HarmonicSectionData, index: number) => `${index}-${section.title}`);

            Blank().height(this.s(24));
          }
          .width('100%')
          .padding({ left: this.s(this.sectionPadding), right: this.s(this.sectionPadding) })
          .constraintSize({ minHeight: this.s(2400) });
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
    Row() {
      Text('')
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.noticeMin))
        .maxLines(1)
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text('电能质量')
        .layoutWeight(3)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text('—宽频谐波')
        .layoutWeight(8)
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.subTitle))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(37))
          .height(this.s(40));
      }
      .layoutWeight(2)
      .height(this.s(this.headerButtonHeight))
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
      .layoutWeight(2)
      .height(this.s(this.headerButtonHeight))
      .padding(0)
      .backgroundColor(this.headerBackgroundColor)
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .padding({
      left: this.s(this.headerPadding),
      right: this.s(this.headerPadding),
      top: this.s(this.headerPadding),
      bottom: this.s(this.headerPadding)
    })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.headerBackgroundColor);
  }

  @Builder
  SectionBlock(section: HarmonicSectionData) {
    Column() {
      this.SectionTitleRow(section.title);
      this.TableHeaderRow();

      ForEach(section.rows, (row: HarmonicPhaseRowData, index: number) => {
        this.DataRow(row);
      }, (row: HarmonicPhaseRowData, index: number) => `${section.title}-${index}-${row.phaseLabel}`);
    }
    .width('100%')
    .padding({ top: this.s(4), bottom: this.s(4) })
    .backgroundColor(this.pageBackgroundColor);
  }

  @Builder
  SectionTitleRow(title: string) {
    Row() {
      Image($r('app.media.right_black'))
        .width(this.s(this.sectionTitleIconSize))
        .height(this.s(24))
        .margin({ right: this.s(2) });

      Text(title)
        .fontSize(this.s(this.fontSize.sectionTitle))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);
    }
    .width('100%')
    .height(this.s(this.sectionHeaderHeight))
    .padding({ left: this.s(4) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  TableHeaderRow() {
    Row() {
      this.HeaderCell('电压', this.phaseLabelWeight, true);
      this.HeaderCell('频率', this.metricWeight, false);
      this.HeaderCell('幅值', this.metricWeight, false);
      this.HeaderCell('相位', this.metricWeight, false);
      this.HeaderCell('含有率', this.metricWeight, false);
      this.HeaderCell('电流', this.phaseLabelWeight, true);
      this.HeaderCell('频率', this.metricWeight, false);
      this.HeaderCell('幅值', this.metricWeight, false);
      this.HeaderCell('相位', this.metricWeight, false);
      this.HeaderCell('含有率', this.metricWeight, false);
    }
    .width('100%')
    .height(this.s(this.tableHeaderHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  HeaderCell(text: string, weight: number, underline: boolean) {
    Text(text)
      .layoutWeight(weight)
      .fontSize(this.s(underline ? this.fontSize.sectionHeader : this.fontSize.tableHeader))
      .fontWeight(underline ? FontWeight.Bold : FontWeight.Normal)
      .fontColor('#000000')
      .fontFamily('STKaiti')
      .textAlign(TextAlign.Center)
      .decoration({ type: underline ? TextDecorationType.Underline : TextDecorationType.None });
  }

  @Builder
  DataRow(row: HarmonicPhaseRowData) {
    Row() {
      this.RowLabelCell(row.phaseLabel, this.phaseLabelWeight);
      this.RowValueCell(row.voltage.frequency, this.metricWeight);
      this.RowValueCell(row.voltage.amplitude, this.metricWeight);
      this.RowValueCell(row.voltage.phase, this.metricWeight);
      this.RowValueCell(row.voltage.ratio, this.metricWeight);
      this.RowLabelCell(row.phaseLabel, this.phaseLabelWeight);
      this.RowValueCell(row.current.frequency, this.metricWeight);
      this.RowValueCell(row.current.amplitude, this.metricWeight);
      this.RowValueCell(row.current.phase, this.metricWeight);
      this.RowValueCell(row.current.ratio, this.metricWeight);
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .padding({ left: this.s(this.rowPaddingX), right: this.s(this.rowPaddingX) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(row.darkBackground ? this.highlightedRowColor : this.pageBackgroundColor);
  }

  @Builder
  RowLabelCell(text: string, weight: number) {
    Text(text)
      .layoutWeight(weight)
      .fontSize(this.s(this.fontSize.rowLabel))
      .fontColor('#000000')
      .fontFamily('STKaiti')
      .textAlign(TextAlign.Start);
  }

  @Builder
  RowValueCell(text: string, weight: number) {
    Text(text)
      .layoutWeight(weight)
      .fontSize(this.s(this.fontSize.rowValue))
      .fontColor('#000000')
      .fontFamily('STKaiti')
      .textAlign(TextAlign.Center);
  }

  @Builder
  SectionDivider() {
    Row() {
      Divider()
        .strokeWidth(this.s(3))
        .color(this.dividerColor)
        .width('100%');
    }
    .width('100%')
    .height(this.s(this.sectionDividerHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(25);
      Blank().layoutWeight(15);

      Button('关闭')
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
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

      Blank().layoutWeight(10);

      Button('返回')
        .layoutWeight(20)
        .height(this.s(this.buttonHeight))
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
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.bottomHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.headerBackgroundColor);
  }
}
