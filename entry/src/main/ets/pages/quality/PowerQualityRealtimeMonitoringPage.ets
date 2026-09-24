import hilog from '@ohos.hilog';
import { common } from '@kit.AbilityKit';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util';
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState';

type RealtimeMetricValue = number | number[];

// RemoteMetry 和 PowerQuality 的数组索引 0 对应线路 1；也支持单线路标量响应。
export interface RealtimeMetricData {
  Ua_Frequency?: RealtimeMetricValue;
  Ub_Frequency?: RealtimeMetricValue;
  Uc_Frequency?: RealtimeMetricValue;
  Ua_RMS?: RealtimeMetricValue;
  Ub_RMS?: RealtimeMetricValue;
  Uc_RMS?: RealtimeMetricValue;
  Ua_Phase?: RealtimeMetricValue;
  Ub_Phase?: RealtimeMetricValue;
  Uc_Phase?: RealtimeMetricValue;
  IA_RMS?: RealtimeMetricValue;
  IB_RMS?: RealtimeMetricValue;
  IC_RMS?: RealtimeMetricValue;
  IA_Phase?: RealtimeMetricValue;
  IB_Phase?: RealtimeMetricValue;
  IC_Phase?: RealtimeMetricValue;
  FreqDeviation_A?: RealtimeMetricValue;
  FreqDeviation_B?: RealtimeMetricValue;
  FreqDeviation_C?: RealtimeMetricValue;
  FreqQualifiRate_A?: RealtimeMetricValue;
  FreqQualifiRate_B?: RealtimeMetricValue;
  FreqQualifiRate_C?: RealtimeMetricValue;
  VoltageDeviation_A?: RealtimeMetricValue;
  VoltageDeviation_B?: RealtimeMetricValue;
  VoltageDeviation_C?: RealtimeMetricValue;
  VoltageDeviation_AB?: RealtimeMetricValue;
  VoltageDeviation_BC?: RealtimeMetricValue;
  VoltageDeviation_CA?: RealtimeMetricValue;
  VoltageQualifiRate_A?: RealtimeMetricValue;
  VoltageQualifiRate_B?: RealtimeMetricValue;
  VoltageQualifiRate_C?: RealtimeMetricValue;
  Voltage_U1?: RealtimeMetricValue;
  Voltage_U2?: RealtimeMetricValue;
  Voltage_Uo?: RealtimeMetricValue;
  Voltage_U0?: RealtimeMetricValue;
  Voltage_U2_Unbalance?: RealtimeMetricValue;
  Voltage_Uo_Unbalance?: RealtimeMetricValue;
  VoltageShortFlicke_A?: RealtimeMetricValue;
  VoltageShortFlicke_B?: RealtimeMetricValue;
  VoltageShortFlicke_C?: RealtimeMetricValue;
  VoltageLongFlicke_A?: RealtimeMetricValue;
  VoltageLongFlicke_B?: RealtimeMetricValue;
  VoltageLongFlicke_C?: RealtimeMetricValue;
  Current_I1?: RealtimeMetricValue;
  Current_I2?: RealtimeMetricValue;
  Current_Io?: RealtimeMetricValue;
  Current_I0?: RealtimeMetricValue;
  Current_I2_Unbalance?: RealtimeMetricValue;
  Current_In_Unbalance?: RealtimeMetricValue;
  Current_Io_Unbalance?: RealtimeMetricValue;
}

interface RealtimeApiResponse extends RealtimeMetricData {
  success?: boolean;
  code?: number;
  data?: RealtimeMetricData;
}

export interface RealtimeMetricCell {
  prefix: string;
  value: string;
}

export interface RealtimeMetricRow {
  id: string;
  title: string;
  cells: RealtimeMetricCell[];
}

function realtimeNumber(value: RealtimeMetricValue | undefined): number | undefined {
  const scalar = Array.isArray(value) ? value[0] : value;
  return typeof scalar === 'number' && Number.isFinite(scalar) ? scalar : undefined;
}

function firstRealtimeNumber(primary: RealtimeMetricValue | undefined,
  fallback: RealtimeMetricValue | undefined): number | undefined {
  const value = realtimeNumber(primary);
  return value !== undefined ? value : realtimeNumber(fallback);
}

export function formatRealtimeValue(value: RealtimeMetricValue | undefined, precision: number,
  unit: string = ''): string {
  const number = realtimeNumber(value);
  if (number === undefined) {
    return '--';
  }
  const rounded = Math.abs(number) < 0.5 * Math.pow(10, -precision) ? 0 : number;
  return rounded.toFixed(precision) + unit;
}

function realtimePhasor(prefix: string, rms: RealtimeMetricValue | undefined,
  phase: RealtimeMetricValue | undefined, unit: string): RealtimeMetricCell {
  if (realtimeNumber(rms) === undefined && realtimeNumber(phase) === undefined) {
    return { prefix: prefix, value: '--' };
  }
  return {
    prefix: prefix,
    value: formatRealtimeValue(rms, 4) + ' ' + unit + '∠' + formatRealtimeValue(phase, 3) + '°'
  };
}

function realtimeTriplet(prefixes: string[], values: (RealtimeMetricValue | undefined)[],
  unit: string): RealtimeMetricCell[] {
  return prefixes.map((prefix: string, index: number): RealtimeMetricCell => {
    return { prefix: prefix, value: formatRealtimeValue(values[index], 4, unit) };
  });
}

export function buildRealtimeRows(base: RealtimeMetricData, quality: RealtimeMetricData): RealtimeMetricRow[] {
  return [
    { id: 'Frequency', title: '频 率:', cells: realtimeTriplet(['fa:', 'fb:', 'fc:'],
      [base.Ua_Frequency, base.Ub_Frequency, base.Uc_Frequency], 'Hz') },
    { id: 'FrequencyDeviation', title: '频率偏差:', cells: realtimeTriplet(['Δfa:', 'Δfb:', 'Δfc:'],
      [quality.FreqDeviation_A, quality.FreqDeviation_B, quality.FreqDeviation_C], 'Hz') },
    { id: 'FrequencyRate', title: '频率合格率:', cells: realtimeTriplet(['γfa:', 'γfb:', 'γfc:'],
      [quality.FreqQualifiRate_A, quality.FreqQualifiRate_B, quality.FreqQualifiRate_C], '%') },
    { id: 'Voltage', title: '电 压:', cells: [
      realtimePhasor('Ua:', base.Ua_RMS, base.Ua_Phase, 'V'),
      realtimePhasor('Ub:', base.Ub_RMS, base.Ub_Phase, 'V'),
      realtimePhasor('Uc:', base.Uc_RMS, base.Uc_Phase, 'V')
    ] },
    { id: 'VoltageDeviation', title: '电压偏差:', cells: realtimeTriplet(['ΔUa:', 'ΔUb:', 'ΔUc:'],
      [quality.VoltageDeviation_A, quality.VoltageDeviation_B, quality.VoltageDeviation_C], '%') },
    { id: 'LineVoltageDeviation', title: '', cells: realtimeTriplet(['ΔUab:', 'ΔUbc:', 'ΔUca:'],
      [quality.VoltageDeviation_AB, quality.VoltageDeviation_BC, quality.VoltageDeviation_CA], '%') },
    { id: 'VoltageRate', title: '电压合格率:', cells: realtimeTriplet(['γUa:', 'γUb:', 'γUc:'],
      [quality.VoltageQualifiRate_A, quality.VoltageQualifiRate_B, quality.VoltageQualifiRate_C], '%') },
    { id: 'VoltageUnbalance', title: '电压不平衡:', cells: realtimeTriplet(['U1:', 'U2:', 'Uo:'],
      [quality.Voltage_U1, quality.Voltage_U2, firstRealtimeNumber(quality.Voltage_Uo, quality.Voltage_U0)], 'V') },
    { id: 'VoltageUnbalanceRate', title: '', cells: [
      { prefix: 'εU2:', value: formatRealtimeValue(quality.Voltage_U2_Unbalance, 4, '%') },
      { prefix: 'εUo:', value: formatRealtimeValue(quality.Voltage_Uo_Unbalance, 4, '%') },
      { prefix: '', value: '' }
    ] },
    { id: 'VoltageShortFlicke', title: '电压短闪变:', cells: realtimeTriplet(['Ua:', 'Ub:', 'Uc:'],
      [quality.VoltageShortFlicke_A, quality.VoltageShortFlicke_B, quality.VoltageShortFlicke_C], '') },
    { id: 'VoltageLongFlicke', title: '电压长闪变:', cells: realtimeTriplet(['Ua:', 'Ub:', 'Uc:'],
      [quality.VoltageLongFlicke_A, quality.VoltageLongFlicke_B, quality.VoltageLongFlicke_C], '') },
    // Qt 使用 IA/IB/IC 保护电流，不能替换成 Ia/Ib/Ic 测量电流。
    { id: 'Current', title: '电 流:', cells: [
      realtimePhasor('Ia:', base.IA_RMS, base.IA_Phase, 'A'),
      realtimePhasor('Ib:', base.IB_RMS, base.IB_Phase, 'A'),
      realtimePhasor('Ic:', base.IC_RMS, base.IC_Phase, 'A')
    ] },
    { id: 'CurrentUnbalance', title: '电流不平衡:', cells: realtimeTriplet(['I1:', 'I2:', 'Io:'],
      [quality.Current_I1, quality.Current_I2, firstRealtimeNumber(quality.Current_Io, quality.Current_I0)], 'A') },
    { id: 'CurrentUnbalanceRate', title: '', cells: [
      { prefix: 'εI2:', value: formatRealtimeValue(quality.Current_I2_Unbalance, 4, '%') },
      { prefix: 'εIo:', value: formatRealtimeValue(
        firstRealtimeNumber(quality.Current_In_Unbalance, quality.Current_Io_Unbalance), 4, '%') },
      { prefix: '', value: '' }
    ] }
  ];
}

export function parseRealtimeData(json: string): RealtimeMetricData {
  const response = JSON.parse(json) as RealtimeApiResponse;
  if (!response || typeof response !== 'object' || Array.isArray(response) || response.success === false ||
    (typeof response.code === 'number' && response.code >= 400)) {
    throw new Error('实时指标响应失败');
  }
  // 兼容项目里已有的带 data 外层响应，以及直接返回字段的响应。
  const data: RealtimeMetricData = response.data !== undefined ? response.data : response;
  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    throw new Error('实时指标数据格式无效');
  }
  return data;
}

export function hasRealtimeData(data: RealtimeMetricData, isBase: boolean): boolean {
  const rows = buildRealtimeRows(isBase ? data : {}, isBase ? {} : data);
  return rows.some((row: RealtimeMetricRow): boolean => {
    return row.cells.some((cell: RealtimeMetricCell): boolean => cell.value !== '' && cell.value !== '--');
  });
}

@Component
export struct PowerQualityRealtimeMonitoringPage {
  @State private uiScale: number = 1;
  @State private rows: RealtimeMetricRow[] = buildRealtimeRows({}, {});
  @State private statusText: string = '正在读取设备数据';
  private baseData: RealtimeMetricData = {};
  private qualityData: RealtimeMetricData = {};
  private readonly columns: number[] = [0, 1, 2];
  private readonly refreshInterval: number = 2000;
  private timerId: number = -1;
  private lifecycleId: number = 0;
  private active: boolean = false;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.active = true;
    this.lifecycleId++;
    this.refreshData(this.lifecycleId);
  }

  aboutToDisappear(): void {
    this.active = false;
    this.lifecycleId++;
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private isCurrentRequest(lifecycleId: number): boolean {
    return this.active && lifecycleId === this.lifecycleId;
  }

  private async fetchData(isBase: boolean, lifecycleId: number): Promise<boolean> {
    const deviceName = isBase ? 'RemoteMetry' : 'PowerQuality';
    const params = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', deviceName);
    params.setExtra('ts', '0');
    try {
      const response: IpcResponse<StringResponse> =
        await IpcUtil.sendRequest<StringResponse>(new IpcRequestConfig('/api/yc/sub', params));
      if (!response.success || !response.data || !response.data.data) {
        throw new Error(deviceName + '请求失败');
      }
      const data = parseRealtimeData(response.data.data);
      if (!hasRealtimeData(data, isBase)) {
        throw new Error(deviceName + '未返回有效指标');
      }
      if (this.isCurrentRequest(lifecycleId)) {
        if (isBase) {
          this.baseData = data;
        } else {
          this.qualityData = data;
        }
        this.rows = buildRealtimeRows(this.baseData, this.qualityData);
      }
      return true;
    } catch (error) {
      hilog.error(0x0001, 'RealtimeMonitoring', '%{public}s: %{public}s', deviceName, String(error));
      return false;
    }
  }

  private async refreshData(lifecycleId: number): Promise<void> {
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    if (!IpcUtil.isConnected()) {
      try {
        await IpcUtil.connect(this.getUIContext().getHostContext() as common.UIAbilityContext);
        if (!IpcUtil.isConnected()) {
          throw new Error('实时数据服务尚未连接');
        }
      } catch (error) {
        if (this.isCurrentRequest(lifecycleId)) {
          this.statusText = '实时数据服务未连接，保留已收到的数据；缺失值显示 --';
          this.scheduleRefresh(lifecycleId);
        }
        hilog.error(0x0001, 'RealtimeMonitoring', '连接失败: %{public}s', String(error));
        return;
      }
    }
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    const baseOk = await this.fetchData(true, lifecycleId);
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    const qualityOk = await this.fetchData(false, lifecycleId);
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    if (baseOk && qualityOk) {
      this.statusText = '';
    } else if (!baseOk && !qualityOk) {
      this.statusText = '设备数据未更新，保留已收到的数据；缺失值显示 --';
    } else {
      this.statusText = (baseOk ? '电能质量指标' : '频率及电压电流') + '未更新，缺失值显示 --';
    }
    this.scheduleRefresh(lifecycleId);
  }

  private scheduleRefresh(lifecycleId: number): void {
    if (!this.isCurrentRequest(lifecycleId)) {
      return;
    }
    // 完成本轮再定时，避免慢请求重叠；组件离开后过期响应不会启动下一轮。
    this.timerId = setTimeout(() => {
      this.timerId = -1;
      this.refreshData(lifecycleId);
    }, this.refreshInterval);
  }

  @Builder
  metricCell(cell: RealtimeMetricCell) {
    Row({ space: 4 * this.uiScale }) {
      if (cell.prefix.length > 0) {
        Text(cell.prefix)
          .fontSize(18 * this.uiScale)
          .fontColor('#111111')
          .maxLines(1)
          .textAlign(TextAlign.End)
      }
      Text(cell.value)
        .layoutWeight(1)
        .fontSize(18 * this.uiScale)
        .minFontSize(12 * this.uiScale)
        .maxFontSize(18 * this.uiScale)
        .maxLines(1)
        .fontColor('#111111')
        .textAlign(TextAlign.Start)
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: 2 * this.uiScale, right: 2 * this.uiScale })
  }

  @Builder
  metricRow(row: RealtimeMetricRow, index: number) {
    Row() {
      Text(row.title)
        .width(115 * this.uiScale)
        .height('100%')
        .fontSize(18 * this.uiScale)
        .fontColor('#111111')
        .maxLines(1)
        .textAlign(TextAlign.End)
      ForEach(this.columns, (column: number) => {
        this.metricCell(row.cells[column])
      }, (column: number) => column.toString())
    }
    .width('100%')
    .height(39 * this.uiScale)
    .padding({ right: 8 * this.uiScale })
    .backgroundColor(index % 2 === 1 ? '#d3d3d3' : '#ffffff')
    .border({ width: { bottom: 1 }, color: '#222222' })
  }

  build() {
    Column() {
      // 保留 Qt 顶部 47 高的灰色栏，仅在读取中或异常时提示数据状态。
      Row() {
        Text(this.statusText)
          .fontSize(14 * this.uiScale)
          .fontColor('#555555')
          .maxLines(1)
      }
      .width('100%')
      .height(47 * this.uiScale)
      .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale })
      .backgroundColor('#c9c9c9')
      .border({ width: { bottom: 1 }, color: '#333333' })
      List({ scroller: this.scroller, space: 0 }) {
        ForEach(this.rows, (row: RealtimeMetricRow, index: number) => {
          ListItem() {
            this.metricRow(row, index)
          }
        }, (row: RealtimeMetricRow) => row.id + ':' + row.cells.map((cell: RealtimeMetricCell) => cell.value).join('|'))
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
        this.uiScale = width / 735;
      }
    })
  }
}
