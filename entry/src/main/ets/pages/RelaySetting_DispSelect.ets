import router from '@ohos.router';
import display from '@ohos.display';

@Observed
class BottomActionState {
  confirmText: string = '确认';
  closeText: string = '关闭';
  backText: string = '返回';
}

@Observed
class RelaySettingSelectVM {
  noticeText: string = '';
  titleLeft: string = '运行操作';
  titleRight: string = '\u2014\u6d4f\u89c8\u4fdd\u62a4\u5b9a\u503c';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

@Entry
@Component
export struct RelaySetting_DispSelect {
  @State vm: RelaySettingSelectVM = new RelaySettingSelectVM();
  @State uiScale: number = 1;
  @State zoneCode: string = '00';
  @State warningText: string = '';

  private readonly midFontSize: number = 18;
  private readonly titleFontSize: number = 20;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  aboutToAppear(): void {
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let val = Math.min(sx, sy);
      this.uiScale = val > 0 ? val : 1;
    } catch (e) {
      this.uiScale = 1;
    }
  }

  private normalizeZoneCode(): string | undefined {
    let trimmed = this.zoneCode.trim();
    if (trimmed.length === 0) {
      this.warningText = '\u8bf7\u8f93\u5165\u6d4f\u89c8\u533a\u53f7';
      return undefined;
    }

    if (!/^\d{1,2}$/.test(trimmed)) {
      this.warningText = '\u533a\u53f7\u4ec5\u652f\u6301 00-19';
      return undefined;
    }

    let normalized = trimmed.padStart(2, '0');
    let zoneIndex = Number(normalized);
    if (isNaN(zoneIndex) || zoneIndex < 0 || zoneIndex > 19) {
      this.warningText = '\u533a\u53f7\u4ec5\u652f\u6301 00-19';
      return undefined;
    }

    this.warningText = '';
    this.zoneCode = normalized;
    return normalized;
  }

  private openRelaySettingDisp(): void {
    let normalized = this.normalizeZoneCode();
    if (!normalized) {
      return;
    }

    router.pushUrl({
      url: 'pages/RelaySettingDisp',
      params: {
        zoneCode: normalized
      }
    }).catch((error: Error) => {
      console.error(`跳转失败，错误码：${error.name}，信息：${error.message}`);
    });
  }

  build() {
    Column() {
      this.HeaderBar();

      Column() {
        Column() {
          Row() {
            Text('\u8bf7\u8f93\u5165\u6d4f\u89c8\u533a\u53f7:')
              .width('auto')
              .height(this.s(81))
              .fontSize(this.s(this.midFontSize + 4))
              .fontColor('#000000')
              .fontFamily('STKaiti')
              .textAlign(TextAlign.Center)
              .margin({ right: this.s(8) });
            TextInput({ text: this.zoneCode, placeholder: '' })
              .width(this.s(81))
              .height(this.s(41))
              .fontSize(this.s(this.midFontSize))
              .fontColor('#000000')
              .fontFamily('monospace')
              .backgroundColor('#FFFFFF')
              .border({ width: 1, color: '#909090' })
              .textAlign(TextAlign.Center)
              .type(InputType.Number)
              .maxLength(2)
              .onChange((value: string) => {
                this.zoneCode = value;
                this.warningText = '';
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center);

          Text(this.warningText)
            .width(this.s(300))
            .height(this.s(50))
            .fontSize(this.s(18))
            .fontColor('#EF2929')
            .fontFamily('STKaiti')
            .textAlign(TextAlign.Center)
            .margin({ top: this.s(40) });
        }
        .width(this.s(1001))
        .alignItems(HorizontalAlign.Center);
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF');

      this.BottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(260)
        .minFontSize(12)
        .maxLines(1)
        .fontSize(this.s(18))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(55);

      Text(this.vm.titleLeft)
        .layoutWeight(135)
        .fontSize(this.s(this.titleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(175)
        .fontSize(this.s(this.titleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(275);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(24))
          .height(this.s(24));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(20))
          .height(this.s(20));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(10), right: this.s(10), top: this.s(8), bottom: this.s(8) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(270);

      Button(this.vm.actions.confirmText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          this.openRelaySettingDisp();
        });

      Blank().layoutWeight(80);

      Button(this.vm.actions.closeText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(80);

      Button(this.vm.actions.backText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(100);

      Text(this.vm.timeText)
        .layoutWeight(160)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .padding({ top: this.s(2), bottom: this.s(2) });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ top: this.s(8), bottom: this.s(6) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
