import router from '@ohos.router';
import display from '@ohos.display';
import { hilog } from '@kit.PerformanceAnalysisKit';
import * as harmonicTelemetryNativeModule from 'libentry.so';

@Observed
class HarmonicMetricData {
  frequency: string = '';
  amplitude: string = '';
  phase: string = '';
  ratio: string = '';

  constructor(frequency: string, amplitude: string, phase: string, ratio: string) {
    this.frequency = frequency;
    this.amplitude = amplitude;
    this.phase = phase;
    this.ratio = ratio;
  }
}

@Observed
class HarmonicPhaseRowData {
  phaseLabel: string = '';
  voltage: HarmonicMetricData = new HarmonicMetricData('', '', '', '');
  current: HarmonicMetricData = new HarmonicMetricData('', '', '', '');
  darkBackground: boolean = false;

  constructor(phaseLabel: string, voltage: HarmonicMetricData, current: HarmonicMetricData, darkBackground: boolean) {
    this.phaseLabel = phaseLabel;
    this.voltage = voltage;
    this.current = current;
    this.darkBackground = darkBackground;
  }
}

@Observed
class HarmonicSectionData {
  title: string = '';
  rows: HarmonicPhaseRowData[] = [];

  constructor(title: string, rows: HarmonicPhaseRowData[]) {
    this.title = title;
    this.rows = rows;
  }
}


interface HarmonicCurrentDisplayValue {
  ready: boolean;
  Ia: number[];
  Ib: number[];
  Ic: number[];
}

interface HarmonicVoltageDisplayValue {
  ready: boolean;
  Ua: number[];
  Ub: number[];
  Uc: number[];
}

interface HarmonicDisplayNativeModule {
  requestHarmonicDisplayData?: () => boolean;
  getHarmonicVoltageDisplayData?: () => HarmonicVoltageDisplayValue | undefined;
  getHarmonicCurrentDisplayData?: () => HarmonicCurrentDisplayValue | undefined;
}

declare function requireNapi(
  moduleName: string,
  isAppModule?: boolean,
  modulePath?: string
): HarmonicDisplayNativeModule | undefined;

const HARMONIC_DEGREE_SYMBOL: string = String.fromCharCode(176);
const HARMONIC_COMPONENT_COUNT: number = 10;
const HARMONIC_PHASE_COUNT: number = 3;
const HARMONIC_GROUP_VALUE_COUNT: number = 3;
const HARMONIC_ARRAY_VALUE_COUNT: number = HARMONIC_COMPONENT_COUNT * HARMONIC_GROUP_VALUE_COUNT;
const HARMONIC_LOG_CHUNK_SIZE: number = 6;
const HARMONIC_FREQUENCY_OFFSET: number = 0;
const HARMONIC_AMPLITUDE_OFFSET: number = 1;
const HARMONIC_PHASE_OFFSET: number = 2;
const DOMAIN: number = 0x0000;
const TCP_ARK_TAG: string = 'JY_TCP_ARK';

function createMetricData(unit: string, ratio: string): HarmonicMetricData {
  return new HarmonicMetricData('00.02Hz', `00.02${unit}`, '00.00°', ratio);
}

function createPhaseRowData(phaseLabel: string, ratio: string, darkBackground: boolean): HarmonicPhaseRowData {
  return new HarmonicPhaseRowData(
    phaseLabel,
    createMetricData('V', ratio),
    createMetricData('A', ratio),
    darkBackground
  );
}

function createSectionData(title: string, ratio: string): HarmonicSectionData {
  return new HarmonicSectionData(title, [
    createPhaseRowData('A相:', ratio, false),
    createPhaseRowData('B相:', ratio, true),
    createPhaseRowData('C相:', ratio, false)
  ]);
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
  return new HarmonicMetricData(metric.frequency, metric.amplitude, metric.phase, metric.ratio);
}

function cloneBroadbandHarmonicSections(): HarmonicSectionData[] {
  return BROADBAND_HARMONIC_SECTIONS.map((section: HarmonicSectionData) => {
    const nextRows: HarmonicPhaseRowData[] = section.rows.map((row: HarmonicPhaseRowData) => {
      return new HarmonicPhaseRowData(
        row.phaseLabel,
        cloneHarmonicMetricData(row.voltage),
        cloneHarmonicMetricData(row.current),
        row.darkBackground
      );
    });
    return new HarmonicSectionData(section.title, nextRows);
  });
}

function formatHarmonicFrequency(value: number): string {
  return `${value.toFixed(2)}Hz`;
}

function formatHarmonicAmplitude(value: number, unit: string): string {
  return `${value.toFixed(2)}${unit}`;
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

function getHarmonicComponentBaseIndex(componentIndex: number): number {
  // C 结构体里每个分量连续占 3 个槽位：
  // [0,1,2] = 工频， [3,4,5] = 谐波1， [6,7,8] = 谐波2 ...
  return componentIndex * HARMONIC_GROUP_VALUE_COUNT;
}

function getHarmonicAmplitudeIndex(componentIndex: number): number {
  // 含有率只能使用幅值位计算：
  // U[1], U[4], U[7], U[10] ... U[28]
  return componentIndex * HARMONIC_GROUP_VALUE_COUNT + HARMONIC_AMPLITUDE_OFFSET;
}

function getHarmonicComponentAmplitude(values: number[], componentIndex: number): number {
  return values[getHarmonicAmplitudeIndex(componentIndex)];
}

function calculateSignalRatioByHarmonicFormula(values: number[], componentIndex: number): string {
  let amplitudeSquareSum: number = 0;
  for (let index = 0; index < HARMONIC_COMPONENT_COUNT; index++) {
    const amplitude = getHarmonicComponentAmplitude(values, index);
    amplitudeSquareSum += amplitude * amplitude;
  }
  const totalAmplitudeRoot = Math.sqrt(amplitudeSquareSum);
  const componentAmplitude = getHarmonicComponentAmplitude(values, componentIndex);
  return formatHarmonicRatio(componentAmplitude, totalAmplitudeRoot);
}

function createMetricFromValues(values: number[], componentIndex: number, unit: string): HarmonicMetricData {
  const baseIndex = getHarmonicComponentBaseIndex(componentIndex);
  const amplitude = getHarmonicComponentAmplitude(values, componentIndex);
  return new HarmonicMetricData(
    formatHarmonicFrequency(values[baseIndex + HARMONIC_FREQUENCY_OFFSET]),
    formatHarmonicAmplitude(amplitude, unit),
    formatHarmonicPhase(values[baseIndex + HARMONIC_PHASE_OFFSET]),
    ''
  );
}

function createVoltageMetricFromValues(values: number[], componentIndex: number): HarmonicMetricData {
  return createMetricFromValues(values, componentIndex, 'V');
}

function createCurrentMetricFromValues(values: number[], componentIndex: number): HarmonicMetricData {
  return createMetricFromValues(values, componentIndex, 'A');
}

function logIndexedArrayLines(prefix: string, arrayName: string, values: string[]): void {
  for (let startIndex = 0; startIndex < values.length; startIndex += HARMONIC_LOG_CHUNK_SIZE) {
    const endIndex = Math.min(startIndex + HARMONIC_LOG_CHUNK_SIZE, values.length);
    const items: string[] = [];
    for (let index = startIndex; index < endIndex; index++) {
      items.push(`${arrayName}[${index}]=${values[index]}`);
    }
    const logLine = `${prefix} ${items.join(', ')}`;
    hilog.info(DOMAIN, TCP_ARK_TAG, '%{public}s', logLine);
    console.info(logLine);
  }
}

function buildRawNumberArrayTexts(values: number[]): string[] {
  return values.map((value: number) => value.toFixed(6));
}

function buildMetricDisplayValueArray(
  sections: HarmonicSectionData[],
  rowIndex: number,
  selector: (row: HarmonicPhaseRowData) => HarmonicMetricData
): string[] {
  const values: string[] = [];
  for (let sectionIndex = 0; sectionIndex < HARMONIC_COMPONENT_COUNT; sectionIndex++) {
    const metric = selector(sections[sectionIndex].rows[rowIndex]);
    values.push(metric.frequency);
    values.push(metric.amplitude);
    values.push(metric.phase);
  }
  return values;
}


function isUsableHarmonicVoltageDisplayValue(value: HarmonicVoltageDisplayValue | undefined): boolean {
  if (!value || !value.ready) {
    return false;
  }

  const phases = [value.Ua, value.Ub, value.Uc];
  return phases.every((phaseValues: number[]) => {
    return Array.isArray(phaseValues) &&
      phaseValues.length >= HARMONIC_ARRAY_VALUE_COUNT &&
    phaseValues.every((item: number) => typeof item === 'number' && isFinite(item));
  });
}

function isUsableHarmonicCurrentDisplayValue(value: HarmonicCurrentDisplayValue | undefined): boolean {
  if (!value || !value.ready) {
    return false;
  }

  const phases = [value.Ia, value.Ib, value.Ic];
  return phases.every((phaseValues: number[]) => {
    return Array.isArray(phaseValues) &&
      phaseValues.length >= HARMONIC_ARRAY_VALUE_COUNT &&
    phaseValues.every((item: number) => typeof item === 'number' && isFinite(item));
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
  sectionTitleIconSize: number = 28;
  sectionHeaderHeight: number = 46;
  tableHeaderHeight: number = 46;
  rowHeight: number = 54;
  phaseLabelWeight: number = 12;
  metricWeight: number = 11;
  highlightedRowColor: string = '#888A85';
}

@Component
struct MetricValuesBlock {
  @ObjectLink metric: HarmonicMetricData;
  @Prop uiScale: number = 1;
  @Prop fontSize: BroadbandHarmonicFontSize = new BroadbandHarmonicFontSize();

  private s(value: number): number {
    return Math.round(value * this.uiScale);
  }

  build() {
    Row() {
      Text(this.metric.frequency)
        .layoutWeight(this.fontSize.metricWeight)
        .fontSize(this.s(this.fontSize.rowValue))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text(this.metric.amplitude)
        .layoutWeight(this.fontSize.metricWeight)
        .fontSize(this.s(this.fontSize.rowValue))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text(this.metric.phase)
        .layoutWeight(this.fontSize.metricWeight)
        .fontSize(this.s(this.fontSize.rowValue))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text(this.metric.ratio)
        .layoutWeight(this.fontSize.metricWeight)
        .fontSize(this.s(this.fontSize.rowValue))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);
    }
    .layoutWeight(this.fontSize.metricWeight * 4)
    .height('100%');
  }
}

@Component
struct PhaseDataRowBlock {
  @ObjectLink row: HarmonicPhaseRowData;
  @Prop uiScale: number = 1;
  @Prop fontSize: BroadbandHarmonicFontSize = new BroadbandHarmonicFontSize();
  @Prop pageBackgroundColor: string = '#FFFFFF';

  private s(value: number): number {
    return Math.round(value * this.uiScale);
  }

  build() {
    Row() {
      Text(this.row.phaseLabel)
        .layoutWeight(this.fontSize.phaseLabelWeight)
        .fontSize(this.s(this.fontSize.rowLabel))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      MetricValuesBlock({
        metric: this.row.voltage,
        uiScale: this.uiScale,
        fontSize: this.fontSize
      });

      Text(this.row.phaseLabel)
        .layoutWeight(this.fontSize.phaseLabelWeight)
        .fontSize(this.s(this.fontSize.rowLabel))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      MetricValuesBlock({
        metric: this.row.current,
        uiScale: this.uiScale,
        fontSize: this.fontSize
      });
    }
    .width('100%')
    .height(this.s(this.fontSize.rowHeight))
    .backgroundColor(this.row.darkBackground ? this.fontSize.highlightedRowColor : this.pageBackgroundColor)
    .alignItems(VerticalAlign.Center);
  }
}

@Component
struct SectionBlock {
  @ObjectLink section: HarmonicSectionData;
  @Prop uiScale: number = 1;
  @Prop fontSize: BroadbandHarmonicFontSize = new BroadbandHarmonicFontSize();
  @Prop pageBackgroundColor: string = '#FFFFFF';

  private s(value: number): number {
    return Math.round(value * this.uiScale);
  }

  build() {
    Column() {
      this.SectionTitleRow(this.section.title);
      this.TableHeaderRow();

      PhaseDataRowBlock({
        row: this.section.rows[0],
        uiScale: this.uiScale,
        fontSize: this.fontSize,
        pageBackgroundColor: this.pageBackgroundColor
      });
      PhaseDataRowBlock({
        row: this.section.rows[1],
        uiScale: this.uiScale,
        fontSize: this.fontSize,
        pageBackgroundColor: this.pageBackgroundColor
      });
      PhaseDataRowBlock({
        row: this.section.rows[2],
        uiScale: this.uiScale,
        fontSize: this.fontSize,
        pageBackgroundColor: this.pageBackgroundColor
      });
    }
    .width('100%')
    .padding({ top: this.s(4), bottom: this.s(4) })
    .backgroundColor(this.pageBackgroundColor);
  }

  @Builder
  SectionTitleRow(title: string) {
    Row() {
      Image($r('app.media.right_black'))
        .width(this.s(this.fontSize.sectionTitleIconSize))
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
    .height(this.s(this.fontSize.sectionHeaderHeight))
    .padding({ left: this.s(4) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  TableHeaderRow() {
    Row() {
      this.HeaderCell('电压', this.fontSize.phaseLabelWeight, true);
      this.HeaderCell('频率', this.fontSize.metricWeight, false);
      this.HeaderCell('幅值', this.fontSize.metricWeight, false);
      this.HeaderCell('相位', this.fontSize.metricWeight, false);
      this.HeaderCell('含有率', this.fontSize.metricWeight, false);
      this.HeaderCell('电流', this.fontSize.phaseLabelWeight, true);
      this.HeaderCell('频率', this.fontSize.metricWeight, false);
      this.HeaderCell('幅值', this.fontSize.metricWeight, false);
      this.HeaderCell('相位', this.fontSize.metricWeight, false);
      this.HeaderCell('含有率', this.fontSize.metricWeight, false);
    }
    .width('100%')
    .height(this.s(this.fontSize.tableHeaderHeight))
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
}

@Entry
@Component
export struct Broadband_Harmonic {
  @State uiScale: number = 1;
  @State sections: HarmonicSectionData[] = cloneBroadbandHarmonicSections();
  @State timeText: string = '2024/12/30\n12:12:30';


  private harmonicDisplayRefreshTimer: number = -1;
  private harmonicDisplayRefreshGeneration: number = 0;
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
  private cachedHarmonicDisplayNativeModule?: HarmonicDisplayNativeModule;

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

    this.requestNativeHarmonicDisplayData();
    this.loadNativeHarmonicDisplayData();
    this.startHarmonicDisplayRefreshTimer();
  }

  aboutToDisappear(): void {
    this.stopHarmonicDisplayRefreshTimer();
  }

  private startHarmonicDisplayRefreshTimer(): void {
    this.stopHarmonicDisplayRefreshTimer();
    const refreshGeneration = this.harmonicDisplayRefreshGeneration;
    this.harmonicDisplayRefreshTimer = setTimeout(() => {
      this.harmonicDisplayRefreshTimer = -1;
      if (refreshGeneration !== this.harmonicDisplayRefreshGeneration) {
        return;
      }
      this.requestNativeHarmonicDisplayData();
      this.loadNativeHarmonicDisplayData();
      this.startHarmonicDisplayRefreshTimer();
    }, 3000);
  }

  private stopHarmonicDisplayRefreshTimer(): void {
    this.harmonicDisplayRefreshGeneration++;
    if (this.harmonicDisplayRefreshTimer >= 0) {
      clearTimeout(this.harmonicDisplayRefreshTimer);
      this.harmonicDisplayRefreshTimer = -1;
    }
  }

  private isValidHarmonicDisplayNativeModule(module: HarmonicDisplayNativeModule | undefined): boolean {
    return !!module &&
      (typeof module.getHarmonicVoltageDisplayData === 'function' ||
        typeof module.getHarmonicCurrentDisplayData === 'function');
  }

  private loadHarmonicDisplayNativeModule(): HarmonicDisplayNativeModule | undefined {
    if (this.isValidHarmonicDisplayNativeModule(this.cachedHarmonicDisplayNativeModule)) {
      return this.cachedHarmonicDisplayNativeModule;
    }
    if (this.isValidHarmonicDisplayNativeModule(harmonicTelemetryNativeModule)) {
      this.cachedHarmonicDisplayNativeModule = harmonicTelemetryNativeModule;
      return this.cachedHarmonicDisplayNativeModule;
    }

    const napiModuleWithPath = requireNapi('entry', true, 'com.example.new_jydl_v3/entry');
    if (this.isValidHarmonicDisplayNativeModule(napiModuleWithPath)) {
      this.cachedHarmonicDisplayNativeModule = napiModuleWithPath;
      return this.cachedHarmonicDisplayNativeModule;
    }

    const napiModuleWithApp = requireNapi('entry', true);
    if (this.isValidHarmonicDisplayNativeModule(napiModuleWithApp)) {
      this.cachedHarmonicDisplayNativeModule = napiModuleWithApp;
      return this.cachedHarmonicDisplayNativeModule;
    }

    const napiModule = requireNapi('entry');
    if (this.isValidHarmonicDisplayNativeModule(napiModule)) {
      this.cachedHarmonicDisplayNativeModule = napiModule;
      return this.cachedHarmonicDisplayNativeModule;
    }

    return undefined;
  }

  private requestNativeHarmonicDisplayData(): void {
    try {
      const nativeModule = this.loadHarmonicDisplayNativeModule();
      if (!nativeModule || typeof nativeModule.requestHarmonicDisplayData !== 'function') {
        return;
      }
      nativeModule.requestHarmonicDisplayData();
    } catch (error) {
      hilog.error(DOMAIN, TCP_ARK_TAG, '宽频谐波 request failed: %{public}s', JSON.stringify(error));
      console.error(`request harmonic display failed: ${JSON.stringify(error)}`);
    }
  }

  private logHarmonicVoltageNativeArrays(value: HarmonicVoltageDisplayValue): void {
    logIndexedArrayLines('界面拿到的原始电压值', 'Ua', buildRawNumberArrayTexts(value.Ua));
    logIndexedArrayLines('界面拿到的原始电压值', 'Ub', buildRawNumberArrayTexts(value.Ub));
    logIndexedArrayLines('界面拿到的原始电压值', 'Uc', buildRawNumberArrayTexts(value.Uc));
  }

  private logHarmonicCurrentNativeArrays(value: HarmonicCurrentDisplayValue): void {
    logIndexedArrayLines('界面拿到的原始电流值', 'Ia', buildRawNumberArrayTexts(value.Ia));
    logIndexedArrayLines('界面拿到的原始电流值', 'Ib', buildRawNumberArrayTexts(value.Ib));
    logIndexedArrayLines('界面拿到的原始电流值', 'Ic', buildRawNumberArrayTexts(value.Ic));
  }

  private logHarmonicVoltageDisplayArrays(): void {
    logIndexedArrayLines('界面显示电压值', 'Ua',
      buildMetricDisplayValueArray(this.sections, 0, (row: HarmonicPhaseRowData) => row.voltage));
    logIndexedArrayLines('界面显示电压值', 'Ub',
      buildMetricDisplayValueArray(this.sections, 1, (row: HarmonicPhaseRowData) => row.voltage));
    logIndexedArrayLines('界面显示电压值', 'Uc',
      buildMetricDisplayValueArray(this.sections, 2, (row: HarmonicPhaseRowData) => row.voltage));
  }

  private logHarmonicCurrentDisplayArrays(): void {
    logIndexedArrayLines('界面显示电流值', 'Ia',
      buildMetricDisplayValueArray(this.sections, 0, (row: HarmonicPhaseRowData) => row.current));
    logIndexedArrayLines('界面显示电流值', 'Ib',
      buildMetricDisplayValueArray(this.sections, 1, (row: HarmonicPhaseRowData) => row.current));
    logIndexedArrayLines('界面显示电流值', 'Ic',
      buildMetricDisplayValueArray(this.sections, 2, (row: HarmonicPhaseRowData) => row.current));
  }

  private loadNativeHarmonicDisplayData(): void {
    try {
      const nativeModule = this.loadHarmonicDisplayNativeModule();
      if (!nativeModule) {
        return;
      }

      let hasLoadedNativeData: boolean = false;

      if (typeof nativeModule.getHarmonicVoltageDisplayData === 'function') {
        const voltageValue = nativeModule.getHarmonicVoltageDisplayData();
        if (isUsableHarmonicVoltageDisplayValue(voltageValue) && voltageValue) {
          const phaseValues = [voltageValue.Ua, voltageValue.Ub, voltageValue.Uc];
          for (let sectionIndex = 0; sectionIndex < HARMONIC_COMPONENT_COUNT; sectionIndex++) {
            for (let rowIndex = 0; rowIndex < HARMONIC_PHASE_COUNT; rowIndex++) {
              const row = this.sections[sectionIndex].rows[rowIndex];
              const voltageMetric = createVoltageMetricFromValues(phaseValues[rowIndex], sectionIndex);
              const voltageRatio = calculateSignalRatioByHarmonicFormula(phaseValues[rowIndex], sectionIndex);
              row.voltage.frequency = voltageMetric.frequency;
              row.voltage.amplitude = voltageMetric.amplitude;
              row.voltage.phase = voltageMetric.phase;
              row.voltage.ratio = voltageRatio;
            }
          }
          //this.logHarmonicVoltageNativeArrays(voltageValue);
          //this.logHarmonicVoltageDisplayArrays();
          hasLoadedNativeData = true;
        }
      }

      if (typeof nativeModule.getHarmonicCurrentDisplayData === 'function') {
        const currentValue = nativeModule.getHarmonicCurrentDisplayData();
        if (isUsableHarmonicCurrentDisplayValue(currentValue) && currentValue) {
          const phaseValues = [currentValue.Ia, currentValue.Ib, currentValue.Ic];
          for (let sectionIndex = 0; sectionIndex < HARMONIC_COMPONENT_COUNT; sectionIndex++) {
            for (let rowIndex = 0; rowIndex < HARMONIC_PHASE_COUNT; rowIndex++) {
              const row = this.sections[sectionIndex].rows[rowIndex];
              const currentMetric = createCurrentMetricFromValues(phaseValues[rowIndex], sectionIndex);
              const currentRatio = calculateSignalRatioByHarmonicFormula(phaseValues[rowIndex], sectionIndex);
              row.current.frequency = currentMetric.frequency;
              row.current.amplitude = currentMetric.amplitude;
              row.current.phase = currentMetric.phase;
              row.current.ratio = currentRatio;
            }
          }
          //this.logHarmonicCurrentNativeArrays(currentValue);
          //this.logHarmonicCurrentDisplayArrays();
          hasLoadedNativeData = true;
        }
      }

      if (hasLoadedNativeData) {
        // this.timeText = this.formatNowText(new Date());
      }
    } catch (error) {
      hilog.error(DOMAIN, TCP_ARK_TAG, '宽频谐波 load failed: %{public}s', JSON.stringify(error));
      console.error(`load harmonic display failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column() {
      Column() {
        this.HeaderBar();

        Scroll() {
          Column() {
            this.HarmonicSectionsContent();
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
  HarmonicSectionsContent() {
    SectionBlock({
      section: this.sections[0],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[1],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[2],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[3],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[4],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[5],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[6],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[7],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[8],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
    this.SectionDivider();
    SectionBlock({
      section: this.sections[9],
      uiScale: this.uiScale,
      fontSize: this.fontSize,
      pageBackgroundColor: this.pageBackgroundColor
    });
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
  SectionBlock(section: HarmonicSectionData, sectionIndex: number) {
    Column() {
      this.SectionTitleRow(section.title);
      this.TableHeaderRow();
      this.DataRow(
        section.rows[0].phaseLabel,
        section.rows[0].darkBackground,
        section.rows[0].voltage.frequency,
        section.rows[0].voltage.amplitude,
        section.rows[0].voltage.phase,
        section.rows[0].voltage.ratio,
        section.rows[0].current.frequency,
        section.rows[0].current.amplitude,
        section.rows[0].current.phase,
        section.rows[0].current.ratio
      );
      this.DataRow(
        section.rows[1].phaseLabel,
        section.rows[1].darkBackground,
        section.rows[1].voltage.frequency,
        section.rows[1].voltage.amplitude,
        section.rows[1].voltage.phase,
        section.rows[1].voltage.ratio,
        section.rows[1].current.frequency,
        section.rows[1].current.amplitude,
        section.rows[1].current.phase,
        section.rows[1].current.ratio
      );
      this.DataRow(
        section.rows[2].phaseLabel,
        section.rows[2].darkBackground,
        section.rows[2].voltage.frequency,
        section.rows[2].voltage.amplitude,
        section.rows[2].voltage.phase,
        section.rows[2].voltage.ratio,
        section.rows[2].current.frequency,
        section.rows[2].current.amplitude,
        section.rows[2].current.phase,
        section.rows[2].current.ratio
      );
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
  DataRow(
    phaseLabel: string,
    darkBackground: boolean,
    voltageFrequency: string,
    voltageAmplitude: string,
    voltagePhase: string,
    voltageRatio: string,
    currentFrequency: string,
    currentAmplitude: string,
    currentPhase: string,
    currentRatio: string
  ) {
    Row() {
      this.RowLabelCell(phaseLabel, this.phaseLabelWeight);
      this.RowValueCell(voltageFrequency, this.metricWeight);
      this.RowValueCell(voltageAmplitude, this.metricWeight);
      this.RowValueCell(voltagePhase, this.metricWeight);
      this.RowValueCell(voltageRatio, this.metricWeight);
      this.RowLabelCell(phaseLabel, this.phaseLabelWeight);
      this.RowValueCell(currentFrequency, this.metricWeight);
      this.RowValueCell(currentAmplitude, this.metricWeight);
      this.RowValueCell(currentPhase, this.metricWeight);
      this.RowValueCell(currentRatio, this.metricWeight);
    }
    .width('100%')
    .height(this.s(this.rowHeight))
    .padding({ left: this.s(this.rowPaddingX), right: this.s(this.rowPaddingX) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(darkBackground ? this.highlightedRowColor : this.pageBackgroundColor);
  }

  @Builder
  RowLabelCell(text: string, weight: number) {
    Text(text)
      .layoutWeight(weight)
      .fontSize(this.s(this.fontSize.rowLabel))
      .fontColor('#000000')
      .fontFamily('STKaiti')
      .textAlign(TextAlign.Center);
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
