// 如果你把它放到了单独的文件中，不要忘记引入依赖的组件，或者把 CbItem 也放进来
@Component
struct CbItem {
  @Prop label: string;
  @Prop isChecked: boolean = true;
  @Prop itemWidth: Length = 'auto';

  build() {
    Row() {
      Checkbox({ name: this.label, group: 'checkboxGroup' })
        .select(this.isChecked)
        .width(16)
        .height(16)
        .selectedColor('#000000') // 黑色选中状态

      Text(this.label)
        .fontSize(14)
        .fontColor(Color.Black)
        .margin({ left: 4 })
    }
    .width(this.itemWidth)
    .margin({ top: 6, bottom: 6 })
  }
}

@Component
export struct TopTitleBar {
  // 提取为可配置的属性，方便其他页面复用时修改文字
  @Prop warningText: string = '温馨提醒：软压板已被改动！';
  @Prop titleText: string = '运行操作—软压板投退';

  build() {
    Column() {
      Row() {
        // 左侧：警告信息
        Text(this.warningText)
          .fontColor(Color.Red)
          .fontSize(14)
          .width('25%')

        // 中间：主标题
        Text(this.titleText)
          .fontWeight(FontWeight.Bold)
          .fontSize(18)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        // 右侧：操作区 (投入/退出复选框 + 刷新/关闭图标)
        Row() {
          CbItem({ label: '投入', isChecked: true })
          Blank().width(10)
          CbItem({ label: '退出', isChecked: false })
          Blank().width(20)

          // 图标部分（使用文本符号代替，如果你有图片也可以换成 Image 组件）
          Text('↺')
            .fontSize(22)
            .margin({ right: 16 })
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              // TODO: 添加刷新逻辑
              console.info("点击了刷新");
            })

          Text('✕')
            .fontSize(20)
            .onClick(() => {
              // TODO: 添加关闭逻辑
              console.info("点击了关闭");
            })
        }
        .width('30%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })

      // 顺便把标题栏下方的虚线分割线也封装在这个组件里
      Line()
        .width('100%')
        .height(1)
        .strokeWidth(1)
        .stroke('#999999')
        .strokeDashArray([4, 4])
        .margin({ top: 4, bottom: 4 })
    }
    .width('100%')
  }
}