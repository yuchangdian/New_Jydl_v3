// 电能质量统计报表（鸿蒙5.1 零报错 最终版）
import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'

const DOMAIN = 0x0001;
const TAG = 'PowerQualityReport';

interface ApiDataItem {
  TerminalId: string;
  DataDate: string;
  VoltageQualifiedRate: number | number[];
  VoltageOverageCount: number | number[];
  FrequencyQualifiedRate: number | number[];
  FrequencyOverageCount: number | number[];
  FlickerOverageCount: number | number[];
  CreateTime?: string;
}

interface ApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: ApiDataItem[];
}

interface DataResult {
  pass: string;
  over: string;
}

interface TableRowData {
  voltage: DataResult;
  freq: DataResult;
  flicker: DataResult;
}

@Component
struct PowerQualityReport {
  @State uiScale: number = 1
  readonly designWidth: number = 720

  @State activePeriod: string = 'day'
  @State activeLine: number = 1
  @State dateData: string[] = []
  @State tableRowData: TableRowData[] = []
  @State isLoading: boolean = false;

  aboutToAppear() {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.fetchPowerQualityData()
  }

  private getSafeValue(value: number | number[] | null | undefined): number {
    if (Array.isArray(value)) {
      return value.length > 0 ? value[0] : 0;
    }
    return value ?? 0;
  }

  private async fetchPowerQualityData(): Promise<void> {
    if (this.isLoading) return;
    this.isLoading = true;

    this.dateData = [];
    this.tableRowData = [];

    const params: IpcParams = new IpcParams();
    params.setExtra('date_type', this.activePeriod);
    params.setExtra('terminal_id', TERMINAL_ID);
    params.setExtra('line_id', this.activeLine.toString());

    const config: IpcRequestConfig = new IpcRequestConfig('/api/rate/get', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data?.data) {
        const apiResponse: ApiResponse = JSON.parse(response.data.data);
        this.updateTableData(apiResponse.data);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '请求异常: %s', String(error));
    } finally {
      this.isLoading = false;
    }
  }

  private updateTableData(apiData: ApiDataItem[]): void {
    if (!apiData || apiData.length === 0) {
      return;
    }

    const newDates: string[] = [];
    const newRows: TableRowData[] = [];

    apiData.forEach((item: ApiDataItem) => {
      const voltageRate = this.getSafeValue(item.VoltageQualifiedRate);
      const voltageCount = this.getSafeValue(item.VoltageOverageCount);
      const freqRate = this.getSafeValue(item.FrequencyQualifiedRate);
      const freqCount = this.getSafeValue(item.FrequencyOverageCount);
      const flickerCount = this.getSafeValue(item.FlickerOverageCount);

      newDates.push(item.DataDate);
      newRows.push({
        voltage: { pass: `${voltageRate.toFixed(2)}%`, over: voltageCount.toString() },
        freq: { pass: `${freqRate.toFixed(2)}%`, over: freqCount.toString() },
        flicker: { pass: '100.00%', over: flickerCount.toString() }
      });
    });

    this.dateData = newDates;
    this.tableRowData = newRows;
  }

  updateData(): void {
    this.fetchPowerQualityData();
  }

  getDateHeaderText(): string {
    switch (this.activePeriod) {
      case 'day': return '日期';
      case 'week': return '周';
      case 'month': return '月';
      case 'quarter': return '季';
      case 'year': return '年';
      default: return '日期';
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('日')
            .fontSize(16 * this.uiScale)
            .fontColor(this.activePeriod === 'day' ? '#ff0000' : '#000')
            .fontWeight(this.activePeriod === 'day' ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left:10, right:10, top:3, bottom:3 })
            .onClick(() => { this.activePeriod = 'day'; this.updateData(); })

          Text('周')
            .fontSize(16 * this.uiScale)
            .fontColor(this.activePeriod === 'week' ? '#ff0000' : '#000')
            .fontWeight(this.activePeriod === 'week' ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left:10, right:10, top:3, bottom:3 })
            .onClick(() => { this.activePeriod = 'week'; this.updateData(); })

          Text('月')
            .fontSize(16 * this.uiScale)
            .fontColor(this.activePeriod === 'month' ? '#ff0000' : '#000')
            .fontWeight(this.activePeriod === 'month' ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left:10, right:10, top:3, bottom:3 })
            .onClick(() => { this.activePeriod = 'month'; this.updateData(); })

          Text('季')
            .fontSize(16 * this.uiScale)
            .fontColor(this.activePeriod === 'quarter' ? '#ff0000' : '#000')
            .fontWeight(this.activePeriod === 'quarter' ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left:10, right:10, top:3, bottom:3 })
            .onClick(() => { this.activePeriod = 'quarter'; this.updateData(); })

          Text('年')
            .fontSize(16 * this.uiScale)
            .fontColor(this.activePeriod === 'year' ? '#ff0000' : '#000')
            .fontWeight(this.activePeriod === 'year' ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left:10, right:10, top:3, bottom:3 })
            .onClick(() => { this.activePeriod = 'year'; this.updateData(); })
        }.margin({ left: 100 * this.uiScale })

        Blank()

        Row() {
          Radio({ group: 'line', value: '1' })
            .scale({ x:1.5, y:1.5 })
            .checked(this.activeLine === 1)
            .onChange((s: boolean) => {
              if (s) { this.activeLine = 1; this.updateData(); }
            })
          Text("线路1").fontSize(18 * this.uiScale).margin({ right:20 })

          Radio({ group: 'line', value: '2' })
            .scale({ x:1.5, y:1.5 })
            .checked(this.activeLine === 2)
            .onChange((s: boolean) => {
              if (s) { this.activeLine = 2; this.updateData(); }
            })
          Text("线路2").fontSize(18 * this.uiScale)
        }.margin({ right:30 })
      }
      .width('100%')
      .height(40 * this.uiScale)
      .backgroundColor('#c9c9c9')

      this.TableHeader()

      Scroll() {
        Column() {
          Column() {
            ForEach(this.dateData, (date: string, index: number) => {
              this.TableRow(
                date,
                this.tableRowData[index].voltage.pass,
                this.tableRowData[index].voltage.over,
                this.tableRowData[index].freq.pass,
                this.tableRowData[index].freq.over,
                index % 2 === 1
              )
            }, (date: string, index: number) => `${this.activeLine}_${this.activePeriod}_${index}`)
          }
          .width('100%')
          .border({ width:1, color:'#999' })
          .backgroundColor('#fff')

          Blank().height(200)
        }
      }
      .align(Alignment.TopStart)
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TableHeader() {
    Stack() {
      Row() {
        Column().width(1).height('100%').backgroundColor('#999').position({ x:'25%' })
        Column().width(1).height('100%').backgroundColor('#999').position({ x:'62%' })
      }

      Column() {
        Row() {
          Text('').width('25%').textAlign(TextAlign.Center)
          Text('电压').width('37%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
          Text('频率').width('37%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
        }.padding({ top:6, bottom:6 })

        Row() {
          Text(this.getDateHeaderText()).width('25%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)

          Row() {
            Text('合格率').width('45%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
            Text('越限次数').width('45%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
            Blank().width('10%')
          }.width('37%')

          Row() {
            Text('合格率').width('45%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
            Text('越限次数').width('45%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold).fontSize(16 * this.uiScale)
            Blank().width('10%')
          }.width('37%')
        }.padding({ bottom:6 })
      }
    }
    .width('100%')
    .height(60 * this.uiScale)
    .backgroundColor('#fff')
    .border({ width:1, color:'#999' })
  }

  @Builder
  TableRow(
    date: string,
    vPass: string,
    vOver: string,
    fPass: string,
    fOver: string,
    isEven: boolean
  ) {
    Stack() {
      Row() {
        Column().width(1).height('100%').backgroundColor('#999').position({ x:'25%' })
        Column().width(1).height('100%').backgroundColor('#999').position({ x:'62%' })
      }

      Row() {
        Text(date).width('25%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale)
        Row() {
          Text(vPass).width('45%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale).fontColor('#666')
          Text(vOver).width('45%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale).fontColor('#666')
          Blank().width('10%')
        }.width('37%')
        Row() {
          Text(fPass).width('45%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale).fontColor('#666')
          Text(fOver).width('45%').textAlign(TextAlign.Center).fontSize(16 * this.uiScale).fontColor('#666')
          Blank().width('10%')
        }.width('37%')
      }.padding({ top:8, bottom:8 })
    }
    .width('100%')
    .height(35 * this.uiScale)
    .backgroundColor(isEven ? '#e0e0e0' : '#fff')
    .border({
      width: { bottom:1 },
      color: { bottom:'#999' }
    })
  }
}

export { PowerQualityReport }