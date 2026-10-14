import router from '@ohos.router';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { common } from '@kit.AbilityKit';
import { HistoryDataQueryService, HistoryExportDocument } from './HistoryDataQueryService';
import { QtHistoryDateDialog } from './QtHistoryDateDialog';

const QT_FONT: string = 'Microsoft YaHei, SimHei, Noto Sans CJK SC, sans-serif';

const CATEGORY_NAMES: string[] = [
  '基波数据', '电能质量指标', '电压谐波', '电流谐波', '电压间谐波', '电流间谐波'
];

function twoDigits(value: number): string {
  return value.toString().padStart(2, '0');
}

function dateText(value: Date): string {
  return `${value.getFullYear()}/${twoDigits(value.getMonth() + 1)}/${twoDigits(value.getDate())}`;
}

function timeText(value: Date): string {
  return `${twoDigits(value.getHours())}:${twoDigits(value.getMinutes())}`;
}

function exportTimeText(value: Date): string {
  return `${value.getFullYear()}${twoDigits(value.getMonth() + 1)}${twoDigits(value.getDate())}_` +
    `${twoDigits(value.getHours())}${twoDigits(value.getMinutes())}${twoDigits(value.getSeconds())}`;
}

@Entry
@Component
struct PowerQualityHistoryPage {
  @State private uiScale: number = 1;
  @State private start: Date = new Date();
  @State private end: Date = new Date();
  @State private selected: boolean[] = [true, true, true, true, true, true];
  @State private exporting: boolean = false;
  @State private clock: string = '';
  @State private startTimeDraft: string = '00:00';
  @State private endTimeDraft: string = '';
  @State private focusedTime: number = -1;
  @State private calendarVisible: boolean = false;
  @State private calendarForStart: boolean = true;
  @State private pressedButton: string = '';
  @State private feedbackVisible: boolean = false;
  @State private feedbackTitle: string = '';
  @State private feedbackMessage: string = '';
  @State private feedbackWidth: number = 333;
  @State private feedbackInformation: boolean = false;
  @State private pageHeight: number = 480;
  private active: boolean = false;
  private generation: number = 0;
  private timerId: number = -1;

  aboutToAppear(): void {
    const now = new Date();
    this.start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    this.end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes());
    this.startTimeDraft = timeText(this.start);
    this.endTimeDraft = timeText(this.end);
    this.active = true;
    this.updateClock();
    this.timerId = setInterval(() => this.updateClock(), 1000);
  }

  aboutToDisappear(): void {
    this.active = false;
    this.generation++;
    this.exporting = false;
    this.calendarVisible = false;
    this.feedbackVisible = false;
    if (this.timerId !== -1) clearInterval(this.timerId);
    this.timerId = -1;
  }

  private updateClock(): void {
    const now = new Date();
    this.clock = `${dateText(now)} ${timeText(now)}:${twoDigits(now.getSeconds())}`;
  }

  private isCurrent(generation: number): boolean {
    return this.active && generation === this.generation;
  }

  private selectDate(isStart: boolean): void {
    this.getUIContext().getFocusController().requestFocus('history-export');
    this.calendarForStart = isStart;
    this.calendarVisible = true;
  }

  private acceptDate(date: Date): void {
    const current = this.calendarForStart ? this.start : this.end;
    const chosen = new Date(date.getFullYear(), date.getMonth(), date.getDate(),
      current.getHours(), current.getMinutes());
    if (this.calendarForStart) this.start = chosen;
    else this.end = chosen;
    this.calendarVisible = false;
  }

  private changeTime(value: string, isStart: boolean): void {
    if (isStart) this.startTimeDraft = value;
    else this.endTimeDraft = value;
    if (!/^\d{1,2}:\d{2}$/.test(value)) return;
    const parts = value.split(':');
    const hour = Number(parts[0]);
    const minute = Number(parts[1]);
    if (hour > 23 || minute > 59) return;
    const current = isStart ? this.start : this.end;
    const chosen = new Date(current.getTime());
    chosen.setHours(hour, minute, 0, 0);
    if (isStart) this.start = chosen;
    else this.end = chosen;
  }

  private normalizeTime(isStart: boolean): void {
    if (isStart) this.startTimeDraft = timeText(this.start);
    else this.endTimeDraft = timeText(this.end);
    this.focusedTime = -1;
  }

  private s(value: number): number { return value * this.uiScale; }

  private calendarHeight(): number {
    return Math.max(180, Math.min(338, this.pageHeight / this.uiScale - 155));
  }

  onBackPress(): boolean {
    if (this.calendarVisible) { this.calendarVisible = false; return true; }
    if (this.feedbackVisible) { this.feedbackVisible = false; return true; }
    return false;
  }

  private showMessage(title: string, message: string): void {
    if (!this.active) return;
    this.feedbackTitle = title;
    this.feedbackMessage = message;
    this.feedbackInformation = title === '导出完成' || message === '数据正在导出，请稍候。';
    let textWidth = 0;
    for (const line of message.split('\n')) {
      const width = this.getUIContext().getMeasureUtils().measureText({
        textContent: line, fontSize: '20vp', fontFamily: QT_FONT
      });
      textWidth = Math.max(textWidth, px2vp(width));
    }
    this.feedbackWidth = Math.max(333, Math.min(600, textWidth + 73));
    this.feedbackVisible = true;
  }

  private async exportHistory(): Promise<void> {
    if (this.exporting) {
      this.showMessage('导出提示', '数据正在导出，请稍候。');
      return;
    }
    const startMs = this.start.getTime();
    const endMs = this.end.getTime();
    if (startMs >= endMs) {
      this.showMessage('导出提示', '结束时间必须晚于开始时间。');
      return;
    }
    if (endMs - startMs > 30 * 86400000) {
      this.showMessage('导出提示', '导出时间范围不能超过30天。');
      return;
    }
    if (!this.selected.some((value: boolean) => value)) {
      this.showMessage('导出提示', '请至少选择一种数据类型。');
      return;
    }
    const generation = ++this.generation;
    this.exporting = true;
    let documents: HistoryExportDocument[] = [];
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const service = new HistoryDataQueryService(context);
      documents = await service.export(startMs, endMs, this.selected.slice(),
        exportTimeText(new Date()), generation, (value: number) => this.isCurrent(value));
      if (!this.isCurrent(generation)) return;
      if (documents.length === 0) {
        this.showMessage('导出失败', '所选时间范围没有可导出的数据。');
        return;
      }
      const documentPicker = new picker.DocumentViewPicker(context);
      const uris = await documentPicker.save({ newFileNames: documents.map((item: HistoryExportDocument) => item.name),
        fileSuffixChoices: ['CSV|.csv'] });
      if (!this.isCurrent(generation)) return;
      if (uris.length !== documents.length) throw new Error('保存的文件数量与导出文件数量不一致');
      let totalRows = 0;
      for (let i = 0; i < documents.length; i++) {
        const output = fs.openSync(uris[i], fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
        try {
          fs.copyFileSync(documents[i].path, output.fd);
        } finally {
          fs.closeSync(output);
        }
        totalRows += documents[i].rows;
      }
      this.showMessage('导出完成', `已导出 ${totalRows} 行数据。\n共生成 ${documents.length} 个 CSV 文件。`);
    } catch (error) {
      this.showMessage('导出失败', String(error));
    } finally {
      for (const document of documents) {
        try { fs.unlinkSync(document.path); } catch (_) {}
      }
      if (this.isCurrent(generation)) this.exporting = false;
    }
  }

  @Builder
  private dateEdit(isStart: boolean, x: number) {
    Text(dateText(isStart ? this.start : this.end))
      .width(this.s(147)).height(this.s(52))
      .padding({ left: this.s(6), right: this.s(6) })
      .fontSize(`${this.s(20)}vp`).fontFamily(QT_FONT).fontColor('#111111')
      .textAlign(TextAlign.Start).maxLines(1)
      .backgroundColor('#FFFFFF')
      .border({ width: this.s(2), color: '#555555' })
      .position({ x: this.s(x), y: this.s(42) })
      .onClick(() => this.selectDate(isStart))
      .accessibilityText(isStart ? '开始日期' : '结束日期')
  }

  @Builder
  private timeEdit(isStart: boolean, x: number) {
    TextInput({ text: isStart ? this.startTimeDraft : this.endTimeDraft })
      .id(isStart ? 'history-start-time' : 'history-end-time')
      .width(this.s(82)).height(this.s(52))
      .padding({ left: this.s(6), right: this.s(6), top: 0, bottom: 0 })
      .fontSize(`${this.s(20)}vp`).fontFamily(QT_FONT).fontColor('#111111')
      .backgroundColor('#FFFFFF').borderRadius(0)
      .border({ width: this.s(2), color: this.focusedTime === (isStart ? 0 : 1) ? '#12A9DC' : '#555555' })
      .maxLength(5).inputFilter('[0-9:]*')
      .selectedBackgroundColor('#12A9DC')
      .position({ x: this.s(x), y: this.s(42) })
      .onFocus(() => this.focusedTime = isStart ? 0 : 1)
      .onBlur(() => this.normalizeTime(isStart))
      .onSubmit(() => this.normalizeTime(isStart))
      .onChange((value: string) => this.changeTime(value, isStart))
      .accessibilityText(isStart ? '开始时间' : '结束时间')
  }

  @Builder
  private categoryCheck(index: number, x: number, y: number) {
    Row({ space: this.s(12) }) {
      Stack() {
        Image($rawfile('history/qt-checkbox-unchecked.png'))
          .width(this.s(26)).height(this.s(26))
        if (this.selected[index]) {
          Polyline({ width: this.s(26), height: this.s(26) })
            .points([[this.s(5), this.s(13)], [this.s(11), this.s(19)], [this.s(21), this.s(7)]])
            .fill('none').stroke('#111111').strokeWidth(this.s(2.4))
            .strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
            .hitTestBehavior(HitTestMode.None)
        }
      }
      .width(this.s(26)).height(this.s(26))
      Text(CATEGORY_NAMES[index])
        .width(this.s(194)).height(this.s(28))
        .fontSize(`${this.s(21)}vp`).fontFamily(QT_FONT).fontColor('#111111')
        .maxLines(1)
    }
    .width(this.s(232)).height(this.s(28))
    .position({ x: this.s(x), y: this.s(y) })
    .onClick(() => {
        const next = this.selected.slice();
        next[index] = !next[index];
        this.selected = next;
    })
    .accessibilityText(`${CATEGORY_NAMES[index]}，${this.selected[index] ? '已勾选' : '未勾选'}`)
  }

  @Builder
  private actionButton(label: string, green: boolean, x: number, action: () => void) {
    Button(label, { type: ButtonType.Normal })
      .id(green ? 'history-export' : 'history-back')
      .width(this.s(137)).height(this.s(42)).padding(0)
      .fontSize(`${this.s(22)}vp`).fontFamily(QT_FONT)
      .fontWeight(FontWeight.Normal)
      .fontColor(green && this.exporting ? '#777777' : '#111111')
      .border({ width: this.s(1), color: '#444444' })
      .borderRadius(this.s(18))
      .backgroundColor(green && this.exporting ? '#C9C9C9' : this.pressedButton === label ? '#A7D6E7' :
        green ? '#78BD35' : '#BCBCBC')
      .stateEffect(false)
      .enabled(!green || !this.exporting)
      .position({ x: this.s(x), y: this.s(9) })
      .onTouch((event: TouchEvent) => {
        this.pressedButton = event.type === TouchType.Down ? label : '';
      })
      .onClick(action)
  }

  @Builder
  private headerBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Rect().width(this.s(23)).height(this.s(31)).fill('#12A9DC')
          .position({ x: this.s(4), y: this.s(4) })
        ForEach([10, 18, 26], (y: number) => {
          Rect().width(this.s(17)).height(this.s(4)).fill('#78BD35')
            .position({ x: this.s(7), y: this.s(y) })
        }, (y: number) => y.toString())
      }
      .width(this.s(31)).height(this.s(39)).backgroundColor('#FFFFFF')
      .borderRadius(this.s(2)).position({ x: this.s(10), y: this.s(10) })
      Text('电能质量历史数据导出')
        .width('100%').height(this.s(33))
        .fontSize(`${this.s(25)}vp`).fontFamily(QT_FONT).fontWeight(FontWeight.Bold)
        .fontColor('#003F9E').textAlign(TextAlign.Center).maxLines(1)
        .position({ x: 0, y: this.s(10) })
    }
    .width('100%').height(this.s(53)).backgroundColor('#12A9DC')
    .border({ width: this.s(1), color: '#202020' })
  }

  @Builder
  private contentArea() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('时间：')
        .width(this.s(69)).height(this.s(52))
        .fontSize(`${this.s(22)}vp`).fontFamily(QT_FONT).fontWeight(FontWeight.Bold).fontColor('#111111')
        .position({ x: this.s(105), y: this.s(42) })
      this.dateEdit(true, 188)
      this.timeEdit(true, 349)
      Text('至')
        .width(this.s(47)).height(this.s(52))
        .fontSize(`${this.s(20)}vp`).fontFamily(QT_FONT).fontColor('#111111')
        .textAlign(TextAlign.Center).position({ x: this.s(445), y: this.s(42) })
      this.dateEdit(false, 506)
      this.timeEdit(false, 667)
      ForEach(CATEGORY_NAMES, (_name: string, index: number) => {
        this.categoryCheck(index, index % 2 === 0 ? 185 : 517, 116 + Math.floor(index / 2) * 48)
      }, (_name: string, index: number) => index.toString())
      Text(this.exporting ? '正在读取并写入历史数据，请稍候……' :
        '请选择时间范围和数据类型，导出文件格式为 CSV。')
        .width(this.s(644)).height(this.s(21))
        .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT).fontColor('#555555')
        .textAlign(TextAlign.Center).maxLines(1)
        .position({ x: this.s(105), y: this.pageHeight - this.s(159) })
    }
    .width('100%').layoutWeight(1).backgroundColor('#FFFFFF')
    .border({ width: { left: this.s(1), right: this.s(1) }, color: '#222222' })
  }

  @Builder
  private footerBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.actionButton(this.exporting ? '导出中...' : '导出', true, 254, () => {
        this.normalizeTime(true);
        this.normalizeTime(false);
        this.exportHistory();
      })
      this.actionButton('返回', false, 432, () => router.back())
      Text(this.clock)
        .width(this.s(188)).height(this.s(59))
        .fontSize(`${this.s(18)}vp`).fontFamily(QT_FONT).fontColor('#111111')
        .textAlign(TextAlign.End).maxLines(1)
        .position({ x: this.s(650), y: this.s(1) })
    }
    .width('100%').height(this.s(61)).backgroundColor('#D5D5D5')
    .border({ width: this.s(1), color: '#222222' })
  }

  @Builder
  private calendarPopup() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row().width('100%').height('100%').backgroundColor('#00000000')
      QtHistoryDateDialog({
        uiScale: this.uiScale, dialogHeight: this.calendarHeight(),
        selectedDate: this.calendarForStart ? this.start : this.end,
        onAccept: (date: Date) => this.acceptDate(date),
        onCancel: () => this.calendarVisible = false
      })
        .position({ x: this.s(this.calendarForStart ? 76 : 394), y: this.s(155) })
    }
    .width('100%').height('100%')
  }

  @Builder
  private feedbackDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Row().width('100%').height('100%').backgroundColor('#00000000')
      Column({ space: this.s(6) }) {
        Row({ space: this.s(19) }) {
          Image(this.feedbackInformation ? $rawfile('history/qt-information.png') : $rawfile('history/qt-warning.png'))
            .width(this.s(32)).height(this.s(32))
          Scroll() {
            Text(this.feedbackMessage)
              .width('100%').fontSize(`${this.s(20)}vp`).fontFamily(QT_FONT).fontColor('#111111')
          }.constraintSize({ maxHeight: this.s(160) }).width(this.s(this.feedbackWidth - 73))
        }
        .width('100%').alignItems(VerticalAlign.Top)
        Button('OK', { type: ButtonType.Normal })
          .width(this.s(29)).height(this.s(40)).padding(0)
          .fontSize(`${this.s(18)}vp`).fontFamily(QT_FONT).fontColor('#111111')
          .fontWeight(FontWeight.Normal)
          .backgroundColor('#BCBCBC').border({ width: this.s(1), color: '#444444' })
          .borderRadius(this.s(12)).stateEffect(false)
          .onClick(() => this.feedbackVisible = false)
      }
      .width(this.s(this.feedbackWidth)).padding(this.s(11)).backgroundColor('#EFEBE7')
      .accessibilityText(this.feedbackTitle)
    }
    .width('100%').height('100%')
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 0 }) {
        this.headerBar()
        this.contentArea()
        this.footerBar()
      }
      .width('100%').height('100%')
      if (this.calendarVisible) this.calendarPopup()
      if (this.feedbackVisible) this.feedbackDialog()
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) this.uiScale = width / 854;
      this.pageHeight = Number(newArea.height);
    })
  }
}
