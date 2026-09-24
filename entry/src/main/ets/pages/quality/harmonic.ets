import hilog from '@ohos.hilog';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util';
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState';
import { HarmonicBarChart } from './HarmonicBarChart';
import {
  HarmonicDistortionData, HarmonicPowerQualityData, HarmonicRow, HarmonicSummaryItem,
  buildHarmonicRows, buildHarmonicSummary
} from './HarmonicData';

const DOMAIN: number = 0x0001;
const TAG: string = 'harmonicContent';
const REFRESH_INTERVAL: number = 2000;

interface HarmonicApiResponse {
  success?: boolean;
  data?: HarmonicDistortionData;
}

interface PowerQualityApiResponse {
  success?: boolean;
  data?: HarmonicPowerQualityData;
}

@Component
struct harmonicContent {
  @State uiScale: number = 1;
  @State selectedIndex: number = 0;
  @State showListMode: boolean = false;
  @State rows: HarmonicRow[] = [];
  @State chartValues: number[] = [];
  @State summary: HarmonicSummaryItem[] = [];
  @State dataStatus: string = '正在读取设备数据';

  private readonly channels: string[] = ['Ua1', 'Ub1', 'Uc1', 'Ia1', 'Ib1', 'Ic1'];
  private readonly summaryRows: number[] = [0, 1, 2];
  private readonly summaryColumns: number[] = [0, 1, 2];
  private voltageData: HarmonicDistortionData = {};
  private currentData: HarmonicDistortionData = {};
  private powerQualityData: HarmonicPowerQualityData = {};
  private tableScroller: Scroller = new Scroller();
  private refreshTimer: number = -1;
  private lifecycleId: number = 0;
  private active: boolean = false;

  aboutToAppear(): void {
    this.active = true;
    this.lifecycleId++;
    this.refreshCurrentChannel();
    this.refreshData(this.lifecycleId);
  }

  aboutToDisappear(): void {
    this.active = false;
    this.lifecycleId++;
    if (this.refreshTimer !== -1) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  private isCurrentRequest(lifecycleId: number): boolean {
    return this.active && this.lifecycleId === lifecycleId;
  }

  private async requestDeviceData(deviceName: string): Promise<string> {
    const params = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', deviceName);
    params.setExtra('ts', '0');
    const config = new IpcRequestConfig('/api/yc/sub', params);
    const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
    if (!response.success || !response.data || !response.data.data) {
      throw new Error(deviceName + '请求失败');
    }
    return response.data.data;
  }

  private async fetchDistortion(isVoltage: boolean, lifecycleId: number): Promise<boolean> {
    const deviceName = isVoltage ? 'HarmonicDistortionU' : 'HarmonicDistortionI';
    try {
      const result: HarmonicApiResponse = JSON.parse(await this.requestDeviceData(deviceName)) as HarmonicApiResponse;
      if (!result || result.success === false || !result.data) {
        throw new Error(deviceName + '响应无有效数据');
      }
      if (this.isCurrentRequest(lifecycleId)) {
        if (isVoltage) {
          this.voltageData = result.data;
        } else {
          this.currentData = result.data;
        }
      }
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s: %{public}s', deviceName, String(error));
      return false;
    }
  }

  private async fetchPowerQuality(lifecycleId: number): Promise<boolean> {
    try {
      const result: PowerQualityApiResponse =
        JSON.parse(await this.requestDeviceData('PowerQuality')) as PowerQualityApiResponse;
      if (!result || result.success === false || !result.data) {
        throw new Error('电能质量响应无有效数据');
      }
      if (this.isCurrentRequest(lifecycleId)) {
        this.powerQualityData = result.data;
      }
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '电能质量请求失败: %{public}s', String(error));
      return false;
    }
  }

  private async refreshData(lifecycleId: number): Promise<void> {
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    // 同一轮收到 U、I 后统一计算同相谐波功率；下一轮在本轮结束后启动，避免请求重叠。
    const voltageOk = await this.fetchDistortion(true, lifecycleId);
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    const currentOk = await this.fetchDistortion(false, lifecycleId);
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    const summaryOk = await this.fetchPowerQuality(lifecycleId);
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    this.refreshCurrentChannel();
    this.dataStatus = voltageOk && currentOk && summaryOk ? '' : '部分数据未更新，缺失值显示 --';
    this.refreshTimer = setTimeout(() => {
      this.refreshTimer = -1;
      this.refreshData(lifecycleId);
    }, REFRESH_INTERVAL);
  }

  private refreshCurrentChannel(): void {
    this.rows = buildHarmonicRows(this.voltageData, this.currentData, this.selectedIndex);
    this.chartValues = this.rows.map((row: HarmonicRow): number => row.ratio === undefined ? 0 : row.ratio);
    this.summary = buildHarmonicSummary(this.powerQualityData, this.selectedIndex);
  }

  private selectChannel(index: number): void {
    this.selectedIndex = (index + this.channels.length) % this.channels.length;
    this.refreshCurrentChannel();
    if (this.showListMode) {
      this.tableScroller.scrollTo({ xOffset: 0, yOffset: 0 });
    }
  }

  @Builder
  channelButton(label: string, index: number) {
    Button(label, { type: ButtonType.Normal })
      .layoutWeight(1)
      .height('100%')
      .padding(0)
      .borderRadius(0)
      .backgroundColor('#c9c9c9')
      .fontSize(16 * this.uiScale)
      .fontColor(this.selectedIndex === index ? '#ff0000' : '#000000')
      .onClick(() => this.selectChannel(index))
  }

  @Builder
  modeOption(label: string, listMode: boolean) {
    Row({ space: 6 * this.uiScale }) {
      Checkbox({ name: listMode ? 'harmonicList' : 'harmonicBar' })
        .select(this.showListMode === listMode)
        .width(20 * this.uiScale)
        .height(20 * this.uiScale)
        .margin(0)
        .selectedColor('#167fff')
        .onChange((checked: boolean) => {
          if (checked) {
            this.showListMode = listMode;
          } else if (this.showListMode === listMode) {
            this.showListMode = !listMode;
          }
        })
      Text(label)
        .fontSize(16 * this.uiScale)
        .fontColor('#000000')
        .onClick(() => { this.showListMode = listMode; })
    }
    .margin({ left: 16 * this.uiScale })
  }

  @Builder
  toolbar() {
    Row() {
      Button('<', { type: ButtonType.Normal })
        .width(32 * this.uiScale).height('100%').padding(0)
        .backgroundColor('#c9c9c9').fontColor('#000000').fontSize(22 * this.uiScale)
        .accessibilityText('上一个通道')
        .onClick(() => this.selectChannel(this.selectedIndex - 1))
      Row() {
        ForEach(this.channels, (channel: string, index: number) => {
          this.channelButton(channel, index)
        }, (channel: string) => channel)
      }
      .layoutWeight(1)
      .height('100%')
      Button('>', { type: ButtonType.Normal })
        .width(32 * this.uiScale).height('100%').padding(0)
        .backgroundColor('#c9c9c9').fontColor('#000000').fontSize(22 * this.uiScale)
        .accessibilityText('下一个通道')
        .onClick(() => this.selectChannel(this.selectedIndex + 1))
      this.modeOption('柱状图', false)
      this.modeOption('列表', true)
    }
    .width('100%')
    .height(40 * this.uiScale)
    .padding({ left: 10 * this.uiScale, right: 10 * this.uiScale })
    .backgroundColor('#c9c9c9')
  }

  @Builder
  summaryCell(index: number) {
    Row({ space: 4 * this.uiScale }) {
      Text(this.summary[index].label)
        .fontSize(15 * this.uiScale)
        .fontColor('#111111')
        .maxLines(1)
      Text(this.summary[index].value)
        .layoutWeight(1)
        .fontSize(15 * this.uiScale)
        .minFontSize(11 * this.uiScale)
        .maxFontSize(15 * this.uiScale)
        .maxLines(1)
        .fontColor('#111111')
        .textAlign(TextAlign.End)
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: 4 * this.uiScale, right: 4 * this.uiScale })
  }

  @Builder
  summaryPanel() {
    Column() {
      ForEach(this.summaryRows, (row: number) => {
        Row() {
          ForEach(this.summaryColumns, (column: number) => {
            if (row * 3 + column < this.summary.length) {
              this.summaryCell(row * 3 + column)
            } else {
              Blank().layoutWeight(1)
            }
          }, (column: number) => column.toString())
        }
        .width('100%')
        .height(30 * this.uiScale)
        .backgroundColor(row === 1 ? '#e0e0e0' : '#ffffff')
      }, (row: number) => row.toString())
    }
    .width('100%')
    .padding({ top: 5 * this.uiScale, bottom: 5 * this.uiScale })
  }

  @Builder
  tableCell(value: string, weight: number, header: boolean = false) {
    Text(value)
      .layoutWeight(weight)
      .height('100%')
      .textAlign(TextAlign.Center)
      .fontColor('#333333')
      .fontSize((header ? 20 : 18) * this.uiScale)
      .minFontSize(12 * this.uiScale)
      .maxFontSize((header ? 20 : 18) * this.uiScale)
      .maxLines(1)
      .padding({ left: 4 * this.uiScale, right: 4 * this.uiScale })
      .border({ width: { right: 1, bottom: 1 }, color: header ? '#c0c0c0' : '#e0e0e0' })
  }

  @Builder
  harmonicTable() {
    Column() {
      Row() {
        this.tableCell('次数', 60, true)
        this.tableCell('含有率', 110, true)
        this.tableCell('有效值', 145, true)
        this.tableCell('相角', 110, true)
        this.tableCell('谐波功率', 156, true)
        this.tableCell('功率因数', 140, true)
      }
      .width('100%')
      .height(39 * this.uiScale)
      .backgroundColor('#e8e8e8')
      List({ scroller: this.tableScroller }) {
        ForEach(this.rows, (row: HarmonicRow) => {
          ListItem() {
            Row() {
              this.tableCell(row.order.toString(), 60)
              this.tableCell(row.contentRate, 110)
              this.tableCell(row.rmsValue, 145)
              this.tableCell(row.phaseAngle, 110)
              this.tableCell(row.apparentPower, 156)
              this.tableCell(row.powerFactor, 140)
            }
            .width('100%')
            .height(39 * this.uiScale)
          }
        }, (row: HarmonicRow) => row.order.toString() + ':' + row.contentRate + ':' + row.rmsValue + ':' +
          row.phaseAngle + ':' + row.apparentPower + ':' + row.powerFactor)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.On)
      .edgeEffect(EdgeEffect.None)
    }
    .width('100%')
    .layoutWeight(1)
    .border({ width: 1, color: '#c0c0c0' })
  }

  build() {
    Column() {
      this.toolbar()
      Column() {
        if (this.showListMode) {
          this.harmonicTable()
        } else {
          Text('谐波含有率柱状图（%）')
            .width('100%')
            .height(26 * this.uiScale)
            .fontSize(16 * this.uiScale)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
          HarmonicBarChart({ values: this.chartValues, uiScale: this.uiScale })
            .width('100%')
            .layoutWeight(1)
          this.summaryPanel()
        }
        if (this.dataStatus.length > 0) {
          Text(this.dataStatus)
            .width('100%')
            .fontSize(12 * this.uiScale)
            .fontColor('#666666')
            .height(20 * this.uiScale)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 8 * this.uiScale, right: 8 * this.uiScale, top: 5 * this.uiScale, bottom: 5 * this.uiScale })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 5 * this.uiScale })
    .backgroundColor('#ffffff')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      // 按组件实际可用 vp 宽度适配，避免把屏幕 px 当成 vp 导致内容溢出。
      const width = Number(newArea.width);
      if (width > 0) {
        this.uiScale = width / 736;
      }
    })
  }
}

export { harmonicContent };
