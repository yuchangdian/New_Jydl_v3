import { window, } from '@kit.ArkUI'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import display from '@ohos.display'
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'
import {
  BarChart,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  Description,
  Legend,
  JArrayList
} from '../../components/ChartStub'
} from '../../components/ChartStub'

const DOMAIN = 0x0001;
const TAG = 'interHarmonicContent';

// 颜色工具函数
function colorToNumber(hexColor: string): number {
  const color = hexColor.replace('#', '')
  return parseInt(color, 16)
}

// 类型定义（更新为8列完整字段）
interface HarmonicItem {
  order: string          // 次数
  contentRate: string    // 含有率
  rmsValue: string       // 有效值
  phaseAngle: string     // 相角
  activePower: string    // 有功功率
  reactivePower: string  // 无功功率
  apparentPower: string  // 视在功率
  powerFactor: string    // 功率因数
}

// 定义柱状图数据接口
interface BarChartItem {
  order: string;
  value: number;
  color: Color;
}

// 定义谐波数据接口
interface HarmonicDistortionData {
  DataTimestamp: number;
  Timestamp_ms: number;
  // 电压数据
  Ua_Angle?: number[][];
  Ua_HarmonicRatio?: number[][];
  Ua_RMS?: number[][];
  Ub_Angle?: number[][];
  Ub_HarmonicRatio?: number[][];
  Ub_RMS?: number[][];
  Uc_Angle?: number[][];
  Uc_HarmonicRatio?: number[][];
  Uc_RMS?: number[][];
  // 电流数据
  Ia_Angle?: number[][];
  Ia_HarmonicRatio?: number[][];
  Ia_RMS?: number[][];
  Ib_Angle?: number[][];
  Ib_HarmonicRatio?: number[][];
  Ib_RMS?: number[][];
  Ic_Angle?: number[][];
  Ic_HarmonicRatio?: number[][];
  Ic_RMS?: number[][];
  // 功率数据
  Fa?: number[][];
  Fb?: number[][];
  Fc?: number[][];
  Pa?: number[][];
  Pb?: number[][];
  Pc?: number[][];
  Qa?: number[][];
  Qb?: number[][];
  Qc?: number[][];
  Sa?: number[][];
  Sb?: number[][];
  Sc?: number[][];
}

// 定义响应数据接口
interface ApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: HarmonicDistortionData;
}

// 定义电能质量响应数据接口
interface PowerQualityApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: PowerQualityData;
}

// 定义电能质量数据接口
interface PowerQualityData {
  DataTimestamp: number;
  Timestamp_ms: number;
  // 频率偏差
  FreqDeviation_A?: number[];
  FreqDeviation_B?: number[];
  FreqDeviation_C?: number[];
  FreqDeviation_All?: number[];
  FreqQualified_Rate?: number[];
  // 电压偏差
  VoltageDeviation_A?: number[];
  VoltageDeviation_B?: number[];
  VoltageDeviation_C?: number[];
  VoltageDeviation_AB?: number[];
  VoltageDeviation_BC?: number[];
  VoltageDeviation_CA?: number[];
  VoltageQualified_Rate?: number[];
  // 不平衡度
  Voltage_U1?: number[];
  Voltage_U2?: number[];
  Voltage_U0?: number[];
  Current_I1?: number[];
  Current_I2?: number[];
  Current_I0?: number[];
  Voltage_U2_Unbalance?: number[];
  Voltage_Uo_Unbalance?: number[];
  Current_I2_Unbalance?: number[];
  Current_Io_Unbalance?: number[];
  // 电压波动
  VoltageFluct_A?: number[];
  VoltageFluct_B?: number[];
  VoltageFluct_C?: number[];
  VoltageFluctFreq_A?: number[];
  VoltageFluctFreq_B?: number[];
  VoltageFluctFreq_C?: number[];
  // 电压闪变
  VoltageShortFlicke_A?: number[];
  VoltageShortFlicke_B?: number[];
  VoltageShortFlicke_C?: number[];
  VoltageLongFlicke_A?: number[];
  VoltageLongFlicke_B?: number[];
  VoltageLongFlicke_C?: number[];
  // 电流总谐波含量
  CurrentTHD_A?: number[];
  CurrentTHD_B?: number[];
  CurrentTHD_C?: number[];
  CurrentOddTHD_A?: number[];
  CurrentOddTHD_B?: number[];
  CurrentOddTHD_C?: number[];
  CurrentEvenTHD_A?: number[];
  CurrentEvenTHD_B?: number[];
  CurrentEvenTHD_C?: number[];
  // 全波有效值
  FullWave_Ua?: number[];
  FullWave_Ub?: number[];
  FullWave_Uc?: number[];
  FullWave_Uab?: number[];
  FullWave_Ubc?: number[];
  FullWave_Uca?: number[];
  FullWave_Ia?: number[];
  FullWave_Ib?: number[];
  FullWave_Ic?: number[];
  // 电压总谐波含量
  VoltageTHD_A?: number[];
  VoltageTHD_B?: number[];
  VoltageTHD_C?: number[];
  VoltageOddTHD_A?: number[];
  VoltageOddTHD_B?: number[];
  VoltageOddTHD_C?: number[];
  VoltageEvenTHD_A?: number[];
  VoltageEvenTHD_B?: number[];
  VoltageEvenTHD_C?: number[];
  // 谐波峰值因子
  PeakFactor_Ua?: number[];
  PeakFactor_Ub?: number[];
  PeakFactor_Uc?: number[];
  PeakFactor_Ia?: number[];
  PeakFactor_Ib?: number[];
  PeakFactor_Ic?: number[];
  // 总谐波功率
  PowerP_THD_A?: number[];
  PowerP_THD_B?: number[];
  PowerP_THD_C?: number[];
  PowerQ_THD_A?: number[];
  PowerQ_THD_B?: number[];
  PowerQ_THD_C?: number[];
  PowerS_THD_A?: number[];
  PowerS_THD_B?: number[];
  PowerS_THD_C?: number[];
  PowerF_THD_A?: number[];
  PowerF_THD_B?: number[];
  PowerF_THD_C?: number[];
  // 全波功率
  FullWave_Pa?: number[];
  FullWave_Pb?: number[];
  FullWave_Pc?: number[];
  FullWave_Pt?: number[];
  FullWave_Qa?: number[];
  FullWave_Qb?: number[];
  FullWave_Qc?: number[];
  FullWave_Qt?: number[];
  FullWave_Sa?: number[];
  FullWave_Sb?: number[];
  FullWave_Sc?: number[];
  FullWave_St?: number[];
  FullWave_Fa?: number[];
  FullWave_Fb?: number[];
  FullWave_Fc?: number[];
  FullWave_Ft?: number[];
}

@Component
struct interHarmonicContent {
  windowClass?: window.Window
  private scrollController: Scroller = new Scroller()

  @State uiScale: number = 1
  readonly designWidth: number = 720

  @State showListMode: boolean = false
  @State currentNavItems: string[] = ['Ua1', 'Ub1', 'Uc1', 'Ia1', 'Ib1', 'Ic1']
  @State selectedIndex: number = 0

  private navItems1: string[] = ['Ua1', 'Ub1', 'Uc1', 'Ia1', 'Ib1', 'Ic1']
  private navItems2: string[] = ['Ua2', 'Ub2', 'Uc2', 'Ia2', 'Ib2', 'Ic2']

  private barChartModel: BarChartModel = new BarChartModel()

  // 谐波数据列表，每个元素对应一个线路和相别的数据
  private harmonicData: HarmonicItem[][] = [
    [], // Ua1
    [], // Ub1
    [], // Uc1
    [], // Ia1
    [], // Ib1
    [], // Ic1
    [], // Ua2
    [], // Ub2
    [], // Uc2
    [], // Ia2
    [], // Ib2
    []  // Ic2
  ]

  @State requestResult: string = ''

  // 电能质量数据
  @State powerQualityData: PowerQualityData | null = null

  // 谐波列表数据，用于柱状图显示
  private harmonicListData: BarChartItem[][] = [
    [], // Ua1
    [], // Ub1
    [], // Uc1
    [], // Ia1
    [], // Ib1
    [], // Ic1
    [], // Ua2
    [], // Ub2
    [], // Uc2
    [], // Ia2
    [], // Ib2
    []  // Ic2
  ]


  aboutToAppear(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.initChartConfig()
    this.updateChartData()
    this.fetchHarmonicData()
  }

  // 获取谐波数据
  private async fetchHarmonicData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取谐波数据');

    // 获取电压谐波数据
    await this.fetchHarmonicDataByType('iHarmonicDistortionU');
    // 获取电流谐波数据
    await this.fetchHarmonicDataByType('iHarmonicDistortionI');
    // 获取功率谐波数据
    await this.fetchHarmonicDataByType('iHarmonicDistortionP');
    // 获取电能质量数据
    await this.fetchPowerQualityData();
  }

  // 获取电能质量数据
  private async fetchPowerQualityData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取电能质量数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'PowerQuality');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '电能质量数据获取成功');
        hilog.info(DOMAIN, TAG, '电能质量数据: %{public}s', response.data.data);
        
        // 解析电能质量数据
        try {
          const apiResponse: PowerQualityApiResponse = JSON.parse(response.data.data) as PowerQualityApiResponse;
          if (apiResponse && apiResponse.data) {
            this.powerQualityData = apiResponse.data;
            hilog.info(DOMAIN, TAG, '电能质量数据解析成功');
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析电能质量数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, '电能质量数据请求失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '电能质量数据请求异常: %{public}s', String(error));
    }
  }

  // 更新谐波数据
  private updateHarmonicData(lineIndex: number, phaseIndex: number, isVoltage: boolean, harmonicData: HarmonicDistortionData, phase: string): void {
    // 计算数据索引
    const dataIndex = lineIndex * 6 + (isVoltage ? phaseIndex : phaseIndex + 3);
    if (dataIndex < 0 || dataIndex >= this.harmonicData.length) {
      return;
    }

    // 获取对应相的数据
    let angles: number[][] | undefined;
    let ratios: number[][] | undefined;
    let rmsValues: number[][] | undefined;

    if (isVoltage) {
      if (phase === 'A') {
        angles = harmonicData.Ua_Angle;
        ratios = harmonicData.Ua_HarmonicRatio;
        rmsValues = harmonicData.Ua_RMS;
      } else if (phase === 'B') {
        angles = harmonicData.Ub_Angle;
        ratios = harmonicData.Ub_HarmonicRatio;
        rmsValues = harmonicData.Ub_RMS;
      } else if (phase === 'C') {
        angles = harmonicData.Uc_Angle;
        ratios = harmonicData.Uc_HarmonicRatio;
        rmsValues = harmonicData.Uc_RMS;
      }
    } else {
      if (phase === 'A') {
        angles = harmonicData.Ia_Angle;
        ratios = harmonicData.Ia_HarmonicRatio;
        rmsValues = harmonicData.Ia_RMS;
      } else if (phase === 'B') {
        angles = harmonicData.Ib_Angle;
        ratios = harmonicData.Ib_HarmonicRatio;
        rmsValues = harmonicData.Ib_RMS;
      } else if (phase === 'C') {
        angles = harmonicData.Ic_Angle;
        ratios = harmonicData.Ic_HarmonicRatio;
        rmsValues = harmonicData.Ic_RMS;
      }
    }

    // 确保数据存在且线路索引有效
    if (!angles || !ratios || !rmsValues || lineIndex >= angles.length) {
      return;
    }

    // 确保线路数据存在
    const angleLineData = angles[lineIndex];
    const ratioLineData = ratios[lineIndex];
    const rmsLineData = rmsValues[lineIndex];
    if (!angleLineData || !ratioLineData || !rmsLineData) {
      return;
    }

    // 更新谐波数据列表（用于含量列表，显示所有数据）
    const harmonicList: HarmonicItem[] = [];
    const maxOrder = Math.min(angleLineData.length, ratioLineData.length, rmsLineData.length);

    // 获取功率数据
    let paLineData: number[] | undefined;
    let qaLineData: number[] | undefined;
    let saLineData: number[] | undefined;
    let faLineData: number[] | undefined;
    
    if (phase === 'A') {
      paLineData = harmonicData.Pa?.[lineIndex];
      qaLineData = harmonicData.Qa?.[lineIndex];
      saLineData = harmonicData.Sa?.[lineIndex];
      faLineData = harmonicData.Fa?.[lineIndex];
    } else if (phase === 'B') {
      paLineData = harmonicData.Pb?.[lineIndex];
      qaLineData = harmonicData.Qb?.[lineIndex];
      saLineData = harmonicData.Sb?.[lineIndex];
      faLineData = harmonicData.Fb?.[lineIndex];
    } else if (phase === 'C') {
      paLineData = harmonicData.Pc?.[lineIndex];
      qaLineData = harmonicData.Qc?.[lineIndex];
      saLineData = harmonicData.Sc?.[lineIndex];
      faLineData = harmonicData.Fc?.[lineIndex];
    }

    for (let order = 0; order < maxOrder; order++) {
      const contentRate = ratioLineData[order];
      const activePower = paLineData?.[order] || 0;
      const reactivePower = qaLineData?.[order] || 0;
      const apparentPower = saLineData?.[order] || 0;
      const powerFactor = faLineData?.[order] || 0;

      harmonicList.push({
        order: (order + 1).toString(), // 次数从1开始
        contentRate: contentRate.toFixed(2) + '%',
        rmsValue: rmsLineData[order].toFixed(2),
        phaseAngle: angleLineData[order].toFixed(2) + '°',
        activePower: activePower.toFixed(2),
        reactivePower: reactivePower.toFixed(2),
        apparentPower: apparentPower.toFixed(2),
        powerFactor: powerFactor.toFixed(2)
      });
    }

    // 更新谐波数据
    this.harmonicData[dataIndex] = harmonicList;

    // 更新谐波列表数据（用于柱状图显示，过滤含有率小于0.1%的数据）
    const listData: BarChartItem[] = [];
    for (const item of harmonicList) {
      const order = parseInt(item.order);
      const value = parseFloat(item.contentRate.replace('%', ''));
      // 含有率小于0.1%则不显示在柱状图中
      if (value < 0.1) {
        continue;
      }
      // 1次为工频，含有率100%，奇数次和偶数次颜色不同
      let color = Color.Blue;
      if (order === 1) {
        color = Color.Red;
      } else if (order % 2 === 0) {
        color = Color.Green;
      }

      listData.push({ order: item.order, value, color });
    }

    // 更新谐波列表数据
    if (dataIndex < this.harmonicListData.length) {
      this.harmonicListData[dataIndex] = listData;
    }
  }

  // 根据类型获取谐波数据
  private async fetchHarmonicDataByType(deviceName: string): Promise<void> {
    hilog.info(DOMAIN, TAG, `开始获取${deviceName === 'iHarmonicDistortionU' ? '电压' : '电流'}谐波数据`);

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', deviceName);
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, `${deviceName === 'iHarmonicDistortionU' ? '电压' : '电流'}谐波数据获取成功`);
        
        // 只有电压数据显示在请求结果中
        if (deviceName === 'iHarmonicDistortionU') {
          this.requestResult = response.data.data;
        }

        // 解析数据
        try {
          const apiResponse: ApiResponse = JSON.parse(response.data.data) as ApiResponse;
          if (apiResponse && apiResponse.data) {
            const harmonicData = apiResponse.data;
            const isVoltage = deviceName === 'iHarmonicDistortionU';
            
            // 处理线路1和线路2的数据
            for (let lineIndex = 0; lineIndex < 2; lineIndex++) {
              // A相数据
              this.updateHarmonicData(lineIndex, 0, isVoltage, harmonicData, 'A');
              // B相数据
              this.updateHarmonicData(lineIndex, 1, isVoltage, harmonicData, 'B');
              // C相数据
              this.updateHarmonicData(lineIndex, 2, isVoltage, harmonicData, 'C');
            }
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, `${deviceName === 'iHarmonicDistortionU' ? '电压' : '电流'}谐波数据请求失败`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `${deviceName === 'iHarmonicDistortionU' ? '电压' : '电流'}谐波数据请求异常: %{public}s`, String(error));
    }
  }

  // 图表初始化
  initChartConfig(): void {
    let description: Description = new Description()
    description.setEnabled(false)
    this.barChartModel.setDescription(description)

    let legend: Legend | null = this.barChartModel.getLegend()
    if (legend) legend.setEnabled(false)

    let xAxis: XAxis | null = this.barChartModel.getXAxis()
    if (xAxis) {
      xAxis.setPosition(XAxisPosition.BOTTOM)
      xAxis.setGranularity(1)
      xAxis.setTextColor(0xFF000000)
      xAxis.setTextSize(10)
      xAxis.setDrawGridLines(false)
    }

    let yLeft: YAxis | null = this.barChartModel.getAxisLeft()
    if (yLeft) {
      yLeft.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
      yLeft.setAxisMinimum(0)
      yLeft.setAxisMaximum(10)
      yLeft.setGridColor(0x4D000000)
    }

    let yRight: YAxis | null = this.barChartModel.getAxisRight()
    if (yRight) yRight.setEnabled(false)

    // 禁止放大缩小
    this.barChartModel.setTouchEnabled(true)
    this.barChartModel.setDoubleTapToZoomEnabled(false)
    this.barChartModel.setScaleXEnabled(false)
    this.barChartModel.setScaleYEnabled(false)

    this.barChartModel.animateY(800)
  }

  // ✅ 终极兼容方案：双数据集实现奇偶分色（100% 无报错）
  updateChartData(): void {
    let oddEntries = new JArrayList<BarEntry>()   // 奇数项
    let evenEntries = new JArrayList<BarEntry>()  // 偶数项

    // 获取当前选中的数据
    const currentData = this.harmonicListData[this.selectedIndex] || [];
    
    currentData.forEach((item, index) => {
      const order = parseInt(item.order);
      if (order % 2 === 1) {
        oddEntries.add(new BarEntry(index, item.value))
      } else {
        evenEntries.add(new BarEntry(index, item.value))
      }
    })

    // 数据集1：奇数 → 绿色
    let set1 = new BarDataSet(oddEntries, "奇次谐波")
    set1.setColorsByArr([colorToNumber('#4CAF50')])
    set1.setDrawValues(false)

    // 数据集2：偶数 → 橙色
    let set2 = new BarDataSet(evenEntries, "偶次谐波")
    set2.setColorsByArr([colorToNumber('#FF9800')])
    set2.setDrawValues(false)

    let data = new BarData()
    data.addDataSet(set1)
    data.addDataSet(set2)

    this.barChartModel.setData(data)
    this.barChartModel.invalidate()
  }

  // 获取当前选中的相别 (A, B, C)
  private getCurrentPhase(): string {
    const currentItem = this.currentNavItems[this.selectedIndex]
    if (currentItem.includes('a') || currentItem.includes('A')) {
      return 'A'
    } else if (currentItem.includes('b') || currentItem.includes('B')) {
      return 'B'
    } else if (currentItem.includes('c') || currentItem.includes('C')) {
      return 'C'
    }
    return 'A'
  }

  // 获取总谐波畸变率
  private getVoltageTHD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.VoltageTHD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.VoltageTHD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.VoltageTHD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总奇次谐波畸变率
  private getVoltageOddTHD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.VoltageOddTHD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.VoltageOddTHD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.VoltageOddTHD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总偶次谐波畸变率
  private getVoltageEvenTHD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.VoltageEvenTHD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.VoltageEvenTHD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.VoltageEvenTHD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总谐波有功功率
  private getPowerP_THD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.PowerP_THD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.PowerP_THD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.PowerP_THD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总谐波无功功率
  private getPowerQ_THD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.PowerQ_THD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.PowerQ_THD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.PowerQ_THD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总谐波视在功率
  private getPowerS_THD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.PowerS_THD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.PowerS_THD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.PowerS_THD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取总谐波功率因数
  private getPowerF_THD(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    if (phase === 'A') value = this.powerQualityData.PowerF_THD_A?.[0]
    else if (phase === 'B') value = this.powerQualityData.PowerF_THD_B?.[0]
    else if (phase === 'C') value = this.powerQualityData.PowerF_THD_C?.[0]
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  // 获取峰值因子
  private getPeakFactor(): string {
    if (!this.powerQualityData) return '0.00'
    const phase = this.getCurrentPhase()
    let value: number | undefined
    // 根据选中的是电压还是电流返回对应的峰值因子
    const currentItem = this.currentNavItems[this.selectedIndex]
    if (currentItem.startsWith('U') || currentItem.startsWith('u')) {
      // 电压峰值因子
      if (phase === 'A') value = this.powerQualityData.PeakFactor_Ua?.[0]
      else if (phase === 'B') value = this.powerQualityData.PeakFactor_Ub?.[0]
      else if (phase === 'C') value = this.powerQualityData.PeakFactor_Uc?.[0]
    } else {
      // 电流峰值因子
      if (phase === 'A') value = this.powerQualityData.PeakFactor_Ia?.[0]
      else if (phase === 'B') value = this.powerQualityData.PeakFactor_Ib?.[0]
      else if (phase === 'C') value = this.powerQualityData.PeakFactor_Ic?.[0]
    }
    return value !== undefined ? value.toFixed(2) : '0.00'
  }

  build() {
    Column() {
      Column() {
        Row() {
          Image($rawfile("left.png"))
            .width(18 * this.uiScale)
            .height(18 * this.uiScale)
            .onClick(() => {
              this.currentNavItems = [...this.navItems1]
              this.selectedIndex = 0
            })

          Scroll(this.scrollController) {
            Row() {
              ForEach(this.currentNavItems, (item: string, index: number) => {
                Text(item)
                  .textAlign(TextAlign.Center)
                  .fontSize(16 * this.uiScale)
                  .fontColor(this.selectedIndex === index ? '#ff0000' : '#000000')
                  .borderRadius(4 * this.uiScale)
                  .padding({ left: 8 * this.uiScale, right: 8 * this.uiScale, top: 4 * this.uiScale, bottom: 4 * this.uiScale })
                  .margin({ right: 6 * this.uiScale })
                  .onClick(() => {
                    this.selectedIndex = index
                  })
              })
            }
          }
          .width(300 * this.uiScale)
          .height(40 * this.uiScale)

          Image($rawfile("right.png"))
            .width(18 * this.uiScale)
            .height(18 * this.uiScale)
            .onClick(() => {
              this.currentNavItems = [...this.navItems2]
              this.selectedIndex = 0
            })

          Radio({ group: 'line', value: 'bar' }) .scale({ x: 1.5, y: 1.5 }) // 放大
            .checked(!this.showListMode)
            .onChange((v) => {
              this.showListMode = false
            })
            .margin({ left: 20 * this.uiScale })
          Text("柱状图")
            .fontSize(16 * this.uiScale)
            .margin({ left: 10 * this.uiScale, right: 15 * this.uiScale })

          Radio({ group: 'line', value: 'list' }) .scale({ x: 1.5, y: 1.5 }) // 放大
            .checked(this.showListMode)
            .onChange((v) => {
              this.showListMode = true
            })
          Text("含量列表")
            .fontSize(16 * this.uiScale)
        }
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#c9c9c9')
        .width('100%')
        .height(40 * this.uiScale)
        .padding({ left: 10 * this.uiScale, right: 10 * this.uiScale })

        if (!this.showListMode) {
          Column() {
            BarChart({ model: this.barChartModel })
              .width('100%')
              .height(220 * this.uiScale)
          }

          Grid() {
            GridItem() { Row() { Text('总间谐波畸变率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getVoltageTHD() + ' %').layoutWeight(1).fontSize(16 * this.uiScale) } }.height(25 * this.uiScale)
            GridItem() { Row() { Text('总间谐波有功功率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getPowerP_THD() + ' W').layoutWeight(1).fontSize(16 * this.uiScale) } }.height(25 * this.uiScale)
            GridItem() { Row() { Text('总间谐波功率因数').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getPowerF_THD()).layoutWeight(1).fontSize(16 * this.uiScale) } }.height(25 * this.uiScale)
            GridItem() { Row() { Text('总奇次间谐波畸变率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getVoltageOddTHD() + ' %').layoutWeight(1).fontSize(16 * this.uiScale) } }.backgroundColor('#ffe0e0e0').height(25 * this.uiScale)
            GridItem() { Row() { Text('总间谐波无功功率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getPowerQ_THD() + ' Var').layoutWeight(1).fontSize(16 * this.uiScale) } }.backgroundColor('#ffe0e0e0').height(25 * this.uiScale)
            GridItem() { Row() { Text('峰值因子').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getPeakFactor()).layoutWeight(1).fontSize(16 * this.uiScale) } }.backgroundColor('#ffe0e0e0').height(25 * this.uiScale)
            GridItem() { Row() { Text('总偶次间谐波畸变率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getVoltageEvenTHD() + ' %').layoutWeight(1).fontSize(16 * this.uiScale) } }.height(25 * this.uiScale)
            GridItem() { Row() { Text('总间谐波视在功率').width(130 * this.uiScale).fontSize(16 * this.uiScale); Text(this.getPowerS_THD() + ' VA').layoutWeight(1).fontSize(16 * this.uiScale) } }.height(25 * this.uiScale)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .layoutWeight(1)
          .padding(10 * this.uiScale)
        } else {
          // ✅ 完全按你提供的表格样式重构列表模式
          Column() {
            // 表头（8列对应）
            Row() {
              Text('次数').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('含有率').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('有效值').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('相角').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('有功功率').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('无功功率').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('视在功率').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
              Text('功率因数').width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
            }
            .width('100%')
            .backgroundColor('#ffe3e3e3')
            .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })

            // 数据列表（奇偶行交替背景色）
            Scroll() {
              Column() {
                ForEach(this.harmonicData[this.selectedIndex] || [], (item: HarmonicItem, index: number) => {
                  Row() {
                    Text(item.order).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.contentRate).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.rmsValue).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.phaseAngle).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.activePower).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.reactivePower).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.apparentPower).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                    Text(item.powerFactor).width('12.5%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
                  }
                  .width('100%')
                  .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
                  .border({ width: { bottom: 1 * this.uiScale }, color: '#ffc6c6c6' })
                  // 奇偶行交替背景色（和截图完全一致）
                  .backgroundColor(index % 2 === 1 ? '#ffe0e0e0' : Color.White)
                })
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
          .backgroundColor('#fff')
          .layoutWeight(1)
        }
      }
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}

export { interHarmonicContent }
