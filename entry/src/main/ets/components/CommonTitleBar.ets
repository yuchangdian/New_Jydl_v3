import router from '@ohos.router';
import display from '@ohos.display';

@Component
export struct CommonTitleBar {
  title: string = '标题';
  @State currentTime: string = '';
  @State currentDate: string = '';
  private timerId: number = -1;
  @State uiScale: number = 1;
  readonly designWidth: number = 720;

  // 格式化日期：YYYY-MM-DD
  formatDate(date: Date): string {
    const year = date.getFullYear().toString();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}/${month}/${day}`;
  }

  // 格式化时间：HH:mm:ss
  formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }

  // 组件显示时启动定时器
  aboutToAppear() {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    
    const now = new Date();
    this.currentDate = this.formatDate(now);
    this.currentTime = this.formatTime(now);

    // 每秒刷新
    this.timerId = setInterval(() => {
      const newTime = new Date();
      this.currentDate = this.formatDate(newTime);
      this.currentTime = this.formatTime(newTime);
    }, 1000);
  }

  // 组件消失时清理定时器
  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    Row() {
      // 返回按钮
      Text('返回')
        .fontSize(18 * this.uiScale)
        .height(38 * this.uiScale)
        .border({ width: 1 * this.uiScale, color: '#000000' })
        .borderRadius(6 * this.uiScale)
        .backgroundColor('#d0d3d8')
        .fontColor('#000000')
        .width(100 * this.uiScale)
        .textAlign(TextAlign.Center)
      .onClick(() => {
        // router.back(-1)
        router.replaceUrl({ url: 'pages/Index' });
      })

      // 右侧：两行时间（上 年月日，下 时分秒）
      Row() {
        Text(this.currentDate)
          .fontSize(16 * this.uiScale)
          .textAlign(TextAlign.Center)
        Text(this.currentTime)
          .fontSize(16 * this.uiScale)
          .textAlign(TextAlign.Center)
          .margin({left:10 * this.uiScale})
      }
      .position({bottom:14 * this.uiScale,right:20 * this.uiScale})
    }
    .width('100%')
    .height(48 * this.uiScale)
    .padding({ left: 16 * this.uiScale, right: 16 * this.uiScale })
    .backgroundColor('#c0c6cc')
    .border({ width: { bottom: 1 * this.uiScale }, color: '#000000' })
    .justifyContent(FlexAlign.Center)
  }
}