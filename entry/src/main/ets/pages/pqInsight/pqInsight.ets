import { window } from '@kit.ArkUI'
import display from '@ohos.display'
import {
  LineChart,
  LineChartModel,
  LineData,
  LineDataSet,
  ILineDataSet,
  BarEntry,
  EntryOhos,
  Highlight,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  AxisDependency,
  Description,
  Legend,
  JArrayList,
  OnChartValueSelectedListener
} from '../../components/ChartStub'

import { CommonTitleBar } from '../../components/CommonTitleBar'
// 自定义线条组件，支持设置粗细和颜色
@Component
struct CustomLine {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  @Prop lineWidth: number = 1.5
  @Prop color: string = '#000000'
  @Prop length: number = 20

  private drawLine() {
    const ctx = this.context
    ctx.clearRect(0, 0, this.length, 10)
    ctx.strokeStyle = this.color
    ctx.lineWidth = this.lineWidth
    ctx.beginPath()
    ctx.moveTo(0, 5)
    ctx.lineTo(this.length, 5)
    ctx.stroke()
  }

  build() {
    Canvas(this.context)
      .width(this.length)
      .height(10)
      .onReady(() => {
        this.drawLine()
      })
  }
}

@Component
struct PQInsight {
  windowClass?: window.Window
  @State isPaused: boolean = false
  @State eventMode: boolean = false
  @State eventText: string = "最近事件: 无"

  @State uaValue: string = "57.25V"
  @State ubValue: string = "57.24V"
  @State ucValue: string = "57.25V"
  @State iaValue: string = "4.100A"
  @State ibValue: string = "4.100A"
  @State icValue: string = "4.100A"

  @State uiScale: number = 1
  readonly designWidth: number = 720

  private lineChartModel: LineChartModel = new LineChartModel()
  private timer: number | null = null

  private readonly COLOR_UA: number = 0xFFFFCC00
  private readonly COLOR_UB: number = 0xFF00D864
  private readonly COLOR_UC: number = 0xFFFF3333
  private readonly COLOR_IA: number = 0x99FFE066
  private readonly COLOR_IB: number = 0x9900D864
  private readonly COLOR_IC: number = 0x99FF3333

  async setFullScreen(flag: boolean): Promise<void> {
    if (!this.windowClass) {
      this.windowClass = await window.getLastWindow(getContext(this))
    }
    this.windowClass.setWindowLayoutFullScreen(flag)
    this.windowClass.setWindowSystemBarEnable([])
  }

  onPageShow(): void {
    this.setFullScreen(true)
  }

  aboutToAppear(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    
    this.initChartConfig()
    this.setChartClickListener()
    this.updateChartData()
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  initChartConfig(): void {
    let description: Description = new Description()
    description.setEnabled(false)
    this.lineChartModel.setDescription(description)

    let legend: Legend | null = this.lineChartModel.getLegend()
    if (legend) {
      legend.setEnabled(false)
    }

    let xAxis: XAxis | null = this.lineChartModel.getXAxis()
    if (xAxis) {
      xAxis.setPosition(XAxisPosition.BOTTOM)
      xAxis.setGranularity(1)
      xAxis.setTextColor(0xFFFFFFFF)
      xAxis.setTextSize(10)
      xAxis.setDrawGridLines(false)
      xAxis.setAxisMinimum(0)
      xAxis.setAxisMaximum(300)
    }

    let leftYAxis: YAxis | null = this.lineChartModel.getAxisLeft()
    if (leftYAxis) {
      leftYAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
      leftYAxis.setAxisMinimum(-80)
      leftYAxis.setAxisMaximum(80)
      leftYAxis.setTextColor(0xFFAAAAAA)
      leftYAxis.setTextSize(10)
      leftYAxis.setGridColor(0xFF222222)
    }

    let rightYAxis: YAxis | null = this.lineChartModel.getAxisRight()
    if (rightYAxis) {
      rightYAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
      rightYAxis.setAxisMinimum(-7)
      rightYAxis.setAxisMaximum(7)
      rightYAxis.setTextColor(0xFFAAAAAA)
      rightYAxis.setTextSize(10)
      rightYAxis.setGridColor(0xFF222222)
    }

    this.lineChartModel.setTouchEnabled(true)
    this.lineChartModel.setDoubleTapToZoomEnabled(false)
    this.lineChartModel.setScaleXEnabled(false)
    this.lineChartModel.setScaleYEnabled(false)
    this.lineChartModel.setDragEnabled(true)
    this.lineChartModel.setPinchZoom(false)
    this.lineChartModel.animateY(800)
  }

  // ✅ 终极修复：getDataSetIndex()
  setChartClickListener(): void {
    const listener: OnChartValueSelectedListener = {
      onValueSelected: (e: EntryOhos, h: Highlight) => {
        const x = h.getX(); // 获取x轴坐标
        const data = this.lineChartModel.getData();
        
        if (data) {
          // 遍历所有数据集，获取对应x位置的值
          for (let i = 0; i < data.getDataSetCount(); i++) {
            const dataSet = data.getDataSetByIndex(i);
            if (dataSet) {
              // 查找x位置最近的数据点
              const entryIndex = this.getEntryIndexByX(dataSet, x);
              if (entryIndex >= 0) {
                const entry = dataSet.getEntryForIndex(entryIndex);
                if (entry) {
                  const y = entry.getY();
                  // 根据数据集索引更新对应的值
                  switch (i) {
                    case 0: this.uaValue = y.toFixed(2) + "V"; break;
                    case 1: this.ubValue = y.toFixed(2) + "V"; break;
                    case 2: this.ucValue = y.toFixed(2) + "V"; break;
                    case 3: this.iaValue = y.toFixed(3) + "A"; break;
                    case 4: this.ibValue = y.toFixed(3) + "A"; break;
                    case 5: this.icValue = y.toFixed(3) + "A"; break;
                  }
                }
              }
            }
          }
        }
      },
      onNothingSelected: () => {}
    };
    this.lineChartModel.setOnChartValueSelectedListener(listener);
  }

  // 根据x坐标查找最近的entry索引
  getEntryIndexByX(dataSet: ILineDataSet, x: number): number {
    let closestIndex = -1;
    let minDistance = Number.MAX_VALUE;
    
    for (let i = 0; i < dataSet.getEntryCount(); i++) {
      const entry = dataSet.getEntryForIndex(i);
      if (entry) {
        const entryX = entry.getX();
        const distance = Math.abs(entryX - x);
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }
    }
    return closestIndex;
  }

  // 获取图表初始数据点值，更新顶部显示
  getInitialValues(): void {
    const data = this.lineChartModel.getData();
    if (data) {
      // 遍历所有数据集，获取第一个数据点的值
      for (let i = 0; i < data.getDataSetCount(); i++) {
        const dataSet = data.getDataSetByIndex(i);
        if (dataSet && dataSet.getEntryCount() > 0) {
          const entry = dataSet.getEntryForIndex(0);
          if (entry) {
            const y = entry.getY();
            // 根据数据集索引更新对应的值
            switch (i) {
              case 0: this.uaValue = y.toFixed(2) + "V"; break;
              case 1: this.ubValue = y.toFixed(2) + "V"; break;
              case 2: this.ucValue = y.toFixed(2) + "V"; break;
              case 3: this.iaValue = y.toFixed(3) + "A"; break;
              case 4: this.ibValue = y.toFixed(3) + "A"; break;
              case 5: this.icValue = y.toFixed(3) + "A"; break;
            }
          }
        }
      }
    }
  }

  genNormalData(): JArrayList<BarEntry>[] {
    let uaData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ubData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ucData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let iaData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ibData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let icData: JArrayList<BarEntry> = new JArrayList<BarEntry>()

    for (let i: number = 0; i < 300; i++) {
      const t: number = i / 300 * 4 * Math.PI
      uaData.add(new BarEntry(i, 57.25 * Math.sin(t)))
      ubData.add(new BarEntry(i, 57.24 * Math.sin(t + 2 * Math.PI / 3)))
      ucData.add(new BarEntry(i, 57.25 * Math.sin(t + 4 * Math.PI / 3)))
      iaData.add(new BarEntry(i, 4.1 * Math.sin(t)))
      ibData.add(new BarEntry(i, 4.1 * Math.sin(t + 2 * Math.PI / 3)))
      icData.add(new BarEntry(i, 4.1 * Math.sin(t + 4 * Math.PI / 3)))
    }
    return [uaData, ubData, ucData, iaData, ibData, icData]
  }

  genEventData(): JArrayList<BarEntry>[] {
    let uaData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ubData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ucData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let iaData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let ibData: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    let icData: JArrayList<BarEntry> = new JArrayList<BarEntry>()

    for (let i: number = 0; i < 300; i++) {
      const t: number = i / 300 * 4 * Math.PI
      let uc: number = 57.25 * Math.sin(t + 4 * Math.PI / 3)
      if (i > 100 && i < 200) uc = 0
      uaData.add(new BarEntry(i, 57.25 * Math.sin(t)))
      ubData.add(new BarEntry(i, 57.24 * Math.sin(t + 2 * Math.PI / 3)))
      ucData.add(new BarEntry(i, uc))
      iaData.add(new BarEntry(i, 4.958 * Math.sin(t)))
      ibData.add(new BarEntry(i, 4.958 * Math.sin(t + 2 * Math.PI / 3)))
      icData.add(new BarEntry(i, 4.958 * Math.sin(t + 4 * Math.PI / 3)))
    }
    return [uaData, ubData, ucData, iaData, ibData, icData]
  }

  updateChartData(): void {
    const dataLists: JArrayList<BarEntry>[] = this.eventMode ? this.genEventData() : this.genNormalData()

    let uaDataSet: LineDataSet = new LineDataSet(dataLists[0], 'Ua')
    uaDataSet.setColorsByArr([this.COLOR_UA])
    uaDataSet.setLineWidth(2)
    uaDataSet.setDrawCircles(false)
    uaDataSet.setDrawValues(false)

    let ubDataSet: LineDataSet = new LineDataSet(dataLists[1], 'Ub')
    ubDataSet.setColorsByArr([this.COLOR_UB])
    ubDataSet.setLineWidth(2)
    ubDataSet.setDrawCircles(false)
    ubDataSet.setDrawValues(false)

    let ucDataSet: LineDataSet = new LineDataSet(dataLists[2], 'Uc')
    ucDataSet.setColorsByArr([this.COLOR_UC])
    ucDataSet.setLineWidth(2)
    ucDataSet.setDrawCircles(false)
    ucDataSet.setDrawValues(false)

    let iaDataSet: LineDataSet = new LineDataSet(dataLists[3], 'Ia')
    iaDataSet.setColorsByArr([this.COLOR_IA])
    iaDataSet.setLineWidth(1.5)
    iaDataSet.setDrawCircles(false)
    iaDataSet.setDrawValues(false)
    iaDataSet.setAxisDependency(AxisDependency.RIGHT)

    let ibDataSet: LineDataSet = new LineDataSet(dataLists[4], 'Ib')
    ibDataSet.setColorsByArr([this.COLOR_IB])
    ibDataSet.setLineWidth(1.5)
    ibDataSet.setDrawCircles(false)
    ibDataSet.setDrawValues(false)
    ibDataSet.setAxisDependency(AxisDependency.RIGHT)

    let icDataSet: LineDataSet = new LineDataSet(dataLists[5], 'Ic')
    icDataSet.setColorsByArr([this.COLOR_IC])
    icDataSet.setLineWidth(1.5)
    icDataSet.setDrawCircles(false)
    icDataSet.setDrawValues(false)
    icDataSet.setAxisDependency(AxisDependency.RIGHT)

    let data: LineData = new LineData()
    data.addDataSet(uaDataSet)
    data.addDataSet(ubDataSet)
    data.addDataSet(ucDataSet)
    data.addDataSet(iaDataSet)
    data.addDataSet(ibDataSet)
    data.addDataSet(icDataSet)

    this.lineChartModel.setData(data)
    this.lineChartModel.invalidate()
    
    // 更新顶部显示值
    this.getInitialValues()
  }

  togglePause(): void {
    this.isPaused = !this.isPaused
  }

  triggerEvent(): void {
    this.eventMode = !this.eventMode
    const now: Date = new Date()
    const h: string = now.getHours().toString().padStart(2, '0')
    const m: string = now.getMinutes().toString().padStart(2, '0')
    const s: string = now.getSeconds().toString().padStart(2, '0')
    this.eventText = `最近事件: ${h}:${m}:${s} C相电压中断`
    this.updateChartData()
  }

  build() {
    Column() {
        Column() {
          Column() {
            LineChart({ model: this.lineChartModel })
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height(280 * this.uiScale)
        }
      Column(){
        Row() {
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#ffffd800',
              length: 30 * this.uiScale
            })
            Text('Ua')
              .fontColor('#ffffd800')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx V')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)

          } .margin({right:20 * this.uiScale})
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#39b54a',
              length: 30 * this.uiScale
            })
            Text('Ub')
              .fontColor('#39b54a')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx V')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)
          }
          .margin({right:20 * this.uiScale})
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#ffff0000',
              length: 30 * this.uiScale
            })
            Text('Uc')
              .fontColor('#ffff0000')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx A')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)

          }
        }
        }          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })  .padding({top:6 * this.uiScale,bottom:5 * this.uiScale})
      Column(){
        Row() {
          Row() {
            CustomLine({
              lineWidth: 2,
              color: '#baffd800',
              length: 30 * this.uiScale
            })
            Text('Ia')
              .fontColor('#baffd800')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx A')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)

          } .margin({right:20 * this.uiScale})
          Row() {
            CustomLine({
              lineWidth: 2,
              color: '#a939b54a',
              length: 30 * this.uiScale
            })
            Text('Ib')
              .fontColor('#a939b54a')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx A')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)
          } .margin({right:20 * this.uiScale})
          Row() {
            CustomLine({
              lineWidth:2,
              color: '#95ff0000',
              length: 30 * this.uiScale
            })
            Text('Ic')
              .fontColor('#95ff0000')
              .fontWeight(FontWeight.Bold)
              .fontSize(16 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text('xxx.xx A')
              .fontColor('#ff000000')
              .fontSize(16 * this.uiScale)
              .width(70 * this.uiScale)

          }
        }
      }          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })
      .padding({top:6 * this.uiScale,bottom:5 * this.uiScale})
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  channelItem(name: string, color: number) {
    Row() {
      Column().width(10 * this.uiScale).height(10 * this.uiScale).backgroundColor(color).borderRadius(2 * this.uiScale)
      Text(name).fontSize(16 * this.uiScale).fontColor('#000').margin({ left:10 * this.uiScale })
    }
    .margin({ bottom:12 * this.uiScale })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  topItem(name: string, value: string, color: number) {
    Row() {
      Column().width(16 * this.uiScale).height(3 * this.uiScale).backgroundColor(color).borderRadius(2 * this.uiScale)
      Text(`${name} ${value}`).fontSize(12 * this.uiScale).margin({ left:10 * this.uiScale }).fontColor('#000')
    }
  }
}
export {PQInsight}
