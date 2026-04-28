import display from '@ohos.display';

@Component
export struct CustomKeyboard {
  // 明确声明所有属性的类型
  currentValue: () => string = () => '';
  onChange: (value: string) => void = () => {};
  onClose: () => void = () => {};
  @Prop keyboardPosition: 'top' | 'bottom' = 'bottom';

  @State inputBuffer: string = '';
  private readonly keyboardRows: string[][] = [
    [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '←','↑',],
    [ '0', 'a', 'b', 'c', 'd', 'e', 'f', '.', ':', '删除', '返回','↓']
  ];

  aboutToAppear(): void {
    this.inputBuffer = this.currentValue();
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
                .width(key === '←' ? 190 : 95)
                .height(70)
                .fontSize(30)
                .backgroundColor( Color.White)
                // .backgroundColor(key === '←' || key === '删除' ? '#FFC0CB' : Color.White)
                .borderRadius(4)
                .fontColor('#000')
                .margin(4)
                .onClick(() => this.handleKey(key))
            }, (key: string) => key)
          }
          .justifyContent(FlexAlign.Center)
        }, (row: string[]) => row.join())
      }
      .width('100%')
      .backgroundColor('#E0E0E0')
      .padding(10)
    }
    .width('100%')
    .position(
      this.keyboardPosition === 'top'
        ? { left: 0, right: 0, top: 100 }
        : { left: 0, right: 0, bottom: 100 }
    )
    .zIndex(9999)
    .onTouch(() => true)
  }
}