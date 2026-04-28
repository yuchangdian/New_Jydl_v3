// 偏差界面

import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'

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
}

// 定义电能质量响应数据接口
interface PowerQualityApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: PowerQualityData;
}

const DOMAIN = 0x0001;
const TAG = 'VoltageMonitoring';

@Component
struct VoltageMonitoring {
  @State uiScale: number = 1
  readonly designWidth: number = 720

  @State activeTab: number = 1
  @State requestResult: string = ''
  @State powerQualityData: PowerQualityData | null = null

  aboutToAppear() {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.fetchVoltageData()
  }

  // 获取偏差数据
  private async fetchVoltageData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取偏差数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'PowerQuality');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '偏差数据获取成功');
        
        // 解析数据
        try {
          const apiResponse: PowerQualityApiResponse = JSON.parse(response.data.data) as PowerQualityApiResponse;
          if (apiResponse && apiResponse.data) {
            this.powerQualityData = apiResponse.data;
            hilog.info(DOMAIN, TAG, '偏差数据解析成功');
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析偏差数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, '偏差数据请求失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '偏差数据请求异常: %{public}s', String(error));
    }
  }

  // 获取电压偏差上值（正数）
  private getVoltageDeviationUpper(phase: string): string {
    if (!this.powerQualityData) return '0.00%'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageDeviation_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageDeviation_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageDeviation_C?.[0]
        break
      case 'AB':
        value = this.powerQualityData.VoltageDeviation_AB?.[0]
        break
      case 'BC':
        value = this.powerQualityData.VoltageDeviation_BC?.[0]
        break
      case 'CA':
        value = this.powerQualityData.VoltageDeviation_CA?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.00%'
    return value > 0 ? value.toFixed(2) + '%' : '0.00%'
  }

  // 获取电压偏差下值（绝对值）
  private getVoltageDeviationLower(phase: string): string {
    if (!this.powerQualityData) return '0.00%'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageDeviation_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageDeviation_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageDeviation_C?.[0]
        break
      case 'AB':
        value = this.powerQualityData.VoltageDeviation_AB?.[0]
        break
      case 'BC':
        value = this.powerQualityData.VoltageDeviation_BC?.[0]
        break
      case 'CA':
        value = this.powerQualityData.VoltageDeviation_CA?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.00%'
    return value < 0 ? Math.abs(value).toFixed(2) + '%' : '0.00%'
  }

  // 获取频率偏差
  private getFreqDeviation(phase: string): string {
    if (!this.powerQualityData) return '0.000Hz'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.FreqDeviation_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.FreqDeviation_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.FreqDeviation_C?.[0]
        break
      case 'All':
        value = this.powerQualityData.FreqDeviation_All?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.000Hz'
    return value.toFixed(3) + 'Hz'
  }

  build() {
    Column() {
      Row() {
        Radio({ group: 'line', value: '1' }) .scale({ x: 1.5, y: 1.5 }) // 放大
          .checked(true)
        Text("线路1")
          .fontSize(18 * this.uiScale)
          .margin({ right: 40 * this.uiScale })

        Radio({ group: 'line', value: '2' }) .scale({ x: 1.5, y: 1.5 }) // 放大
        Text("线路2")
          .fontSize(18 * this.uiScale)
      }
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#c9c9c9')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(40 * this.uiScale)

      Scroll() {
        Column() {
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ua 上偏差', this.getVoltageDeviationUpper('A'), 'Uab 上偏差', this.getVoltageDeviationUpper('AB'), 0)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ub 上偏差', this.getVoltageDeviationUpper('B'), 'Ubc 上偏差', this.getVoltageDeviationUpper('BC'), 1)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Uc 上偏差', this.getVoltageDeviationUpper('C'), 'Uca 上偏差', this.getVoltageDeviationUpper('CA'), 2)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          Blank()
            .height(20)

          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ua 下偏差', this.getVoltageDeviationLower('A'), 'Uab 下偏差', this.getVoltageDeviationLower('AB'), 0)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ub 下偏差', this.getVoltageDeviationLower('B'), 'Ubc 下偏差', this.getVoltageDeviationLower('BC'), 1)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Uc 下偏差', this.getVoltageDeviationLower('C'), 'Uca 下偏差', this.getVoltageDeviationLower('CA'), 2)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          Blank()
            .height(20)

          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ua 频率偏差', this.getFreqDeviation('A'), '总频率偏差', this.getFreqDeviation('All'), 0)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Ub 频率偏差', this.getFreqDeviation('B'), '', '', 1)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('Uc 频率偏差', this.getFreqDeviation('C'), '', '', 2)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
        }
        .width('100%')
        .backgroundColor('#fff')
        .align(Alignment.TopStart)
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)

    }
   .layoutWeight(1)
  }

  @Builder
  TableRow(item1: string, value1: string, item2: string, value2: string, rowIndex: number) {
    Row() {
      Row() {
        Text(item1)
          .fontSize(16 * this.uiScale)
          .padding({ left: 36 * this.uiScale, right: 12 * this.uiScale, top: 8 * this.uiScale, bottom: 8 * this.uiScale })
        Text(value1)
          .fontSize(16 * this.uiScale)
          .fontColor('#666')
          .padding({ left: 16 * this.uiScale, right: 12 * this.uiScale, top: 8 * this.uiScale, bottom: 8 * this.uiScale })
      }
      .width('50%')

      Row() {
        Text(item2)
          .fontSize(16 * this.uiScale)
          .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale, top: 8 * this.uiScale, bottom: 8 * this.uiScale })
        Text(value2)
          .fontSize(16 * this.uiScale)
          .fontColor('#666')
          .padding({ left: 16 * this.uiScale, right: 12 * this.uiScale, top: 8 * this.uiScale, bottom: 8 * this.uiScale })
      }
      .width('50%')
    }
    .width('100%')
    .backgroundColor(rowIndex % 2 === 0 ? '#fff' : '#e0e0e0')
  }
}
export {VoltageMonitoring}