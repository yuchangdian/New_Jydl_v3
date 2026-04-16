import router from '@ohos.router';
import display from '@ohos.display';

@Observed
class BottomActionState {
  confirmText: string = '确认';
  closeText: string = '关闭';
  backText: string = '返回';
}

@Observed
class PasswordSetVM {
  noticeText: string = '';
  titleLeft: string = '装置设置—';
  titleRight: string = '密码设置';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

class PasswordSetFontSize {
  notice: number = 20;
  title: number = 22;
  label: number = 22;
  input: number = 22;
  bottomButton: number = 20;
  timeText: number = 20;
  titleMin: number = 14;
  noticeMin: number = 12;
  timeLineHeight: number = 24;
}

@Entry
@Component
export struct Password_Set {
  @State vm: PasswordSetVM = new PasswordSetVM();
  @State uiScale: number = 1;
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';

  private readonly fontSize: PasswordSetFontSize = new PasswordSetFontSize();
  private readonly pageBaseWidth: number = 1280;
  private readonly pageBaseHeight: number = 720;
  private readonly layoutZoom: number = 1.2;
  private readonly pageMaxWidth: number = 1024;
  private readonly headerHeight: number = 81;
  private readonly footerHeight: number = 91;
  private readonly headerButtonWidth: number = 81;
  private readonly headerButtonHeight: number = 61;
  private readonly formWidth: number = 490;
  private readonly labelWidth: number = 278;
  private readonly labelHeight: number = 40;
  private readonly inputWidth: number = 200;
  private readonly inputHeight: number = 40;
  private readonly formTopSpace: number = 89;
  private readonly formMiddleSpace: number = 60;
  private readonly formShiftLeft: number = 56;
  private readonly bottomButtonWidth: number = 111;
  private readonly bottomButtonHeight: number = 61;
  private readonly bottomButtonRadius: number = 20;
  private readonly timeWidth: number = 194;
  private readonly inputBorderColor: string = '#B8B8B8';

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / this.pageBaseWidth;
      let sy = d.height / this.pageBaseHeight;
      let val = Math.min(sx, sy);
      this.uiScale = (val > 0 ? val : 1) * this.layoutZoom;
    } catch (error) {
      this.uiScale = this.layoutZoom;
    }
  }

  private getFieldValue(fieldKey: string): string {
    switch (fieldKey) {
      case 'old':
        return this.oldPassword;
      case 'new':
        return this.newPassword;
      case 'confirm':
        return this.confirmPassword;
      default:
        return '';
    }
  }

  private setFieldValue(fieldKey: string, value: string): void {
    switch (fieldKey) {
      case 'old':
        this.oldPassword = value;
        break;
      case 'new':
        this.newPassword = value;
        break;
      case 'confirm':
        this.confirmPassword = value;
        break;
      default:
        break;
    }
  }

  private handleConfirm(): void {
    console.info('Password_Set confirm clicked');
  }

  build() {
    Column() {
      Column() {
        this.HeaderBar();

        Column() {
          Blank().height(this.s(this.formTopSpace));
          this.PasswordRow('请输入旧密码：', 'old');
          Blank().height(this.s(this.formMiddleSpace));
          this.PasswordRow('请输入新密码：', 'new');
          Blank().height(this.s(this.formMiddleSpace));
          this.PasswordRow('请再次确认新密码：', 'confirm');
          Blank().layoutWeight(1);
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .alignItems(HorizontalAlign.Center)
        .margin({ right: this.s(this.formShiftLeft) });

        this.BottomBar();
      }
      .width('100%')
      .height('100%')
      .constraintSize({ maxWidth: this.s(this.pageMaxWidth) })
      .backgroundColor('#FFFFFF');
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Row() {
      Blank().width(this.s(10));

      Text(this.vm.noticeText)
        .width(this.s(291))
        .minFontSize(this.s(this.fontSize.noticeMin))
        .maxLines(1)
        .fontSize(this.s(this.fontSize.notice))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Blank().width(this.s(79));

      Text(this.vm.titleLeft)
        .width(this.s(151))
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center);

      Text(this.vm.titleRight)
        .width(this.s(141))
        .minFontSize(this.s(this.fontSize.titleMin))
        .fontSize(this.s(this.fontSize.title))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(1);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(37))
          .height(this.s(40));
      }
      .width(this.s(this.headerButtonWidth))
      .height(this.s(this.headerButtonHeight))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(32))
          .height(this.s(40));
      }
      .width(this.s(this.headerButtonWidth))
      .height(this.s(this.headerButtonHeight))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .borderRadius(0)
      .onClick(() => {
        router.back();
      });

      Blank().width(this.s(13));
    }
    .width('100%')
    .height(this.s(this.headerHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  PasswordRow(label: string, fieldKey: string) {
    Row() {
      Text(label)
        .width(this.s(this.labelWidth))
        .height(this.s(this.labelHeight))
        .fontSize(this.s(this.fontSize.label))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.End);

      Blank().width(this.s(10));

      this.PasswordInput(fieldKey);
    }
    .width(this.s(this.formWidth))
    .height(this.s(this.labelHeight))
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  PasswordInput(fieldKey: string) {
    Row() {
      TextInput({ text: this.getFieldValue(fieldKey), placeholder: '' })
        .layoutWeight(1)
        .height('100%')
        .fontSize(this.s(this.fontSize.input))
        .fontColor('#000000')
        .fontFamily('Noto Sans CJK SC')
        .backgroundColor('#FFFFFF')
        .border({ width: 0 })
        .padding({ left: this.s(8), right: this.s(8), top: 0, bottom: 0 })
        .textAlign(TextAlign.Start)
        .type(InputType.Password)
        .maxLength(20)
        .onChange((value: string) => {
          this.setFieldValue(fieldKey, value);
        });
    }
    .width(this.s(this.inputWidth))
    .height(this.s(this.inputHeight))
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: this.inputBorderColor })
    .borderRadius(0)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  BottomActionButton(label: string, action: () => void) {
    Button(label)
      .width(this.s(this.bottomButtonWidth))
      .height(this.s(this.bottomButtonHeight))
      .fontSize(this.s(this.fontSize.bottomButton))
      .fontColor('#000000')
      .fontFamily('STKaiti')
      .backgroundColor('#BEBEBE')
      .border({ width: 0 })
      .borderRadius(this.s(this.bottomButtonRadius))
      .padding(0)
      .onClick(() => {
        action();
      });
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().width(this.s(270));

      this.BottomActionButton(this.vm.actions.confirmText, () => {
        this.handleConfirm();
      });

      Blank().width(this.s(79));

      this.BottomActionButton(this.vm.actions.closeText, () => {
        router.back();
      });

      Blank().width(this.s(79));

      this.BottomActionButton(this.vm.actions.backText, () => {
        router.back();
      });

      Blank().layoutWeight(1);

      Text(this.vm.timeText)
        .width(this.s(this.timeWidth))
        .height(this.s(71))
        .fontSize(this.s(this.fontSize.timeText))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .lineHeight(this.s(this.fontSize.timeLineHeight))
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(this.s(this.footerHeight))
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
