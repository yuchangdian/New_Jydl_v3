const QT_FONT: string = 'Microsoft YaHei, SimHei, Noto Sans CJK SC, sans-serif';
const MONTH_NAMES: string[] = ['一月', '二月', '三月', '四月', '五月', '六月',
  '七月', '八月', '九月', '十月', '十一月', '十二月'];
const WEEKDAY_NAMES: string[] = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

export interface HistoryCalendarDay {
  date: Date;
  inMonth: boolean;
}

export interface HistoryCalendarWeek {
  number: number;
  days: HistoryCalendarDay[];
}

function isoWeek(date: Date): number {
  const day = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  day.setUTCDate(day.getUTCDate() + 4 - (day.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(day.getUTCFullYear(), 0, 1));
  return Math.ceil(((day.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}

export function buildHistoryCalendarWeeks(year: number, month: number): HistoryCalendarWeek[] {
  const first = new Date(year, month, 1);
  const weekdayOffset = (first.getDay() + 6) % 7;
  // Qt 的六周视图在一号为周一时，第一行仍显示上一周。
  const offset = weekdayOffset === 0 ? 7 : weekdayOffset;
  const weeks: HistoryCalendarWeek[] = [];
  for (let row = 0; row < 6; row++) {
    const days: HistoryCalendarDay[] = [];
    for (let column = 0; column < 7; column++) {
      const date = new Date(year, month, 1 - offset + row * 7 + column);
      days.push({ date: date, inMonth: date.getMonth() === month });
    }
    weeks.push({ number: isoWeek(days[0].date), days: days });
  }
  return weeks;
}

@Component
export struct QtHistoryDateDialog {
  @Prop uiScale: number = 1;
  @Prop dialogHeight: number = 325;
  @Prop selectedDate: Date = new Date();
  onAccept: (date: Date) => void = () => {};
  onCancel: () => void = () => {};
  @State private shownYear: number = 2026;
  @State private shownMonth: number = 0;
  @State private pendingDate: Date = new Date();
  @State private weeks: HistoryCalendarWeek[] = [];
  @State private monthMenuVisible: boolean = false;
  @State private yearEditing: boolean = false;
  @State private yearDraft: string = '';
  @State private pressedButton: string = '';

  aboutToAppear(): void {
    this.pendingDate = new Date(this.selectedDate.getTime());
    this.shownYear = this.pendingDate.getFullYear();
    this.shownMonth = this.pendingDate.getMonth();
    this.refreshWeeks();
  }

  private s(value: number): number { return value * this.uiScale; }

  private refreshWeeks(): void {
    this.weeks = buildHistoryCalendarWeeks(this.shownYear, this.shownMonth);
    this.yearDraft = this.shownYear.toString();
  }

  private moveMonth(delta: number): void {
    const next = new Date(this.shownYear, this.shownMonth + delta, 1);
    if (next.getFullYear() < 1752 || next.getFullYear() > 9999) return;
    this.shownYear = next.getFullYear();
    this.shownMonth = next.getMonth();
    this.monthMenuVisible = false;
    this.refreshWeeks();
  }

  private commitYear(): void {
    const year = Number(this.yearDraft);
    if (Number.isInteger(year) && year >= 1752 && year <= 9999) this.shownYear = year;
    this.yearEditing = false;
    this.refreshWeeks();
  }

  private stepYear(delta: number): void {
    const next = this.shownYear + delta;
    if (next < 1752 || next > 9999) return;
    this.shownYear = next;
    this.refreshWeeks();
    this.yearEditing = true;
  }

  private isSelected(date: Date): boolean {
    return date.getFullYear() === this.pendingDate.getFullYear() &&
      date.getMonth() === this.pendingDate.getMonth() && date.getDate() === this.pendingDate.getDate();
  }

  private chooseDay(day: HistoryCalendarDay): void {
    this.pendingDate = new Date(day.date.getTime());
    if (!day.inMonth) {
      this.shownYear = day.date.getFullYear();
      this.shownMonth = day.date.getMonth();
      this.refreshWeeks();
    }
  }

  @Builder
  private navigationBar() {
    Row() {
      Image($rawfile('history/qt-calendar-prevmonth.png'))
        .width(this.s(19)).height(this.s(19))
        .margin({ left: this.s(3.5), right: this.s(3.5) })
        .onClick(() => this.moveMonth(-1))
        .accessibilityText('上个月')
      Blank().layoutWeight(1)
      Text(MONTH_NAMES[this.shownMonth] + '、')
        .width(this.s(51)).height('100%')
        .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT).fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.yearEditing = false;
          this.monthMenuVisible = !this.monthMenuVisible;
        })
      if (this.yearEditing) {
        Row() {
          TextInput({ text: this.yearDraft })
            .width(this.s(43)).height(this.s(28)).padding(this.s(2))
            .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT).fontColor('#111111')
            .backgroundColor('#FFFFFF').borderRadius(0)
            .type(InputType.Number).maxLength(4).enableKeyboardOnFocus(false)
            .onChange((value: string) => this.yearDraft = value)
            .onSubmit(() => this.commitYear())
          Column() {
            Text('▴').width(this.s(14)).height(this.s(14))
              .fontSize(`${this.s(10)}vp`).textAlign(TextAlign.Center).fontColor('#111111')
              .onClick(() => this.stepYear(1)).accessibilityText('增加年份')
            Text('▾').width(this.s(14)).height(this.s(14))
              .fontSize(`${this.s(10)}vp`).textAlign(TextAlign.Center).fontColor('#111111')
              .onClick(() => this.stepYear(-1)).accessibilityText('减少年份')
          }.backgroundColor('#ECECEC')
        }.width(this.s(57)).height(this.s(28))
      } else {
        Text(this.shownYear.toString())
          .width(this.s(57)).height('100%')
          .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT).fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .onClick(() => { this.monthMenuVisible = false; this.yearEditing = true; })
      }
      Blank().layoutWeight(1)
      Image($rawfile('history/qt-calendar-nextmonth.png'))
        .width(this.s(19)).height(this.s(19))
        .margin({ left: this.s(3.5), right: this.s(3.5) })
        .onClick(() => this.moveMonth(1))
        .accessibilityText('下个月')
    }
    .width('100%').height(this.s(28)).backgroundColor('#308CC6')
  }

  @Builder
  private calendarGrid() {
    Column() {
      Row() {
        ForEach(WEEKDAY_NAMES, (name: string, index: number) => {
          Text(name)
            .width(this.s(346 / 8)).height('100%')
            .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT)
            .fontColor(index >= 6 ? '#FF0000' : '#000000')
            .textAlign(TextAlign.Center).backgroundColor('#ECECEC')
            .border({ width: { right: this.s(1), bottom: this.s(1) }, color: '#B4B4B4' })
        }, (_name: string, index: number) => index.toString())
      }
      .height(this.s((this.dialogHeight - 109) / 7))
      ForEach(this.weeks, (week: HistoryCalendarWeek) => {
        Row() {
          Text(week.number.toString())
            .width(this.s(346 / 8)).height('100%')
            .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT).fontColor('#000000')
            .textAlign(TextAlign.Center).backgroundColor('#ECECEC')
            .border({ width: { right: this.s(1), bottom: this.s(1) }, color: '#B4B4B4' })
          ForEach(week.days, (day: HistoryCalendarDay, index: number) => {
            Stack({ alignContent: Alignment.TopStart }) {
              Text(day.date.getDate().toString())
                .width('100%').height('100%')
                .fontSize(`${this.s(16)}vp`).fontFamily(QT_FONT)
                .fontColor(this.isSelected(day.date) ? '#FFFFFF' :
                  !day.inMonth ? '#BEBEBE' : index >= 5 ? '#FF0000' : '#000000')
                .textAlign(TextAlign.Center)
              if (this.isSelected(day.date)) {
                Rect().width(this.s(346 / 8 - 2)).height(this.s((this.dialogHeight - 109) / 7 - 2))
                  .fill('#00000000').stroke('#FFFFFF').strokeWidth(this.s(1))
                  .strokeDashArray([this.s(1), this.s(2)])
                  .position({ x: this.s(1), y: this.s(1) })
                  .hitTestBehavior(HitTestMode.None)
              }
            }
              .width(this.s(346 / 8)).height('100%')
              .backgroundColor(this.isSelected(day.date) ? '#308CC6' : '#FFFFFF')
              .border({ width: { right: this.s(1), bottom: this.s(1) }, color: '#B4B4B4' })
              .onClick(() => { this.monthMenuVisible = false; this.chooseDay(day); })
              .parallelGesture(TapGesture({ count: 2 }).onAction(() => this.onAccept(day.date)))
          }, (day: HistoryCalendarDay) => day.date.getTime().toString())
        }
        .height(this.s((this.dialogHeight - 109) / 7))
      }, (week: HistoryCalendarWeek) => week.days[0].date.getTime().toString())
    }
    .width(this.s(346)).height(this.s(this.dialogHeight - 109))
    .border({ width: { left: this.s(1) }, color: '#B4B4B4' })
  }

  @Builder
  private dialogButton(label: string, key: string, action: () => void) {
    Button(label, { type: ButtonType.Normal })
      .width(this.s(98)).height(this.s(48)).padding(0)
      .fontSize(`${this.s(22)}vp`).fontFamily(QT_FONT).fontColor('#111111')
      .fontWeight(FontWeight.Normal)
      .backgroundColor(this.pressedButton === key ? '#A7D6E7' : '#BCBCBC')
      .border({ width: this.s(1), color: '#444444' }).borderRadius(this.s(14))
      .stateEffect(false)
      .onTouch((event: TouchEvent) => {
        this.pressedButton = event.type === TouchType.Down ? key : '';
      })
      .onClick(action)
  }

  @Builder
  private monthMenu() {
    Column({ space: this.s(4) }) {
      ForEach([0, 1, 2, 3, 4, 5], (row: number) => {
        Row({ space: this.s(4) }) {
          ForEach([row * 2, row * 2 + 1], (index: number) => {
            Button(`${index + 1}月`, { type: ButtonType.Normal })
              .width(this.s(72)).height(this.s(40)).padding(0)
              .fontSize(`${this.s(18)}vp`).fontFamily(QT_FONT).fontColor('#111111')
              .fontWeight(FontWeight.Normal)
              .backgroundColor('#BCBCBC')
              .border({ width: this.s(1), color: '#444444' }).borderRadius(this.s(12))
              .stateEffect(false)
              .onClick(() => {
                this.shownMonth = index;
                this.monthMenuVisible = false;
                this.refreshWeeks();
              })
          }, (index: number) => index.toString())
        }
      }, (row: number) => row.toString())
    }
    .padding(this.s(9)).width(this.s(166)).height(this.s(278))
    .backgroundColor('#FFFFFF').border({ width: this.s(1), color: '#A0A0A0' })
    .position({ x: this.s(132), y: this.s(41) })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 0 }) {
        this.navigationBar()
        this.calendarGrid()
      }
      .width(this.s(346)).position({ x: this.s(13), y: this.s(13) })
      Row({ space: this.s(6) }) {
        this.dialogButton('确定', 'accept', () => this.onAccept(this.pendingDate))
        this.dialogButton('取消', 'cancel', () => this.onCancel())
      }
      .position({ x: this.s(85), y: this.s(this.dialogHeight - 61) })
      if (this.monthMenuVisible) this.monthMenu()
    }
    .width(this.s(372)).height(this.s(this.dialogHeight)).backgroundColor('#EFEBE7')
  }
}
