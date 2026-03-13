import router from '@ohos.router';

class SubMenuItemModel {
  title: string = '';

  constructor(title: string) {
    this.title = title;
  }
}

class MenuSubItemModel {
  title: string = '';
  subItems: SubMenuItemModel[] = [];

  constructor(title: string, subItems?: string[]) {
    this.title = title;
    if (subItems) {
      this.subItems = subItems.map((item: string) => new SubMenuItemModel(item));
    }
  }
}

class MenuItemModel {
  title: string = '';
  items: MenuSubItemModel[] = [];

  constructor(title: string, items: MenuSubItemModel[]) {
    this.title = title;
    this.items = items;
  }
}

const MENU_DATA: MenuItemModel[] = [
  new MenuItemModel('运行操作', [
    new MenuSubItemModel('压板投退'),
    new MenuSubItemModel('定值切换'),
    new MenuSubItemModel('遥控操作'),
    new MenuSubItemModel('浏览'),
    new MenuSubItemModel('整定')
  ]),
  new MenuItemModel('电能质量', [
    new MenuSubItemModel('实时指标'),
    new MenuSubItemModel('谐波分析'),
    new MenuSubItemModel('告警定值'),
    new MenuSubItemModel('浏览'),
    new MenuSubItemModel('整定')
  ]),
  new MenuItemModel('高级分析', [
    new MenuSubItemModel('故障特征'),
    new MenuSubItemModel('负荷特征'),
    new MenuSubItemModel('风险评估')
  ]),
  new MenuItemModel('定值管理', [
    new MenuSubItemModel('一次系统', ['浏览', '整定']),
    new MenuSubItemModel('模拟量', ['浏览', '整定']),
    new MenuSubItemModel('遥测参数', ['浏览', '整定']),
    new MenuSubItemModel('遥信参数', ['浏览', '整定']),
    new MenuSubItemModel('遥控参数', ['浏览', '整定']),
    new MenuSubItemModel('越限报警', ['浏览', '整定']),
    new MenuSubItemModel('统计参数', ['浏览', '整定']),
    new MenuSubItemModel('保护定值', ['浏览', '整定', '拷贝', '删除'])
  ]),
  new MenuItemModel('报告管理', [
    new MenuSubItemModel('保护报告', ['动作', '告警', '录波', '变位', '操作', 'SOE']),
    new MenuSubItemModel('测控报告'),
    new MenuSubItemModel('装置设置'),
    new MenuSubItemModel('IEC61850')
  ]),
  new MenuItemModel('打印操作', [
    new MenuSubItemModel('软压板'),
    new MenuSubItemModel('设备参数'),
    new MenuSubItemModel('系统定值'),
    new MenuSubItemModel('测控参数'),
    new MenuSubItemModel('保护定值'),
    new MenuSubItemModel('保护状态')
  ]),
  new MenuItemModel('装置测试', [
    new MenuSubItemModel('开出测试'),
    new MenuSubItemModel('开入测试'),
    new MenuSubItemModel('灯光测试'),
    new MenuSubItemModel('精度测试'),
    new MenuSubItemModel('零漂测试'),
    new MenuSubItemModel('远动测试'),
    new MenuSubItemModel('试验测试')
  ]),
  new MenuItemModel('装置设置', [
    new MenuSubItemModel('时间设置'),
    new MenuSubItemModel('对时设置'),
    new MenuSubItemModel('通信设置'),
    new MenuSubItemModel('液晶设置'),
    new MenuSubItemModel('电度量'),
    new MenuSubItemModel('模拟量'),
    new MenuSubItemModel('密码设置')
  ])
];

@Component
export struct TopMenu {
  @State menuIndex: number = -1;
  @State subMenuIndex: number = -1;

  private closeMenus(): void {
    this.menuIndex = -1;
    this.subMenuIndex = -1;
  }

  private openPage(url: string): void {
    router.pushUrl({
      url: url
    }).catch((error: Error) => {
      console.error('router push failed: ' + error.name + ' ' + error.message);
    });
    this.closeMenus();
  }

  private handleDirectItemClick(item: MenuSubItemModel): void {
    if (item.title === '压板投退') {
      this.openPage('pages/SoftStrapSet');
      return;
    }
    this.closeMenus();
  }

  private handleLeafClick(item: MenuSubItemModel, subItem: SubMenuItemModel): void {
    if (item.title === '一次系统' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_PrimarySystem_Set');
      return;
    }
    if (item.title === '模拟量' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_AnalogQuantity_Set');
      return;
    }
    if (item.title === '遥测参数' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_TeleMeasuring_Set');
      return;
    }
    if (item.title === '遥信参数' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_TeleSignaling_Set');
      return;
    }
    if (item.title === '遥控参数' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_TeleControlling_Set');
      return;
    }
    if (item.title === '越限报警' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_ExceedingLimit_Set');
      return;
    }
    if (item.title === '统计参数' && subItem.title === '整定') {
      this.openPage('pages/CommonSetting_Statistics_Set');
      return;
    }
    if (item.title === '保护定值' && subItem.title === '浏览') {
      this.openPage('pages/RelaySetting_DispSelect');
      return;
    }
    if (item.title === '保护定值' && subItem.title === '整定') {
      this.openPage('pages/RelaySetting_SetSelect');
      return;
    }
    this.closeMenus();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row() {
          ForEach(MENU_DATA, (menu: MenuItemModel, index: number) => {
            Column() {
              Column() {
                Text(menu.title)
                  .fontSize(22)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .padding(8)
                  .width('100%')
                  .textAlign(TextAlign.Center);
              }
              .width('100%')
              .height('100%')
              .backgroundColor(this.menuIndex === index ? '#c0c6cc' : '#d6dadc')
              .borderRadius(5)
              .margin({ left: 3, right: 3 })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.menuIndex = this.menuIndex === index ? -1 : index;
                this.subMenuIndex = -1;
              });

              if (this.menuIndex === index) {
                Column() {
                  ForEach(menu.items, (item: MenuSubItemModel, subIndex: number) => {
                    Column() {
                      Row() {
                        Text(item.title)
                          .fontSize(22)
                          .fontColor('#333333')
                          .layoutWeight(1)
                          .textAlign(TextAlign.Start);
                      }
                      .backgroundColor(this.subMenuIndex === subIndex ? '#c0c6cc' : '#d6dadc')
                      .width('100%')
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .onClick(() => {
                        if (item.subItems.length > 0) {
                          this.subMenuIndex = this.subMenuIndex === subIndex ? -1 : subIndex;
                          return;
                        }
                        this.handleDirectItemClick(item);
                      });

                      if (item.subItems.length > 0 && this.subMenuIndex === subIndex) {
                        Column() {
                          ForEach(item.subItems, (subItem: SubMenuItemModel, leafIndex: number) => {
                            Row() {
                              Text(subItem.title)
                                .fontSize(22)
                                .fontColor('#333333')
                                .width('100%')
                                .textAlign(TextAlign.Center);
                            }
                            .width('100%')
                            .height(35)
                            .justifyContent(FlexAlign.Center)
                            .padding({ left: 12, right: 12 })
                            .onClick(() => {
                              this.handleLeafClick(item, subItem);
                            });
                          }, (subItem: SubMenuItemModel, leafIndex: number) => leafIndex.toString() + subItem.title);
                        }
                        .backgroundColor('#d6dadc')
                        .width(100)
                        .height(item.subItems.length * 35)
                        .borderRadius(5)
                        .position({ x: '100%', y: 0 })
                        .zIndex(10001);
                      }
                    }
                  }, (item: MenuSubItemModel, subIndex: number) => subIndex.toString() + item.title);
                }
                .width('100%')
                .borderRadius({ bottomLeft: 5, bottomRight: 5 })
                .clip(false)
                .zIndex(9999);
              }
            }
            .layoutWeight(1)
            .height(60);
          }, (menu: MenuItemModel, index: number) => index.toString() + menu.title);
        }
        .width('100%')
        .height('12%')
        .backgroundColor('#e2e6ec')
        .padding({ left: 20, right: 20 });
      }
      .width('100%');
    }
    .width('100%');
  }
}
