// common/EventDialog.ets
import { EventManager } from './EventManager';

@CustomDialog
export struct EventDialog {
  controller?: CustomDialogController
  content: string = ''

  build() {
    Column() {
      // ========== 仅修改这里：全新标题栏样式，完全匹配效果图 ==========
      Row() {
        Text('报告')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(80)
      .backgroundColor('#0099EE') // 效果图天蓝色标题背景
      .justifyContent(FlexAlign.Center) // 文字水平居中
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })
      .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 0, bottomRight: 0 }) // 顶部圆角和弹窗保持一致
      // ==========================================================

      Scroll() {
        Text(this.content)
          .fontSize(28)
          .lineHeight(36)
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .height('60%')
      .width('98%')
      .align(Alignment.TopStart)
      .margin({ top: 10 })
      Row(){
        Text('关 闭')
          .fontSize(32)
          .fontColor('#ffffff')
          .backgroundColor('#0099EE')
          .padding({left:20,bottom:10,right:20,top:10})
          .borderRadius({ topLeft: 12, topRight: 12, bottomLeft:12, bottomRight:12 }) // 顶部圆角和弹窗保持一致
          .onClick(async () => {
            console.info('关闭按钮被点击');
            // ✅ 关闭弹窗
            await EventManager.getInstance().closeCurrentDialog();
            // ✅ 可选：清除上次事件记录，允许相同事件再次弹出（如果需要的话）
            // EventManager.getInstance().resetLastEvent();
          })

      }.border({ width: { top: 1  }, color: '#E0E0E0' })  .height(80)// 效果图天蓝色标题背景
      .width('100%').justifyContent(FlexAlign.Center)
    }
    .padding(0) // 标题栏不需要内边距，铺满宽度
    .width('76%')
    .backgroundColor('#FFFFFF')
    .borderRadius(30)
    .margin({top:70})
    .shadow({ radius: 30, color: '#40000000' })
  }
}