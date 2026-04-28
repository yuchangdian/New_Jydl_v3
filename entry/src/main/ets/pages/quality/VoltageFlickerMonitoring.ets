// 电压波动与闪变界面

import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'

// 定义电能质量数据接口
interface PowerQualityData {
  DataTimestamp: number;
  Timestamp_ms: number;
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
}

// 定义电能质量响应数据接口
interface PowerQualityApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: PowerQualityData;
}

const DOMAIN = 0x0001;
const TAG = 'VoltageFlickerMonitoring';

@Component
struct VoltageFlickerMonitoring {
  @State uiScale: number = 1
  readonly designWidth: number = 720

  @State activeTab: number = 2
  @State requestResult: string = ''
  @State powerQualityData: PowerQualityData | null = null

  aboutToAppear() {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.fetchVoltageFlickerData()
  }

  // 获取电压波动与闪变数据
  private async fetchVoltageFlickerData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取电压波动与闪变数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'PowerQuality');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '电压波动与闪变数据获取成功');
        
        // 解析数据
        try {
          const apiResponse: PowerQualityApiResponse = JSON.parse(response.data.data) as PowerQualityApiResponse;
          if (apiResponse && apiResponse.data) {
            this.powerQualityData = apiResponse.data;
            hilog.info(DOMAIN, TAG, '电压波动与闪变数据解析成功');
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析电压波动与闪变数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, '电压波动与闪变数据请求失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '电压波动与闪变数据请求异常: %{public}s', String(error));
    }
  }

  // 获取电压波动
  private getVoltageFluct(phase: string): string {
    if (!this.powerQualityData) return '0.00%'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageFluct_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageFluct_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageFluct_C?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.00%'
    return value.toFixed(2) + '%'
  }

  // 获取电压波动频次
  private getVoltageFluctFreq(phase: string): string {
    if (!this.powerQualityData) return '0 次/小时'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageFluctFreq_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageFluctFreq_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageFluctFreq_C?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0 次/小时'
    return value.toFixed(0) + ' 次/小时'
  }

  // 获取电压短时闪变
  private getVoltageShortFlicke(phase: string): string {
    if (!this.powerQualityData) return '0.000'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageShortFlicke_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageShortFlicke_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageShortFlicke_C?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.000'
    return value.toFixed(3)
  }

  // 获取电压长时闪变
  private getVoltageLongFlicke(phase: string): string {
    if (!this.powerQualityData) return '0.000'
    let value: number | undefined
    switch (phase) {
      case 'A':
        value = this.powerQualityData.VoltageLongFlicke_A?.[0]
        break
      case 'B':
        value = this.powerQualityData.VoltageLongFlicke_B?.[0]
        break
      case 'C':
        value = this.powerQualityData.VoltageLongFlicke_C?.[0]
        break
      default:
        value = 0
    }
    if (value === undefined) return '0.000'
    return value.toFixed(3)
  }

  build() {
    Column() {
      Row() {
        Radio({ group: 'line', value: '1' }) .scale({ x: 1.5, y: 1.5 }) // 放大
          .checked(true)
        Text("线路1")
          .fontSize(18 * this.uiScale)
          .margin({ right: 40 * this.uiScale })

        Radio({ group: 'line', value: '2' })
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
          if (this.activeTab === 1) {
            this.TitleRow('电压波动', '电压闪变')
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ua 波动', this.getVoltageFluct('A'), 'Ua 短时闪变', this.getVoltageShortFlicke('A'), 0)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ub 波动', this.getVoltageFluct('B'), 'Ub 短时闪变', this.getVoltageShortFlicke('B'), 1)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Uc 波动', this.getVoltageFluct('C'), 'Uc 短时闪变', this.getVoltageShortFlicke('C'), 2)
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
            this.DataRow('Ua 波动频次', this.getVoltageFluctFreq('A'), 'Ua 长时闪变', this.getVoltageLongFlicke('A'), 0)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ub 波动频次', this.getVoltageFluctFreq('B'), 'Ub 长时闪变', this.getVoltageLongFlicke('B'), 1)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Uc 波动频次', this.getVoltageFluctFreq('C'), 'Uc 长时闪变', this.getVoltageLongFlicke('C'), 2)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')

            // 添加底部空白，确保内容从上到下分布
            Blank()
              .height(200)
          } else {
            this.TitleRow('电压波动', '电压闪变')
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ua 波动', this.getVoltageFluct('A'), 'Ua 短时闪变', this.getVoltageShortFlicke('A'), 0)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ub 波动', this.getVoltageFluct('B'), 'Ub 短时闪变', this.getVoltageShortFlicke('B'), 1)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Uc 波动', this.getVoltageFluct('C'), 'Uc 短时闪变', this.getVoltageShortFlicke('C'), 2)
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
            this.DataRow('Ua 波动频次', this.getVoltageFluctFreq('A'), 'Ua 长时闪变', this.getVoltageLongFlicke('A'), 0)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Ub 波动频次', this.getVoltageFluctFreq('B'), 'Ub 长时闪变', this.getVoltageLongFlicke('B'), 1)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')
            this.DataRow('Uc 波动频次', this.getVoltageFluctFreq('C'), 'Uc 长时闪变', this.getVoltageLongFlicke('C'), 2)
            Divider()
              .width('100%')
              .height(1)
              .backgroundColor('#666')

            // 添加底部空白，确保内容从上到下分布
            Blank()
              .height(200)
          }
        }
        .width('100%')
        .backgroundColor('#fff')
        .padding(10)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)

    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabItem(tabNum: number, title: string) {
    Column() {
      Row() {
        if (this.activeTab === tabNum) {
          Column()
            .width(24 * this.uiScale)
            .height(24 * this.uiScale)
            .backgroundColor('#000')
            .borderRadius(3 * this.uiScale)
            .borderWidth(1 * this.uiScale)
            .borderColor('#fff')
        } else {
          Column()
            .width(24 * this.uiScale)
            .height(24 * this.uiScale)
            .backgroundColor('#fff')
            .borderRadius(3 * this.uiScale)
            .borderWidth(1 * this.uiScale)
            .borderColor('#333')
        }
        Text(title)
          .fontSize(16 * this.uiScale)
          .margin({ left: 6 * this.uiScale })
      }
    }
    .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale, top: 6 * this.uiScale, bottom: 6 * this.uiScale })
    .onClick(() => {
      this.activeTab = tabNum
    })
  }

  @Builder
  TitleRow(title1: string, title2: string) {
    Row() {
      Row() {
        Text(title1)
          .fontSize(16 * this.uiScale)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 90 * this.uiScale, right: 12 * this.uiScale, top: 6 * this.uiScale, bottom: 6 * this.uiScale })
      }
      .width('50%')

      Row() {
        Text(title2)
          .fontSize(16 * this.uiScale)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 70 * this.uiScale, right: 12 * this.uiScale, top: 6 * this.uiScale, bottom: 6 * this.uiScale })
      }
      .width('50%')
    }
    .width('100%')
  }

  @Builder
  DataRow(item1: string, value1: string, item2: string, value2: string, rowIndex: number) {
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
export {VoltageFlickerMonitoring}