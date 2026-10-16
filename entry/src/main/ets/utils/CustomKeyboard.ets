import display from '@ohos.display';

@Component
export struct CustomKeyboard {
  // 明确声明所有属性的类型
  currentValue: () => string = () => '';
  onChange: (value: string) => void = () => {};
  onClose: () => void = () => {};
  @Prop @Watch('resetInputSession') inputSession: number = 0;

  @State keyboardPosition: 'top' | 'bottom' = 'bottom';
  @State inputBuffer: string = '';
  @State keyboardScaleValue: number = 1;
  private readonly keyboardRows: string[][] = [
    [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '←','↑',],
    [ '0', 'a', 'b', 'c', 'd', 'e', 'f', '.', ':', '删除', '返回','↓']
  ];
  private readonly designWidth: number = 1024;
  private readonly normalKeyWidth: number = 68;
  private readonly actionKeyWidth: number = 92;
  private readonly keyHeight: number = 56;
  private readonly keyFontSize: number = 24;
  private readonly keyBorderRadius: number = 4;
  private readonly keyMargin: number = 3;
  private readonly keyboardPadding: number = 8;

  aboutToAppear(): void {
    this.resetInputSession();
    this.keyboardScaleValue = this.resolveKeyboardScale();
  }
  private resetInputSession(): void {
    this.inputBuffer = this.currentValue();
    this.keyboardPosition = 'bottom';
  }
//打一杯水吧，现在去打，我很渴
  private resolveKeyboardScale(): number {
    try {
      const screen = display.getDefaultDisplaySync();
      // 显示屏尺寸为 px，按键尺寸为 vp，先换算再计算比例。
      return this.scaleForWidth(this.getUIContext().px2vp(screen.width));
    } catch (e) {
      return 1;
    }
  }

  private scaleForWidth(width: number): number {
    return Number.isFinite(width) && width > 0 ? Math.min(width / this.designWidth, 1) : 1;
  }

  private s(value: number): number {
    return Math.round(value * this.keyboardScaleValue);
  }

  private buttonWidthForKey(key: string): number {
    if (key === '←' || key === '删除' || key === '返回') {
      return this.s(this.actionKeyWidth);
    }
    return this.s(this.normalKeyWidth);
  }

  private handleKey(key: string): void {
    switch (key) {
      case '←':
      case '删除':
        if (this.inputBuffer.length > 0) {
          this.inputBuffer = this.inputBuffer.slice(0, -1);
        }
        this.onChange(this.inputBuffer);
        break;
      case '返回':
        this.onClose();
        break;
      case '↑':
        this.keyboardPosition = 'top';
        break;
      case '↓':
        this.keyboardPosition = 'bottom';
        break;
      default:
        this.inputBuffer += key;
        this.onChange(this.inputBuffer);
        break;
    }
  }

  build(): void {
    Stack() {
      Column() {
        // 移除泛型，只保留 ForEach 正常用法
        ForEach(this.keyboardRows, (row: string[]) => {
          Row() {
            ForEach(row, (key: string) => {
              Button(key)
                .width(this.buttonWidthForKey(key))
                .height(this.s(this.keyHeight))
                .fontSize(this.s(this.keyFontSize))
                .backgroundColor( Color.White)
                .borderRadius(this.s(this.keyBorderRadius))
                .fontColor('#000')
                .margin(this.s(this.keyMargin))
                .onClick(() => this.handleKey(key))
            }, (key: string) => key)
          }
          .justifyContent(FlexAlign.Center)
        }, (row: string[]) => row.join())
      }
      .width('100%')
      .backgroundColor('#E0E0E0')
      .padding(this.s(this.keyboardPadding))
    }
    .width('100%')
    .position(
      this.keyboardPosition === 'top'
        ? { left: 0, right: 0, top: 0 }
        : { left: 0, right: 0, bottom: 0 }
    )
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      // 使用所属窗口的实际 vp 宽度，支持不同像素密度和窗口宽度。
      this.keyboardScaleValue = this.scaleForWidth(Number(newArea.width));
    })
    .zIndex(9999)
    .onTouch(() => true)
  }
}
