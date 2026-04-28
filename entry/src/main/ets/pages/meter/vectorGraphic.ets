import { window } from '@kit.ArkUI'
import display from '@ohos.display'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util';
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState';
import hilog from '@ohos.hilog';

// 定义相量数据接口 - 按照实际接口返回格式
interface VectorData {
  // 电压
  Ua_RMS?: number[];
  Ub_RMS?: number[];
  Uc_RMS?: number[];
  // 电流 (注意：接口返回的是大写的 IA、IB、IC)
  IA_RMS?: number[];
  IB_RMS?: number[];
  IC_RMS?: number[];
  // 角度
  Ua_Phase?: number[];
  Ub_Phase?: number[];
  Uc_Phase?: number[];
  IA_Phase?: number[];
  IB_Phase?: number[];
  IC_Phase?: number[];
}

// 定义API外层响应接口
interface ApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: VectorData;
}

const DOMAIN = 0x0003;
const TAG = 'vectorGraphic';

// 定义角度标签类型
interface AngleLabel {
  ang: number;
  x: number;
  y: number;
}

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
export struct VectorGraphic {
  windowClass?: window.Window
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State uiScale: number = 1
  readonly designWidth: number = 720
  @State selectedLine: number = 1
  @State vectorData: VectorData = {}
  private timerId: number = -1 // 定时器ID

  aboutToAppear(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.startPolling(); // 启动定时轮询
  }

  aboutToDisappear(): void {
    this.stopPolling(); // 页面销毁时停止轮询
  }

  // 启动轮询
  private startPolling(): void {
    this.stopPolling(); // 确保没有重复的定时器
    this.fetchVectorData(); // 立即执行一次
    this.timerId = setInterval(() => {
      this.fetchVectorData();
    }, 2000); // 2秒间隔
  }

  // 停止轮询
  private stopPolling(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private async fetchVectorData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取相量数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'RemoteMetry');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data?.data) {
        hilog.info(DOMAIN, TAG, '相量数据获取成功');

        try {
          // 解析外层JSON字符串
          let outerData: ApiResponse;

          if (typeof response.data.data === 'string') {
            outerData = JSON.parse(response.data.data) as ApiResponse;
          } else {
            outerData = response.data.data as ApiResponse;
          }

          // 从 outerData.data 中获取实际的数据
          const actualData: VectorData = outerData.data;

          hilog.info(DOMAIN, TAG, '实际数据中的 Ua_RMS: %{public}s', JSON.stringify(actualData?.Ua_RMS));

          // 直接赋值
          this.vectorData = actualData;

          hilog.info(DOMAIN, TAG, '赋值后 vectorData.Ua_RMS: %{public}s', JSON.stringify(this.vectorData.Ua_RMS));

          this.drawVectorChart();
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, '解析失败: %{public}s', String(parseError));
        }
      } else {
        hilog.error(DOMAIN, TAG, '请求失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '请求异常: %{public}s', String(error));
    }
  }

  // 安全取值：根据线路选择对应的数据
  private getValue(arr?: number[]): string {
    if (!arr || arr.length === 0) return '0.00';
    // 根据线路选择：线路1取索引0，线路2取索引1
    const index = this.selectedLine === 1 ? 0 : 1;
    const val = arr[index];
    return isNaN(val) ? '0.00' : val.toFixed(2);
  }

  // 获取数值，用于计算（根据线路选择）
  private getNumberValue(arr?: number[]): number {
    if (!arr || arr.length === 0) return 0;
    // 根据线路选择：线路1取索引0，线路2取索引1
    const index = this.selectedLine === 1 ? 0 : 1;
    const val = arr[index];
    return isNaN(val) ? 0 : val;
  }

  private drawArrow(ctx: CanvasRenderingContext2D, fromX: number, fromY: number, toX: number, toY: number, headLength: number = 8) {
    const angle = Math.atan2(toY - fromY, toX - fromX)
    ctx.beginPath()
    ctx.moveTo(fromX, fromY)
    ctx.lineTo(toX, toY)
    ctx.lineTo(toX - headLength * Math.cos(angle - Math.PI / 6), toY - headLength * Math.sin(angle - Math.PI / 6))
    ctx.moveTo(toX, toY)
    ctx.lineTo(toX - headLength * Math.cos(angle + Math.PI / 6), toY - headLength * Math.sin(angle + Math.PI / 6))
    ctx.stroke()
  }

  private drawVectorChart() {
    const ctx = this.context
    const centerX = 150 * this.uiScale
    const centerY = 150 * this.uiScale
    const maxRadius = 110 * this.uiScale

    // 白底
    ctx.clearRect(0, 0, 300 * this.uiScale, 300 * this.uiScale)
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, 300 * this.uiScale, 300 * this.uiScale)

    // 外圆 白底+灰边（实线）
    ctx.fillStyle = '#ffffff'
    ctx.beginPath()
    ctx.arc(centerX, centerY, maxRadius, 0, Math.PI * 2)
    ctx.fill()
    ctx.strokeStyle = '#333333'
    ctx.lineWidth = 0.625 * this.uiScale
    ctx.setLineDash([])
    ctx.stroke()

    // 内部同心圆（虚线）
    ctx.strokeStyle = '#333333'
    ctx.lineWidth = 0.625 * this.uiScale
    ctx.setLineDash([3 * this.uiScale, 2 * this.uiScale])
    const radii: number[] = [88 * this.uiScale, 66 * this.uiScale, 44 * this.uiScale, 22 * this.uiScale]
    for (const r of radii) {
      ctx.beginPath()
      ctx.arc(centerX, centerY, r, 0, Math.PI * 2)
      ctx.stroke()
    }
    ctx.setLineDash([])

    // ====================== 电力标准角度线：顺时针为正 ======================
    ctx.strokeStyle = '#333333'
    ctx.lineWidth = 0.625 * this.uiScale
    const angles: number[] = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330]
    for (const angle of angles) {
      // 电力标准：0°向右，顺时针增加
      const rad = (-angle) * Math.PI / 180
      const x = centerX + maxRadius * Math.cos(rad)
      const y = centerY + maxRadius * Math.sin(rad)
      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.lineTo(x, y)
      ctx.stroke()
    }

    // ====================== 角度文字 ======================
    ctx.fillStyle = '#000000'
    ctx.font = (18 * this.uiScale) + 'px sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'

    const labelRadius = maxRadius + 18 * this.uiScale
    const labels: AngleLabel[] = [
      { ang: 0,   x: centerX + labelRadius, y: centerY },
      { ang: 30,  x: centerX + labelRadius * Math.cos(-30*Math.PI/180), y: centerY + labelRadius * Math.sin(-30*Math.PI/180) },
      { ang: 60,  x: centerX + labelRadius * Math.cos(-60*Math.PI/180), y: centerY + labelRadius * Math.sin(-60*Math.PI/180) },
      { ang: 90,  x: centerX, y: centerY - labelRadius },
      { ang: 120, x: centerX + labelRadius * Math.cos(-120*Math.PI/180), y: centerY + labelRadius * Math.sin(-120*Math.PI/180) },
      { ang: 150, x: centerX + labelRadius * Math.cos(-150*Math.PI/180), y: centerY + labelRadius * Math.sin(-150*Math.PI/180) },
      { ang: 180, x: centerX - labelRadius, y: centerY },
      { ang: 210, x: centerX + labelRadius * Math.cos(-210*Math.PI/180), y: centerY + labelRadius * Math.sin(-210*Math.PI/180) },
      { ang: 240, x: centerX + labelRadius * Math.cos(-240*Math.PI/180), y: centerY + labelRadius * Math.sin(-240*Math.PI/180) },
      { ang: 270, x: centerX, y: centerY + labelRadius },
      { ang: 300, x: centerX + labelRadius * Math.cos(-300*Math.PI/180), y: centerY + labelRadius * Math.sin(-300*Math.PI/180) },
      { ang: 330, x: centerX + labelRadius * Math.cos(-330*Math.PI/180), y: centerY + labelRadius * Math.sin(-330*Math.PI/180) },
    ]

    for (const l of labels) {
      ctx.fillText(l.ang + '°', l.x, l.y)
    }

    // ====================== 电力相量箭头（根据API数据绘制） ======================
    // 获取各相的幅值和相位 - 使用大写的 IA、IB、IC
    const uaRMS = this.getNumberValue(this.vectorData.Ua_RMS);
    const ubRMS = this.getNumberValue(this.vectorData.Ub_RMS);
    const ucRMS = this.getNumberValue(this.vectorData.Uc_RMS);
    const iaRMS = this.getNumberValue(this.vectorData.IA_RMS);
    const ibRMS = this.getNumberValue(this.vectorData.IB_RMS);
    const icRMS = this.getNumberValue(this.vectorData.IC_RMS);

    const uaPhase = this.getNumberValue(this.vectorData.Ua_Phase);
    const ubPhase = this.getNumberValue(this.vectorData.Ub_Phase);
    const ucPhase = this.getNumberValue(this.vectorData.Uc_Phase);
    const iaPhase = this.getNumberValue(this.vectorData.IA_Phase);
    const ibPhase = this.getNumberValue(this.vectorData.IB_Phase);
    const icPhase = this.getNumberValue(this.vectorData.IC_Phase);

    // 以 Ua 为基准，基准长度为 100 * uiScale
    const baseLength = 100 * this.uiScale;
    const uaBase = uaRMS > 0 ? uaRMS : 1;

    // 计算各相的长度比例
    const ubLength = ubRMS > 0 ? (ubRMS / uaBase) * baseLength : baseLength;
    const ucLength = ucRMS > 0 ? (ucRMS / uaBase) * baseLength : baseLength;

    // 电流长度扩大10倍
    const iaLength = iaRMS > 0 ? (iaRMS / uaBase) * baseLength * 10 : baseLength * 0.5;
    const ibLength = ibRMS > 0 ? (ibRMS / uaBase) * baseLength * 10 : baseLength * 0.5;
    const icLength = icRMS > 0 ? (icRMS / uaBase) * baseLength * 10 : baseLength * 0.5;

    // A相电压（黄色实线）
    ctx.strokeStyle = '#f9d71c'
    ctx.lineWidth = 2.5 * this.uiScale
    ctx.lineCap = 'round'
    const uaAngle = -uaPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + baseLength * Math.cos(uaAngle),
      centerY + baseLength * Math.sin(uaAngle),
      8 * this.uiScale)

    // B相电压（绿色实线）
    ctx.strokeStyle = '#39b54a'
    const ubAngle = -ubPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + ubLength * Math.cos(ubAngle),
      centerY + ubLength * Math.sin(ubAngle),
      8 * this.uiScale)

    // C相电压（红色实线）
    ctx.strokeStyle = '#ed1c24'
    const ucAngle = -ucPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + ucLength * Math.cos(ucAngle),
      centerY + ucLength * Math.sin(ucAngle),
      8 * this.uiScale)

    // 电流（虚线）
    ctx.lineWidth = 1.25 * this.uiScale
    ctx.setLineDash([2.5 * this.uiScale, 1.25 * this.uiScale])

    // A相电流（黄色虚线）- 长度已扩大10倍
    ctx.strokeStyle = '#f9d71c'
    const iaAngle = -iaPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + iaLength * Math.cos(iaAngle),
      centerY + iaLength * Math.sin(iaAngle),
      6 * this.uiScale)

    // B相电流（绿色虚线）- 长度已扩大10倍
    ctx.strokeStyle = '#39b54a'
    const ibAngle = -ibPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + ibLength * Math.cos(ibAngle),
      centerY + ibLength * Math.sin(ibAngle),
      6 * this.uiScale)

    // C相电流（红色虚线）- 长度已扩大10倍
    ctx.strokeStyle = '#ed1c24'
    const icAngle = -icPhase * Math.PI / 180
    this.drawArrow(ctx, centerX, centerY,
      centerX + icLength * Math.cos(icAngle),
      centerY + icLength * Math.sin(icAngle),
      6 * this.uiScale)

    ctx.setLineDash([])

    // 中心点
    ctx.fillStyle = '#000000'
    ctx.beginPath()
    ctx.arc(centerX, centerY, 3 * this.uiScale, 0, Math.PI * 2)
    ctx.fill()
  }
  build() {
    Column() {
      Row() {
        Radio({ group: 'line', value: '1' })
          .scale({ x: 1.5, y: 1.5 })
          .checked(this.selectedLine === 1)
          .onChange((isSelected) => {
            if (isSelected) {
              this.selectedLine = 1;
              this.drawVectorChart(); // 切换线路时重新绘制图表
            }
          })
        Text("线路1")
          .fontSize(18 * this.uiScale)
          .margin({ right: 40 * this.uiScale })

        Radio({ group: 'line', value: '2' })
          .scale({ x: 1.5, y: 1.5 })
          .checked(this.selectedLine === 2)
          .onChange((isSelected) => {
            if (isSelected) {
              this.selectedLine = 2;
              this.drawVectorChart(); // 切换线路时重新绘制图表
            }
          })
        Text("线路2")
          .fontSize(18 * this.uiScale)
      }
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#c9c9c9')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(40 * this.uiScale)

      Row() {
        Column() {
          Canvas(this.context)
            .width(300 * this.uiScale)
            .height(300 * this.uiScale)
            .onReady(() => {
              this.drawVectorChart()
            })
        }
        .width('100%')
        .aspectRatio(1)
        .constraintSize({ maxWidth: 300 * this.uiScale })

        Column() {
          // 电压 Ua
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#ffffd800',
              length: 30 * this.uiScale
            })
            Text('Ua')
              .fontColor('#ffffd800')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.Ua_RMS)} V`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.Ua_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })

          // 电压 Ub
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#39b54a',
              length: 30 * this.uiScale
            })
            Text('Ub')
              .fontColor('#39b54a')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.Ub_RMS)} V`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.Ub_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })

          // 电压 Uc
          Row() {
            CustomLine({
              lineWidth: 4,
              color: '#ffff0000',
              length: 30 * this.uiScale
            })
            Text('Uc')
              .fontColor('#ffff0000')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.Uc_RMS)} V`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.Uc_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })

          // 电流 Ia (注意使用大写 IA)
          Row() {
            CustomLine({
              lineWidth: 2,
              color: '#baffd800',
              length: 30 * this.uiScale
            })
            Text('Ia')
              .fontColor('#baffd800')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.IA_RMS)} A`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.IA_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })
          .margin({ top: 20 * this.uiScale })

          // 电流 Ib (注意使用大写 IB)
          Row() {
            CustomLine({
              lineWidth: 2,
              color: '#a939b54a',
              length: 30 * this.uiScale
            })
            Text('Ib')
              .fontColor('#a939b54a')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.IB_RMS)} A`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.IB_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })

          // 电流 Ic (注意使用大写 IC)
          Row() {
            CustomLine({
              lineWidth: 2,
              color: '#95ff0000',
              length: 30 * this.uiScale
            })
            Text('Ic')
              .fontColor('#95ff0000')
              .fontWeight(FontWeight.Bold)
              .fontSize(18 * this.uiScale)
              .width(40 * this.uiScale)
              .textAlign(TextAlign.Center)
            Text(`${this.getValue(this.vectorData.IC_RMS)} A`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .width(75 * this.uiScale)
            Text(`${this.getValue(this.vectorData.IC_Phase)} °`)
              .fontColor('#ff000000')
              .fontSize(18 * this.uiScale)
              .margin({ left: 10 * this.uiScale })
              .width(75 * this.uiScale)
          }
          .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
          .border({ width: { bottom: 1 * this.uiScale }, color: '#555555' })
        }
        .padding({ left: 20 * this.uiScale, right: 20 * this.uiScale })
      }
      .padding(20 * this.uiScale)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}