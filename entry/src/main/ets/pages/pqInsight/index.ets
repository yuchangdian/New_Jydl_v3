import { window, } from '@kit.ArkUI'
import display from '@ohos.display'
import router from '@ohos.router'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import { PQInsight } from './pqInsight';
@Entry
@Component
struct meterIndex {
  windowClass?: window.Window
  @State selectedMenuItem: string = "波形"
  @State uiScale: number = 1
  readonly designWidth: number = 720


  onPageShow(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
  }

  build() {
    Column() {
      // 主体内容区
      Row() {
        // 左侧菜单
        Column(){
          Row(){
            Image( $rawfile("icon/icon03.png"))
              .width(18 * this.uiScale)
              .height(18 * this.uiScale)
            Text("波形")
              .fontSize(18 * this.uiScale)
              .fontColor('#ffffff')
              .margin({left:5 * this.uiScale})
          }
          .width(100 * this.uiScale)
          .backgroundColor('#ff167fff')
          .height(40 * this.uiScale)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text("刷新")
              .fontSize(18 * this.uiScale)
              .fontColor('#000000')
              .width(85 * this.uiScale)
              .textAlign(TextAlign.Center)
              .borderRadius(5 * this.uiScale)
              .height(30 * this.uiScale)
              .border({ width: 1 * this.uiScale, color: '#000000' })
              .backgroundColor('#ffababab')
              .margin({top:10 * this.uiScale})
            Text("最近事件")
              .fontSize(18 * this.uiScale)
              .fontColor('#000000')
              .width(85 * this.uiScale)
              .height(30 * this.uiScale)
              .textAlign(TextAlign.Center)
              .borderRadius(5 * this.uiScale)
              .border({ width: 1 * this.uiScale, color: '#000000' })
              .backgroundColor('#ffababab')
              .margin({top:10 * this.uiScale})
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/pqInsight/EventCenter'
                })
              })
            // this.menuItem("最近事件")
            // this.menuItem("基波数据")

          }
          .width(100 * this.uiScale)

        }
        .height('100%')
        .backgroundColor('#F5F5F5')
        .border({ width: { right: 1 * this.uiScale }, color: '#333333' })

        // 右侧内容区
        this.getContent()
      }
      .layoutWeight(1)

      // 底部标题栏
      CommonTitleBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  // 菜单项
  @Builder
  menuItem(name: string) {
    Text(name)
      .width('100%')
      .height(38 * this.uiScale)
      .textAlign(TextAlign.Center)
      .fontSize(18 * this.uiScale)
      .fontColor(this.selectedMenuItem === name ? '#ffff0000' :'#ff0a0a0a')
      .border({ width: { bottom:1 * this.uiScale }, color: '#ffc4c4c4' })
      .onClick(() => {
        this.selectedMenuItem = name
      })
  }

  // 根据选中的菜单项显示不同内容
  @Builder
  getContent() {
    PQInsight()
      .layoutWeight(1)
    .backgroundColor(Color.White)
  }

  // 宽频相量内容



}