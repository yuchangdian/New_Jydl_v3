@Component
export struct ReportDialog {
  build() {
    Column() {
      Row() {
        Text('报告')
          .fontSize(36)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(80)
      .backgroundColor('#00B8F5')
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column() {
          this.buildAlertRow('电压不平衡越限告警:', '****年**月**日**:**:**:**')
          this.buildContentRow('电压不平衡度：负序不平衡度：xx.xx%  零序不平衡度：xx.xx%')
          this.buildContentRow('电压序分量：正序：xxx.xxV  负序：xxx.xxV  零序：xxx.xxV')
          this.buildAlertRow('电压不平衡越限告警返回:', '****年**月**日**:**:**:**')
          this.buildAlertRow('电压总谐波含量越限告警:', '**年**月**日**:**:**:**')
          this.buildContentRow('三相电压总谐波含量：xx.xx%  xx.xx%  xx.xx%')
        }
        .width('100%')
        .padding(20)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)

      Row() {
        Button('返回', { type: ButtonType.Normal })
          .width(180)
          .height(60)
          .fontSize(32)
          .onClick(() => {
          })
      }
      .width('100%')
      .height(90)
      .backgroundColor('#E5E5E5')
      .justifyContent(FlexAlign.Center)
    }
    .width('90%')
    .height('70%')
    .backgroundColor(Color.White)
    .border({ width: 1, color: Color.Black })
  }

  @Builder
  buildAlertRow(title: string, time: string) {
    Row() {
      Text(title).fontSize(28)
      Text(time).fontSize(28).margin({ left: 60 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  buildContentRow(content: string) {
    Row() {
      Text(content).fontSize(28).margin({ left: 40 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}