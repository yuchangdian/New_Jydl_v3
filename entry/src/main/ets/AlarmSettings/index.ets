import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, IpcDataBase, IpcConnectionState } from '../utils/IPC_Util';
import { DEFAULT_PASSWORD, TERMINAL_ID } from '../common/GlobalState';
import hilog from '@ohos.hilog';
import router from '@ohos.router';
import { CustomKeyboard } from '../utils/CustomKeyboard';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';

const DOMAIN = 0x0001;
const TAG = 'AlarmSettings';

// 文件内容响应数据结构
class FileContentData extends IpcDataBase {
  code: number = 0;
  success: boolean = false;
  message: string = '';
  data: string | Record<string, Object> = '';
}

// 文件内容响应接口
interface FileContentResponse {
  code: number;
  success: boolean;
  message: string;
  data: string;
}

// PowerQualitySettingUnit 接口
interface PowerQualitySettingUnit {
  Enable: number;
  Time: number;
  ActValue: number;
}

// PowerQuality 接口
interface PowerQuality {
  CurrentEvenHAR: PowerQualitySettingUnit;
  CurrentEvenTHD: PowerQualitySettingUnit;
  CurrentInterHAR: PowerQualitySettingUnit;
  CurrentInterTHD: PowerQualitySettingUnit;
  CurrentOddHAR: PowerQualitySettingUnit;
  CurrentOddTHD: PowerQualitySettingUnit;
  CurrentTHD: PowerQualitySettingUnit;
  CurrentUnbalance: PowerQualitySettingUnit;
  FreqDeviation: PowerQualitySettingUnit;
  VoltageDeviation: PowerQualitySettingUnit;
  VoltageEvenHAR: PowerQualitySettingUnit;
  VoltageEvenTHD: PowerQualitySettingUnit;
  VoltageFluct: PowerQualitySettingUnit;
  VoltageInterHAR: PowerQualitySettingUnit;
  VoltageInterTHD: PowerQualitySettingUnit;
  VoltageLongFlicke: PowerQualitySettingUnit;
  VoltageOddHAR: PowerQualitySettingUnit;
  VoltageOddTHD: PowerQualitySettingUnit;
  VoltageRef_SegSwell: number;
  VoltageSeg: PowerQualitySettingUnit;
  VoltageShortFlicke: PowerQualitySettingUnit;
  VoltageSwell: PowerQualitySettingUnit;
  VoltageTHD: PowerQualitySettingUnit;
  VoltageUnbalance: PowerQualitySettingUnit;
}

// 内层数据接口
interface InnerData {
  PowerQuality: PowerQuality;
}

// 业务响应数据结构
interface BusinessResponse {
  code: number;
  success: boolean;
  message: string;
}

// 电能质量定值接口
interface PowerQualitySetting {
  "Enable": boolean;
  "Line": number;
  "Code": number;
  "Data": PowerQuality;
}

// 请求数据接口
interface RequestData {
  "电能质量定值": PowerQualitySetting;
}

@Entry
@Component
export struct AlarmSettings {
  @State uiScale: number = 1
  readonly designWidth: number = 720
  @State currentTime: string = ''
  @State currentDate: string = ''
  private timerId: number = -1
  @State isListReady: boolean = false
  @State edgeId: string = ''
  @State passwordDialogVisible: boolean = false;
  @State passwordInput: string = '';
  @State loading: boolean = false;

  // ===================== 键盘控制 =====================
  @State isKeyboardShow: boolean = false;
  @State currentDisplayValue: string = '';
  @State currentRowId: number = -1;
  @State currentInputType: number = 0;
  @State keyboardPosition: 'bottom' | 'top' = 'bottom';
  @State forceLockFocus: boolean = false;

  // 滚动偏移量
  @State scrollOffsetY: number = 0;
  // ==================================================

  // ===================== 所有输入框状态 =====================
  // 电压相关
  @State voltageUnbalanceEnable: number = 0;
  @State voltageUnbalanceValue: string = 'xx.xx';
  @State voltageUnbalanceTime: string = 'xx.xxx';
  @State voltageDeviationEnable: number = 0;
  @State voltageDeviationValue: string = 'xx.xx';
  @State voltageDeviationTime: string = 'xx.xxx';
  @State frequencyDeviationEnable: number = 0;
  @State frequencyDeviationValue: string = 'xx.xx';
  @State frequencyDeviationTime: string = 'xx.xxx';
  @State voltageShortFlickerEnable: number = 0;
  @State voltageShortFlickerValue: string = 'xx.xx';
  @State voltageShortFlickerTime: string = 'xx.xxx';
  @State voltageLongFlickerEnable: number = 0;
  @State voltageLongFlickerValue: string = 'xx.xx';
  @State voltageLongFlickerTime: string = 'xx.xxx';
  @State voltageFluctuationEnable: number = 0;
  @State voltageFluctuationValue: string = 'xx.xx';
  @State voltageFluctuationTime: string = 'xx.xxx';
  @State voltageSagEnable: number = 0;
  @State voltageSagValue: string = 'xx.xx';
  @State voltageSagTime: string = 'xx.xxx';
  @State voltageSwellEnable: number = 0;
  @State voltageSwellValue: string = 'xx.xx';
  @State voltageSwellTime: string = 'xx.xxx';
  @State voltageTotalHarmonicEnable: number = 0;
  @State voltageTotalHarmonicValue: string = 'xx.xx';
  @State voltageTotalHarmonicTime: string = 'xx.xxx';
  @State voltageOddHarmonicEnable: number = 0;
  @State voltageOddHarmonicValue: string = 'xx.xx';
  @State voltageOddHarmonicTime: string = 'xx.xxx';
  @State voltageEvenHarmonicEnable: number = 0;
  @State voltageEvenHarmonicValue: string = 'xx.xx';
  @State voltageEvenHarmonicTime: string = 'xx.xxx';
  @State voltageSingleOddHarmonicEnable: number = 0;
  @State voltageSingleOddHarmonicValue: string = 'xx.xx';
  @State voltageSingleOddHarmonicTime: string = 'xx.xxx';
  @State voltageSingleEvenHarmonicEnable: number = 0;
  @State voltageSingleEvenHarmonicValue: string = 'xx.xx';
  @State voltageSingleEvenHarmonicTime: string = 'xx.xxx';
  @State voltageInterHarmonicEnable: number = 0;
  @State voltageInterHarmonicValue: string = 'xx.xx';
  @State voltageInterHarmonicTime: string = 'xx.xxx';
  @State voltageSingleInterHarmonicEnable: number = 0;
  @State voltageSingleInterHarmonicValue: string = 'xx.xx';
  @State voltageSingleInterHarmonicTime: string = 'xx.xxx';
  // 电流相关
  @State currentUnbalanceEnable: number = 0;
  @State currentUnbalanceValue: string = 'xx.xx';
  @State currentUnbalanceTime: string = 'xx.xxx';
  @State currentTotalHarmonicEnable: number = 0;
  @State currentTotalHarmonicValue: string = 'xx.xx';
  @State currentTotalHarmonicTime: string = 'xx.xxx';
  @State currentOddHarmonicEnable: number = 0;
  @State currentOddHarmonicValue: string = 'xx.xx';
  @State currentOddHarmonicTime: string = 'xx.xxx';
  @State currentEvenHarmonicEnable: number = 0;
  @State currentEvenHarmonicValue: string = 'xx.xx';
  @State currentEvenHarmonicTime: string = 'xx.xxx';
  @State currentSingleOddHarmonicEnable: number = 0;
  @State currentSingleOddHarmonicValue: string = 'xx.xx';
  @State currentSingleOddHarmonicTime: string = 'xx.xxx';
  @State currentSingleEvenHarmonicEnable: number = 0;
  @State currentSingleEvenHarmonicValue: string = 'xx.xx';
  @State currentSingleEvenHarmonicTime: string = 'xx.xxx';
  @State currentInterHarmonicEnable: number = 0;
  @State currentInterHarmonicValue: string = 'xx.xx';
  @State currentInterHarmonicTime: string = 'xx.xxx';
  @State currentSingleInterHarmonicEnable: number = 0;
  @State currentSingleInterHarmonicValue: string = 'xx.xx';
  @State currentSingleInterHarmonicTime: string = 'xx.xxx';
  // ==========================================================

  private readonly refOptions: SelectOption[] = [
    { value: '额定电压' },
    { value: '滑动参考电压' }
  ]

  formatDate(date: Date): string {
    const year = date.getFullYear().toString();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}/${month}/${day}`;
  }

  formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }

  onPageShow(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }

    const now = new Date();
    this.currentDate = this.formatDate(now);
    this.currentTime = this.formatTime(now);

    // 初始化 edgeId
    this.edgeId = TERMINAL_ID;
    hilog.info(DOMAIN, TAG, 'edgeId: %{public}s', this.edgeId);

    // 请求文件内容
    this.fetchFileContent();

    setTimeout(() => {
      this.isListReady = true;
    }, 50);

    setTimeout(() => {
      this.timerId = setInterval(() => {
        const newTime = new Date();
        this.currentDate = this.formatDate(newTime);
        this.currentTime = this.formatTime(newTime);
      }, 1000);
    }, 300);
  }

  async fetchFileContent(): Promise<void> {
    if (!this.edgeId) {
      hilog.error(DOMAIN, TAG, 'edgeId为空，无法请求文件');
      return;
    }

    if (IpcUtil.getConnectionState() !== IpcConnectionState.CONNECTED) {
      hilog.info(DOMAIN, TAG, 'IPC未连接，开始连接IPC');
      await IpcUtil.connect(getContext(this) as common.UIAbilityContext);
      hilog.info(DOMAIN, TAG, 'IPC连接完成');
    }

    const params: IpcParams = new IpcParams();
    params.filePath = `/jyet_config/static/${this.edgeId}_RemoteAdjust.json`;

    const config: IpcRequestConfig = new IpcRequestConfig('/api/file/content', params);

    try {
      hilog.info(DOMAIN, TAG, '开始请求文件: %{public}s', params.filePath);
      const response = await IpcUtil.sendRequest<FileContentData>(config);

      if (response.success) {
        const fileContentData = response.data as FileContentData;
        let content = '';
        
        if (typeof fileContentData.data === 'string') {
          content = fileContentData.data as string;
        } else if (typeof fileContentData.data === 'object') {
          content = JSON.stringify(fileContentData.data);
        }
        
        hilog.info(DOMAIN, TAG, '文件内容获取成功，长度: %{public}d', content.length);
        hilog.info(DOMAIN, TAG, '文件内容: %{public}s', content);
        
        if (content) {
          try {
            const outerResponse = JSON.parse(content) as FileContentResponse;
            hilog.info(DOMAIN, TAG, '解析外层响应成功，code: %{public}d, success: %{public}s', outerResponse.code, outerResponse.success);
            
            if (outerResponse.success && outerResponse.data) {
              hilog.info(DOMAIN, TAG, '文件数据获取成功');
              try {
                const innerData = JSON.parse(outerResponse.data) as InnerData;
                if (innerData.PowerQuality) {
                  const powerQuality = innerData.PowerQuality;
                  
                  // 电压相关
                  if (powerQuality.VoltageUnbalance) {
                    this.voltageUnbalanceEnable = powerQuality.VoltageUnbalance.Enable;
                    this.voltageUnbalanceValue = powerQuality.VoltageUnbalance.ActValue.toFixed(2);
                    this.voltageUnbalanceTime = (powerQuality.VoltageUnbalance.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageDeviation) {
                    this.voltageDeviationEnable = powerQuality.VoltageDeviation.Enable;
                    this.voltageDeviationValue = powerQuality.VoltageDeviation.ActValue.toFixed(2);
                    this.voltageDeviationTime = (powerQuality.VoltageDeviation.Time / 100).toFixed(3);
                  }
                  if (powerQuality.FreqDeviation) {
                    this.frequencyDeviationEnable = powerQuality.FreqDeviation.Enable;
                    this.frequencyDeviationValue = powerQuality.FreqDeviation.ActValue.toFixed(2);
                    this.frequencyDeviationTime = (powerQuality.FreqDeviation.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageShortFlicke) {
                    this.voltageShortFlickerEnable = powerQuality.VoltageShortFlicke.Enable;
                    this.voltageShortFlickerValue = powerQuality.VoltageShortFlicke.ActValue.toFixed(2);
                    this.voltageShortFlickerTime = (powerQuality.VoltageShortFlicke.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageLongFlicke) {
                    this.voltageLongFlickerEnable = powerQuality.VoltageLongFlicke.Enable;
                    this.voltageLongFlickerValue = powerQuality.VoltageLongFlicke.ActValue.toFixed(2);
                    this.voltageLongFlickerTime = (powerQuality.VoltageLongFlicke.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageFluct) {
                    this.voltageFluctuationEnable = powerQuality.VoltageFluct.Enable;
                    this.voltageFluctuationValue = powerQuality.VoltageFluct.ActValue.toFixed(2);
                    this.voltageFluctuationTime = (powerQuality.VoltageFluct.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageSeg) {
                    this.voltageSagEnable = powerQuality.VoltageSeg.Enable;
                    this.voltageSagValue = powerQuality.VoltageSeg.ActValue.toFixed(2);
                    this.voltageSagTime = (powerQuality.VoltageSeg.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageSwell) {
                    this.voltageSwellEnable = powerQuality.VoltageSwell.Enable;
                    this.voltageSwellValue = powerQuality.VoltageSwell.ActValue.toFixed(2);
                    this.voltageSwellTime = (powerQuality.VoltageSwell.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageTHD) {
                    this.voltageTotalHarmonicEnable = powerQuality.VoltageTHD.Enable;
                    this.voltageTotalHarmonicValue = powerQuality.VoltageTHD.ActValue.toFixed(2);
                    this.voltageTotalHarmonicTime = (powerQuality.VoltageTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageOddTHD) {
                    this.voltageOddHarmonicEnable = powerQuality.VoltageOddTHD.Enable;
                    this.voltageOddHarmonicValue = powerQuality.VoltageOddTHD.ActValue.toFixed(2);
                    this.voltageOddHarmonicTime = (powerQuality.VoltageOddTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageEvenTHD) {
                    this.voltageEvenHarmonicEnable = powerQuality.VoltageEvenTHD.Enable;
                    this.voltageEvenHarmonicValue = powerQuality.VoltageEvenTHD.ActValue.toFixed(2);
                    this.voltageEvenHarmonicTime = (powerQuality.VoltageEvenTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageOddHAR) {
                    this.voltageSingleOddHarmonicEnable = powerQuality.VoltageOddHAR.Enable;
                    this.voltageSingleOddHarmonicValue = powerQuality.VoltageOddHAR.ActValue.toFixed(2);
                    this.voltageSingleOddHarmonicTime = (powerQuality.VoltageOddHAR.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageEvenHAR) {
                    this.voltageSingleEvenHarmonicEnable = powerQuality.VoltageEvenHAR.Enable;
                    this.voltageSingleEvenHarmonicValue = powerQuality.VoltageEvenHAR.ActValue.toFixed(2);
                    this.voltageSingleEvenHarmonicTime = (powerQuality.VoltageEvenHAR.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageInterTHD) {
                    this.voltageInterHarmonicEnable = powerQuality.VoltageInterTHD.Enable;
                    this.voltageInterHarmonicValue = powerQuality.VoltageInterTHD.ActValue.toFixed(2);
                    this.voltageInterHarmonicTime = (powerQuality.VoltageInterTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.VoltageInterHAR) {
                    this.voltageSingleInterHarmonicEnable = powerQuality.VoltageInterHAR.Enable;
                    this.voltageSingleInterHarmonicValue = powerQuality.VoltageInterHAR.ActValue.toFixed(2);
                    this.voltageSingleInterHarmonicTime = (powerQuality.VoltageInterHAR.Time / 100).toFixed(3);
                  }
                  
                  // 电流相关
                  if (powerQuality.CurrentUnbalance) {
                    this.currentUnbalanceEnable = powerQuality.CurrentUnbalance.Enable;
                    this.currentUnbalanceValue = powerQuality.CurrentUnbalance.ActValue.toFixed(2);
                    this.currentUnbalanceTime = (powerQuality.CurrentUnbalance.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentTHD) {
                    this.currentTotalHarmonicEnable = powerQuality.CurrentTHD.Enable;
                    this.currentTotalHarmonicValue = powerQuality.CurrentTHD.ActValue.toFixed(2);
                    this.currentTotalHarmonicTime = (powerQuality.CurrentTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentOddTHD) {
                    this.currentOddHarmonicEnable = powerQuality.CurrentOddTHD.Enable;
                    this.currentOddHarmonicValue = powerQuality.CurrentOddTHD.ActValue.toFixed(2);
                    this.currentOddHarmonicTime = (powerQuality.CurrentOddTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentEvenTHD) {
                    this.currentEvenHarmonicEnable = powerQuality.CurrentEvenTHD.Enable;
                    this.currentEvenHarmonicValue = powerQuality.CurrentEvenTHD.ActValue.toFixed(2);
                    this.currentEvenHarmonicTime = (powerQuality.CurrentEvenTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentOddHAR) {
                    this.currentSingleOddHarmonicEnable = powerQuality.CurrentOddHAR.Enable;
                    this.currentSingleOddHarmonicValue = powerQuality.CurrentOddHAR.ActValue.toFixed(2);
                    this.currentSingleOddHarmonicTime = (powerQuality.CurrentOddHAR.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentEvenHAR) {
                    this.currentSingleEvenHarmonicEnable = powerQuality.CurrentEvenHAR.Enable;
                    this.currentSingleEvenHarmonicValue = powerQuality.CurrentEvenHAR.ActValue.toFixed(2);
                    this.currentSingleEvenHarmonicTime = (powerQuality.CurrentEvenHAR.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentInterTHD) {
                    this.currentInterHarmonicEnable = powerQuality.CurrentInterTHD.Enable;
                    this.currentInterHarmonicValue = powerQuality.CurrentInterTHD.ActValue.toFixed(2);
                    this.currentInterHarmonicTime = (powerQuality.CurrentInterTHD.Time / 100).toFixed(3);
                  }
                  if (powerQuality.CurrentInterHAR) {
                    this.currentSingleInterHarmonicEnable = powerQuality.CurrentInterHAR.Enable;
                    this.currentSingleInterHarmonicValue = powerQuality.CurrentInterHAR.ActValue.toFixed(2);
                    this.currentSingleInterHarmonicTime = (powerQuality.CurrentInterHAR.Time / 100).toFixed(3);
                  }
                }
              } catch (innerParseError) {
                hilog.error(DOMAIN, TAG, '解析内层数据异常: %{public}s', String(innerParseError));
              }
            } else {
              hilog.error(DOMAIN, TAG, '外层响应失败或data为空');
            }
          } catch (parseError) {
            hilog.error(DOMAIN, TAG, '解析文件数据异常: %{public}s', String(parseError));
          }
        }
      } else {
        hilog.error(DOMAIN, TAG, '文件获取失败: %{public}s', response.error || '未知错误');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '文件请求异常: %{public}s', String(error));
    }
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  @Builder
  EmptyKeyboardBuilder() {
    Column()
      .width(0)
      .height(0)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            Image($rawfile("icon/icon04.png"))
              .width(18 * this.uiScale)
              .height(18 * this.uiScale)
            Text("告警定值")
              .fontSize(18 * this.uiScale)
              .fontColor('#ffffff')
              .margin({ left: 5 * this.uiScale })
          }
          .width(100 * this.uiScale)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#ff167fff')
          .height('100%')

          Row() {
            Radio({ group: 'line', value: '1' }).checked(true) .scale({ x: 1.5, y: 1.5 })
            Text("线路1")
              .fontSize(18 * this.uiScale)
              .margin({ right: 40 * this.uiScale })

            Radio({ group: 'line', value: '2' }) .scale({ x: 1.5, y: 1.5 })
            Text("线路2")
              .fontSize(18 * this.uiScale)
          }
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#c9c9c9')
          .layoutWeight(1)
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .height(40 * this.uiScale)
        .justifyContent(FlexAlign.Center)

        // 🔥 关键：Scroll 添加滚动监听
        Scroll() {
          Column() {
            if (this.isListReady) {
              this.buildAlarmItem(0, '【电压不平衡】', this.voltageUnbalanceEnable, this.voltageUnbalanceValue, '%', this.voltageUnbalanceTime, '秒')
              this.buildAlarmItem(1, '【电压偏差】', this.voltageDeviationEnable, this.voltageDeviationValue, '%', this.voltageDeviationTime, '秒')
              this.buildAlarmItem(2, '【频率偏差】', this.frequencyDeviationEnable, this.frequencyDeviationValue, 'Hz', this.frequencyDeviationTime, '秒')
              this.buildAlarmItem(3, '【电压短闪变】', this.voltageShortFlickerEnable, this.voltageShortFlickerValue, '', this.voltageShortFlickerTime, '秒')
              this.buildAlarmItem(4, '【电压长闪变】', this.voltageLongFlickerEnable, this.voltageLongFlickerValue, '', this.voltageLongFlickerTime, '秒')
              this.buildAlarmItem(5, '【电压波动】', this.voltageFluctuationEnable, this.voltageFluctuationValue, '%', this.voltageFluctuationTime, '秒')
              this.buildAlarmItem(6, '【电压暂降】', this.voltageSagEnable, this.voltageSagValue, '%', this.voltageSagTime, '秒')
              this.buildAlarmItem(7, '【电压暂升】', this.voltageSwellEnable, this.voltageSwellValue, '%', this.voltageSwellTime, '秒')
              this.buildRefValueItem()
              this.buildAlarmItem(8, '【电压总谐波含量】', this.voltageTotalHarmonicEnable, this.voltageTotalHarmonicValue, '%', this.voltageTotalHarmonicTime, '秒')
              this.buildAlarmItem(9, '【电压总奇次谐波含量】', this.voltageOddHarmonicEnable, this.voltageOddHarmonicValue, '%', this.voltageOddHarmonicTime, '秒')
              this.buildAlarmItem(10, '【电压总偶次谐波含量】', this.voltageEvenHarmonicEnable, this.voltageEvenHarmonicValue, '%', this.voltageEvenHarmonicTime, '秒')
              this.buildAlarmItem(11, '【电压单一奇次谐波含量】', this.voltageSingleOddHarmonicEnable, this.voltageSingleOddHarmonicValue, '%', this.voltageSingleOddHarmonicTime, '秒')
              this.buildAlarmItem(12, '【电压单一偶次谐波含量】', this.voltageSingleEvenHarmonicEnable, this.voltageSingleEvenHarmonicValue, '%', this.voltageSingleEvenHarmonicTime, '秒')
              this.buildAlarmItem(13, '【电压总间谐波含量】', this.voltageInterHarmonicEnable, this.voltageInterHarmonicValue, '%', this.voltageInterHarmonicTime, '秒')
              this.buildAlarmItem(14, '【电压单一间谐波含量】', this.voltageSingleInterHarmonicEnable, this.voltageSingleInterHarmonicValue, '%', this.voltageSingleInterHarmonicTime, '秒')
              this.buildAlarmItem(15, '【电流不平衡】', this.currentUnbalanceEnable, this.currentUnbalanceValue, '%', this.currentUnbalanceTime, '秒')
              this.buildAlarmItem(16, '【电流总谐波含量】', this.currentTotalHarmonicEnable, this.currentTotalHarmonicValue, '%', this.currentTotalHarmonicTime, '秒')
              this.buildAlarmItem(17, '【电流总奇次谐波含量】', this.currentOddHarmonicEnable, this.currentOddHarmonicValue, '%', this.currentOddHarmonicTime, '秒')
              this.buildAlarmItem(18, '【电流总偶次谐波含量】', this.currentEvenHarmonicEnable, this.currentEvenHarmonicValue, '%', this.currentEvenHarmonicTime, '秒')
              this.buildAlarmItem(19, '【电流单一奇次谐波含量】', this.currentSingleOddHarmonicEnable, this.currentSingleOddHarmonicValue, '%', this.currentSingleOddHarmonicTime, '秒')
              this.buildAlarmItem(20, '【电流单一偶次谐波含量】', this.currentSingleEvenHarmonicEnable, this.currentSingleEvenHarmonicValue, '%', this.currentSingleEvenHarmonicTime, '秒')
              this.buildAlarmItem(21, '【电流总间谐波含量】', this.currentInterHarmonicEnable, this.currentInterHarmonicValue, '%', this.currentInterHarmonicTime, '秒')
              this.buildAlarmItem(22, '【电流单一间谐波含量】', this.currentSingleInterHarmonicEnable, this.currentSingleInterHarmonicValue, '%', this.currentSingleInterHarmonicTime, '秒')
            }
          }
          .width('100%')
        }
        .onScroll((xOffset: number, yOffset: number) => {
          // 实时记录滚动位置
          this.scrollOffsetY = yOffset;
        })
        .layoutWeight(1)

        Row() {
          Text('确定')
            .fontSize(18 * this.uiScale)
            .height(38 * this.uiScale)
            .width(100 * this.uiScale)
            .border({ width: 1 * this.uiScale, color: '#000000' })
            .borderRadius(6 * this.uiScale)
            .backgroundColor('#167fff')
            .fontColor('#ffffff')
            .textAlign(TextAlign.Center)
            .margin({ right: 8 * this.uiScale })
            .fontSize(16 * this.uiScale)
            .onClick(() => {
              this.onConfirmClick()
            })

          Text('返回')
            .fontSize(18 * this.uiScale)
            .height(38 * this.uiScale)
            .border({ width: 1 * this.uiScale, color: '#000000' })
            .borderRadius(6 * this.uiScale)
            .backgroundColor('#d0d3d8')
            .fontColor('#000000')
            .width(100 * this.uiScale)
            .fontSize(16 * this.uiScale)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' });
            })

          Row() {
            Text(this.currentDate)
              .fontSize(12 * this.uiScale)
              .textAlign(TextAlign.Center)
              .margin({ left: 10 * this.uiScale })
            Text(this.currentTime)
              .fontSize(12 * this.uiScale)
              .textAlign(TextAlign.Center)
          }
          .position({ bottom: 14 * this.uiScale, right: 20 * this.uiScale })
        }
        .width('100%')
        .height(48 * this.uiScale)
        .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale })
        .backgroundColor('#c0c6cc')
        .border({ width: { top: 1 * this.uiScale }, color: '#000000' })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        if (this.isKeyboardShow) {
          CustomKeyboard({
            currentValue: () => this.currentDisplayValue,
            onChange: (val) => {
              this.currentDisplayValue = val;
              this.saveCurrentInput();
            },
            onClose: () => {
              this.saveCurrentInput();
              this.isKeyboardShow = false;
              this.currentRowId = -1;
            },
            keyboardPosition: this.keyboardPosition
          })
        }
      }
      .width('100%')
      .height('100%')
      .onClick(() => {
        this.saveCurrentInput();
        this.isKeyboardShow = false;
        this.currentRowId = -1;
        this.forceLockFocus = false;
      })

      // 密码输入对话框
      if (this.passwordDialogVisible) {
        this.PasswordInputDialog();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PasswordInputDialog() {
    Stack() {
      Row() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#55000000')
    

      Column() {
        Text('是否确定修改定值')
          .width('100%')
          .fontSize(18 * this.uiScale)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 * this.uiScale });

        // 密码输入
        Row() {
          Text('密码:')
            .fontSize(16 * this.uiScale)
            .fontColor('#000000')
            .width(60 * this.uiScale)
            .textAlign(TextAlign.Start);
          TextInput({ text: this.passwordInput, placeholder: '请输入密码' })
            .type(InputType.Password)
            .width(200 * this.uiScale)
            .height(40 * this.uiScale)
            .fontSize(16 * this.uiScale)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#999999', radius: 4 * this.uiScale })
            .padding({ left: 10 * this.uiScale, right: 10 * this.uiScale })
            .onChange((value: string) => {
              this.passwordInput = value;
            });
        }
        .width('100%')
        .margin({ bottom: 20 * this.uiScale })
        .alignItems(VerticalAlign.Center);

        Row() {
          Button('取消')
            .width(100 * this.uiScale)
            .height(40 * this.uiScale)
            .fontSize(16 * this.uiScale)
            .fontColor('#000000')
            .backgroundColor('#E5E5E5')
            .border({ width: 0 })
            .borderRadius(4 * this.uiScale)
            .margin({ right: 20 * this.uiScale })
            .onClick(() => {
              this.closePasswordDialog();
            });

          Button('确定')
            .width(100 * this.uiScale)
            .height(40 * this.uiScale)
            .fontSize(16 * this.uiScale)
            .fontColor('#FFFFFF')
            .backgroundColor('#167fff')
            .border({ width: 0 })
            .borderRadius(4 * this.uiScale)
            .onClick(() => {
              this.confirmOperation(this.passwordInput);
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);
      }
      .width(300 * this.uiScale)
      .padding({ left: 20 * this.uiScale, right: 20 * this.uiScale, top: 20 * this.uiScale, bottom: 20 * this.uiScale })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(8 * this.uiScale);
    }
    .width('100%')
    .height('100%');
  }

  private saveCurrentInput(): void {
    if (this.currentRowId === -1) return;
    switch (this.currentRowId) {
      case 0: if (this.currentInputType === 0) this.voltageUnbalanceValue = this.currentDisplayValue; else this.voltageUnbalanceTime = this.currentDisplayValue; break;
      case 1: if (this.currentInputType === 0) this.voltageDeviationValue = this.currentDisplayValue; else this.voltageDeviationTime = this.currentDisplayValue; break;
      case 2: if (this.currentInputType === 0) this.frequencyDeviationValue = this.currentDisplayValue; else this.frequencyDeviationTime = this.currentDisplayValue; break;
      case 3: if (this.currentInputType === 0) this.voltageShortFlickerValue = this.currentDisplayValue; else this.voltageShortFlickerTime = this.currentDisplayValue; break;
      case 4: if (this.currentInputType === 0) this.voltageLongFlickerValue = this.currentDisplayValue; else this.voltageLongFlickerTime = this.currentDisplayValue; break;
      case 5: if (this.currentInputType === 0) this.voltageFluctuationValue = this.currentDisplayValue; else this.voltageFluctuationTime = this.currentDisplayValue; break;
      case 6: if (this.currentInputType === 0) this.voltageSagValue = this.currentDisplayValue; else this.voltageSagTime = this.currentDisplayValue; break;
      case 7: if (this.currentInputType === 0) this.voltageSwellValue = this.currentDisplayValue; else this.voltageSwellTime = this.currentDisplayValue; break;
      case 8: if (this.currentInputType === 0) this.voltageTotalHarmonicValue = this.currentDisplayValue; else this.voltageTotalHarmonicTime = this.currentDisplayValue; break;
      case 9: if (this.currentInputType === 0) this.voltageOddHarmonicValue = this.currentDisplayValue; else this.voltageOddHarmonicTime = this.currentDisplayValue; break;
      case 10: if (this.currentInputType === 0) this.voltageEvenHarmonicValue = this.currentDisplayValue; else this.voltageEvenHarmonicTime = this.currentDisplayValue; break;
      case 11: if (this.currentInputType === 0) this.voltageSingleOddHarmonicValue = this.currentDisplayValue; else this.voltageSingleOddHarmonicTime = this.currentDisplayValue; break;
      case 12: if (this.currentInputType === 0) this.voltageSingleEvenHarmonicValue = this.currentDisplayValue; else this.voltageSingleEvenHarmonicTime = this.currentDisplayValue; break;
      case 13: if (this.currentInputType === 0) this.voltageInterHarmonicValue = this.currentDisplayValue; else this.voltageInterHarmonicTime = this.currentDisplayValue; break;
      case 14: if (this.currentInputType === 0) this.voltageSingleInterHarmonicValue = this.currentDisplayValue; else this.voltageSingleInterHarmonicTime = this.currentDisplayValue; break;
      case 15: if (this.currentInputType === 0) this.currentUnbalanceValue = this.currentDisplayValue; else this.currentUnbalanceTime = this.currentDisplayValue; break;
      case 16: if (this.currentInputType === 0) this.currentTotalHarmonicValue = this.currentDisplayValue; else this.currentTotalHarmonicTime = this.currentDisplayValue; break;
      case 17: if (this.currentInputType === 0) this.currentOddHarmonicValue = this.currentDisplayValue; else this.currentOddHarmonicTime = this.currentDisplayValue; break;
      case 18: if (this.currentInputType === 0) this.currentEvenHarmonicValue = this.currentDisplayValue; else this.currentEvenHarmonicTime = this.currentDisplayValue; break;
      case 19: if (this.currentInputType === 0) this.currentSingleOddHarmonicValue = this.currentDisplayValue; else this.currentSingleOddHarmonicTime = this.currentDisplayValue; break;
      case 20: if (this.currentInputType === 0) this.currentSingleEvenHarmonicValue = this.currentDisplayValue; else this.currentSingleEvenHarmonicTime = this.currentDisplayValue; break;
      case 21: if (this.currentInputType === 0) this.currentInterHarmonicValue = this.currentDisplayValue; else this.currentInterHarmonicTime = this.currentDisplayValue; break;
      case 22: if (this.currentInputType === 0) this.currentSingleInterHarmonicValue = this.currentDisplayValue; else this.currentSingleInterHarmonicTime = this.currentDisplayValue; break;
    }
  }

  onConfirmClick() {
    console.info('显示账号密码输入框');
    this.passwordDialogVisible = true;
  }

  private async confirmOperation(password: string): Promise<void> {
    if (!password) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return;
    }

    if (password !== DEFAULT_PASSWORD) {
      promptAction.showToast({
        message: '密码错误',
        duration: 2000
      });
      return;
    }

    this.loading = true;

    try {
      console.info('密码验证成功');
      
      // 构建电能质量定值数据
      const powerQualityData = this.buildPowerQualityData();
      
      const data: RequestData = {
        "电能质量定值": {
          "Enable": true,
          "Line": 1,
          "Code": 1,
          "Data": powerQualityData
        }
      };

      hilog.info(DOMAIN, TAG, '准备发送设置数据: %{public}s', JSON.stringify(data));

      const params: IpcParams = new IpcParams();
      params.setExtra('edgeId', this.edgeId);
      params.setExtra('data', JSON.stringify(data));

      hilog.info(DOMAIN, TAG, '请求参数 - edgeId: %{public}s', this.edgeId);
      hilog.info(DOMAIN, TAG, '请求参数 - data: %{public}s', JSON.stringify(data));

      const config: IpcRequestConfig = new IpcRequestConfig('/api/remote/adjust/set', params);

      hilog.info(DOMAIN, TAG, '开始请求remote/adjust/set，edgeId: %{public}s', this.edgeId);
      const response = await IpcUtil.sendRequest<FileContentData>(config);
      hilog.info(DOMAIN, TAG, 'remote/adjust/set请求成功: %{public}s', JSON.stringify(response));

      if (response.success && response.data) {
        try {
          const businessData: BusinessResponse = JSON.parse(response.data.data as string);
          hilog.info(DOMAIN, TAG, '业务数据解析 - code: %{public}d, success: %{public}s, message: %{public}s',
            businessData.code, businessData.success, businessData.message);

          if (businessData.success) {
            hilog.info(DOMAIN, TAG, '设置保存成功');
            promptAction.showToast({
              message: '设置保存成功',
              duration: 3000
            });
          } else {
            hilog.error(DOMAIN, TAG, '设置保存失败: %{public}s', businessData.message);
            promptAction.showToast({
              message: `设置保存失败: ${businessData.message}`,
              duration: 3000
            });
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '业务数据解析失败: %{public}s', String(parseError));
          promptAction.showToast({
            message: '设置保存失败',
            duration: 3000
          });
        }
      } else {
        hilog.error(DOMAIN, TAG, '设置保存失败: %{public}s', response.error || '未知错误');
        promptAction.showToast({
          message: '设置保存失败',
          duration: 3000
        });
      }

      this.passwordDialogVisible = false;
      this.passwordInput = '';
    } catch (error) {
      console.error('确认操作异常: %{public}s', String(error));
      promptAction.showToast({
        message: '设置保存失败',
        duration: 3000
      });
    } finally {
      this.loading = false;
    }
  }

  private buildPowerQualityData(): PowerQuality {
    return {
      // 电压相关
      VoltageUnbalance: {
        Enable: this.voltageUnbalanceEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageUnbalanceValue),
        Time: parseFloat(this.voltageUnbalanceTime) * 100
      },
      VoltageDeviation: {
        Enable: this.voltageDeviationEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageDeviationValue),
        Time: parseFloat(this.voltageDeviationTime) * 100
      },
      FreqDeviation: {
        Enable: this.frequencyDeviationEnable ? 1 : 0,
        ActValue: parseFloat(this.frequencyDeviationValue),
        Time: parseFloat(this.frequencyDeviationTime) * 100
      },
      VoltageShortFlicke: {
        Enable: this.voltageShortFlickerEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageShortFlickerValue),
        Time: parseFloat(this.voltageShortFlickerTime) * 100
      },
      VoltageLongFlicke: {
        Enable: this.voltageLongFlickerEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageLongFlickerValue),
        Time: parseFloat(this.voltageLongFlickerTime) * 100
      },
      VoltageFluct: {
        Enable: this.voltageFluctuationEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageFluctuationValue),
        Time: parseFloat(this.voltageFluctuationTime) * 100
      },

      VoltageSwell: {
        Enable: this.voltageSwellEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageSwellValue),
        Time: parseFloat(this.voltageSwellTime) * 100
      },
      // 谐波相关
      VoltageTHD: {
        Enable: this.voltageTotalHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageTotalHarmonicValue),
        Time: parseFloat(this.voltageTotalHarmonicTime) * 100
      },
      VoltageOddTHD: {
        Enable: this.voltageOddHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageOddHarmonicValue),
        Time: parseFloat(this.voltageOddHarmonicTime) * 100
      },
      VoltageEvenTHD: {
        Enable: this.voltageEvenHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageEvenHarmonicValue),
        Time: parseFloat(this.voltageEvenHarmonicTime) * 100
      },
      VoltageOddHAR: {
        Enable: this.voltageSingleOddHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageSingleOddHarmonicValue),
        Time: parseFloat(this.voltageSingleOddHarmonicTime) * 100
      },
      VoltageEvenHAR: {
        Enable: this.voltageSingleEvenHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageSingleEvenHarmonicValue),
        Time: parseFloat(this.voltageSingleEvenHarmonicTime) * 100
      },
      VoltageInterTHD: {
        Enable: this.voltageInterHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageInterHarmonicValue),
        Time: parseFloat(this.voltageInterHarmonicTime) * 100
      },
      VoltageInterHAR: {
        Enable: this.voltageSingleInterHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageSingleInterHarmonicValue),
        Time: parseFloat(this.voltageSingleInterHarmonicTime) * 100
      },
      // 电流相关
      CurrentUnbalance: {
        Enable: this.currentUnbalanceEnable ? 1 : 0,
        ActValue: parseFloat(this.currentUnbalanceValue),
        Time: parseFloat(this.currentUnbalanceTime) * 100
      },
      CurrentTHD: {
        Enable: this.currentTotalHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentTotalHarmonicValue),
        Time: parseFloat(this.currentTotalHarmonicTime) * 100
      },
      CurrentOddTHD: {
        Enable: this.currentOddHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentOddHarmonicValue),
        Time: parseFloat(this.currentOddHarmonicTime) * 100
      },
      CurrentEvenTHD: {
        Enable: this.currentEvenHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentEvenHarmonicValue),
        Time: parseFloat(this.currentEvenHarmonicTime) * 100
      },
      CurrentOddHAR: {
        Enable: this.currentSingleOddHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentSingleOddHarmonicValue),
        Time: parseFloat(this.currentSingleOddHarmonicTime) * 100
      },
      CurrentEvenHAR: {
        Enable: this.currentSingleEvenHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentSingleEvenHarmonicValue),
        Time: parseFloat(this.currentSingleEvenHarmonicTime) * 100
      },
      CurrentInterTHD: {
        Enable: this.currentInterHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentInterHarmonicValue),
        Time: parseFloat(this.currentInterHarmonicTime) * 100
      },
      CurrentInterHAR: {
        Enable: this.currentSingleInterHarmonicEnable ? 1 : 0,
        ActValue: parseFloat(this.currentSingleInterHarmonicValue),
        Time: parseFloat(this.currentSingleInterHarmonicTime) * 100
      },
      // 其他
      VoltageRef_SegSwell: 0,
      VoltageSeg: {
        Enable: this.voltageSagEnable ? 1 : 0,
        ActValue: parseFloat(this.voltageSagValue),
        Time: parseFloat(this.voltageSagTime) * 100
      }
    };
  }

  private closePasswordDialog(): void {
    this.passwordDialogVisible = false;
    this.passwordInput = '';
  }

  // 👇 辅助方法：通过相对父组件的偏移来估算当前输入框的真实 Y 坐标
  private getInputRelativeY(rowId: number, inputType: number): number {
    // 每个 alarmItem 高度约 48 * uiScale，顶部 header 约 40 * uiScale
    let itemHeight = 48 * this.uiScale;
    let headerHeight = 40 * this.uiScale;
    let rowIndex = rowId;

    // 估算该行在滚动区域的顶部 Y（相对于 Scroll 容器）
    let rowY = headerHeight + rowIndex * itemHeight;

    // 根据 inputType 调整偏移（动作定值在左，时间在右，垂直位置相同）
    // 这里只需要 Y 坐标，偏移不影响
    return rowY - this.scrollOffsetY;
  }

  @Builder
  buildAlarmItem(rowId: number, label: string, enable: number, value1: string, unit1: string, value2: string, unit2: string) {
    Row() {
      Text(label)
        .fontSize(15 * this.uiScale)
        .fontWeight(FontWeight.Medium)
        .width(180 * this.uiScale)

      Row({ space: 8 * this.uiScale }) {
        Text('投/退：')
          .fontSize(14 * this.uiScale)
        Select([{ value: '退出' }, { value: '投入' }])
          .value(enable === 1 ? '投入' : '退出')
          .width(80 * this.uiScale)
          .height(32 * this.uiScale)
          .backgroundColor(Color.White)
          .border({ width: 1 * this.uiScale, color: '#999', radius: 3 * this.uiScale })
          .font({ size: 14 * this.uiScale })
          .optionFont({ size: 14 * this.uiScale })
          .onClick(() => {
            this.forceLockFocus = true;
            this.saveCurrentInput();
            this.isKeyboardShow = false;
            this.currentRowId = -1;
          })
          .onSelect((index: number, value: string) => {
            setTimeout(() => {
              this.forceLockFocus = false;
            }, 300);
            // 根据选择更新 enable 状态
            this.updateEnableState(rowId, value === '投入' ? 1 : 0);
          })

        Text('动作定值：')
          .fontSize(14 * this.uiScale)
        TextInput({ text: this.getValueByRowIdAndType(rowId, 0) })
          .width(70 * this.uiScale)
          .height(32 * this.uiScale)
          .fontSize(14 * this.uiScale)
          .backgroundColor(Color.White)
          .border({ width: 1 * this.uiScale, color: '#999', radius: 3 * this.uiScale })
          .focusable(true)
          .focusOnTouch(true)
          .customKeyboard(this.EmptyKeyboardBuilder())
          .onFocus(() => {
            if (this.forceLockFocus) return;

            // 👇 通过计算获取输入框相对于屏幕的 Y 坐标
            let inputY = this.getInputRelativeY(rowId, 0);

            // 👇 👇 👇 这是真正屏幕安全区域高度
            let screenHeight = display.getDefaultDisplaySync().height;
            let safeHeight = screenHeight - 150; // 减去底部导航/键盘高度

            // 👇 👇 👇 只要输入框 Y > 1/3 屏幕，就判定在下方，键盘弹上
            this.keyboardPosition = inputY > safeHeight / 1.5 ? "top" : "bottom";

            console.log(
              "✅ 最终判定 -> 输入框Y:", inputY,
              " 屏幕半高:", safeHeight / 1.5,
              " 键盘位置:", this.keyboardPosition
            );

            this.currentRowId = rowId;
            this.currentInputType = 0;
            this.currentDisplayValue = this.getValueByRowIdAndType(rowId, 0);
            this.isKeyboardShow = true;
          })
          .onChange((val: string) => {
            this.currentDisplayValue = val;
            this.saveCurrentInput();
          })
          .onBlur(() => {
            this.saveCurrentInput();
          })

        Text(unit1)
          .fontSize(14 * this.uiScale)
          .width(24 * this.uiScale)

        Text('动作时间：')
          .fontSize(14 * this.uiScale)
        TextInput({ text: this.getValueByRowIdAndType(rowId, 1) })
          .width(70 * this.uiScale)
          .height(32 * this.uiScale)
          .fontSize(14 * this.uiScale)
          .backgroundColor(Color.White)
          .border({ width: 1 * this.uiScale, color: '#999', radius: 3 * this.uiScale })
          .focusable(true)
          .focusOnTouch(true)
          .customKeyboard(this.EmptyKeyboardBuilder())
          .onFocus(() => {
            if (this.forceLockFocus) return;

            // 👇 通过计算获取输入框相对于屏幕的 Y 坐标
            let inputY = this.getInputRelativeY(rowId, 1);

            let screenHeight = display.getDefaultDisplaySync().height;
            let safeHeight = screenHeight - 150;

            this.keyboardPosition = inputY > safeHeight / 1.5 ? "top" : "bottom";
            console.log(
              "✅ 最终判定 -> 输入框Y:", inputY,
              " 屏幕半高:", safeHeight / 1.5,
              " 键盘位置:", this.keyboardPosition
            );
            this.currentRowId = rowId;
            this.currentInputType = 1;
            this.currentDisplayValue = this.getValueByRowIdAndType(rowId, 1);
            this.isKeyboardShow = true;
          })
          .onChange((val: string) => {
            this.currentDisplayValue = val;
            this.saveCurrentInput();
          })
          .onBlur(() => {
            this.saveCurrentInput();
          })

        Text(unit2)
          .fontSize(14 * this.uiScale)
          .width(24 * this.uiScale)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(VerticalAlign.Center)
    .padding(4 * this.uiScale)
    .border({ width: { bottom: 1 }, color: { bottom: '#5d5d5d' }, style: { bottom: BorderStyle.Dashed } })
    .width('100%')
  }

  private getValueByRowIdAndType(rowId: number, type: number): string {
    switch (rowId) {
      case 0: return type === 0 ? this.voltageUnbalanceValue : this.voltageUnbalanceTime;
      case 1: return type === 0 ? this.voltageDeviationValue : this.voltageDeviationTime;
      case 2: return type === 0 ? this.frequencyDeviationValue : this.frequencyDeviationTime;
      case 3: return type === 0 ? this.voltageShortFlickerValue : this.voltageShortFlickerTime;
      case 4: return type === 0 ? this.voltageLongFlickerValue : this.voltageLongFlickerTime;
      case 5: return type === 0 ? this.voltageFluctuationValue : this.voltageFluctuationTime;
      case 6: return type === 0 ? this.voltageSagValue : this.voltageSagTime;
      case 7: return type === 0 ? this.voltageSwellValue : this.voltageSwellTime;
      case 8: return type === 0 ? this.voltageTotalHarmonicValue : this.voltageTotalHarmonicTime;
      case 9: return type === 0 ? this.voltageOddHarmonicValue : this.voltageOddHarmonicTime;
      case 10: return type === 0 ? this.voltageEvenHarmonicValue : this.voltageEvenHarmonicTime;
      case 11: return type === 0 ? this.voltageSingleOddHarmonicValue : this.voltageSingleOddHarmonicTime;
      case 12: return type === 0 ? this.voltageSingleEvenHarmonicValue : this.voltageSingleEvenHarmonicTime;
      case 13: return type === 0 ? this.voltageInterHarmonicValue : this.voltageInterHarmonicTime;
      case 14: return type === 0 ? this.voltageSingleInterHarmonicValue : this.voltageSingleInterHarmonicTime;
      case 15: return type === 0 ? this.currentUnbalanceValue : this.currentUnbalanceTime;
      case 16: return type === 0 ? this.currentTotalHarmonicValue : this.currentTotalHarmonicTime;
      case 17: return type === 0 ? this.currentOddHarmonicValue : this.currentOddHarmonicTime;
      case 18: return type === 0 ? this.currentEvenHarmonicValue : this.currentEvenHarmonicTime;
      case 19: return type === 0 ? this.currentSingleOddHarmonicValue : this.currentSingleOddHarmonicTime;
      case 20: return type === 0 ? this.currentSingleEvenHarmonicValue : this.currentSingleEvenHarmonicTime;
      case 21: return type === 0 ? this.currentInterHarmonicValue : this.currentInterHarmonicTime;
      case 22: return type === 0 ? this.currentSingleInterHarmonicValue : this.currentSingleInterHarmonicTime;
      default: return '';
    }
  }

  private updateEnableState(rowId: number, value: number): void {
    switch (rowId) {
      case 0: this.voltageUnbalanceEnable = value; break;
      case 1: this.voltageDeviationEnable = value; break;
      case 2: this.frequencyDeviationEnable = value; break;
      case 3: this.voltageShortFlickerEnable = value; break;
      case 4: this.voltageLongFlickerEnable = value; break;
      case 5: this.voltageFluctuationEnable = value; break;
      case 6: this.voltageSagEnable = value; break;
      case 7: this.voltageSwellEnable = value; break;
      case 8: this.voltageTotalHarmonicEnable = value; break;
      case 9: this.voltageOddHarmonicEnable = value; break;
      case 10: this.voltageEvenHarmonicEnable = value; break;
      case 11: this.voltageSingleOddHarmonicEnable = value; break;
      case 12: this.voltageSingleEvenHarmonicEnable = value; break;
      case 13: this.voltageInterHarmonicEnable = value; break;
      case 14: this.voltageSingleInterHarmonicEnable = value; break;
      case 15: this.currentUnbalanceEnable = value; break;
      case 16: this.currentTotalHarmonicEnable = value; break;
      case 17: this.currentOddHarmonicEnable = value; break;
      case 18: this.currentEvenHarmonicEnable = value; break;
      case 19: this.currentSingleOddHarmonicEnable = value; break;
      case 20: this.currentSingleEvenHarmonicEnable = value; break;
      case 21: this.currentInterHarmonicEnable = value; break;
      case 22: this.currentSingleInterHarmonicEnable = value; break;
    }
  }

  @Builder
  buildRefValueItem() {
    Row() {
      Text('【电压暂降/暂升参考值】')
        .fontSize(15 * this.uiScale)
        .fontWeight(FontWeight.Medium)
        .width(180 * this.uiScale)

      Row({ space: 8 * this.uiScale }) {
        Select(this.refOptions)
          .width(200 * this.uiScale)
          .height(32 * this.uiScale)
          .backgroundColor(Color.White)
          .border({ width: 1 * this.uiScale, color: '#999', radius: 3 * this.uiScale })
          .font({ size: 14 * this.uiScale })
          .optionFont({ size: 14 * this.uiScale })
          .onClick(() => {
            this.forceLockFocus = true;
            this.saveCurrentInput();
            this.isKeyboardShow = false;
            this.currentRowId = -1;
          })
          .onSelect((index: number, value: string) => {
            setTimeout(() => {
              this.forceLockFocus = false;
            }, 300);
          })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(VerticalAlign.Center)
    .padding(4 * this.uiScale)
    .border({ width: { bottom: 1 }, color: { bottom: '#5d5d5d' }, style: { bottom: BorderStyle.Dashed } })
    .width('100%')
  }
}
