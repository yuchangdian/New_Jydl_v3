import router from '@ohos.router';
import hilog from '@ohos.hilog';
import { Jybsmr131PacketValue } from 'libentry.so';
import { Jybsmr131Protocol, Jybsmr131TelemetryAddress } from '../../protocol/Jybsmr131';
import { PQInsight } from './pqInsight';
import { WAVEFORM_NAMES, WaveformBuffer, WaveformFrame, emptyWaveformFrame } from './WaveformData';

const POLL_INTERVAL: number = 200;
const REQUEST_INTERVAL: number = 2000;
const STALE_INTERVAL: number = 10000;

@Entry
@Component
struct WaveformAnalysisPage {
  @State uiScale: number = 1;
  @State isRefreshing: boolean = true;
  @State visible: boolean[] = [true, true, true, true, true, true];
  @State frame: WaveformFrame = emptyWaveformFrame();
  @State dataStatus: string = '等待设备波形数据（0/6）';
  private readonly names: string[] = WAVEFORM_NAMES;
  private readonly addresses: Jybsmr131TelemetryAddress[] = [
    Jybsmr131TelemetryAddress.WaveformUa, Jybsmr131TelemetryAddress.WaveformUb,
    Jybsmr131TelemetryAddress.WaveformUc, Jybsmr131TelemetryAddress.WaveformIa,
    Jybsmr131TelemetryAddress.WaveformIb, Jybsmr131TelemetryAddress.WaveformIc
  ];
  private buffer: WaveformBuffer = new WaveformBuffer();
  private presentedFrame?: WaveformFrame;
  private timerId: number = -1;
  private active: boolean = false;
  private nextRequestAt: number = 0;
  private lastCompleteAt: number = 0;
  private requestFailed: boolean = false;

  onPageShow(): void {
    if (this.active) {
      return;
    }
    this.active = true;
    this.nextRequestAt = 0;
    this.pollData();
    this.timerId = setInterval(() => this.pollData(), POLL_INTERVAL);
  }

  onPageHide(): void {
    this.stopPolling();
  }

  aboutToDisappear(): void {
    this.stopPolling();
  }

  private stopPolling(): void {
    this.active = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private pollData(): void {
    if (!this.active) {
      return;
    }
    const now: number = Date.now();
    try {
      if (now >= this.nextRequestAt) {
        this.nextRequestAt = now + REQUEST_INTERVAL;
        this.requestFailed = false;
        this.addresses.forEach((address: Jybsmr131TelemetryAddress) => {
          if (!Jybsmr131Protocol.requestTelemetry(address)) {
            this.requestFailed = true;
          }
        });
      }
      const packets: Jybsmr131PacketValue[] = this.addresses.map((address: Jybsmr131TelemetryAddress) =>
        Jybsmr131Protocol.telemetry(address));
      if (this.buffer.accept(packets)) {
        this.lastCompleteAt = now;
      }
      this.presentFrame();
      this.updateStatus(now);
    } catch (error) {
      this.dataStatus = '波形读取失败，保留当前显示';
      hilog.error(0x0001, 'WaveformAnalysis', '波形读取失败：%{public}s', String(error));
    }
  }

  private updateStatus(now: number): void {
    if (this.requestFailed) {
      this.dataStatus = this.isRefreshing ? '波形请求未发送成功，正在重试' : '已停止刷新，设备连接异常';
    } else if (!this.isRefreshing) {
      this.dataStatus = '已停止刷新';
    } else if (!this.buffer.hasCompleteFrame) {
      this.dataStatus = '等待设备波形数据（' + this.buffer.receivedCount.toString() + '/6）';
    } else if (now - this.lastCompleteAt >= STALE_INTERVAL) {
      this.dataStatus = '波形数据未更新，保留上一帧（' + this.buffer.receivedCount.toString() + '/6）';
    } else {
      this.dataStatus = '';
    }
  }

  private toggleRefreshing(): void {
    this.isRefreshing = !this.isRefreshing;
    this.buffer.setRefreshing(this.isRefreshing);
    this.presentFrame();
    this.updateStatus(Date.now());
  }

  private presentFrame(): void {
    // @State 会包装对象，用普通引用记录已发布帧，避免每次轮询都复制 2400 点。
    if (this.presentedFrame !== this.buffer.displayed) {
      this.presentedFrame = this.buffer.displayed;
      this.frame = this.buffer.displayed;
    }
  }

  private setChannelVisible(index: number, selected: boolean): void {
    const next: boolean[] = this.visible.slice();
    next[index] = selected;
    this.visible = next;
  }

  @Builder
  channelOption(name: string, index: number) {
    Row({ space: 10 * this.uiScale }) {
      Checkbox({ name: name })
        .select(this.visible[index])
        .width(22 * this.uiScale)
        .height(22 * this.uiScale)
        .margin(0)
        .selectedColor('#167fff')
        .accessibilityText(name + '通道')
        .onChange((checked: boolean) => this.setChannelVisible(index, checked))
      Text(name)
        .fontSize(16 * this.uiScale)
        .fontColor('#000000')
        .onClick(() => this.setChannelVisible(index, !this.visible[index]))
    }
    .width('100%')
    .height(32 * this.uiScale)
    .padding({ left: 12 * this.uiScale })
  }

  @Builder
  sidebar() {
    Scroll() {
      Column({ space: 6 * this.uiScale }) {
        Button(this.isRefreshing ? '停止' : '刷新', { type: ButtonType.Normal })
          .width(85 * this.uiScale).height(32 * this.uiScale).padding(0)
          .fontSize(18 * this.uiScale)
          .fontColor(this.isRefreshing ? '#ffffff' : '#000000')
          .backgroundColor(this.isRefreshing ? '#167fff' : '#ababab')
          .border({ width: 1 * this.uiScale, color: '#000000' })
          .borderRadius(5 * this.uiScale)
          .onClick(() => this.toggleRefreshing())
        Button('最近事件', { type: ButtonType.Normal })
          .width(85 * this.uiScale).height(32 * this.uiScale).padding(0)
          .fontSize(18 * this.uiScale).fontColor('#000000').backgroundColor('#ababab')
          .border({ width: 1 * this.uiScale, color: '#000000' })
          .borderRadius(5 * this.uiScale)
          .onClick(() => router.pushUrl({ url: 'pages/pqInsight/EventCenter' }))
        Column({ space: 6 * this.uiScale }) {
          ForEach(this.names, (name: string, index: number) => {
            this.channelOption(name, index)
          }, (name: string) => name)
        }
        .width('100%')
        .margin({ top: 4 * this.uiScale })
      }
      .width('100%')
      .padding({ top: 8 * this.uiScale, bottom: 8 * this.uiScale })
    }
    .width(110 * this.uiScale)
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor('#f0f0f0')
    .border({ width: { right: 1 * this.uiScale }, color: '#333333' })
  }

  build() {
    Column() {
      Row() {
        Row({ space: 5 * this.uiScale }) {
          Image($rawfile('icon/icon03.png')).width(18 * this.uiScale).height(18 * this.uiScale)
          Text('波形').fontSize(18 * this.uiScale).fontColor('#ffffff')
        }
        .width(110 * this.uiScale).height('100%')
        .justifyContent(FlexAlign.Center).backgroundColor('#167fff')
        Text(this.dataStatus)
          .layoutWeight(1).height('100%')
          .fontSize(14 * this.uiScale).fontColor('#555555')
          .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale })
          .maxLines(1)
      }
      .width('100%').height(50 * this.uiScale).backgroundColor('#c0c6cc')
      Row() {
        this.sidebar()
        PQInsight({ frame: this.frame, visible: this.visible, uiScale: this.uiScale })
          .layoutWeight(1)
      }
      .width('100%').layoutWeight(1)
      Stack() {
        Button('返回', { type: ButtonType.Normal })
          .width(100 * this.uiScale).height(38 * this.uiScale).padding(0)
          .fontSize(16 * this.uiScale).fontColor('#111111').backgroundColor('#eeeeee')
          .border({ width: 1 * this.uiScale, color: '#8f8f8f' }).borderRadius(2 * this.uiScale)
          .onClick(() => router.back())
        Row() {
          TextClock().format('yyyy/MM/dd   HH:mm:ss')
            .fontSize(14 * this.uiScale).fontColor('#111111')
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.End)
        .padding({ right: 20 * this.uiScale })
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%').height(50 * this.uiScale).backgroundColor('#c0c6cc')
      .border({ width: { top: 1 * this.uiScale }, color: '#9a9a9a' })
    }
    .width('100%').height('100%').backgroundColor('#f0f0f0')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width: number = Number(newArea.width);
      const height: number = Number(newArea.height);
      if (width > 0 && height > 0) {
        this.uiScale = Math.min(width / 854, height / 480);
      }
    })
  }
}
