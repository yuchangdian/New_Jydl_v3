/**
 * 遥视页面
 * 保护功能投退软压板
 */
import { SectionTitle } from '../../common/SectionTitle';
import { IpcUtil, IpcRequestConfig, IpcParams, IpcDataBase, IpcConnectionState } from '../../utils/IPC_Util';
import { PreferencesUtil } from '../../utils/Preferences_Util';
import hilog from '@ohos.hilog';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

const DOMAIN = 0x0001;
const TAG = 'Yt';

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

interface BusinessResponse {
  code: number;
  success: boolean;
  message: string;
}

interface CurrentDeviceInfo {
  TerminalId: string;
  TerminalNumber: string;
  TerminalType: number;
  TerminalSeries: number;
  TerminalStatus: number;
  Data: Object[];
  detail: Record<string, Object>;
}

// RemoteAdjust 数据类型
interface AnalogCorrectCoeff {
  Ia: number[];
  Ib: number[];
  Ic: number[];
  Ir: number[];
  Ua: number;
  Ub: number;
  Uc: number;
}

interface TransformerRatio {
  CT: number[];
  CT_Sec: number[];
  CTn: number[];
  PT: number[];
  PT_Sec: number[];
}

interface FunctionEnable {
  CurrentQuality_Enable: number[];
  Line_Enable: number[];
  VoltageQuality_Enable: number;
}

interface SoftStrapItem {
  CurrentUnbalance: number;
  HarmonicRelay: number;
  HighFrequence: number;
  InversePower: number;
  LowFrequence: number;
  LowVoltage: number;
  OverHeat: number;
  OverLoad: number;
  OverVoltage: number;
  VoltageUnbalance: number;
}

interface SettingItem<T> {
  Enable: boolean;
  Line: number;
  Code: number;
  Data: T;
}

interface SettingsData {
  "功能投退": SettingItem<Record<string, Object>>;
  "保护功能软压板": SettingItem<SoftStrapItem[]>;
}

interface RemoteAdjustData {
  AnalogCorrectCoeff: AnalogCorrectCoeff;
  CurrentConstantValueCode: number[];
  FunctionEnable: FunctionEnable;
  LineStatus: number[];
  PowerQualitySetting: Record<string, Object>;
  SoftStrap: SoftStrapItem[];
  TransformerRatio: TransformerRatio;
}

@Component
struct SwitchSvg {
  @Prop isClosed: boolean = true;

  build() {
    Stack() {
      if (this.isClosed) {
        this.ClosedSwitch()
      } else {
        this.OpenSwitch()
      }
    }
    .width(50)
    .height(70)
  }

  // 闭合 - 红色（已缩小居中）
  @Builder
  ClosedSwitch() {
    Rect()
      .width(20)
      .height(70)
      .radius(10)
      .fill(Color.Transparent)
      .stroke(Color.Red)
      .strokeWidth(2)
      .position({ x: 15, y: 0 })
    Circle()
      .width(14)
      .height(14)
      .fill(Color.Red)
      .position({ x: 18, y: 5 })
    Circle()
      .width(14)
      .height(14)
      .fill(Color.Red)
      .position({ x: 18, y: 51 })
    Rect()
      .width(14)
      .height(14)
      .fill(Color.Red)
      .position({ x: 18, y: 28 })
    Line()
      .width(2)
      .height(60)
      .stroke(Color.Red)
      .strokeWidth(2)
      .startPoint([32, 5])
      .endPoint([32, 65])
      .position({ x: -7, y: 0 })
  }

  // 断开 - 绿色（已缩小居中）
  @Builder
  OpenSwitch() {
    Rect()
      .width(16)
      .height(70)
      .radius(9)
      .fill(Color.Transparent)
      .stroke('#008000')
      .strokeWidth(2)
      .rotate({ angle: -26, centerX: 8, centerY: 28 })
      .position({ x:3, y: 2 })
    Rect()
      .width(12)
      .height(12)
      .fill('#008000')
      .rotate({ angle: -26, centerX: 6, centerY: 6 })
      .position({ x: 8, y: 29 })
    Line()
      .width(2)
      .height(56)
      .stroke('#008000')
      .strokeWidth(2)
      .startPoint([0, 7])
      .endPoint([28, 63])
      .position({ x: 0, y: 0 })
    Circle()
      .width(14)
      .height(14)
      .fill('#008000')
      .position({ x: 18, y: 5 })
    Circle()
      .width(12)
      .height(12)
      .fill('#008000')
      .position({ x: 19, y: 53 })
  }
}

@Component
struct SwitchItem {
  @Prop label: string = '';
  @Link isClosed: boolean;
  @Prop hasChanged: boolean = false;
  onValueChanged?: () => void;
  build() {
    Column() {
      SwitchSvg({ isClosed: this.isClosed })
        .onClick(() => {
          this.isClosed = !this.isClosed;
          if (this.onValueChanged) {
            this.onValueChanged();
          }
        })
      Text(this.label)
        .fontSize(16)
        .fontColor(Color.White)
        .textAlign(TextAlign.Start)
        .margin({ top:8 })
    }
    .width(140)
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 16,top:16,right:16 })
    .padding(8)

    .backgroundColor('#000e1e')
    .borderRadius(12)
    .border({
      width: this.hasChanged ? 1 : 0,
      color: this.hasChanged ? '#cdbf8057' : Color.Transparent
    })
    .shadow({ radius: 10, color: '#5fb8ff7d', offsetX: 0, offsetY: 0 })
  }
}

@Component
struct Yt {
  @State edgeId: string = '';
  @State lineFunctionEnabled: boolean = false;
  @State overLoadEnabled: boolean = true;
  @State overVoltageEnabled: boolean = false;
  @State lowVoltageEnabled: boolean = false;
  @State highFrequencyEnabled: boolean = false;
  @State lowFrequencyEnabled: boolean = false;
  @State voltageUnbalanceEnabled: boolean = false;
  @State currentUnbalanceEnabled: boolean = false;
  @State inversePowerEnabled: boolean = false;
  @State overHeatEnabled: boolean = false;
  @State voltageQualityEnabled: boolean = true;
  @State currentQualityEnabled: boolean = false;
  @State hasValueChanged: boolean = false;
  @State confirmDialog: boolean = false;
  @State inputAccount: string = '';
  @State inputPassword: string = '';
  @State loading: boolean = false;
  @State isExternalKeyboardConnected: boolean = true;
  
  @State lineFunctionChanged: boolean = false;
  @State overLoadChanged: boolean = false;
  @State overVoltageChanged: boolean = false;
  @State lowVoltageChanged: boolean = false;
  @State highFrequencyChanged: boolean = false;
  @State lowFrequencyChanged: boolean = false;
  @State voltageUnbalanceChanged: boolean = false;
  @State currentUnbalanceChanged: boolean = false;
  @State inversePowerChanged: boolean = false;
  @State overHeatChanged: boolean = false;
  @State voltageQualityChanged: boolean = false;
  @State currentQualityChanged: boolean = false;
  
  private originalLineFunctionEnabled: boolean = false;
  private originalOverLoadEnabled: boolean = true;
  private originalOverVoltageEnabled: boolean = false;
  private originalLowVoltageEnabled: boolean = false;
  private originalHighFrequencyEnabled: boolean = false;
  private originalLowFrequencyEnabled: boolean = false;
  private originalVoltageUnbalanceEnabled: boolean = false;
  private originalCurrentUnbalanceEnabled: boolean = false;
  private originalInversePowerEnabled: boolean = false;
  private originalOverHeatEnabled: boolean = false;
  private originalVoltageQualityEnabled: boolean = true;
  private originalCurrentQualityEnabled: boolean = false;
  
  private textInputController: TextInputController = new TextInputController();

  async aboutToAppear() {
    this.detectExternalKeyboard()
    await this.loadDeviceInfo()
    this.fetchRemoteAdjust()
  }

  detectExternalKeyboard(): void {
    this.isExternalKeyboardConnected = true;
  }

  private checkValueChanged(): void {
    this.lineFunctionChanged = this.lineFunctionEnabled !== this.originalLineFunctionEnabled;
    this.overLoadChanged = this.overLoadEnabled !== this.originalOverLoadEnabled;
    this.overVoltageChanged = this.overVoltageEnabled !== this.originalOverVoltageEnabled;
    this.lowVoltageChanged = this.lowVoltageEnabled !== this.originalLowVoltageEnabled;
    this.highFrequencyChanged = this.highFrequencyEnabled !== this.originalHighFrequencyEnabled;
    this.lowFrequencyChanged = this.lowFrequencyEnabled !== this.originalLowFrequencyEnabled;
    this.voltageUnbalanceChanged = this.voltageUnbalanceEnabled !== this.originalVoltageUnbalanceEnabled;
    this.currentUnbalanceChanged = this.currentUnbalanceEnabled !== this.originalCurrentUnbalanceEnabled;
    this.inversePowerChanged = this.inversePowerEnabled !== this.originalInversePowerEnabled;
    this.overHeatChanged = this.overHeatEnabled !== this.originalOverHeatEnabled;
    this.voltageQualityChanged = this.voltageQualityEnabled !== this.originalVoltageQualityEnabled;
    this.currentQualityChanged = this.currentQualityEnabled !== this.originalCurrentQualityEnabled;
    
    this.hasValueChanged = 
      this.lineFunctionChanged ||
      this.overLoadChanged ||
      this.overVoltageChanged ||
      this.lowVoltageChanged ||
      this.highFrequencyChanged ||
      this.lowFrequencyChanged ||
      this.voltageUnbalanceChanged ||
      this.currentUnbalanceChanged ||
      this.inversePowerChanged ||
      this.overHeatChanged ||
      this.voltageQualityChanged ||
      this.currentQualityChanged;
  }

  private async loadDeviceInfo(): Promise<void> {
    try {
      const currentDeviceInfoStr = await PreferencesUtil.get('currentDeviceInfo', '');
      hilog.info(DOMAIN, TAG, '获取设备信息字符串: %{public}s', String(currentDeviceInfoStr));
      
      if (currentDeviceInfoStr && typeof currentDeviceInfoStr === 'string') {
        const currentDeviceInfo = JSON.parse(currentDeviceInfoStr) as CurrentDeviceInfo;
        this.edgeId = currentDeviceInfo.TerminalId;
        hilog.info(DOMAIN, TAG, '设备ID: %{public}s, edgeId: %{public}s', 
          currentDeviceInfo.TerminalId, this.edgeId);
      } else {
        hilog.warn(DOMAIN, TAG, '设备信息为空');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '加载设备信息异常: %{public}s', String(error));
    }
  }

  async fetchRemoteAdjust(): Promise<void> {
    if (!this.edgeId) {
      hilog.error(DOMAIN, TAG, 'edgeId为空，无法请求RemoteAdjust文件');
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
      hilog.info(DOMAIN, TAG, '开始请求RemoteAdjust文件: %{public}s', params.filePath);
      const response = await IpcUtil.sendRequest<FileContentData>(config);

      if (response.success) {
        const fileContentData = response.data as FileContentData;
        let content = '';
        
        if (typeof fileContentData.data === 'string') {
          content = fileContentData.data as string;
        } else if (typeof fileContentData.data === 'object') {
          content = JSON.stringify(fileContentData.data);
        }
        
        hilog.info(DOMAIN, TAG, 'RemoteAdjust文件内容获取成功，长度: %{public}d', content.length);
        hilog.info(DOMAIN, TAG, 'RemoteAdjust文件内容: %{public}s', content);
        
        if (content) {
          try {
            const outerResponse = JSON.parse(content) as FileContentResponse;
            hilog.info(DOMAIN, TAG, '解析外层响应成功，code: %{public}d, success: %{public}s', outerResponse.code, outerResponse.success);
            
            if (outerResponse.success && outerResponse.data) {
              const data = JSON.parse(outerResponse.data) as RemoteAdjustData;
              hilog.info(DOMAIN, TAG, '解析RemoteAdjust数据成功: %{public}s', JSON.stringify(data));
              
              if (data.SoftStrap && data.SoftStrap.length > 0) {
                const softStrap = data.SoftStrap[0];
                this.overLoadEnabled = softStrap.OverLoad === 1;
                this.overVoltageEnabled = softStrap.OverVoltage === 1;
                this.lowVoltageEnabled = softStrap.LowVoltage === 1;
                this.highFrequencyEnabled = softStrap.HighFrequence === 1;
                this.lowFrequencyEnabled = softStrap.LowFrequence === 1;
                this.voltageUnbalanceEnabled = softStrap.VoltageUnbalance === 1;
                this.currentUnbalanceEnabled = softStrap.CurrentUnbalance === 1;
                this.inversePowerEnabled = softStrap.InversePower === 1;
                this.overHeatEnabled = softStrap.OverHeat === 1;
                
                this.originalOverLoadEnabled = this.overLoadEnabled;
                this.originalOverVoltageEnabled = this.overVoltageEnabled;
                this.originalLowVoltageEnabled = this.lowVoltageEnabled;
                this.originalHighFrequencyEnabled = this.highFrequencyEnabled;
                this.originalLowFrequencyEnabled = this.lowFrequencyEnabled;
                this.originalVoltageUnbalanceEnabled = this.voltageUnbalanceEnabled;
                this.originalCurrentUnbalanceEnabled = this.currentUnbalanceEnabled;
                this.originalInversePowerEnabled = this.inversePowerEnabled;
                this.originalOverHeatEnabled = this.overHeatEnabled;
                
                hilog.info(DOMAIN, TAG, 'SoftStrap状态设置完成');
              }
              
              if (data.FunctionEnable) {
                this.lineFunctionEnabled = data.FunctionEnable.Line_Enable.length > 0 && data.FunctionEnable.Line_Enable[0] === 1;
                this.voltageQualityEnabled = data.FunctionEnable.VoltageQuality_Enable === 1;
                this.currentQualityEnabled = data.FunctionEnable.CurrentQuality_Enable.length > 0 && data.FunctionEnable.CurrentQuality_Enable[0] === 1;
                
                this.originalLineFunctionEnabled = this.lineFunctionEnabled;
                this.originalVoltageQualityEnabled = this.voltageQualityEnabled;
                this.originalCurrentQualityEnabled = this.currentQualityEnabled;
                
                hilog.info(DOMAIN, TAG, 'FunctionEnable状态设置完成');
              }
              
              this.lineFunctionChanged = false;
              this.overLoadChanged = false;
              this.overVoltageChanged = false;
              this.lowVoltageChanged = false;
              this.highFrequencyChanged = false;
              this.lowFrequencyChanged = false;
              this.voltageUnbalanceChanged = false;
              this.currentUnbalanceChanged = false;
              this.inversePowerChanged = false;
              this.overHeatChanged = false;
              this.voltageQualityChanged = false;
              this.currentQualityChanged = false;
              this.hasValueChanged = false;
            } else {
              hilog.warn(DOMAIN, TAG, '外层响应失败或data为空');
            }
          } catch (parseError) {
            hilog.error(DOMAIN, TAG, '解析RemoteAdjust数据异常: %{public}s', String(parseError));
          }
        }
      } else {
        hilog.error(DOMAIN, TAG, '请求RemoteAdjust文件失败: %{public}s', response.error || '未知错误');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '请求RemoteAdjust文件异常: %{public}s', String(error));
    }
  }

  private async sendSettingsData(): Promise<void> {
    if (!this.edgeId) {
      hilog.error(DOMAIN, TAG, 'edgeId为空，无法发送数据');
      promptAction.showToast({
        message: '设备信息不完整',
        duration: 3000,
        bottom: 500
      });
      return;
    }

    if (IpcUtil.getConnectionState() !== IpcConnectionState.CONNECTED) {
      hilog.info(DOMAIN, TAG, 'IPC未连接，开始连接IPC');
      await IpcUtil.connect(getContext(this) as common.UIAbilityContext);
      hilog.info(DOMAIN, TAG, 'IPC连接完成');
    }

    const functionEnableData: Record<string, Object> = {
      "CurrentQuality_Enable": [this.currentQualityEnabled ? 1 : 0],
      "Line_Enable": [this.lineFunctionEnabled ? 1 : 0],
      "VoltageQuality_Enable": this.voltageQualityEnabled ? 1 : 0
    };

    const softStrapData: SoftStrapItem[] = [{
      "CurrentUnbalance": this.currentUnbalanceEnabled ? 1 : 0,
      "HarmonicRelay": 0,
      "HighFrequence": this.highFrequencyEnabled ? 1 : 0,
      "InversePower": this.inversePowerEnabled ? 1 : 0,
      "LowFrequence": this.lowFrequencyEnabled ? 1 : 0,
      "LowVoltage": this.lowVoltageEnabled ? 1 : 0,
      "OverHeat": this.overHeatEnabled ? 1 : 0,
      "OverLoad": this.overLoadEnabled ? 1 : 0,
      "OverVoltage": this.overVoltageEnabled ? 1 : 0,
      "VoltageUnbalance": this.voltageUnbalanceEnabled ? 1 : 0
    }];

    const data: SettingsData = {
      "功能投退": {
        "Enable": true,
        "Line": 1,
        "Code": 1,
        "Data": functionEnableData
      },
      "保护功能软压板": {
        "Enable": true,
        "Line": 1,
        "Code": 1,
        "Data": softStrapData
      }
    };

    hilog.info(DOMAIN, TAG, '准备发送设置数据: %{public}s', JSON.stringify(data));

    const params: IpcParams = new IpcParams();
    params.setExtra('edgeId', this.edgeId);
    params.setExtra('data', JSON.stringify(data));

    hilog.info(DOMAIN, TAG, '请求参数 - edgeId: %{public}s', this.edgeId);
    hilog.info(DOMAIN, TAG, '请求参数 - data: %{public}s', JSON.stringify(data));

    const config: IpcRequestConfig = new IpcRequestConfig('/api/remote/adjust/set', params);

    try {
      hilog.info(DOMAIN, TAG, '开始请求remote/adjust/set，edgeId: %{public}s', this.edgeId);
      const response = await IpcUtil.sendRequest<FileContentData>(config);
      hilog.info(DOMAIN, TAG, 'remote/adjust/set请求成功: %{public}s', JSON.stringify(response));

      if (response.success && response.data) {
        try {
          const businessData = JSON.parse(response.data.data as string) as BusinessResponse;
          hilog.info(DOMAIN, TAG, '业务数据解析 - code: %{public}d, success: %{public}s, message: %{public}s',
            businessData.code, businessData.success, businessData.message);

          if (businessData.success) {
            hilog.info(DOMAIN, TAG, '设置保存成功');
            promptAction.showToast({
              message: '设置保存成功',
              duration: 3000,
              bottom: 500
            });
            await this.fetchRemoteAdjust();
          } else {
            hilog.error(DOMAIN, TAG, '设置保存失败: %{public}s', businessData.message || '未知错误');
            promptAction.showToast({
              message: businessData.message || '设置保存失败',
              duration: 3000,
              bottom: 500
            });
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '业务数据解析失败: %{public}s', String(parseError));
          promptAction.showToast({
            message: '响应数据解析异常',
            duration: 3000,
            bottom: 500
          });
        }
      } else {
        hilog.error(DOMAIN, TAG, '设置保存失败: 响应数据为空');
        promptAction.showToast({
          message: '响应数据为空',
          duration: 3000,
          bottom: 500
        });
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '请求remote/adjust/set异常: %{public}s', String(error));
      promptAction.showToast({
        message: '请求异常',
        duration: 3000,
        bottom: 500
      });
    }
  }

  private async confirmOperation(): Promise<void> {
    if (!this.inputAccount || !this.inputPassword) {
      promptAction.showToast({
        message: '请输入账号和密码',
        duration: 3000,
        bottom: 500
      });
      return;
    }

    this.loading = true;

    try {
      await this.sendSettingsData();
      this.inputAccount = '';
      this.inputPassword = '';
      this.confirmDialog = false;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '确认操作异常: %{public}s', String(error));
    } finally {
      this.loading = false;
    }
  }

  @Builder
  EmptyKeyboardBuilder() {
    Column()
      .width(0)
      .height(0)
  }

  @Builder
  confirmDialogBuilder() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.inputPassword = ''
          this.inputAccount = ''
          this.confirmDialog = false
        })

      Column() {
        Column() {
          Text('确定修改？')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')
            .margin({ bottom: 20 })

          Text('请输入操作员账号和密码')
            .fontSize(14)
            .fontColor('#ffffff')
            .margin({ bottom: 20 })

          Column({ space: 15 }) {
            Row() {
              Text('账号：')
                .fontSize(14)
                .fontColor('#ffffff')
                .width(60)
                  TextInput({ placeholder: '请输入账号', text: this.inputAccount, controller: this.textInputController })
                .placeholderColor('#888888')
                .fontSize(14)
                .fontColor('#ffffff')
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .layoutWeight(1)
                .height(40)
                .padding({ left: 10, right: 10 })
                .border({
                  width: 1,
                  color: '#57a4f5',
                  radius: 4
                })
                .enableKeyboardOnFocus(false)
                .customKeyboard(this.isExternalKeyboardConnected ? this.EmptyKeyboardBuilder() : undefined)
                .onChange((value: string) => {
                  this.inputAccount = value
                })
            }
            .width('100%')

            Row() {
              Text('密码：')
                .fontSize(14)
                .fontColor('#ffffff')
                .width(60)
              TextInput({ placeholder: '请输入密码', text: this.inputPassword })
                .placeholderColor('#888888')
                .fontSize(14)
                .fontColor('#ffffff')
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .layoutWeight(1)
                .height(40)
                .padding({ left: 10, right: 10 })
                .border({
                  width: 1,
                  color: '#57a4f5',
                  radius: 4
                })
                .type(InputType.Password)
                .enableKeyboardOnFocus(false)
                .customKeyboard(this.isExternalKeyboardConnected ? this.EmptyKeyboardBuilder() : undefined)
                .onChange((value: string) => {
                  this.inputPassword = value
                })
            }
            .width('100%')
          }
          .width('100%')

          Row({ space: 20 }) {
            Button('取消')
              .fontSize(16)
              .fontColor('#ffffff')
              .backgroundColor('#666666')
              .height(40)
              .padding({ left: 30, right: 30 })
              .onClick(() => {
                this.inputPassword = ''
                this.inputAccount = ''
                this.confirmDialog = false
              })

            Button('确定')
              .fontSize(16)
              .fontColor('#ffffff')
              .backgroundColor('#007dff')
              .height(40)
              .padding({ left: 30, right: 30 })
              .onClick(() => {
                this.confirmOperation();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 20 })
        }
        .width('100%')
        .padding(20)
      }
      .width(400)
      .backgroundColor('#000e1e')
      .borderRadius(12)
      .padding(24)
      .shadow({ radius: 10, color: '#5fb8ff7d', offsetX: 0, offsetY: 0 })
      .onClick(() => {
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .align(Alignment.Center)
  }

  build() {
    Stack() {
      Column() {
        // 顶部提示
      
          Row() {
              if (this.hasValueChanged) {
            Text('*投退功能已被修改! 是否固化定值:')
              .fontSize(14)
              .fontColor('#ff4444')
            Text('确认')
               .backgroundColor('#007dff')
              .fontColor('#ffffff')
              .borderRadius(4)
              .padding({ left: 30, right: 30, top: 10, bottom: 10 })
              .margin({left:10})
              .onClick(() => {
                this.confirmDialog = true;
              })
        }

          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .height(60)
          .margin({ bottom: 16 })

        Column() {
          SectionTitle({ title: '线路投退设置' })

          Row() {
            Text('退出')
              .fontSize(15)
              .fontColor(Color.White)
            Toggle({ type: ToggleType.Switch, isOn: this.lineFunctionEnabled })
              .selectedColor('#52B4FF')
              .margin({ left: 12 })
              .onChange((isOn: boolean) => {
                this.lineFunctionEnabled = isOn;
                this.checkValueChanged();
              })
               Text('投入')
              .fontSize(15)
              .fontColor(Color.White)
          }
          .width('100%')
          .margin({ top: 10, bottom: 16 })
          .padding(12)
          .backgroundColor('#000e1e')
          .borderRadius(12)
          .border({
            width: this.lineFunctionChanged ? 1 : 0,
            color: this.lineFunctionChanged ? '#cdbf8057' : Color.Transparent
          })
          .shadow({ radius: 10, color: '#5fb8ff7d', offsetX: 0, offsetY: 0 })

          SectionTitle({ title: '保护功能投退软压板' })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            SwitchItem({ label: '过负荷保护', isClosed: $overLoadEnabled, hasChanged: this.overLoadChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '过电压保护', isClosed: $overVoltageEnabled, hasChanged: this.overVoltageChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '低电压保护', isClosed: $lowVoltageEnabled, hasChanged: this.lowVoltageChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '高频保护', isClosed: $highFrequencyEnabled, hasChanged: this.highFrequencyChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '低频保护', isClosed: $lowFrequencyEnabled, hasChanged: this.lowFrequencyChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '电压不平衡保护', isClosed: $voltageUnbalanceEnabled, hasChanged: this.voltageUnbalanceChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '电流不平衡保护', isClosed: $currentUnbalanceEnabled, hasChanged: this.currentUnbalanceChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '逆功率保护', isClosed: $inversePowerEnabled, hasChanged: this.inversePowerChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '过热保护', isClosed: $overHeatEnabled, hasChanged: this.overHeatChanged, onValueChanged: () => { this.checkValueChanged(); } })
          }
          .width('100%')
          .margin({ bottom: 20 })

          SectionTitle({ title: '电能质量监测功能投退软压板' })

          Flex({ wrap: FlexWrap.Wrap }) {
            SwitchItem({ label: '电压质量', isClosed: $voltageQualityEnabled, hasChanged: this.voltageQualityChanged, onValueChanged: () => { this.checkValueChanged(); } })
            SwitchItem({ label: '电流质量', isClosed: $currentQualityEnabled, hasChanged: this.currentQualityChanged, onValueChanged: () => { this.checkValueChanged(); } })
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .padding(16)

      if (this.confirmDialog) {
        this.confirmDialogBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }
}

export { Yt };