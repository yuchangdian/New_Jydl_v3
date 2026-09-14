// common/BottomActionBar.ets
import router from '@ohos.router';

@Component
export struct BottomActionBar {
  @Prop confirmText: string = '确认';
  @Prop closeText: string = '关闭';
  @Prop backText: string = '返回';
  @Prop showTime: boolean = true;
  @Prop midFontSize: number = 24;
  @Prop scaleValue: number = 1;  // 传递缩放值而不是函数

  @State currentTime: string = '';  // 动态时间状态

  onConfirm?: () => void;
  onClose?: () => void;
  onBack?: () => void;

  private timerId: number = -1;

  // 创建缩放函数
  private s(v: number): number {
    return Math.round(v * this.scaleValue);
  }

  // 格式化时间
  private formatTime(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${year}/${month}/${day}\n${hours}:${minutes}:${seconds}`;
  }

  // 更新时间
  private updateTime(): void {
    const now = new Date();
    this.currentTime = this.formatTime(now);
  }

  // 启动定时器
  private startTimer(): void {
    this.updateTime();
    this.timerId = setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  // 停止定时器
  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  aboutToAppear(): void {
    if (this.showTime) {
      this.startTimer();
    }
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  build() {
    Row() {
      Blank().layoutWeight(270);

      Button(this.confirmText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          if (this.onConfirm) {
            this.onConfirm();
          }
        });

      Blank().layoutWeight(80);

      Button(this.closeText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          } else {
            router.back();
          }
        });

      Blank().layoutWeight(80);

      Button(this.backText)
        .layoutWeight(110)
        .height(this.s(48))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .backgroundColor('#BEBEBE')
        .border({ width: 0 })
        .onClick(() => {
          if (this.onBack) {
            this.onBack();
          } else {
            router.back();
          }
        });

      Blank().layoutWeight(100);

      if (this.showTime) {
        Text(this.currentTime)
          .layoutWeight(160)
          .height(this.s(48))
          .fontSize(this.s(this.midFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .padding({ top: this.s(2), bottom: this.s(2) });
      } else {
        Blank().layoutWeight(160);
      }
    }
    .width('100%')
    .height(this.s(70))
    .padding({ top: this.s(8), bottom: this.s(6) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}