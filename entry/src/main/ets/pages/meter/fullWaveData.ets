import display from '@ohos.display';
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util';
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState';
import hilog from '@ohos.hilog';

// 定义数据项接口
interface DataRow {
  label: string;
  unit: string;
  values: string[];
}

// 定义相数据接口
interface PhaseData {
  phaseA: number;
  phaseB: number;
  phaseC: number;
  total: number;
}

// 定义角度数据接口
interface AngleData {
  phaseA: number;
  phaseB: number;
  phaseC: number;
}

// 定义功率数据接口
interface PowerData {
  active: PhaseData;
  reactive: PhaseData;
  apparent: PhaseData;
}

// 定义角度集合接口
interface AngleCollection {
  voltage: AngleData;
  current: AngleData;
}

// 定义全波数据接口
interface FullWaveData {
  FullWave_Ua?: number[];
  FullWave_Ub?: number[];
  FullWave_Uc?: number[];
  FullWave_Uab?: number[];
  FullWave_Ubc?: number[];
  FullWave_Uca?: number[];
  FullWave_Ia?: number[];
  FullWave_Ib?: number[];
  FullWave_Ic?: number[];
  FullWave_Pa?: number[];
  FullWave_Pb?: number[];
  FullWave_Pc?: number[];
  FullWave_Pt?: number[];
  FullWave_Qa?: number[];
  FullWave_Qb?: number[];
  FullWave_Qc?: number[];
  FullWave_Qt?: number[];
  FullWave_Sa?: number[];
  FullWave_Sb?: number[];
  FullWave_Sc?: number[];
  FullWave_St?: number[];
  FullWave_Fa?: number[];
  FullWave_Fb?: number[];
  FullWave_Fc?: number[];
  FullWave_Ft?: number[];
  FreqDeviation_A?: number[];
  FreqDeviation_B?: number[];
  FreqDeviation_C?: number[];
  FreqDeviation_All?: number[];
}

// 定义原始响应数据接口
interface RawApiResponse {
  code?: number;
  success?: boolean;
  message?: string;
  data?: FullWaveData;
  // 以下字段用于兼容直接返回 FullWaveData 的情况
  FullWave_Ua?: number[];
  FullWave_Ub?: number[];
  FullWave_Uc?: number[];
  FullWave_Uab?: number[];
  FullWave_Ubc?: number[];
  FullWave_Uca?: number[];
  FullWave_Ia?: number[];
  FullWave_Ib?: number[];
  FullWave_Ic?: number[];
  FullWave_Pa?: number[];
  FullWave_Pb?: number[];
  FullWave_Pc?: number[];
  FullWave_Pt?: number[];
  FullWave_Qa?: number[];
  FullWave_Qb?: number[];
  FullWave_Qc?: number[];
  FullWave_Qt?: number[];
  FullWave_Sa?: number[];
  FullWave_Sb?: number[];
  FullWave_Sc?: number[];
  FullWave_St?: number[];
  FullWave_Fa?: number[];
  FullWave_Fb?: number[];
  FullWave_Fc?: number[];
  FullWave_Ft?: number[];
  FreqDeviation_A?: number[];
  FreqDeviation_B?: number[];
  FreqDeviation_C?: number[];
  FreqDeviation_All?: number[];
  Voltage_U1?: number[];
  Voltage_U2?: number[];
  Voltage_U0?: number[];
  Current_I1?: number[];
  Current_I2?: number[];
  Current_I0?: number[];
}

// 定义响应数据接口
interface ApiResponse {
  code: number;
  success: boolean;
  message: string;
  data: FullWaveData;
}

const DOMAIN = 0x0001;
const TAG = 'fullWaveData';

@Component
struct fullWaveData {
  @State uiScale: number = 1
  readonly designWidth: number = 720
  @State dataRows: DataRow[] = [
    { label: 'ULn', unit: 'V', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'ULL', unit: 'V', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'I', unit: 'A', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'P', unit: 'W', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'Q', unit: 'Var', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'S', unit: 'VA', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'PF', unit: '', values: ['0.00', '0.00', '0.00', '0.00'] },
    { label: 'U Angle', unit: '', values: ['0.00', '0.00', '0.00', ''] },
    { label: 'I Angle', unit: '', values: ['0.00', '0.00', '0.00', ''] },
  ]
  @State selectedLine: number = 1

  aboutToAppear(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.fetchFullWaveData();
  }

  private async fetchFullWaveData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取全波数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'PowerQuality');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data?.data) {
        hilog.info(DOMAIN, TAG, '全波数据获取成功');

        try {
          // 兼容解析：防止返回结构不严格匹配
          const rawData: RawApiResponse = JSON.parse(response.data.data);
          const apiResponse: ApiResponse = {
            code: rawData.code || 0,
            success: rawData.success ?? true,
            message: rawData.message || '',
            data: rawData.data || rawData // 兼容直接返回 data 的情况
          };

          if (apiResponse.data) {
            this.updateDataRows(apiResponse.data);
          }
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

  // ✅ 修复：重新创建数组，让 @State 触发刷新
  private updateDataRows(data: FullWaveData): void {
    const newRows = [...this.dataRows];

    // 1. 相电压 ULn
    newRows[0].values = [
      this.getValue(data.FullWave_Ua),
      this.getValue(data.FullWave_Ub),
      this.getValue(data.FullWave_Uc),
      this.getTotalValue([data.FullWave_Ua, data.FullWave_Ub, data.FullWave_Uc])
    ];

    // 2. 线电压 ULL
    newRows[1].values = [
      this.getValue(data.FullWave_Uab),
      this.getValue(data.FullWave_Ubc),
      this.getValue(data.FullWave_Uca),
      this.getTotalValue([data.FullWave_Uab, data.FullWave_Ubc, data.FullWave_Uca])
    ];

    // 3. 电流 I
    newRows[2].values = [
      this.getValue(data.FullWave_Ia),
      this.getValue(data.FullWave_Ib),
      this.getValue(data.FullWave_Ic),
      this.getTotalValue([data.FullWave_Ia, data.FullWave_Ib, data.FullWave_Ic])
    ];

    // 4. 有功 P
    newRows[3].values = [
      this.getValue(data.FullWave_Pa),
      this.getValue(data.FullWave_Pb),
      this.getValue(data.FullWave_Pc),
      this.getValue(data.FullWave_Pt)
    ];

    // 5. 无功 Q
    newRows[4].values = [
      this.getValue(data.FullWave_Qa),
      this.getValue(data.FullWave_Qb),
      this.getValue(data.FullWave_Qc),
      this.getValue(data.FullWave_Qt)
    ];

    // 6. 视在 S
    newRows[5].values = [
      this.getValue(data.FullWave_Sa),
      this.getValue(data.FullWave_Sb),
      this.getValue(data.FullWave_Sc),
      this.getValue(data.FullWave_St)
    ];

    // 7. 功率因数 PF
    newRows[6].values = [
      this.getValue(data.FullWave_Fa),
      this.getValue(data.FullWave_Fb),
      this.getValue(data.FullWave_Fc),
      this.getValue(data.FullWave_Ft)
    ];

   

    // ✅ 关键：重新赋值，触发 UI 刷新
    this.dataRows = newRows;
    hilog.info(DOMAIN, TAG, '数据已更新并刷新 UI');
  }

  // 安全取值：空/undefined 都返回 0.00
  private getValue(arr?: number[]): string {
    if (!arr || arr.length === 0) return '0.00';
    const val = arr[0];
    return isNaN(val) ? '0.00' : val.toFixed(2);
  }

  private getTotalValue(arrays: (number[] | undefined)[]): string {
    let sum = 0;
    let count = 0;
    for (const arr of arrays) {
      if (arr && arr.length > 0 && !isNaN(arr[0])) {
        sum += arr[0];
        count++;
      }
    }
    return count > 0 ? (sum / count).toFixed(2) : '0.00';
  }

  @Builder
  buildCell(text: string, isGray: boolean) {
    Text(text)
      .width('16.6%')
      .height(30 * this.uiScale)
      .textAlign(TextAlign.Center)
      .backgroundColor(isGray ? '#E0E0E0' : '#FFFFFF')
      .border({ width: { bottom:1 * this.uiScale }, color: '#ff000000' })
      .fontSize(16 * this.uiScale)
  }

  @Builder
  buildHeaderCell(text: string) {
    Text(text)
      .width('16.6%')
      .height(30 * this.uiScale)
      .textAlign(TextAlign.Center)
      .border({ width: { bottom:1 * this.uiScale }, color: '#ff000000' })
      .fontSize(16 * this.uiScale)
      .fontWeight(FontWeight.Bold)
  }

  build() {
    Column() {
      Row() {
        Radio({ group: 'line', value: '1' })
          .checked(this.selectedLine === 1)
          .scale({ x: 1.5, y: 1.5 })
          .onChange((isSelected) => {
            if (isSelected) {
              this.selectedLine = 1;
              this.fetchFullWaveData();
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
              this.fetchFullWaveData();
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

      Scroll() {
        Column() {
          Flex({ wrap: FlexWrap.NoWrap }) {
            this.buildHeaderCell('')
            this.buildHeaderCell('A/AB')
            this.buildHeaderCell('B/BC')
            this.buildHeaderCell('C/CA')
            this.buildHeaderCell('Total/Avg')
            this.buildHeaderCell('Unit')
          }

          ForEach(this.dataRows, (row: DataRow, index: number) => {
            Flex({ wrap: FlexWrap.NoWrap }) {
              this.buildCell(row.label, index % 2 === 1)
              this.buildCell(row.values[0], index % 2 === 1)
              this.buildCell(row.values[1], index % 2 === 1)
              this.buildCell(row.values[2], index % 2 === 1)
              this.buildCell(row.values[3], index % 2 === 1)
              this.buildCell(row.unit, index % 2 === 1)
            }
          }, (row: DataRow, index: number) => `${row.label}-${index}`)
        }
      }
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }
}

export { fullWaveData }