import hilog from '@ohos.hilog';
import { common } from '@kit.AbilityKit';
import { IpcUtil, IpcParams, IpcRequestConfig, IpcResponse, StringResponse } from '../../utils/IPC_Util';
import { TERMINAL_ID } from '../../common/GlobalState';

const REPORT_ROW_COUNT: number = 9;
type QualificationRateValue = number | number[];

interface QualificationRateFields {
  VoltageQualifiRate_All?: QualificationRateValue;
  FreqQualifiRate_All?: QualificationRateValue;
}

export interface QualificationReportRecord extends QualificationRateFields {
  TerminalId?: string;
  DataDate?: string;
  CreateTime?: string;
  CreatedAtMs?: number;
  Id?: number;
  VoltageQualifiedRate?: QualificationRateValue;
  FrequencyQualifiedRate?: QualificationRateValue;
  PowerQuality?: QualificationRateFields;
}

interface QualificationReportResponse {
  success?: boolean;
  code?: number;
  data?: QualificationReportRecord[];
}

export interface QualificationReportRow {
  key: string;
  date: string;
  voltage: string;
  frequency: string;
  flicker: string;
}

interface DailyQualificationSample {
  day: string;
  timestamp: number;
  id: number;
  record: QualificationReportRecord;
}

function qualificationNumber(value: QualificationRateValue | undefined): number | undefined {
  const number = Array.isArray(value) ? value[0] : value;
  return typeof number === 'number' && Number.isFinite(number) ? number : undefined;
}

export function qualificationRateText(value: QualificationRateValue | undefined, precision: number): string {
  const number = qualificationNumber(value);
  if (number === undefined) {
    return '--';
  }
  const rounded = Math.abs(number) < 0.5 * Math.pow(10, -precision) ? 0 : number;
  return rounded.toFixed(precision) + ' %';
}

function localReportDay(date: Date): string {
  return date.getFullYear().toString().padStart(4, '0') + '-' +
    (date.getMonth() + 1).toString().padStart(2, '0') + '-' + date.getDate().toString().padStart(2, '0');
}

// 日期字符串按本地自然日解析，避免 yyyy-MM-dd 被解释为 UTC 后跨日。
function canonicalReportDay(value: string | undefined): string | undefined {
  if (typeof value !== 'string') {
    return undefined;
  }
  const match = value.trim().match(/^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$/);
  if (!match) {
    return undefined;
  }
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const date = new Date(0);
  date.setFullYear(year, month - 1, day);
  date.setHours(0, 0, 0, 0);
  if (year < 1 || date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
    return undefined;
  }
  return localReportDay(date);
}

function reportTimestamp(value: string | undefined): number | undefined {
  if (typeof value !== 'string') {
    return undefined;
  }
  const match = value.trim().match(
    /^(\d{4}[-/]\d{1,2}[-/]\d{1,2})(?:[ T](\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,3}))?(Z|[+-]\d{2}:?\d{2})?)?$/);
  if (!match) {
    return undefined;
  }
  const day = canonicalReportDay(match[1]);
  if (!day || Number(match[2] || '0') > 23 || Number(match[3] || '0') > 59 || Number(match[4] || '0') > 59) {
    return undefined;
  }
  const time = day + 'T' + (match[2] || '00') + ':' + (match[3] || '00') + ':' + (match[4] || '00') +
    '.' + (match[5] || '0').padEnd(3, '0') + (match[6] || '');
  const timestamp = Date.parse(time);
  return Number.isFinite(timestamp) ? timestamp : undefined;
}

function sampleForRecord(record: QualificationReportRecord): DailyQualificationSample | undefined {
  const createdAt = qualificationNumber(record.CreatedAtMs);
  const createdAtMs = createdAt !== undefined && Number.isFinite(new Date(createdAt).getTime()) ? createdAt : undefined;
  const createTime = reportTimestamp(record.CreateTime);
  // Qt 原始记录按 CreatedAtMs 分日；现有日报接口以 DataDate 指定统计日期。
  const day = createdAtMs !== undefined ? localReportDay(new Date(createdAtMs)) :
    (canonicalReportDay(record.DataDate) || (createTime !== undefined ? localReportDay(new Date(createTime)) : undefined));
  if (!day) {
    return undefined;
  }
  return {
    day: day,
    timestamp: createdAtMs !== undefined ? createdAtMs : (createTime !== undefined ? createTime : Date.parse(day + 'T00:00:00')),
    id: qualificationNumber(record.Id) ?? 0,
    record: record
  };
}

export function buildDailyQualificationRows(records: QualificationReportRecord[], terminalId: string = ''): QualificationReportRow[] {
  const latestByDay = new Map<string, DailyQualificationSample>();
  records.forEach((record: QualificationReportRecord) => {
    if (!record || typeof record !== 'object' || Array.isArray(record)) {
      return;
    }
    if (terminalId.length > 0 && typeof record.TerminalId === 'string' && record.TerminalId.length > 0 &&
      record.TerminalId !== terminalId) {
      return;
    }
    const sample = sampleForRecord(record);
    if (!sample) {
      return;
    }
    const previous = latestByDay.get(sample.day);
    if (!previous || sample.timestamp > previous.timestamp ||
      (sample.timestamp === previous.timestamp && sample.id > previous.id)) {
      latestByDay.set(sample.day, sample);
    }
  });

  // 取最近九个有记录的日期，然后按从早到晚显示；不补造缺失自然日。
  const samples = Array.from(latestByDay.values()).sort((left: DailyQualificationSample, right: DailyQualificationSample) =>
    left.day.localeCompare(right.day)).slice(-REPORT_ROW_COUNT);
  const rows: QualificationReportRow[] = samples.map((sample: DailyQualificationSample): QualificationReportRow => {
    const record = sample.record;
    const voltage = qualificationNumber(record.PowerQuality?.VoltageQualifiRate_All) ??
      qualificationNumber(record.VoltageQualifiRate_All) ?? qualificationNumber(record.VoltageQualifiedRate);
    const frequency = qualificationNumber(record.PowerQuality?.FreqQualifiRate_All) ??
      qualificationNumber(record.FreqQualifiRate_All) ?? qualificationNumber(record.FrequencyQualifiedRate);
    return {
      key: sample.day,
      date: sample.day.replace(/-/g, '/'),
      voltage: qualificationRateText(voltage, 2),
      frequency: qualificationRateText(frequency, 3),
      // Qt 未给闪变合格率绑定数据，越限次数也不能推算合格率。
      flicker: '--'
    };
  });
  while (rows.length < REPORT_ROW_COUNT) {
    rows.push({ key: 'empty-' + rows.length.toString(), date: '--', voltage: '--', frequency: '--', flicker: '--' });
  }
  return rows;
}

export function parseQualificationReport(json: string): QualificationReportRecord[] {
  const parsed = JSON.parse(json) as QualificationReportResponse | QualificationReportRecord[];
  if (Array.isArray(parsed)) {
    return parsed as QualificationReportRecord[];
  }
  const response = parsed as QualificationReportResponse;
  if (!response || typeof response !== 'object' || response.success === false ||
    (typeof response.code === 'number' && response.code >= 400) || !Array.isArray(response.data)) {
    throw new Error('合格率日报响应格式无效或请求失败');
  }
  return response.data;
}

@Component
export struct PowerQualityReportPage {
  @State private uiScale: number = 1;
  @State private rows: QualificationReportRow[] = buildDailyQualificationRows([]);
  @State private statusText: string = '正在读取合格率日报';
  @State private isLoading: boolean = false;
  private active: boolean = false;
  private requestId: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.active = true;
    this.loadDailyQualificationRates();
  }

  aboutToDisappear(): void {
    this.active = false;
    this.requestId++;
    this.isLoading = false;
  }

  private isCurrentRequest(requestId: number): boolean {
    return this.active && requestId === this.requestId;
  }

  private async loadDailyQualificationRates(): Promise<void> {
    if (!this.active || this.isLoading) {
      return;
    }
    const requestId = ++this.requestId;
    this.isLoading = true;
    this.rows = buildDailyQualificationRows([]);
    this.statusText = '正在读取合格率日报';
    try {
      if (!IpcUtil.isConnected()) {
        await IpcUtil.connect(this.getUIContext().getHostContext() as common.UIAbilityContext);
      }
      if (!this.isCurrentRequest(requestId)) {
        return;
      }
      if (!IpcUtil.isConnected()) {
        throw new Error('报表数据服务未连接');
      }
      const params = new IpcParams();
      params.setExtra('date_type', 'day');
      params.setExtra('terminal_id', TERMINAL_ID);
      params.setExtra('line_id', '1');
      const response: IpcResponse<StringResponse> =
        await IpcUtil.sendRequest<StringResponse>(new IpcRequestConfig('/api/rate/get', params));
      if (!this.isCurrentRequest(requestId)) {
        return;
      }
      if (!response.success || !response.data || !response.data.data) {
        throw new Error('读取合格率日报失败');
      }
      this.rows = buildDailyQualificationRows(parseQualificationReport(response.data.data), TERMINAL_ID);
      this.statusText = this.rows[0].date === '--' ? '暂无合格率日报记录' : '';
    } catch (error) {
      if (this.isCurrentRequest(requestId)) {
        this.statusText = '合格率日报读取失败，重新进入页面可重试';
      }
      hilog.error(0x0001, 'PowerQualityReportPage', '读取失败: %{public}s', String(error));
    } finally {
      if (this.isCurrentRequest(requestId)) {
        this.isLoading = false;
      }
    }
  }

  @Builder
  reportCell(value: string, weight: number, header: boolean = false, lastColumn: boolean = false) {
    Text(value)
      .layoutWeight(weight)
      .height('100%')
      .padding({ left: 6 * this.uiScale, right: 6 * this.uiScale })
      .fontSize((header ? 16 : 15) * this.uiScale)
      .minFontSize(12 * this.uiScale)
      .maxFontSize((header ? 16 : 15) * this.uiScale)
      .maxLines(1)
      .fontColor('#111111')
      .textAlign(TextAlign.Center)
      .border({ width: { right: lastColumn ? 0 : 1 }, color: '#333333' })
  }

  @Builder
  tableHeader() {
    Column() {
      Row() {
        this.reportCell('', 11, true)
        this.reportCell('电压', 20, true)
        this.reportCell('频率', 20, true)
        this.reportCell('闪变', 20, true, true)
      }
      .width('100%')
      .height(34 * this.uiScale)
      Row() {
        this.reportCell('日期', 11, true)
        this.reportCell('合格率', 20, true)
        this.reportCell('合格率', 20, true)
        this.reportCell('合格率', 20, true, true)
      }
      .width('100%')
      .height(34 * this.uiScale)
    }
    .width('100%')
    .padding({ right: 8 * this.uiScale })
    .backgroundColor('#ffffff')
    .border({ width: { bottom: 1 }, color: '#333333' })
  }

  build() {
    Column() {
      Row() {
        Text(this.statusText)
          .fontSize(14 * this.uiScale)
          .fontColor('#555555')
          .maxLines(1)
      }
      .width('100%')
      .height(53 * this.uiScale)
      .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale })
      .backgroundColor('#c9c9c9')
      .border({ width: { bottom: 1 }, color: '#333333' })
      this.tableHeader()
      List({ scroller: this.scroller, space: 0 }) {
        ForEach(this.rows, (row: QualificationReportRow, index: number) => {
          ListItem() {
            Row() {
              this.reportCell(row.date, 11)
              this.reportCell(row.voltage, 20)
              this.reportCell(row.frequency, 20)
              this.reportCell(row.flicker, 20, false, true)
            }
            .width('100%')
            .height(31 * this.uiScale)
            .padding({ right: 8 * this.uiScale })
            .backgroundColor(index % 2 === 1 ? '#d7d7d7' : '#ffffff')
            .border({ width: { bottom: 1 }, color: '#333333' })
          }
        }, (row: QualificationReportRow) => row.key + ':' + row.voltage + ':' + row.frequency + ':' + row.flicker)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.On)
      .edgeEffect(EdgeEffect.None)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.uiScale = width / 739;
      }
    })
  }
}
