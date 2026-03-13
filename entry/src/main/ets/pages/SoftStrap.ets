import { SoftStrapPanel } from '../components/SoftStrapPanel';

@Entry
@Component
export struct SoftStrap {
  build() {
    Column() {
      SoftStrapPanel({
        panelTitle: '运行操作—软压板投退',
        showBorder: true,
        showBottomBar: true,
        autoBackOnClose: true,
        autoBackOnBack: true
      })
    }
    .width('100%')
    .height('100%')
  }
}