import router from '@ohos.router';
import { Jybsmr131NumericField, Jybsmr131PacketValue } from 'libentry.so';
import { DEFAULT_PASSWORD } from '../common/GlobalState';
import { QtAlarmSettingSelect } from '../components/QtAlarmSettingSelect';
import { PowerQualityAlarmSettingRow } from '../components/PowerQualityAlarmSettingRow';
import {
  buildPowerQualitySettingFields,
  createPowerQualityAlarmRows,
  packetMatchesFields,
  PowerQualityAlarmRow,
  readPacketValue,
  validatePowerQualitySetting
} from '../models/PowerQualityAlarmSetting';
import { Jybsmr131Protocol, Jybsmr131SettingAddress } from '../protocol/Jybsmr131';

const VOLTAGE_REFERENCE_OPTIONS: SelectOption[] = [{ value: '额定电压' }, { value: '滑动参考电压' }];
const RECORD_FREQUENCY_OPTIONS: SelectOption[] = [
  { value: '50kHz' }, { value: '25kHz' }, { value: '12.5kHz' }, { value: '10kHz' }, { value: '5kHz' }
];

@Entry
@Component
export struct CommonSetting_PowerQuality_Set {
  @State uiScale: number = 1;
  @State dateText: string = '';
  @State timeText: string = '';
  @State noticeText: string = '';
  @State statusText: string = '正在读取装置定值...';
  @State readingSetting: boolean = false;
  @State voltageReferenceIndex: number = 0;
  @State recordFrequencyIndex: number = 0;
  @State normalRecordLength: string = '0.00';
  @State violationRecordLength: string = '0.00';
  @State rows: PowerQualityAlarmRow[] = createPowerQualityAlarmRows();
  @State passwordVisible: boolean = false;
  @State passwordInput: string = '';
  @State confirmVisible: boolean = false;
  @State waitingVisible: boolean = false;
  @State feedbackVisible: boolean = false;
  @State feedbackTitle: string = '提示';
  @State feedbackMessage: string = '';

  private readonly designWidth: number = 854;
  private clockTimer: number = -1;
  private loadTimer: number = -1;
  private confirmTimer: number = -1;
  private baselineRevision: number = 0;
  private baselineSessionId: number = 0;
  private settingLoaded: boolean = false;
  private confirmPollCount: number = 0;
  private pendingFields: Jybsmr131NumericField[] = [];

  aboutToAppear(): void {
    this.updateClock();
    this.clockTimer = setInterval(() => this.updateClock(), 1000);
    this.requestSetting();
  }

  aboutToDisappear(): void {
    this.stopTimer(this.clockTimer);
    this.stopTimer(this.loadTimer);
    this.stopTimer(this.confirmTimer);
  }

  private s(value: number): number {
    return value * this.uiScale;
  }

  private stopTimer(timerId: number): void {
    if (timerId >= 0) clearInterval(timerId);
  }

  private updateClock(): void {
    const now = new Date();
    this.dateText = `${now.getFullYear()}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getDate().toString().padStart(2, '0')}`;
    this.timeText = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
  }

  private requestSetting(): void {
    const previous = Jybsmr131Protocol.setting(Jybsmr131SettingAddress.PowerQuality);
    if (!Jybsmr131Protocol.requestSetting(Jybsmr131SettingAddress.PowerQuality)) {
      this.statusText = '读取请求发送失败，请检查设备连接';
      return;
    }
    this.readingSetting = true;
    let count = 0;
    this.loadTimer = setInterval(() => {
      const packet = Jybsmr131Protocol.setting(Jybsmr131SettingAddress.PowerQuality);
      if (packet.ready && (packet.sessionId !== previous.sessionId || packet.revision > previous.revision)) {
        this.stopTimer(this.loadTimer);
        this.loadTimer = -1;
        this.readingSetting = false;
        this.applyPacket(packet);
        this.statusText = '已读取装置定值';
      } else if (++count >= 10) {
        this.stopTimer(this.loadTimer);
        this.loadTimer = -1;
        this.readingSetting = false;
        this.statusText = '未收到装置定值，当前内容不可提交';
      }
    }, 200);
  }

  private applyPacket(packet: Jybsmr131PacketValue): void {
    const reference = readPacketValue(packet, 'VoltageRef_SegSwell');
    const normal = readPacketValue(packet, 'RecoedSize_Normal');
    const violation = readPacketValue(packet, 'RecoedSize_Violation');
    this.voltageReferenceIndex = reference === 1 ? 1 : 0;
    if (normal !== undefined) this.normalRecordLength = normal.toFixed(2);
    if (violation !== undefined) this.violationRecordLength = violation.toFixed(2);
    this.rows.forEach((row: PowerQualityAlarmRow) => {
      const enabled = readPacketValue(packet, `${row.key}.Enable`);
      const value = readPacketValue(packet, `${row.key}.ActValue`);
      if (enabled !== undefined) row.enabled = enabled === 1 ? '投入' : '退出';
      // 与 Qt QString::number 的默认六位有效数字一致，避免显示 float 尾差。
      if (value !== undefined) row.value = Number(value.toPrecision(6)).toString();
    });
    this.rows = this.rows.slice();
    this.baselineRevision = packet.revision;
    this.baselineSessionId = packet.sessionId;
    this.settingLoaded = true;
    this.noticeText = '';
  }

  private markChanged(): void {
    this.noticeText = '温馨提醒：定值已被改动！';
  }

  private verifyPassword(): void {
    if (this.passwordInput.length === 0) {
      this.showFeedback('提示', '请输入密码');
      return;
    }
    if (this.passwordInput !== DEFAULT_PASSWORD) {
      this.showFeedback('提示', '密码错误');
      return;
    }
    const errors = validatePowerQualitySetting(this.normalRecordLength, this.violationRecordLength, this.rows);
    if (errors.length > 0) {
      this.passwordVisible = false;
      this.showFeedback('输入超出范围', errors.join('\n'));
      return;
    }
    this.passwordVisible = false;
    this.confirmVisible = true;
  }

  private sendSetting(): void {
    this.confirmVisible = false;
    const packet = Jybsmr131Protocol.setting(Jybsmr131SettingAddress.PowerQuality);
    if (!packet.ready || !this.settingLoaded || packet.sessionId !== this.baselineSessionId) {
      this.showFeedback('修改失败', '尚未收到装置定值，请检查设备连接。');
      return;
    }
    this.baselineRevision = packet.revision;
    this.pendingFields = buildPowerQualitySettingFields(
      this.voltageReferenceIndex, this.normalRecordLength, this.violationRecordLength, this.rows
    );
    if (!Jybsmr131Protocol.updateSetting(Jybsmr131SettingAddress.PowerQuality, this.pendingFields)) {
      this.showFeedback('修改失败', '定值报文发送失败，请检查设备连接。');
      return;
    }
    this.waitingVisible = true;
    this.confirmPollCount = 0;
    this.confirmTimer = setInterval(() => this.pollConfirmation(), 200);
  }

  private pollConfirmation(): void {
    const packet = Jybsmr131Protocol.setting(Jybsmr131SettingAddress.PowerQuality);
    if (packet.sessionId !== this.baselineSessionId) {
      this.stopTimer(this.confirmTimer);
      this.confirmTimer = -1;
      this.waitingVisible = false;
      this.showFeedback('修改失败', '设备连接已变化，请重新进入页面读取定值。');
      return;
    }
    if (packet.ready && packet.revision > this.baselineRevision) {
      this.stopTimer(this.confirmTimer);
      this.confirmTimer = -1;
      this.waitingVisible = false;
      if (packetMatchesFields(packet, this.pendingFields)) {
        this.applyPacket(packet);
        this.statusText = '修改成功';
        this.showFeedback('提示', '修改成功');
      } else {
        this.showFeedback('修改失败', '装置回包与提交的定值不一致。');
      }
      return;
    }
    if (++this.confirmPollCount >= 10) {
      this.stopTimer(this.confirmTimer);
      this.confirmTimer = -1;
      this.waitingVisible = false;
      this.showFeedback('修改失败', '装置未在 2 秒内确认本次修改。');
    }
  }

  private showFeedback(title: string, message: string): void {
    this.feedbackTitle = title;
    this.feedbackMessage = message;
    this.feedbackVisible = true;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        this.HeaderBar();
        this.ContentArea();
        this.BottomBar();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF');

      if (this.passwordVisible) this.PasswordDialog();
      if (this.confirmVisible) this.ConfirmDialog();
      if (this.waitingVisible) this.WaitingDialog();
      if (this.feedbackVisible) this.FeedbackDialog();
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) this.uiScale = width / this.designWidth;
    });
  }

  @Builder
  HeaderBar() {
    Row() {
      Row({ space: this.s(3) }) {
        Rect().width(this.s(5)).height(this.s(19)).fill('#657F32');
        Rect().width(this.s(5)).height(this.s(13)).fill('#657F32');
        Rect().width(this.s(5)).height(this.s(7)).fill('#657F32');
      }
      .width(this.s(24)).height(this.s(27)).alignItems(VerticalAlign.Bottom);
      Text('告警定值　整定')
        .layoutWeight(1)
        .fontSize(this.s(20))
        .fontWeight(FontWeight.Normal)
        .fontColor('#003F9E')
        .textAlign(TextAlign.Center);
      Blank().width(this.s(24));
    }
    .width('100%')
    .height(this.s(44))
    .padding({ left: this.s(18), right: this.s(18) })
    .backgroundColor('#12A9DC')
    .border({ width: this.s(1), color: '#202020' });
  }

  @Builder
  ContentArea() {
    Scroll() {
      Column() {
        this.VoltageReferenceRow();
        this.RecordFrequencyRow();
        this.RecordLengthRow();
        ForEach(this.rows, (row: PowerQualityAlarmRow) => {
          PowerQualityAlarmSettingRow({ row: row, uiScale: this.uiScale,
            onChanged: () => this.markChanged() });
        }, (row: PowerQualityAlarmRow) => row.key);
        // Qt scrollAreaWidgetContents 的末尾留白。
        Row().height(this.s(124)).width('100%');
      }
      .width('100%')
      .padding({ right: this.s(8) });
    }
    .width('100%')
    .layoutWeight(1)
    .enabled(!this.readingSetting)
    .scrollBar(BarState.On)
    .scrollBarWidth(this.s(8))
    .scrollBarColor('#C0C0C0')
    .edgeEffect(EdgeEffect.None);
  }

  @Builder
  RowTitle(title: string) {
    Text('【' + title + '】')
      .width(this.s(220))
      .fontSize(this.s(18))
      .fontWeight(FontWeight.Normal)
      .fontColor('#111111')
      .maxLines(1)
      .minFontSize(this.s(15))
      .maxFontSize(this.s(18))
      .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST);
  }

  @Builder
  VoltageReferenceRow() {
    Row({ space: this.s(8) }) {
      this.RowTitle('电压暂降/暂升参考值');
      QtAlarmSettingSelect({ options: VOLTAGE_REFERENCE_OPTIONS, selectedIndex: this.voltageReferenceIndex,
        controlWidth: 200, uiScale: this.uiScale, onSelect: (index: number) => {
          if (this.voltageReferenceIndex !== index) {
            this.voltageReferenceIndex = index;
            this.markChanged();
          }
        }
      });
    }
    .width('100%').height(this.s(50))
    .padding({ left: this.s(4), right: this.s(4) })
    .border({ width: { bottom: this.s(1) }, color: '#5D5D5D', style: BorderStyle.Dashed });
  }

  @Builder
  RecordFrequencyRow() {
    Row({ space: this.s(8) }) {
      this.RowTitle('录波频率');
      // Qt 未给录波频率接入结构字段，保留原位置和外观，固定显示。
      Row() {
        Text(RECORD_FREQUENCY_OPTIONS[this.recordFrequencyIndex].value)
          .layoutWeight(1).fontSize(this.s(16)).fontColor('#111111');
        this.SelectArrow();
      }
      .width(this.s(200)).height(this.s(38))
      .padding({ left: this.s(4), right: this.s(4) })
      .backgroundColor('#FFFFFF')
      .border({ width: this.s(1), color: '#999999' })
      .borderRadius(this.s(3))
      .accessibilityText('录波频率 50kHz，当前协议只读');
    }
    .width('100%').height(this.s(50))
    .padding({ left: this.s(4), right: this.s(4) })
    .border({ width: { bottom: this.s(1) }, color: '#5D5D5D', style: BorderStyle.Dashed });
  }

  @Builder
  SelectArrow() {
    Polygon({ width: this.s(7), height: this.s(4) })
      .points([[0, 0], [this.s(7), 0], [this.s(3.5), this.s(4)]])
      .fill('#111111');
  }

  @Builder
  RecordLengthRow() {
    Row({ space: this.s(8) }) {
      this.RowTitle('录波长度');
      Text('正常状态时间：').width(this.s(126)).fontSize(this.s(18)).fontColor('#111111');
      TextInput({ text: this.normalRecordLength })
        .width(this.s(70)).height(this.s(38))
        .padding({ left: this.s(3), right: this.s(3), top: 0, bottom: 0 })
        .type(InputType.NUMBER_DECIMAL).fontSize(this.s(18)).fontColor('#111111')
        .backgroundColor('#FFFFFF')
        .border({ width: this.s(1), color: '#999999' }).borderRadius(this.s(3))
        .onChange((text: string) => {
          if (text !== this.normalRecordLength) {
            this.normalRecordLength = text;
            this.markChanged();
          }
        });
      Text('毫秒').width(this.s(80)).fontSize(this.s(18)).fontColor('#111111');
      Blank().layoutWeight(1);
      Text('越限状态时间：').width(this.s(126)).fontSize(this.s(18)).fontColor('#111111');
      TextInput({ text: this.violationRecordLength })
        .width(this.s(70)).height(this.s(38))
        .padding({ left: this.s(3), right: this.s(3), top: 0, bottom: 0 })
        .type(InputType.NUMBER_DECIMAL).fontSize(this.s(18)).fontColor('#111111')
        .backgroundColor('#FFFFFF')
        .border({ width: this.s(1), color: '#999999' }).borderRadius(this.s(3))
        .onChange((text: string) => {
          if (text !== this.violationRecordLength) {
            this.violationRecordLength = text;
            this.markChanged();
          }
        });
      Text('毫秒').width(this.s(80)).fontSize(this.s(18)).fontColor('#111111');
    }
    .width('100%').height(this.s(50))
    .padding({ left: this.s(4), right: this.s(4) })
    .border({ width: { bottom: this.s(1) }, color: '#5D5D5D', style: BorderStyle.Dashed });
  }

  @Builder
  BottomBar() {
    // 以原 Qt 854 px 底栏的坐标等比布局，日期和时间保持横排。
    Stack({ alignContent: Alignment.TopStart }) {
      Text(this.noticeText.length > 0 ? this.noticeText :
        (this.statusText === '已读取装置定值' ? '' : this.statusText))
        .width(this.s(155)).height(this.s(47))
        .position({ x: this.s(31), y: this.s(1) })
        .fontSize(this.s(13)).fontColor('#D90000')
        .maxLines(2);
      Row() {
        this.ActionButton('确定', () => { this.passwordInput = ''; this.passwordVisible = true; });
      }.position({ x: this.s(234), y: this.s(4) });
      Row() {
        this.ActionButton('返回', () => router.back());
      }.position({ x: this.s(440), y: this.s(4) });
      Text(this.dateText).width(this.s(88)).height(this.s(47))
        .position({ x: this.s(643), y: this.s(1) })
        .fontSize(this.s(15)).fontColor('#111111').textAlign(TextAlign.End).maxLines(1);
      Text(this.timeText).width(this.s(76)).height(this.s(47))
        .position({ x: this.s(737), y: this.s(1) })
        .fontSize(this.s(15)).fontColor('#111111').textAlign(TextAlign.End).maxLines(1);
    }
    .width('100%').height(this.s(49)).backgroundColor('#D5D5D5')
    .border({ width: this.s(1), color: '#222222' });
  }

  @Builder
  PasswordDialog() {
    this.DialogMask();
    Column() {
      Text('请输入操作密码').fontSize(this.s(20)).fontWeight(FontWeight.Bold).margin({ bottom: this.s(16) });
      TextInput({ text: this.passwordInput, placeholder: '请输入密码' })
        .width('100%').height(this.s(42)).type(InputType.Password).fontSize(this.s(17))
        .backgroundColor('#FFFFFF').border({ width: 1, color: '#7B8A91' })
        .onChange((value: string) => this.passwordInput = value);
      Row() {
        this.DialogButton('取消', () => { this.passwordVisible = false; this.passwordInput = ''; });
        this.DialogButton('确定', () => this.verifyPassword());
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: this.s(18) });
    }
    .width(this.s(340)).padding(this.s(22)).backgroundColor('#F7F7F7')
    .border({ width: 1, color: '#7B8A91' }).borderRadius(this.s(5));
  }

  @Builder
  ConfirmDialog() {
    this.DialogMask();
    Column() {
      Text('电能质量告警定值已被改动').fontSize(this.s(20)).fontWeight(FontWeight.Bold);
      Text('请再次确认是否保存新《电能质量告警定值》！')
        .fontSize(this.s(17)).textAlign(TextAlign.Center).margin({ top: this.s(14), bottom: this.s(20) });
      Row() {
        this.DialogButton('取消', () => this.confirmVisible = false);
        this.DialogButton('确定', () => this.sendSetting());
      }.width('100%').justifyContent(FlexAlign.SpaceBetween);
    }
    .width(this.s(430)).padding(this.s(22)).backgroundColor('#F7F7F7')
    .border({ width: 1, color: '#7B8A91' }).borderRadius(this.s(5));
  }

  @Builder
  WaitingDialog() {
    this.DialogMask();
    Column() {
      LoadingProgress().width(this.s(42)).height(this.s(42)).color('#12A9DC');
      Text('正在改动电能质量告警定值\n等待修改完毕......')
        .fontSize(this.s(18)).textAlign(TextAlign.Center).margin({ top: this.s(16) });
    }
    .width(this.s(360)).padding(this.s(24)).backgroundColor('#F7F7F7')
    .border({ width: 1, color: '#7B8A91' }).borderRadius(this.s(5));
  }

  @Builder
  FeedbackDialog() {
    this.DialogMask();
    Column() {
      Text(this.feedbackTitle).fontSize(this.s(20)).fontWeight(FontWeight.Bold);
      Scroll() {
        Text(this.feedbackMessage).width('100%').fontSize(this.s(16)).textAlign(TextAlign.Center);
      }
      .width('100%').constraintSize({ maxHeight: this.s(240) })
      .margin({ top: this.s(14), bottom: this.s(20) });
      this.DialogButton('确定', () => this.feedbackVisible = false);
    }
    .width(this.s(460)).padding(this.s(22)).backgroundColor('#F7F7F7')
    .border({ width: 1, color: '#7B8A91' }).borderRadius(this.s(5));
  }

  @Builder
  DialogMask() {
    Row().width('100%').height('100%').backgroundColor('#66000000');
  }

  @Builder
  DialogButton(text: string, action: () => void) {
    Button(text).width(this.s(125)).height(this.s(40)).fontSize(this.s(17)).fontColor('#101010')
      .backgroundColor('#D8DDE0').borderRadius(this.s(3)).onClick(() => action());
  }

  @Builder
  ActionButton(text: string, action: () => void) {
    Button(text, { type: ButtonType.Normal })
      .width(this.s(155)).height(this.s(40)).fontSize(this.s(20))
      .fontWeight(FontWeight.Normal).fontColor('#111111')
      .backgroundColor('#BCBCBC').border({ width: this.s(1), color: '#222222' })
      .borderRadius(this.s(14)).onClick(() => action());
  }
}
