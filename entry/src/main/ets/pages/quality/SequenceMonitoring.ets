// 不平衡界面

import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'

// 定义电能质量数据接口
interface PowerQualityData {
  DataTimestamp: number;
  Timestamp_ms: number;
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
}

// 定义电能质量响应数据接口
interface PowerQualityApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: PowerQualityData;
}

const DOMAIN = 0x0001;
const TAG = 'SequenceMonitoring';

@Component
struct SequenceMonitoring {
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
    this.fetchSequenceData()
  }

  // 获取不平衡数据
  private async fetchSequenceData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取不平衡数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'PowerQuality');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '不平衡数据获取成功');
        
        // 解析数据
        try {
          const apiResponse: PowerQualityApiResponse = JSON.parse(response.data.data) as PowerQualityApiResponse;
          if (apiResponse && apiResponse.data) {
            this.powerQualityData = apiResponse.data;
            hilog.info(DOMAIN, TAG, '不平衡数据解析成功');
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析不平衡数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, '不平衡数据请求失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '不平衡数据请求异常: %{public}s', String(error));
    }
  }

  // 获取正序电压
  private getVoltageU1(): string {
    if (!this.powerQualityData || !this.powerQualityData.Voltage_U1) return '0.00V'
    return this.powerQualityData.Voltage_U1[0].toFixed(2) + 'V'
  }

  // 获取负序电压
  private getVoltageU2(): string {
    if (!this.powerQualityData || !this.powerQualityData.Voltage_U2) return '0.00V'
    return this.powerQualityData.Voltage_U2[0].toFixed(2) + 'V'
  }

  // 获取零序电压
  private getVoltageU0(): string {
    if (!this.powerQualityData || !this.powerQualityData.Voltage_U0) return '0.00V'
    return this.powerQualityData.Voltage_U0[0].toFixed(2) + 'V'
  }

  // 获取正序电流
  private getCurrentI1(): string {
    if (!this.powerQualityData || !this.powerQualityData.Current_I1) return '0.00A'
    return this.powerQualityData.Current_I1[0].toFixed(2) + 'A'
  }

  // 获取负序电流
  private getCurrentI2(): string {
    if (!this.powerQualityData || !this.powerQualityData.Current_I2) return '0.00A'
    return this.powerQualityData.Current_I2[0].toFixed(2) + 'A'
  }

  // 获取零序电流
  private getCurrentI0(): string {
    if (!this.powerQualityData || !this.powerQualityData.Current_I0) return '0.00A'
    return this.powerQualityData.Current_I0[0].toFixed(2) + 'A'
  }

  // 获取电压负序不平衡度
  private getVoltageU2Unbalance(): string {
    if (!this.powerQualityData || !this.powerQualityData.Voltage_U2_Unbalance) return '0.00%'
    return this.powerQualityData.Voltage_U2_Unbalance[0].toFixed(2) + '%'
  }

  // 获取电压零序不平衡度
  private getVoltageU0Unbalance(): string {
    if (!this.powerQualityData || !this.powerQualityData.Voltage_Uo_Unbalance) return '0.00%'
    return this.powerQualityData.Voltage_Uo_Unbalance[0].toFixed(2) + '%'
  }

  // 获取电流负序不平衡度
  private getCurrentI2Unbalance(): string {
    if (!this.powerQualityData || !this.powerQualityData.Current_I2_Unbalance) return '0.00%'
    return this.powerQualityData.Current_I2_Unbalance[0].toFixed(2) + '%'
  }

  // 获取电流零序不平衡度
  private getCurrentI0Unbalance(): string {
    if (!this.powerQualityData || !this.powerQualityData.Current_Io_Unbalance) return '0.00%'
    return this.powerQualityData.Current_Io_Unbalance[0].toFixed(2) + '%'
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
          this.TableRow('正序电压U1', this.getVoltageU1(), '', '', 0)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('负序电压U2', this.getVoltageU2(), '负序电压不平衡度', this.getVoltageU2Unbalance(), 1)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('零序电压U0', this.getVoltageU0(), '零序电压不平衡度', this.getVoltageU0Unbalance(), 2)
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
          this.TableRow('正序电流I1', this.getCurrentI1(), '', '', 0)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('负序电流I2', this.getCurrentI2(), '负序电流不平衡度', this.getCurrentI2Unbalance(), 1)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
          this.TableRow('零序电流I0', this.getCurrentI0(), '零序电流不平衡度', this.getCurrentI0Unbalance(), 2)
          Divider()
            .width('100%')
            .height(1)
            .backgroundColor('#666')
        }
        .width('100%')
        .backgroundColor('#fff')
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .layoutWeight(1)
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
      .width(item2 === '' && value2 === '' ? '100%' : '50%')
      .justifyContent(FlexAlign.Start)

      if (item2 !== '' || value2 !== '') {
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
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor(rowIndex % 2 === 0 ? '#fff' : '#e0e0e0')
  }
}
export {SequenceMonitoring}