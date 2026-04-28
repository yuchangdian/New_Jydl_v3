export enum AxisDependency {
  LEFT = 0,
  RIGHT = 1
}

export enum XAxisPosition {
  TOP = 0,
  BOTTOM = 1
}

export enum YAxisLabelPosition {
  OUTSIDE_CHART = 0,
  INSIDE_CHART = 1
}

export class JArrayList<T> {
  private items: T[] = []

  add(item: T): void {
    this.items.push(item)
  }

  get(index: number): T | null {
    return index >= 0 && index < this.items.length ? this.items[index] : null
  }

  size(): number {
    return this.items.length
  }
}

export class EntryOhos {
  private x: number
  private y: number

  constructor(x: number, y: number) {
    this.x = x
    this.y = y
  }

  getX(): number {
    return this.x
  }

  getY(): number {
    return this.y
  }
}

export class BarEntry extends EntryOhos {
  constructor(x: number, y: number) {
    super(x, y)
  }
}

export class Highlight {
  private x: number

  constructor(x: number = 0) {
    this.x = x
  }

  getX(): number {
    return this.x
  }
}

export interface OnChartValueSelectedListener {
  onValueSelected?: (e: EntryOhos, h: Highlight) => void
  onNothingSelected?: () => void
}

class AxisBase {
  setPosition(_value: number): void {}
  setTextColor(_value: number): void {}
  setTextSize(_value: number): void {}
  setAxisMinimum(_value: number): void {}
  setAxisMaximum(_value: number): void {}
  setGranularity(_value: number): void {}
  setDrawGridLines(_value: boolean): void {}
  setGridColor(_value: number): void {}
  setEnabled(_value: boolean): void {}
}

export class XAxis extends AxisBase {
}

export class YAxis extends AxisBase {
}

export class Description {
  setEnabled(_value: boolean): void {}
}

export class Legend {
  setEnabled(_value: boolean): void {}
}

export interface ILineDataSet {
  getEntryCount(): number
  getEntryForIndex(index: number): EntryOhos | null
}

export class LineDataSet implements ILineDataSet {
  private entries: JArrayList<BarEntry>
  private label: string

  constructor(entries: JArrayList<BarEntry>, label: string) {
    this.entries = entries
    this.label = label
  }

  setColorsByArr(_colors: number[]): void {}
  setLineWidth(_value: number): void {}
  setDrawCircles(_value: boolean): void {}
  setDrawValues(_value: boolean): void {}
  setAxisDependency(_value: AxisDependency): void {}

  getEntryCount(): number {
    return this.entries.size()
  }

  getEntryForIndex(index: number): EntryOhos | null {
    return this.entries.get(index)
  }
}

export class BarDataSet {
  private entries: JArrayList<BarEntry>
  private label: string

  constructor(entries: JArrayList<BarEntry>, label: string) {
    this.entries = entries
    this.label = label
  }

  setColorsByArr(_colors: number[]): void {}
  setDrawValues(_value: boolean): void {}
}

export class LineData {
  private dataSets: ILineDataSet[] = []

  addDataSet(dataSet: ILineDataSet): void {
    this.dataSets.push(dataSet)
  }

  getDataSetCount(): number {
    return this.dataSets.length
  }

  getDataSetByIndex(index: number): ILineDataSet | null {
    return index >= 0 && index < this.dataSets.length ? this.dataSets[index] : null
  }
}

export class BarData {
  private dataSets: BarDataSet[] = []

  addDataSet(dataSet: BarDataSet): void {
    this.dataSets.push(dataSet)
  }
}

class ChartModelBase<T> {
  private xAxis: XAxis = new XAxis()
  private leftAxis: YAxis = new YAxis()
  private rightAxis: YAxis = new YAxis()
  private legend: Legend = new Legend()
  private data: T | null = null
  private listener?: OnChartValueSelectedListener

  setDescription(_description: Description): void {}
  getLegend(): Legend {
    return this.legend
  }
  getXAxis(): XAxis {
    return this.xAxis
  }
  getAxisLeft(): YAxis {
    return this.leftAxis
  }
  getAxisRight(): YAxis {
    return this.rightAxis
  }
  setTouchEnabled(_value: boolean): void {}
  setDragEnabled(_value: boolean): void {}
  setScaleXEnabled(_value: boolean): void {}
  setScaleYEnabled(_value: boolean): void {}
  setPinchZoom(_value: boolean): void {}
  setDoubleTapToZoomEnabled(_value: boolean): void {}
  setOnChartValueSelectedListener(listener: OnChartValueSelectedListener): void {
    this.listener = listener
  }
  animateY(_duration: number): void {}
  invalidate(): void {}
  setData(data: T): void {
    this.data = data
  }
  getData(): T | null {
    return this.data
  }
}

export class LineChartModel extends ChartModelBase<LineData> {
}

export class BarChartModel extends ChartModelBase<BarData> {
}

@Component
export struct LineChart {
  @Prop model: LineChartModel = new LineChartModel()

  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#fff7f7f7')
  }
}

@Component
export struct BarChart {
  @Prop model: BarChartModel = new BarChartModel()

  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#fff7f7f7')
  }
}
