import { window } from '@kit.ArkUI'
import display from '@ohos.display'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import { IpcUtil, IpcRequestConfig, IpcParams, StringResponse, IpcResponse } from '../../utils/IPC_Util'
import { PROJECT_CODE, TERMINAL_ID } from '../../common/GlobalState'
import hilog from '@ohos.hilog'

// 事件数据类型定义
interface EventItem {
  id: number
  content: string
  time: string
  eventPath: string
}

// API 事件数据类型定义
interface ApiEventItem {
  Id: number
  ProjectCode: string
  TerminalId: string
  Level: number
  EventType: string
  EventName: string
  EventTime: string
  EventLine: string
  EventPath: string
  IsRead: number
  ConfirmorAccount: string
  CreateId: number
  CreateTime: string
}

// API 事件数据列表类型定义
interface EventDataList {
  total: number
  unread_count: number
  data: ApiEventItem[]
}

// API 响应数据类型定义
interface ApiResponse {
  code: number
  success: boolean
  message: string
  data: EventDataList
}

// 文件内容响应类型定义
interface FileContentResponse {
  code: number
  success: boolean
  message: string
  data: string
}

const DOMAIN = 0x0001;
const TAG = 'EventCenter';

// 获取当前日期字符串（格式：YYYY/MM/DD）
function getCurrentDate(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = (today.getMonth() + 1).toString().padStart(2, '0');
  const day = today.getDate().toString().padStart(2, '0');
  return `${year}/${month}/${day}`;
}

@Entry
@Component
struct meterIndex {
  windowClass?: window.Window
  @State selectedMenuItem: string = "事件"
  @State uiScale: number = 1
  @State selectedLine: number = 1
  @State startDate: string = getCurrentDate()
  @State endDate: string = getCurrentDate()
  @State requestResult: string = ''
  readonly designWidth: number = 720

  // 弹窗显示控制
  @State isDialogVisible: boolean = false
  @State isLoading: boolean = false
  @State detailContent: string = ''
  @State currentEventName: string = ''

  // 数据相关状态（不使用分页）
  @State eventList: EventItem[] = []
  @State totalCount: number = 0
  @State isLoadingList: boolean = false

  onPageShow(): void {
    try {
      let dis = display.getDefaultDisplaySync()
      this.uiScale = dis.width / this.designWidth
    } catch (e) {
      this.uiScale = 1
    }
    this.fetchEventData(false)
  }

  // 获取事件数据
  // isRecent50: true=获取最近50条(不传时间范围), false=获取全部(传时间范围)
  private async fetchEventData(isRecent50: boolean = false): Promise<void> {
    if (this.isLoadingList) return

    hilog.info(DOMAIN, TAG, '========== 获取事件数据 ==========');

    if (isRecent50) {
      hilog.info(DOMAIN, TAG, '模式: 获取最近50条（不传时间范围，dataSize=50）');
    } else {
      hilog.info(DOMAIN, TAG, '模式: 获取全部数据（传时间范围，不传dataSize）');
      hilog.info(DOMAIN, TAG, '开始时间: %{public}s', this.startDate);
      hilog.info(DOMAIN, TAG, '结束时间: %{public}s', this.endDate);
    }

    this.isLoadingList = true

    const params: IpcParams = new IpcParams();
    params.projectCode = PROJECT_CODE;
    params.terminalId = TERMINAL_ID;

    // 传时间范围

    params.setExtra('dataIndex','1');
    // 如果是最近50条，传dataSize=50，否则不传dataSize（查询全部）
    if (isRecent50) {
      params.setExtra('dataSize', '50');
      params.setExtra('startTime',  '');
      params.setExtra('endTime', '');
    }else{
      params.setExtra('dataSize', '');
      params.setExtra('startTime', this.startDate || '');
      params.setExtra('endTime', this.endDate || '');

    }
    // 注意：不传dataIndex，让接口返回全部数据

    const config: IpcRequestConfig = new IpcRequestConfig('/api/events', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);
      hilog.info(DOMAIN, TAG, '请求响应状态: %{public}s', response.success ? '成功' : '失败');

      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '原始响应数据: %{public}s', response.data.data);

        try {
          const parsedResponse: ApiResponse = JSON.parse(response.data.data);
          hilog.info(DOMAIN, TAG, '解析后响应码: %{public}d', parsedResponse.code);
          hilog.info(DOMAIN, TAG, '解析后消息: %{public}s', parsedResponse.message);

          if (parsedResponse && parsedResponse.success && parsedResponse.data) {
            const eventData = parsedResponse.data.data;
            this.totalCount = parsedResponse.data.total || 0
            hilog.info(DOMAIN, TAG, '总数据量: %{public}d', this.totalCount);

            if (eventData && eventData.length > 0) {
              this.eventList = eventData.map((item: ApiEventItem) => {
                return {
                  id: item.Id,
                  content: item.EventName,
                  time: item.EventTime,
                  eventPath: item.EventPath
                } as EventItem;
              });
              hilog.info(DOMAIN, TAG, '获取到 %{public}d 条数据', this.eventList.length);
            } else {
              this.eventList = []
              hilog.info(DOMAIN, TAG, '没有数据');
            }
          } else {
            hilog.error(DOMAIN, TAG, '响应解析失败: %{public}s', parsedResponse?.message || '未知错误');
            this.eventList = []
            this.totalCount = 0
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, 'JSON解析异常: %{public}s', String(parseError))
          this.eventList = []
          this.totalCount = 0
        }

        this.requestResult = response.data.data
      } else {
        hilog.error(DOMAIN, TAG, '事件数据请求失败')
        this.eventList = []
        this.totalCount = 0
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '事件数据请求异常: %{public}s', String(error))
      this.eventList = []
      this.totalCount = 0
    } finally {
      this.isLoadingList = false
      hilog.info(DOMAIN, TAG, '========== 请求结束 ==========');
    }
  }

  // 时间查询（获取全部数据）
  private searchByTime(): void {
    hilog.info(DOMAIN, TAG, '========== 时间查询 ==========');
    hilog.info(DOMAIN, TAG, '开始日期: %{public}s', this.startDate);
    hilog.info(DOMAIN, TAG, '结束日期: %{public}s', this.endDate);

    // 获取全部数据（传时间范围）
    this.fetchEventData(false)
  }

  // 获取最近50条数据（不传时间范围，只传dataSize=50）
  private fetchRecent50(): void {
    hilog.info(DOMAIN, TAG, '========== 获取最近50条数据 ==========');
    hilog.info(DOMAIN, TAG, '不传时间范围，dataSize=50');

    // 获取最近50条
    this.fetchEventData(true)
  }

  // 线路切换查询
  private onLineChange(line: number): void {
    hilog.info(DOMAIN, TAG, '========== 线路切换 ==========');
    hilog.info(DOMAIN, TAG, '切换到线路: %{public}d', line);
    this.selectedLine = line;
    // 获取全部数据
    this.fetchEventData(false);
  }

  // 通过 IPC 获取事件详情
  private async fetchEventDetail(eventPath: string, eventName: string): Promise<void> {
    hilog.info(DOMAIN, TAG, '========== 开始请求事件详情 ==========');
    hilog.info(DOMAIN, TAG, '事件名称: %{public}s', eventName);
    hilog.info(DOMAIN, TAG, '请求参数 filePath: %{public}s', eventPath);

    this.isLoading = true;
    this.currentEventName = eventName;
    this.detailContent = '';

    const params: IpcParams = new IpcParams();
    params.setExtra('filePath', eventPath);

    const config: IpcRequestConfig = new IpcRequestConfig('/api/file/content', params);

    try {
      const response: IpcResponse<StringResponse> = await IpcUtil.sendRequest<StringResponse>(config);

      hilog.info(DOMAIN, TAG, '========== 请求响应 ==========');
      hilog.info(DOMAIN, TAG, '响应成功状态: %{public}s', response.success ? '成功' : '失败');

      if (response.success && response.data && response.data.data) {
        hilog.info(DOMAIN, TAG, '原始响应数据: %{public}s', response.data.data);

        try {
          const parsedResponse: FileContentResponse = JSON.parse(response.data.data);
          hilog.info(DOMAIN, TAG, '解析后响应码: %{public}d', parsedResponse.code);
          hilog.info(DOMAIN, TAG, '解析后消息: %{public}s', parsedResponse.message);
          hilog.info(DOMAIN, TAG, '解析后data内容: %{public}s', parsedResponse.data);

          if (parsedResponse.success && parsedResponse.data) {
            this.detailContent = parsedResponse.data.replace(/\n$/, '');
            hilog.info(DOMAIN, TAG, '最终显示内容: %{public}s', this.detailContent);
          } else {
            this.detailContent = parsedResponse.message || '无有效数据';
          }
        } catch (parseError) {
          hilog.error(DOMAIN, TAG, 'JSON解析失败: %{public}s', String(parseError));
          this.detailContent = response.data.data;
        }

        this.isDialogVisible = true;
      } else {
        hilog.error(DOMAIN, TAG, '请求失败，无有效数据');
        this.detailContent = '请求失败：未获取到有效数据';
        this.isDialogVisible = true;
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '========== 请求异常 ==========');
      hilog.error(DOMAIN, TAG, '异常信息: %{public}s', String(error));
      this.detailContent = `请求异常：${String(error)}`;
      this.isDialogVisible = true;
    } finally {
      this.isLoading = false;
      hilog.info(DOMAIN, TAG, '========== 请求结束 ==========');
    }
  }

  // 关闭弹窗
  private closeDialog() {
    this.isDialogVisible = false;
    this.detailContent = '';
  }

  // 显示开始日期选择器（字体放大版）
  private showStartDatePicker() {
    try {
      const dateParts = this.startDate.split('/');
      const currentDate = new Date(
        parseInt(dateParts[0]),
        parseInt(dateParts[1]) - 1,
        parseInt(dateParts[2])
      );

      DatePickerDialog.show({
        selected: currentDate,
        start: new Date(2020, 0, 1),
        end: new Date(),
        lunar: false,
        textStyle: {
          color: '#007DFF',
          font: { size: '24fp' }
        },
        selectedTextStyle: {
          color: '#007DFF',
          font: { size: '30fp', weight: FontWeight.Bold }
        },
        acceptButtonStyle: {
          fontSize: '26fp',
          fontWeight: FontWeight.Medium
        },
        cancelButtonStyle: {
          fontSize: '26fp',
          fontWeight: FontWeight.Medium
        },
        onAccept: (value: DatePickerResult) => {
          if (value.year && value.month !== undefined && value.day) {
            const year = value.year;
            const month = (value.month + 1).toString().padStart(2, '0');
            const day = value.day.toString().padStart(2, '0');
            this.startDate = `${year}/${month}/${day}`;
            hilog.info(DOMAIN, TAG, '开始日期已选择: %{public}s', this.startDate);
          }
        },
        onCancel: () => {
          hilog.info(DOMAIN, TAG, '开始日期选择取消');
        }
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, '显示开始日期选择器失败: %{public}s', String(error));
    }
  }

  // 显示结束日期选择器（字体放大版）
  private showEndDatePicker() {
    try {
      const dateParts = this.endDate.split('/');
      const currentDate = new Date(
        parseInt(dateParts[0]),
        parseInt(dateParts[1]) - 1,
        parseInt(dateParts[2])
      );

      DatePickerDialog.show({
        selected: currentDate,
        start: new Date(2020, 0, 1),
        end: new Date(),
        lunar: false,
        textStyle: {
          color: '#007DFF',
          font: { size: '24fp' }
        },
        selectedTextStyle: {
          color: '#007DFF',
          font: { size: '30fp', weight: FontWeight.Bold }
        },
        acceptButtonStyle: {
          fontSize: '26fp',
          fontWeight: FontWeight.Medium
        },
        cancelButtonStyle: {
          fontSize: '26fp',
          fontWeight: FontWeight.Medium
        },
        onAccept: (value: DatePickerResult) => {
          if (value.year && value.month !== undefined && value.day) {
            const year = value.year;
            const month = (value.month + 1).toString().padStart(2, '0');
            const day = value.day.toString().padStart(2, '0');
            this.endDate = `${year}/${month}/${day}`;
            hilog.info(DOMAIN, TAG, '结束日期已选择: %{public}s', this.endDate);
          }
        },
        onCancel: () => {
          hilog.info(DOMAIN, TAG, '结束日期选择取消');
        }
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, '显示结束日期选择器失败: %{public}s', String(error));
    }
  }

  // 构建弹窗内容
  @Builder
  EventDetailDialog() {
    Column() {
      Row() {
        Text('事件详情')
          .fontSize(18 * this.uiScale)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffffff')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .backgroundColor('#0099EE')
      .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale, top: 16 * this.uiScale, bottom: 12 * this.uiScale })
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })
      .borderRadius({ topLeft: 16 * this.uiScale, topRight: 16 * this.uiScale, bottomLeft: 0, bottomRight: 0 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40 * this.uiScale)
            .height(40 * this.uiScale)
            .color('#0099EE')
          Text('加载中...')
            .fontSize(14 * this.uiScale)
            .fontColor('#999999')
            .margin({ top: 12 * this.uiScale })
        }
        .width('100%')
        .height(200 * this.uiScale)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            Text(this.detailContent)
              .fontSize(16 * this.uiScale)
              .fontColor('#333333')
              .padding(16 * this.uiScale)
              .backgroundColor('#F5F5F5')
              .borderRadius(8 * this.uiScale)
              .width('100%')
              .textAlign(TextAlign.Start)
              .lineHeight(24 * this.uiScale)
          }
          .width('100%')
          .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale, bottom: 16 * this.uiScale })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.TopStart)
      }

      Row() {
        Button('确 定')
          .width(100 * this.uiScale)
          .height(36 * this.uiScale)
          .fontSize(15 * this.uiScale)
          .backgroundColor('#0099EE')
          .borderRadius(8 * this.uiScale)
          .onClick(() => this.closeDialog())
      }
      .width('100%')
      .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale, top: 12 * this.uiScale, bottom: 16 * this.uiScale })
      .justifyContent(FlexAlign.Center)
      .border({ width: { top: 1 }, color: '#E0E0E0' })
    }
    .width('90%')
    .height('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16 * this.uiScale)
    .shadow({ radius: 20 * this.uiScale, color: '#40000000' })
  }

  build() {
    Stack() {
      Column() {
        Row() {
          // 左侧时间选择区域
          Column() {
            Row() {
              Image($rawfile("icon/icon05.png"))
                .width(18 * this.uiScale)
                .height(18 * this.uiScale)
              Text("事件")
                .fontSize(16 * this.uiScale)
                .fontColor('#ffffff')
                .margin({ left: 5 * this.uiScale })
            }
            .width(100 * this.uiScale)
            .backgroundColor('#ff167fff')
            .height(40 * this.uiScale)
            .justifyContent(FlexAlign.Center)

            Column({ space: 8 * this.uiScale }) {
              Text(this.startDate)
                .width(90 * this.uiScale)
                .height(30 * this.uiScale)
                .fontSize(14 * this.uiScale)
                .backgroundColor('#fff')
                .border({ width: 1, color: '#999' })
                .fontColor('#000000')
                .borderRadius(5 * this.uiScale)
                .textAlign(TextAlign.Center)
                .onClick(() => this.showStartDatePicker())

              Text("至")
                .fontSize(12 * this.uiScale)

              Text(this.endDate)
                .width(90 * this.uiScale)
                .height(30 * this.uiScale)
                .fontSize(14 * this.uiScale)
                .textAlign(TextAlign.Center)
                .fontColor('#000000')
                .backgroundColor('#fff')
                .border({ width: 1, color: '#999' })
                .borderRadius(5 * this.uiScale)
                .onClick(() => this.showEndDatePicker())

              Button("时间查询")
                .width(90 * this.uiScale)
                .height(30 * this.uiScale)
                .backgroundColor('#ffababab')
                .borderRadius(5 * this.uiScale)
                .fontSize(14 * this.uiScale)
                .onClick(() => this.searchByTime())

              Button("最近50条")
                .width(90 * this.uiScale)
                .height(30 * this.uiScale)
                .backgroundColor('#ffababab')
                .borderRadius(5 * this.uiScale)
                .fontSize(14 * this.uiScale)
                .onClick(() => this.fetchRecent50())
            }
            .width(100 * this.uiScale)
            .padding(10 * this.uiScale)
            .alignItems(HorizontalAlign.Center)
          }
          .height('100%')
          .backgroundColor('#F5F5F5')

          // 右侧事件列表
          Column() {
            Row() {
              Radio({ group: 'line', value: '1' })
                .checked(this.selectedLine === 1)
                .onChange(() => this.onLineChange(1))
                .scale({ x: 1.5, y: 1.5 })
              Text("线路1")
                .fontSize(18 * this.uiScale)
                .margin({ right: 40 * this.uiScale })

              Radio({ group: 'line', value: '2' })
                .checked(this.selectedLine === 2)
                .onChange(() => this.onLineChange(2))
                .scale({ x: 1.5, y: 1.5 })
              Text("线路2")
                .fontSize(18 * this.uiScale)
            }
            .height(40 * this.uiScale)
            .backgroundColor('#c9c9c9')
            .justifyContent(FlexAlign.Center)
            .width('100%')

            // 事件列表
            List() {
              if (this.isLoadingList && this.eventList.length === 0) {
                ListItem() {
                  Row() {
                    LoadingProgress()
                      .width(30 * this.uiScale)
                      .height(30 * this.uiScale)
                      .color('#0099EE')
                    Text('加载中...')
                      .fontSize(14 * this.uiScale)
                      .fontColor('#999999')
                      .margin({ left: 12 * this.uiScale })
                  }
                  .width('100%')
                  .height(200 * this.uiScale)
                  .justifyContent(FlexAlign.Center)
                }
              } else if (this.eventList.length === 0) {
                ListItem() {
                  Row() {
                    Text('暂无事件数据')
                      .fontSize(14 * this.uiScale)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .height(200 * this.uiScale)
                  .justifyContent(FlexAlign.Center)
                }
              } else {
                ForEach(this.eventList, (item: EventItem) => {
                  ListItem() {
                    Row() {
                      Row() {
                        Text(item.content)
                          .fontSize(16 * this.uiScale)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .margin({ right: 8 * this.uiScale })
                          .layoutWeight(1)
                        Text(item.time)
                          .fontSize(16 * this.uiScale)
                          .fontColor('#333333')
                      }
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ left: 12 * this.uiScale, right: 12 * this.uiScale, top: 12 * this.uiScale, bottom: 12 * this.uiScale })
                    .border({ width: { bottom: 1 }, color: '#E0E0E0' })
                    .onClick(() => {
                      hilog.info(DOMAIN, TAG, '点击事件: id=%{public}d, name=%{public}s, path=%{public}s',
                        item.id, item.content, item.eventPath);
                      this.fetchEventDetail(item.eventPath, item.content);
                    })
                  }
                })
              }
            }
            .layoutWeight(1)
            .backgroundColor('#fff')
            .scrollBar(BarState.Auto)
          }
          .layoutWeight(1)
          .height('100%')
        }
        .layoutWeight(1)
        CommonTitleBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F0F0')

      // 自定义弹窗遮罩层
      if (this.isDialogVisible) {
        Column() {
          this.EventDetailDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick((event: ClickEvent) => {
          if (event.target) {
            this.closeDialog();
          }
        })
      }
    }
  }
}