import router from '@ohos.router';
import display from '@ohos.display';

// HeaderBar 配置类
export class HeaderBarConfig {
  noticeText: string = '';
  titleLeft: string = '';
  titleRight: string = '';
  showReturn: boolean = true;
  showClose: boolean = true;
  returnIcon: Resource = $r('app.media.return');
  closeIcon: Resource = $r('app.media.close');
  backgroundColor: string = '#D3D3D3';
  noticeColor: string = '#EF2929';
  titleColor: string = '#000000';
}

// HeaderBar 字体配置
export class HeaderBarFontSizeConfig {
  notice: number = 20;
  headerTitle: number = 24;
  headerSubTitle: number = 22;
  titleMin: number = 16;
  noticeMin: number = 14;
}

// HeaderBar 布局配置
export class HeaderBarLayoutConfig {
  headerHeight: number = 81;
  noticeWidth: number = 291;
  noticeHeight: number = 61;
  titleLeftWidth: number = 151;
  titleLeftHeight: number = 61;
  titleRightWidth: number = 121;
  titleRightHeight: number = 61;
  buttonWidth: number = 81;
  buttonHeight: number = 51;
  returnIconWidth: number = 37;
  returnIconHeight: number = 40;
  closeIconWidth: number = 32;
  closeIconHeight: number = 40;
  noticePositionX: number = 10;
  noticePositionY: number = 10;
  titleLeftPositionX: number = 370;
  titleLeftPositionY: number = 10;
  titleRightPositionX: number = 500;
  titleRightPositionY: number = 10;
  returnButtonPositionX: number = 840;
  closeButtonPositionX: number = 920;
  buttonPositionY: number = 20;
}

// HeaderBar 完整配置
export class HeaderBarPageConfig {
  text: HeaderBarConfig = new HeaderBarConfig();
  fontSize: HeaderBarFontSizeConfig = new HeaderBarFontSizeConfig();
  layout: HeaderBarLayoutConfig = new HeaderBarLayoutConfig();
}

// 默认配置
const DEFAULT_HEADER_BAR_CONFIG: HeaderBarPageConfig = new HeaderBarPageConfig();

@Component
export struct HeaderBar {
  @Prop config: HeaderBarPageConfig = DEFAULT_HEADER_BAR_CONFIG;
  @Prop uiScale: number = 1;
  @Prop showNotice: boolean = true;
  @Prop noticeText: string = '';
  @Prop titleLeft: string = '';
  @Prop titleRight: string = '';
  @Prop showReturn: boolean = true;
  @Prop showClose: boolean = true;
  @Prop onReturnClick?: () => void;
  @Prop onCloseClick?: () => void;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  build() {
    Stack() {
      // 提示文本
      if (this.showNotice && this.noticeText) {
        Text(this.noticeText)
          .width(this.s(this.config.layout.noticeWidth))
          .height(this.s(this.config.layout.noticeHeight))
          .fontSize(this.s(this.config.fontSize.notice))
          .minFontSize(this.s(this.config.fontSize.noticeMin))
          .fontColor(this.config.text.noticeColor)
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .position({
            x: this.s(this.config.layout.noticePositionX),
            y: this.s(this.config.layout.noticePositionY)
          });
      }

      // 左侧标题
      if (this.titleLeft) {
        Text(this.titleLeft)
          .width(this.s(this.config.layout.titleLeftWidth))
          .height(this.s(this.config.layout.titleLeftHeight))
          .fontSize(this.s(this.config.fontSize.headerTitle))
          .minFontSize(this.s(this.config.fontSize.titleMin))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.text.titleColor)
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .position({
            x: this.s(this.config.layout.titleLeftPositionX),
            y: this.s(this.config.layout.titleLeftPositionY)
          });
      }

      // 右侧标题
      if (this.titleRight) {
        Text(this.titleRight)
          .width(this.s(this.config.layout.titleRightWidth))
          .height(this.s(this.config.layout.titleRightHeight))
          .fontSize(this.s(this.config.fontSize.headerSubTitle))
          .minFontSize(this.s(this.config.fontSize.titleMin))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.config.text.titleColor)
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .position({
            x: this.s(this.config.layout.titleRightPositionX),
            y: this.s(this.config.layout.titleRightPositionY)
          });
      }

      // 返回按钮
      if (this.showReturn) {
        Button() {
          Image(this.config.text.returnIcon)
            .width(this.s(this.config.layout.returnIconWidth))
            .height(this.s(this.config.layout.returnIconHeight));
        }
        .width(this.s(this.config.layout.buttonWidth))
        .height(this.s(this.config.layout.buttonHeight))
        .padding(0)
        .backgroundColor(this.config.text.backgroundColor)
        .border({ width: 0 })
        .borderRadius(0)
        .position({
          x: this.s(this.config.layout.returnButtonPositionX),
          y: this.s(this.config.layout.buttonPositionY)
        })
        .onClick(() => {
          if (this.onReturnClick) {
            this.onReturnClick();
          } else {
            router.back();
          }
        });
      }

      // 关闭按钮
      if (this.showClose) {
        Button() {
          Image(this.config.text.closeIcon)
            .width(this.s(this.config.layout.closeIconWidth))
            .height(this.s(this.config.layout.closeIconHeight));
        }
        .width(this.s(this.config.layout.buttonWidth))
        .height(this.s(this.config.layout.buttonHeight))
        .padding(0)
        .backgroundColor(this.config.text.backgroundColor)
        .border({ width: 0 })
        .borderRadius(0)
        .position({
          x: this.s(this.config.layout.closeButtonPositionX),
          y: this.s(this.config.layout.buttonPositionY)
        })
        .onClick(() => {
          if (this.onCloseClick) {
            this.onCloseClick();
          } else {
            router.back();
          }
        });
      }
    }
    .width('100%')
    .height(this.s(this.config.layout.headerHeight))
    .backgroundColor(this.config.text.backgroundColor);
  }
}