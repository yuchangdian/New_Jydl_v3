// Qt 整定页的小尺寸下拉框。系统 Select 的内部留白会截断 65 宽度下的中文。
@Component
export struct QtAlarmSettingSelect {
  @Prop options: SelectOption[] = [];
  @Prop selectedIndex: number = 0;
  @Prop controlWidth: number = 65;
  @Prop uiScale: number = 1;
  @State expanded: boolean = false;
  onSelect: (index: number) => void = (_index: number) => {};

  @Builder
  OptionList() {
    Column() {
      ForEach(this.options, (option: SelectOption, index: number) => {
        Text(option.value)
          .width('100%').height(38 * this.uiScale)
          .padding({ left: 4 * this.uiScale, right: 4 * this.uiScale })
          .fontSize(16 * this.uiScale).fontWeight(FontWeight.Normal)
          .fontColor(index === this.selectedIndex ? '#FFFFFF' : '#111111')
          .backgroundColor(index === this.selectedIndex ? '#167FFF' : '#FFFFFF')
          .maxLines(1)
          .onClick(() => {
            this.expanded = false;
            if (index !== this.selectedIndex) this.onSelect(index);
          });
      }, (option: SelectOption) => option.value.toString());
    }
    .width(this.controlWidth * this.uiScale)
    .backgroundColor('#FFFFFF')
    .border({ width: this.uiScale, color: '#999999' });
  }

  build() {
    Row({ space: 4 * this.uiScale }) {
      Text(this.options[this.selectedIndex].value)
        .layoutWeight(1).fontSize(16 * this.uiScale)
        .fontWeight(FontWeight.Normal).fontColor('#111111').maxLines(1);
      Polygon({ width: 7 * this.uiScale, height: 4 * this.uiScale })
        .points([[0, 0], [7 * this.uiScale, 0], [3.5 * this.uiScale, 4 * this.uiScale]])
        .fill('#111111');
    }
    .width(this.controlWidth * this.uiScale).height(38 * this.uiScale)
    .padding({ left: 4 * this.uiScale, right: 4 * this.uiScale })
    .backgroundColor('#FFFFFF')
    .border({ width: this.uiScale, color: '#999999' })
    .borderRadius(3 * this.uiScale)
    .focusable(true)
    .accessibilityText(this.options[this.selectedIndex].value.toString())
    .onClick(() => this.expanded = !this.expanded)
    .bindPopup(this.expanded, {
      builder: this.OptionList,
      placement: Placement.BottomLeft,
      enableArrow: false,
      targetSpace: 0,
      radius: 0,
      shadow: { radius: 0 },
      popupColor: '#FFFFFF',
      showInSubWindow: false,
      onStateChange: (event: PopupStateChangeParam) => {
        if (!event.isVisible) this.expanded = false;
      }
    });
  }
}
