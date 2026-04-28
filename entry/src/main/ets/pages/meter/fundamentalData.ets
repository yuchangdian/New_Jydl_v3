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

// 定义基波数据接口
interface FundamentalData {
  // 电压
  Ua_RMS?: number[];
  Ub_RMS?: number[];
  Uc_RMS?: number[];
  // 电流
  Ia_RMS?: number[];
  Ib_RMS?: number[];
  Ic_RMS?: number[];
  // 功率
  Pa?: number[];
  Pb?: number[];
  Pc?: number[];
  Pt?: number[];
  Qa?: number[];
  Qb?: number[];
  Qc?: number[];
  Qt?: number[];
  Sa?: number[];
  Sb?: number[];
  Sc?: number[];
  St?: number[];
  // 功率因数
  Fa?: number[];
  Fb?: number[];
  Fc?: number[];
  Ft?: number[];
  // 角度
  Ua_Phase?: number[];
  Ub_Phase?: number[];
  Uc_Phase?: number[];
  Ia_Phase?: number[];
  Ib_Phase?: number[];
  Ic_Phase?: number[];
  // 频率
  Ua_Frequency?: number[];
  Ub_Frequency?: number[];
  Uc_Frequency?: number[];
}

const DOMAIN = 0x0002;
const TAG = 'fundamentalData';

@Component
struct fundamentalData {
  @State uiScale: number = 1
  readonly designWidth: number = 720
  @State selectedLine: number = 1
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
    { label: 'Freq.', unit: 'Hz', values: ['0.00', '', '', ''] }
  ]

  aboutToAppear(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.fetchFundamentalData();
  }

  private async fetchFundamentalData(): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始获取基波数据');

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;
    params.setExtra('deviceName', 'RemoteMetry');
    params.setExtra('ts', '0');
    const config: IpcRequestConfig = new IpcRequestConfig('/api/yc/sub', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      if (response.success && response.data?.data) {
        hilog.info(DOMAIN, TAG, '基波数据获取成功');
        
        try {
          const data: FundamentalData = JSON.parse(response.data.data);
          hilog.info(DOMAIN, TAG, 'API数据部分: %{public}s', JSON.stringify(data));
          this.updateDataRows(data);
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

  // 更新数据行
  private updateDataRows(data: FundamentalData): void {
    const newRows = [...this.dataRows];

    // 1. 相电压 ULn
    newRows[0].values = [
      this.getValue(data.Ua_RMS),
      this.getValue(data.Ub_RMS),
      this.getValue(data.Uc_RMS),
      this.getTotalValue([data.Ua_RMS, data.Ub_RMS, data.Uc_RMS])
    ];

    // 2. 线电压 ULL (假设没有直接的线电压数据，使用相电压计算)
    newRows[1].values = [
      this.getValue(data.Ua_RMS),
      this.getValue(data.Ub_RMS),
      this.getValue(data.Uc_RMS),
      this.getTotalValue([data.Ua_RMS, data.Ub_RMS, data.Uc_RMS])
    ];

    // 3. 电流 I
    newRows[2].values = [
      this.getValue(data.Ia_RMS),
      this.getValue(data.Ib_RMS),
      this.getValue(data.Ic_RMS),
      this.getTotalValue([data.Ia_RMS, data.Ib_RMS, data.Ic_RMS])
    ];

    // 4. 有功 P
    newRows[3].values = [
      this.getValue(data.Pa),
      this.getValue(data.Pb),
      this.getValue(data.Pc),
      this.getValue(data.Pt)
    ];

    // 5. 无功 Q
    newRows[4].values = [
      this.getValue(data.Qa),
      this.getValue(data.Qb),
      this.getValue(data.Qc),
      this.getValue(data.Qt)
    ];

    // 6. 视在 S
    newRows[5].values = [
      this.getValue(data.Sa),
      this.getValue(data.Sb),
      this.getValue(data.Sc),
      this.getValue(data.St)
    ];

    // 7. 功率因数 PF
    newRows[6].values = [
      this.getValue(data.Fa),
      this.getValue(data.Fb),
      this.getValue(data.Fc),
      this.getValue(data.Ft)
    ];

    // 8. 电压角度 U Angle
    newRows[7].values = [
      this.getValue(data.Ua_Phase),
      this.getValue(data.Ub_Phase),
      this.getValue(data.Uc_Phase),
      ''
    ];

    // 9. 电流角度 I Angle
    newRows[8].values = [
      this.getValue(data.Ia_Phase),
      this.getValue(data.Ib_Phase),
      this.getValue(data.Ic_Phase),
      ''
    ];

    // 10. 频率 Freq.
    newRows[9].values = [
      this.getValue(data.Ua_Frequency), '', '', ''
    ];

    // 关键：重新赋值，触发 UI 刷新
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
          .scale({ x: 1.5, y: 1.5 })
          .checked(this.selectedLine === 1)
          .onChange((isSelected) => {
            if (isSelected) {
              this.selectedLine = 1;
              this.fetchFundamentalData();
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
              this.fetchFundamentalData();
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

export { fundamentalData }