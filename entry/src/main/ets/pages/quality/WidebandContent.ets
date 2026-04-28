import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util';
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState';
import hilog from '@ohos.hilog';

// 定义数据项接口
interface DataItem {
  frequency: string;
  amplitude: string;
  phase: string;
  contentRate: string;
}

// 定义谐波数据接口
interface HarmonicData {
  DataTimestamp: number;
  Timestamp_ms: number;
  Ua_Angle: number[][];
  Ua_Frequency: number[][];
  Ua_HarmonicRatio: number[][];
  Ua_RMS: number[][];
  Ub_Angle: number[][];
  Ub_Frequency: number[][];
  Ub_HarmonicRatio: number[][];
  Ub_RMS: number[][];
  Uc_Angle: number[][];
  Uc_Frequency: number[][];
  Uc_HarmonicRatio: number[][];
  Uc_RMS: number[][];
}

// 定义响应数据接口
interface ApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: HarmonicData;
}

const DOMAIN = 0x0001;
const TAG = 'WidebandContent';

@Component
export struct WidebandContent {
  @State uiScale: number = 1;
  readonly designWidth: number = 720;
  @State requestResult: string = '';

  // 延迟加载后面的谐波，避免首屏卡顿
  @State showExtraHarmonic: boolean = false;

  // 电压数据
  @State voltageData: DataItem[] = [
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }, // A相
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }, // B相
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }  // C相
  ];

  // 电流数据
  @State currentData: DataItem[] = [
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }, // A相
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }, // B相
    { frequency: "0.000Hz", amplitude: "0.00", phase: "0.00°", contentRate: "0.00%" }  // C相
  ];

  // 缓存缩放值，避免大量重复计算
  private scale4: number = 4;
  private scale5: number = 5;
  private scale8: number = 8;
  private scale10: number = 10;
  private scale12: number = 12;
  private scale14: number = 14;
  private scale18: number = 18;
  private scale40: number = 40;
  private scale60: number = 60;

  aboutToAppear() {
    let dis = display.getDefaultDisplaySync();
    this.uiScale = dis.width / this.designWidth;

    // 预计算所有缩放尺寸
    this.scale4 = 4 * this.uiScale;
    this.scale5 = 5 * this.uiScale;
    this.scale8 = 8 * this.uiScale;
    this.scale10 = 10 * this.uiScale;
    this.scale12 = 16 * this.uiScale;
    this.scale14 = 16 * this.uiScale;
    this.scale18 = 18 * this.uiScale;
    this.scale40 = 40 * this.uiScale;
    this.scale60 = 60 * this.uiScale;

    // 延迟渲染谐波4~9，让出主线程先渲染首屏
    setTimeout(() => {
      this.showExtraHarmonic = true;
    }, 30);

    // 调用数据获取方法
    this.fetchWidebandData();
  }

  // 获取宽带数据
  private async fetchWidebandData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取宽带数据');

    // 获取电压数据
    await this.fetchHarmonicData('HarmonicU');
    // 获取电流数据
    await this.fetchHarmonicData('HarmonicI');
  }

  // 获取谐波数据（电压或电流）
  private async fetchHarmonicData(deviceName: string): Promise<void> {
    hilog.info(DOMAIN, TAG, `开始获取${deviceName === 'HarmonicU' ? '电压' : '电流'}数据`);

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', deviceName);
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, `${deviceName === 'HarmonicU' ? '电压' : '电流'}数据获取成功`);
        
        // 只有电压数据显示在请求结果中
        if (deviceName === 'HarmonicU') {
          this.requestResult = response.data.data;
        }

        // 解析数据
        try {
          const apiResponse: ApiResponse = JSON.parse(response.data.data) as ApiResponse;
          if (apiResponse && apiResponse.data) {
            const lineIndex = 0; // 线路1
            const isVoltage = deviceName === 'HarmonicU';
            const targetData = isVoltage ? this.voltageData : this.currentData;
            const harmonicData = apiResponse.data;
            
            // A相数据
            if (harmonicData.Ua_Frequency && harmonicData.Ua_Frequency[lineIndex]) {
              targetData[0].frequency = harmonicData.Ua_Frequency[lineIndex][0].toFixed(3) + 'Hz';
            }
            if (harmonicData.Ua_RMS && harmonicData.Ua_RMS[lineIndex]) {
              targetData[0].amplitude = harmonicData.Ua_RMS[lineIndex][0].toFixed(2);
            }
            if (harmonicData.Ua_Angle && harmonicData.Ua_Angle[lineIndex]) {
              targetData[0].phase = harmonicData.Ua_Angle[lineIndex][0].toFixed(2) + '°';
            }
            if (harmonicData.Ua_HarmonicRatio && harmonicData.Ua_HarmonicRatio[lineIndex]) {
              targetData[0].contentRate = harmonicData.Ua_HarmonicRatio[lineIndex][0].toFixed(2) + '%';
            }

            // B相数据
            if (harmonicData.Ub_Frequency && harmonicData.Ub_Frequency[lineIndex]) {
              targetData[1].frequency = harmonicData.Ub_Frequency[lineIndex][0].toFixed(3) + 'Hz';
            }
            if (harmonicData.Ub_RMS && harmonicData.Ub_RMS[lineIndex]) {
              targetData[1].amplitude = harmonicData.Ub_RMS[lineIndex][0].toFixed(2);
            }
            if (harmonicData.Ub_Angle && harmonicData.Ub_Angle[lineIndex]) {
              targetData[1].phase = harmonicData.Ub_Angle[lineIndex][0].toFixed(2) + '°';
            }
            if (harmonicData.Ub_HarmonicRatio && harmonicData.Ub_HarmonicRatio[lineIndex]) {
              targetData[1].contentRate = harmonicData.Ub_HarmonicRatio[lineIndex][0].toFixed(2) + '%';
            }

            // C相数据
            if (harmonicData.Uc_Frequency && harmonicData.Uc_Frequency[lineIndex]) {
              targetData[2].frequency = harmonicData.Uc_Frequency[lineIndex][0].toFixed(3) + 'Hz';
            }
            if (harmonicData.Uc_RMS && harmonicData.Uc_RMS[lineIndex]) {
              targetData[2].amplitude = harmonicData.Uc_RMS[lineIndex][0].toFixed(2);
            }
            if (harmonicData.Uc_Angle && harmonicData.Uc_Angle[lineIndex]) {
              targetData[2].phase = harmonicData.Uc_Angle[lineIndex][0].toFixed(2) + '°';
            }
            if (harmonicData.Uc_HarmonicRatio && harmonicData.Uc_HarmonicRatio[lineIndex]) {
              targetData[2].contentRate = harmonicData.Uc_HarmonicRatio[lineIndex][0].toFixed(2) + '%';
            }
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析数据失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, `${deviceName === 'HarmonicU' ? '电压' : '电流'}数据请求失败`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `${deviceName === 'HarmonicU' ? '电压' : '电流'}数据请求异常: %{public}s`, String(error));
    }
  }

  build() {
    Column() {
      // 线路选择栏
      Row() {
        Radio({ group: 'line', value: '1' }) .scale({ x: 1.5, y: 1.5 }) // 放大
          .checked(true)
        Text("线路1")
          .fontSize(this.scale18)
          .margin({ right: 40 * this.uiScale })

        Radio({ group: 'line', value: '2' }) .scale({ x: 1.5, y: 1.5 }) // 放大
        Text("线路2")
          .fontSize(this.scale18)
      }
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#c9c9c9')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(this.scale40)

      // ===================== 性能优化：用 List 替换 Scroll+Column =====================
      List({ space: this.scale12 }) {
        ListItem() {
          this.dataSection("工频分量")
        }

        ListItem() {
          this.dataSection("谐波分量1")
        }

        ListItem() {
          this.dataSection("谐波分量2")
        }

        ListItem() {
          this.dataSection("谐波分量3")
        }

        // 谐波4~9 延迟加载
        if (this.showExtraHarmonic) {
          ListItem() { this.dataSection("谐波分量4") }
          ListItem() { this.dataSection("谐波分量5") }
          ListItem() { this.dataSection("谐波分量6") }
          ListItem() { this.dataSection("谐波分量7") }
          ListItem() { this.dataSection("谐波分量8") }
          ListItem() { this.dataSection("谐波分量9") }
        }

    
      }
      .padding({ top: this.scale5, bottom: this.scale5, left: this.scale5, right: this.scale5 })
      .layoutWeight(1)
      .cachedCount(2)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  // 数据段：电压 + 电流
  @Builder
  dataSection(title: string) {
    Column({ space: this.scale8 }) {
      Text(`>${title}`)
        .fontSize(this.scale14)
        .width('100%')

      Row({ space: this.scale10 }) {
        // 电压区域
        Column({ space: this.scale4 }) {
          this.voltageHeader()
          this.dataRow("A相", false, true)
          this.dataRow("B相", true, true)
          this.dataRow("C相", false, true)
        }
        .layoutWeight(1)

        // 电流区域
        Column({ space: this.scale4 }) {
          this.currentHeader()
          this.dataRow("A相", false, false)
          this.dataRow("B相", true, false)
          this.dataRow("C相", false, false)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
  }

  // 电压表头
  @Builder
  voltageHeader() {
    Flex() {
      this.headerText("电压")
      this.headerText("频率")
      this.headerText("幅值")
      this.headerText("相位")
      this.headerText("含有率")
    }
    .width('100%')
  }

  // 电流表头
  @Builder
  currentHeader() {
    Flex() {
      this.headerText("电流")
      this.headerText("频率")
      this.headerText("幅值")
      this.headerText("相位")
      this.headerText("含有率")
    }
    .width('100%')
  }

  // 数据行
  @Builder
  dataRow(phase: string, gray: boolean, isVoltage: boolean) {
    Flex() {
      this.valueText(phase)
      this.valueText((isVoltage ? this.voltageData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2] : this.currentData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2]).frequency)
      this.valueText((isVoltage ? this.voltageData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2] : this.currentData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2]).amplitude)
      this.valueText((isVoltage ? this.voltageData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2] : this.currentData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2]).phase)
      this.valueText((isVoltage ? this.voltageData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2] : this.currentData[phase === "A相" ? 0 : phase === "B相" ? 1 : 2]).contentRate)
    }
    .width('100%')
    .backgroundColor(gray ? '#E8E8E8' : '#F9F9F9')
    .padding({ top: this.scale4, bottom: this.scale4 })
  }

  // 表头文字
  @Builder
  headerText(text: string) {
    Text(text)
      .fontSize(this.scale14)
      .width(this.scale60)
      .textAlign(TextAlign.Center)
  }

  // 数据文字
  @Builder
  valueText(text: string) {
    Text(text)
      .fontSize(this.scale12)
      .width(this.scale60)
      .textAlign(TextAlign.Center)
  }
}