import { window, } from '@kit.ArkUI'
import display from '@ohos.display'
import { CommonTitleBar } from '../../components/CommonTitleBar'
import { VectorGraphic } from './vectorGraphic';
import { fullWaveData } from './fullWaveData';
import { fundamentalData } from './fundamentalData';

@Entry
@Component
struct meterIndex {
  windowClass?: window.Window
  @State selectedMenuItem: string = "矢量图"
  @State uiScale: number = 1
  readonly designWidth: number = 720

  async setFullScreen(flag: boolean): Promise<void> {
    if (!this.windowClass) {
      this.windowClass = await window.getLastWindow(getContext(this))
    }
    this.windowClass.setWindowLayoutFullScreen(flag)
    this.windowClass.setWindowSystemBarEnable([])
  }

  onPageShow(): void {
    try {
      let dis = display.getDefaultDisplaySync();
      this.uiScale = dis.width / this.designWidth;
    } catch (e) {
      this.uiScale = 1;
    }
    this.setFullScreen(true)
  }

  build() {
    Column() {
      // 主体内容区
      Row() {
        // 左侧菜单
        Column(){
          Row(){
            Image( $rawfile("icon/icon02.png"))
              .width(18 * this.uiScale)
              .height(18 * this.uiScale)
            Text("表计")
              .fontSize(18 * this.uiScale)
              .fontColor('#ffffff')
              .margin({left:5 * this.uiScale})
          }
          .width(100 * this.uiScale)
          .backgroundColor('#ff167fff')
          .height(40 * this.uiScale)
          .justifyContent(FlexAlign.Center)

          Column() {
            this.menuItem("矢量图")
            this.menuItem("全波数据")
            this.menuItem("基波数据")

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
    Column() {
      if (this.selectedMenuItem === "矢量图") {
        VectorGraphic()
      } else if (this.selectedMenuItem === "全波数据") {
         fullWaveData()
      }else if (this.selectedMenuItem === "基波数据") {
        fundamentalData()
      } else {
        // Text(`当前选中: ${this.selectedMenuItem}`)
        //   .fontSize(16)
        //   .fontColor('#666666')
        //   .margin({ top: 50 })
      }
    }
    .layoutWeight(1)
    .backgroundColor(Color.White)
  }

  // 宽频相量内容



}