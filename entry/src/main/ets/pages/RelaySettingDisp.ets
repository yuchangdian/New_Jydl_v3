import router from '@ohos.router';
import display from '@ohos.display';
import {
  RELAY_PROFILE_COUNT,
  RELAY_SETTING_PROFILES_STORE_KEY,
  RelayFieldBinding,
  RelaySettingProfile,
  RelaySettingProfilesStore,
  RelayStoredField,
  buildRelayFieldBindings,
  cloneRelaySettingProfilesStoreForProfileUpdate,
  createDefaultRelaySettingProfile,
  createDefaultRelaySettingProfilesStore,
  relayDefaultSelectOptions,
  relayDefaultStoredField,
  relayDeserializeProfilesStore,
  relayFindFieldBinding,
  relayFormatStoredField,
  relayNormalizeZoneCode,
  relayParseStoredField,
  relayReadProfileField,
  relaySerializeProfilesStore,
  relayWriteProfileField,
  relayZoneCodeForIndex,
  relayZoneCodeToIndex
} from './RelaySettingProfiles';

const RELAY_SETTING_STORE_KEY: string = 'relay_setting_set_store';

PersistentStorage.persistProp(RELAY_SETTING_STORE_KEY, '');
PersistentStorage.persistProp(RELAY_SETTING_PROFILES_STORE_KEY, '');

@Observed
class StrapFlag {
  id: string;
  label: string;
  checked: boolean;
  enabled: boolean;

  constructor(id: string, label: string, checked: boolean = false, enabled: boolean = true) {
    this.id = id;
    this.label = label;
    this.checked = checked;
    this.enabled = enabled;
  }
}

@Observed
class HeaderModeState {
  inMode: StrapFlag = new StrapFlag('checkBox', '投入', true, true);
  outMode: StrapFlag = new StrapFlag('checkBox_2', '退出', false, true);
}

@Observed
class BottomActionState {
  defaultText: string = '默认值';
  confirmText: string = '确认';
  closeText: string = '关闭';
  cancelText: string = '取消';
}

class RouterParams {
  zoneCode?: string;
}

class RelayValueEntry {
  key: string;
  value: string;

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

class RelayCellSpec {
  id: string;
  kind: string;
  text: string;
  weight: number;

  constructor(id: string, kind: string, text: string, weight: number) {
    this.id = id;
    this.kind = kind;
    this.text = text;
    this.weight = weight;
  }
}

class RelayRowItemSpec {
  id: string;
  kind: string;
  weight: number;
  cells: RelayCellSpec[];

  constructor(id: string, kind: string, weight: number, cells: RelayCellSpec[] = []) {
    this.id = id;
    this.kind = kind;
    this.weight = weight;
    this.cells = cells;
  }
}

class RelayRowSpec {
  id: string;
  leftMargin: number;
  rightMargin: number;
  items: RelayRowItemSpec[];

  constructor(id: string, leftMargin: number, rightMargin: number, items: RelayRowItemSpec[]) {
    this.id = id;
    this.leftMargin = leftMargin;
    this.rightMargin = rightMargin;
    this.items = items;
  }
}

class RelaySectionSpec {
  id: string;
  title: string;
  rows: RelayRowSpec[];

  constructor(id: string, title: string, rows: RelayRowSpec[]) {
    this.id = id;
    this.title = title;
    this.rows = rows;
  }
}

class RelayMonitorFieldSpec {
  id: string;
  label: string;
  value: string;
  unit: string;
  kind: string;
  boxWidth: number;

  constructor(
    id: string,
    label: string,
    value: string,
    unit: string = '',
    kind: string = 'input',
    boxWidth: number = 112
  ) {
    this.id = id;
    this.label = label;
    this.value = value;
    this.unit = unit;
    this.kind = kind;
    this.boxWidth = boxWidth;
  }
}

class RelayMonitorSectionSpec {
  id: string;
  title: string;
  fields: RelayMonitorFieldSpec[];

  constructor(id: string, title: string, fields: RelayMonitorFieldSpec[]) {
    this.id = id;
    this.title = title;
    this.fields = fields;
  }
}

const RELAY_MAIN_SECTIONS: RelaySectionSpec[] = [
  new RelaySectionSpec('section-01', '【公共定值】', [
    new RelayRowSpec('section-01-row-01', 40, 0, [
        new RelayRowItemSpec('section-01-row-01-item-01', 'group', 8, [new RelayCellSpec('section-01-row-01-item-01-cell-01', 'label', '故障指示灯复位：', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-02', 'group', 5, [new RelayCellSpec('section-01-row-01-item-02-cell-01', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-03', 'spacer', 2),
        new RelayRowItemSpec('section-01-row-01-item-04', 'group', 12, [new RelayCellSpec('section-01-row-01-item-04-cell-01', 'label', '故障指示灯复归时间：', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-05', 'group', 3, [new RelayCellSpec('section-01-row-01-item-05-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-06', 'group', 2, [new RelayCellSpec('section-01-row-01-item-06-cell-01', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-07', 'spacer', 3),
        new RelayRowItemSpec('section-01-row-01-item-08', 'group', 11, [new RelayCellSpec('section-01-row-01-item-08-cell-01', 'label', '故障遥信保持时间：', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-09', 'group', 3, [new RelayCellSpec('section-01-row-01-item-09-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-10', 'group', 2, [new RelayCellSpec('section-01-row-01-item-10-cell-01', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-11', 'spacer', 1)
    ]),
    new RelayRowSpec('section-01-row-02', 40, 0, [
        new RelayRowItemSpec('section-01-row-02-item-01', 'group', 8, [new RelayCellSpec('section-01-row-02-item-01-cell-01', 'label', '无压定值：', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-02', 'group', 4, [new RelayCellSpec('section-01-row-02-item-02-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-03', 'group', 2, [new RelayCellSpec('section-01-row-02-item-03-cell-01', 'unit', 'V', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-04', 'spacer', 1),
        new RelayRowItemSpec('section-01-row-02-item-05', 'group', 12, [new RelayCellSpec('section-01-row-02-item-05-cell-01', 'label', '无电流定值：', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-06', 'group', 3, [new RelayCellSpec('section-01-row-02-item-06-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-07', 'group', 2, [new RelayCellSpec('section-01-row-02-item-07-cell-01', 'unit', 'A', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-08', 'spacer', 3),
        new RelayRowItemSpec('section-01-row-02-item-09', 'group', 11, [new RelayCellSpec('section-01-row-02-item-09-cell-01', 'label', '有压定值：', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-10', 'group', 3, [new RelayCellSpec('section-01-row-02-item-10-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-11', 'group', 2, [new RelayCellSpec('section-01-row-02-item-11-cell-01', 'unit', 'V', 1)]),
        new RelayRowItemSpec('section-01-row-02-item-12', 'spacer', 1)
    ]),
    new RelayRowSpec('section-01-row-03', 40, 0, [
        new RelayRowItemSpec('section-01-row-03-item-01', 'group', 10, [new RelayCellSpec('section-01-row-03-item-01-cell-01', 'label', '过量继电器返回系数：', 1)]),
        new RelayRowItemSpec('section-01-row-03-item-02', 'group', 5, [new RelayCellSpec('section-01-row-03-item-02-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-03-item-03', 'spacer', 10),
        new RelayRowItemSpec('section-01-row-03-item-04', 'group', 10, [new RelayCellSpec('section-01-row-03-item-04-cell-01', 'label', '欠量继电器返回系数：', 1)]),
        new RelayRowItemSpec('section-01-row-03-item-05', 'group', 5, [new RelayCellSpec('section-01-row-03-item-05-cell-01', 'input', '120.00', 1)]),
        new RelayRowItemSpec('section-01-row-03-item-06', 'spacer', 10)
    ]),
    new RelayRowSpec('section-01-row-04', 40, 0, [
        new RelayRowItemSpec('section-01-row-04-item-01', 'group', 15, [new RelayCellSpec('section-01-row-04-item-01-cell-01', 'label', '3Io折算至外接零序CT二次值：', 1)]),
        new RelayRowItemSpec('section-01-row-04-item-02', 'group', 5, [new RelayCellSpec('section-01-row-04-item-02-cell-01', 'select', '折算', 1)]),
        new RelayRowItemSpec('section-01-row-04-item-03', 'spacer', 30)
    ])
  ]),
  new RelaySectionSpec('section-02', '【通信定值】', [
    new RelayRowSpec('section-02-row-01', 40, 0, [
        new RelayRowItemSpec('section-02-row-01-item-01', 'group', 10, [new RelayCellSpec('section-02-row-01-item-01-cell-01', 'label', '通道A边缘终端单元MAC：', 1), new RelayCellSpec('section-02-row-01-item-01-cell-02', 'input', '00:00:00:00:00:00', 1)]),
        new RelayRowItemSpec('section-02-row-01-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-02-row-01-item-03', 'group', 10, [new RelayCellSpec('section-02-row-01-item-03-cell-01', 'label', '通道B边缘终端单元MAC：', 1), new RelayCellSpec('section-02-row-01-item-03-cell-02', 'input', '00:00:00:00:00:00', 1)])
    ]),
    new RelayRowSpec('section-02-row-02', 40, 0, [
        new RelayRowItemSpec('section-02-row-02-item-01', 'group', 10, [new RelayCellSpec('section-02-row-02-item-01-cell-01', 'label', '通道A本侧保护单元MAC：', 1), new RelayCellSpec('section-02-row-02-item-01-cell-02', 'input', '00:00:00:00:00:00', 1)]),
        new RelayRowItemSpec('section-02-row-02-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-02-row-02-item-03', 'group', 10, [new RelayCellSpec('section-02-row-02-item-03-cell-01', 'label', '通道B本侧保护单元MAC：', 1), new RelayCellSpec('section-02-row-02-item-03-cell-02', 'input', '00:00:00:00:00:00', 1)])
    ]),
    new RelayRowSpec('section-02-row-03', 40, 0, [
        new RelayRowItemSpec('section-02-row-03-item-01', 'group', 10, [new RelayCellSpec('section-02-row-03-item-01-cell-01', 'label', '通道A对侧保护单元MAC：', 1), new RelayCellSpec('section-02-row-03-item-01-cell-02', 'input', '00:00:00:00:00:00', 1)]),
        new RelayRowItemSpec('section-02-row-03-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-02-row-03-item-03', 'group', 10, [new RelayCellSpec('section-02-row-03-item-03-cell-01', 'label', '通道B对侧保护单元MAC：', 1), new RelayCellSpec('section-02-row-03-item-03-cell-02', 'input', '00:00:00:00:00:00', 1)])
    ]),
    new RelayRowSpec('section-02-row-04', 40, 0, [
        new RelayRowItemSpec('section-02-row-04-item-01', 'group', 6, [new RelayCellSpec('section-02-row-04-item-01-cell-01', 'label', '边缘终端单元识别码：', 1)]),
        new RelayRowItemSpec('section-02-row-04-item-02', 'group', 4, [new RelayCellSpec('section-02-row-04-item-02-cell-01', 'input', '12345678', 1)]),
        new RelayRowItemSpec('section-02-row-04-item-03', 'spacer', 5),
        new RelayRowItemSpec('section-02-row-04-item-04', 'spacer', 11),
        new RelayRowItemSpec('section-02-row-04-item-05', 'spacer', 4)
    ]),
    new RelayRowSpec('section-02-row-05', 40, 0, [
        new RelayRowItemSpec('section-02-row-05-item-01', 'group', 6, [new RelayCellSpec('section-02-row-05-item-01-cell-01', 'label', '本侧保护单元识别码：', 1)]),
        new RelayRowItemSpec('section-02-row-05-item-02', 'group', 4, [new RelayCellSpec('section-02-row-05-item-02-cell-01', 'input', '12345678', 1)]),
        new RelayRowItemSpec('section-02-row-05-item-03', 'spacer', 5),
        new RelayRowItemSpec('section-02-row-05-item-04', 'group', 7, [new RelayCellSpec('section-02-row-05-item-04-cell-01', 'label', '对侧保护单元识别码：', 1)]),
        new RelayRowItemSpec('section-02-row-05-item-05', 'group', 4, [new RelayCellSpec('section-02-row-05-item-05-cell-01', 'input', '12345678', 1)]),
        new RelayRowItemSpec('section-02-row-05-item-06', 'spacer', 4)
    ])
  ]),
  new RelaySectionSpec('section-03', '【纵联保护公共定值】', [
    new RelayRowSpec('section-03-row-01', 40, 0, [
        new RelayRowItemSpec('section-03-row-01-item-01', 'group', 10, [new RelayCellSpec('section-03-row-01-item-01-cell-01', 'label', 'CT断线闭锁纵联保护：', 5), new RelayCellSpec('section-03-row-01-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-03-row-01-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-03-row-01-item-03', 'group', 11, [new RelayCellSpec('section-03-row-01-item-03-cell-01', 'label', 'CT饱和闭锁纵联保护：', 5), new RelayCellSpec('section-03-row-01-item-03-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-03-row-01-item-04', 'spacer', 4)
    ]),
    new RelayRowSpec('section-03-row-02', 40, 0, [
        new RelayRowItemSpec('section-03-row-02-item-01', 'group', 10, [new RelayCellSpec('section-03-row-02-item-01-cell-01', 'label', '两侧启动相互闭锁：', 5), new RelayCellSpec('section-03-row-02-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-03-row-02-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-03-row-02-item-03', 'group', 11, [new RelayCellSpec('section-03-row-02-item-03-cell-01', 'label', '远方跳闸受启动元件控制：', 5), new RelayCellSpec('section-03-row-02-item-03-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-03-row-02-item-04', 'spacer', 4)
    ])
  ]),
  new RelaySectionSpec('section-04', '【纵联保护启动元件】', [
    new RelayRowSpec('section-04-row-01', 40, 0, [
        new RelayRowItemSpec('section-04-row-01-item-01', 'group', 10, [new RelayCellSpec('section-04-row-01-item-01-cell-01', 'label', '电流突变量启动元件：', 5), new RelayCellSpec('section-04-row-01-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-04-row-01-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-04-row-01-item-03', 'group', 12, [new RelayCellSpec('section-04-row-01-item-03-cell-01', 'label', '电流突变量启动元件定值：', 10), new RelayCellSpec('section-04-row-01-item-03-cell-02', 'spacer', '', 6), new RelayCellSpec('section-04-row-01-item-03-cell-03', 'input', '820.00', 5), new RelayCellSpec('section-04-row-01-item-03-cell-04', 'unit', 'A', 1)]),
        new RelayRowItemSpec('section-04-row-01-item-04', 'spacer', 3)
    ]),
    new RelayRowSpec('section-04-row-02', 40, 0, [
        new RelayRowItemSpec('section-04-row-02-item-01', 'group', 10, [new RelayCellSpec('section-04-row-02-item-01-cell-01', 'label', '相电流启动元件：', 5), new RelayCellSpec('section-04-row-02-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-04-row-02-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-04-row-02-item-03', 'group', 12, [new RelayCellSpec('section-04-row-02-item-03-cell-01', 'label', '相电流启动元件定值：', 10), new RelayCellSpec('section-04-row-02-item-03-cell-02', 'spacer', '', 6), new RelayCellSpec('section-04-row-02-item-03-cell-03', 'input', '820.00', 5), new RelayCellSpec('section-04-row-02-item-03-cell-04', 'unit', 'A', 1)]),
        new RelayRowItemSpec('section-04-row-02-item-04', 'spacer', 3)
    ]),
    new RelayRowSpec('section-04-row-03', 40, 0, [
        new RelayRowItemSpec('section-04-row-03-item-01', 'group', 10, [new RelayCellSpec('section-04-row-03-item-01-cell-01', 'label', '零序电流变量启动元件：', 5), new RelayCellSpec('section-04-row-03-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-04-row-03-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-04-row-03-item-03', 'group', 12, [new RelayCellSpec('section-04-row-03-item-03-cell-01', 'label', '零序电流变量启动元件定值：', 10), new RelayCellSpec('section-04-row-03-item-03-cell-02', 'spacer', '', 6), new RelayCellSpec('section-04-row-03-item-03-cell-03', 'input', '820.00', 5), new RelayCellSpec('section-04-row-03-item-03-cell-04', 'unit', 'A', 1)]),
        new RelayRowItemSpec('section-04-row-03-item-04', 'spacer', 3)
    ]),
    new RelayRowSpec('section-04-row-04', 40, 0, [
        new RelayRowItemSpec('section-04-row-04-item-01', 'group', 10, [new RelayCellSpec('section-04-row-04-item-01-cell-01', 'label', '电流突变量启动元件：', 5), new RelayCellSpec('section-04-row-04-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-04-row-04-item-02', 'spacer', 5),
        new RelayRowItemSpec('section-04-row-04-item-03', 'group', 12, [new RelayCellSpec('section-04-row-04-item-03-cell-01', 'label', '电流突变量启动元件定值：', 10), new RelayCellSpec('section-04-row-04-item-03-cell-02', 'spacer', '', 6), new RelayCellSpec('section-04-row-04-item-03-cell-03', 'input', '820.00', 5), new RelayCellSpec('section-04-row-04-item-03-cell-04', 'unit', 'A', 1)]),
        new RelayRowItemSpec('section-04-row-04-item-04', 'spacer', 3)
    ])
  ]),
  new RelaySectionSpec('section-05', '【分相电流差动保护】', [
    new RelayRowSpec('section-05-row-01', 40, 0, [
        new RelayRowItemSpec('section-05-row-01-item-01', 'group', 8, [new RelayCellSpec('section-05-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-05-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-05-row-01-item-01-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-05-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-05-row-01-item-03', 'group', 10, [new RelayCellSpec('section-05-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-05-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-05-row-01-item-03-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-05-row-01-item-04', 'spacer', 0),
        new RelayRowItemSpec('section-05-row-01-item-05', 'group', 9, [new RelayCellSpec('section-05-row-01-item-05-cell-01', 'label', '差流定值：', 10), new RelayCellSpec('section-05-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-05-row-01-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-05-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-05-row-01-item-06', 'spacer', 0),
        new RelayRowItemSpec('section-05-row-01-item-07', 'group', 11, [new RelayCellSpec('section-05-row-01-item-07-cell-01', 'label', '差流高定值：', 10), new RelayCellSpec('section-05-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-05-row-01-item-07-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-05-row-01-item-07-cell-04', 'spacer', '', 2)])
    ])
  ]),
  new RelaySectionSpec('section-06', '【零序纵联保护】', [
    new RelayRowSpec('section-06-row-01', 40, 0, [
        new RelayRowItemSpec('section-06-row-01-item-01', 'group', 8, [new RelayCellSpec('section-06-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-06-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-06-row-01-item-01-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-06-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-06-row-01-item-03', 'group', 10, [new RelayCellSpec('section-06-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-06-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-06-row-01-item-03-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-06-row-01-item-04', 'spacer', 0),
        new RelayRowItemSpec('section-06-row-01-item-05', 'group', 9, [new RelayCellSpec('section-06-row-01-item-05-cell-01', 'label', '电流定值：', 10), new RelayCellSpec('section-06-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-06-row-01-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-06-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-06-row-01-item-06', 'spacer', 0),
        new RelayRowItemSpec('section-06-row-01-item-07', 'group', 11, [new RelayCellSpec('section-06-row-01-item-07-cell-01', 'label', '电流高定值：', 10), new RelayCellSpec('section-06-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-06-row-01-item-07-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-06-row-01-item-07-cell-04', 'spacer', '', 2)])
    ]),
    new RelayRowSpec('section-06-row-02', 40, 0, [
        new RelayRowItemSpec('section-06-row-02-item-01', 'group', 10, [new RelayCellSpec('section-06-row-02-item-01-cell-01', 'label', '电流比例系数：', 10), new RelayCellSpec('section-06-row-02-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-06-row-02-item-01-cell-03', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-06-row-02-item-02', 'spacer', 25)
    ])
  ]),
  new RelaySectionSpec('section-07', '【过电流保护公共定值】', [
    new RelayRowSpec('section-07-row-01', 40, 0, [
        new RelayRowItemSpec('section-07-row-01-item-01', 'group', 9, [new RelayCellSpec('section-07-row-01-item-01-cell-01', 'label', '线电压闭锁定值：', 12), new RelayCellSpec('section-07-row-01-item-01-cell-02', 'spacer', '', 2), new RelayCellSpec('section-07-row-01-item-01-cell-03', 'input', '820.00', 8), new RelayCellSpec('section-07-row-01-item-01-cell-04', 'unit', 'V', 1)]),
        new RelayRowItemSpec('section-07-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-07-row-01-item-03', 'group', 11, [new RelayCellSpec('section-07-row-01-item-03-cell-01', 'label', '负序电压闭锁定值：', 12), new RelayCellSpec('section-07-row-01-item-03-cell-02', 'spacer', '', 2), new RelayCellSpec('section-07-row-01-item-03-cell-03', 'input', '820.00', 8), new RelayCellSpec('section-07-row-01-item-03-cell-04', 'unit', 'V', 1)]),
        new RelayRowItemSpec('section-07-row-01-item-04', 'spacer', 2)
    ]),
    new RelayRowSpec('section-07-row-02', 40, 0, [
        new RelayRowItemSpec('section-07-row-02-item-01', 'group', 10, [new RelayCellSpec('section-07-row-02-item-01-cell-01', 'label', '涌流抑制比：', 12), new RelayCellSpec('section-07-row-02-item-01-cell-02', 'spacer', '', 6), new RelayCellSpec('section-07-row-02-item-01-cell-03', 'input', '820.00', 8), new RelayCellSpec('section-07-row-02-item-01-cell-04', 'unit', '%', 1)]),
        new RelayRowItemSpec('section-07-row-02-item-02', 'spacer', 20)
    ])
  ]),
  new RelaySectionSpec('section-08', '【过电流保护I段】', [
    new RelayRowSpec('section-08-row-01', 40, 0, [
        new RelayRowItemSpec('section-08-row-01-item-01', 'group', 10, [new RelayCellSpec('section-08-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-08-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-08-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-08-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-08-row-01-item-03', 'group', 10, [new RelayCellSpec('section-08-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-08-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-08-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-08-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-08-row-01-item-05', 'group', 10, [new RelayCellSpec('section-08-row-01-item-05-cell-01', 'label', '复压元件：', 5), new RelayCellSpec('section-08-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-08-row-01-item-05-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-08-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-08-row-01-item-07', 'group', 10, [new RelayCellSpec('section-08-row-01-item-07-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-08-row-01-item-07-cell-02', 'select', '投入', 1), new RelayCellSpec('section-08-row-01-item-07-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-08-row-01-item-08', 'spacer', 2),
        new RelayRowItemSpec('section-08-row-01-item-09', 'group', 10, [new RelayCellSpec('section-08-row-01-item-09-cell-01', 'label', '涌流抑制：', 5), new RelayCellSpec('section-08-row-01-item-09-cell-02', 'select', '投入', 1), new RelayCellSpec('section-08-row-01-item-09-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-08-row-02', 40, 0, [
        new RelayRowItemSpec('section-08-row-02-item-01', 'group', 10, [new RelayCellSpec('section-08-row-02-item-01-cell-01', 'label', '电流定值：', 10), new RelayCellSpec('section-08-row-02-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-08-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-08-row-02-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-08-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-08-row-02-item-03', 'group', 10, [new RelayCellSpec('section-08-row-02-item-03-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-08-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-08-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-08-row-02-item-03-cell-04', 'spacer', '', 4)]),
        new RelayRowItemSpec('section-08-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-09', '【过电流保护II段】', [
    new RelayRowSpec('section-09-row-01', 40, 0, [
        new RelayRowItemSpec('section-09-row-01-item-01', 'group', 10, [new RelayCellSpec('section-09-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-09-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-09-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-09-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-09-row-01-item-03', 'group', 10, [new RelayCellSpec('section-09-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-09-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-09-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-09-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-09-row-01-item-05', 'group', 10, [new RelayCellSpec('section-09-row-01-item-05-cell-01', 'label', '复压元件：', 5), new RelayCellSpec('section-09-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-09-row-01-item-05-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-09-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-09-row-01-item-07', 'group', 10, [new RelayCellSpec('section-09-row-01-item-07-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-09-row-01-item-07-cell-02', 'select', '投入', 1), new RelayCellSpec('section-09-row-01-item-07-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-09-row-01-item-08', 'spacer', 2),
        new RelayRowItemSpec('section-09-row-01-item-09', 'group', 10, [new RelayCellSpec('section-09-row-01-item-09-cell-01', 'label', '涌流抑制：', 5), new RelayCellSpec('section-09-row-01-item-09-cell-02', 'select', '投入', 1), new RelayCellSpec('section-09-row-01-item-09-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-09-row-02', 40, 0, [
        new RelayRowItemSpec('section-09-row-02-item-01', 'group', 10, [new RelayCellSpec('section-09-row-02-item-01-cell-01', 'label', '电流定值：', 10), new RelayCellSpec('section-09-row-02-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-09-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-09-row-02-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-09-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-09-row-02-item-03', 'group', 10, [new RelayCellSpec('section-09-row-02-item-03-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-09-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-09-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-09-row-02-item-03-cell-04', 'spacer', '', 4)]),
        new RelayRowItemSpec('section-09-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-10', '【过电流保护III段】', [
    new RelayRowSpec('section-10-row-01', 40, 0, [
        new RelayRowItemSpec('section-10-row-01-item-01', 'group', 10, [new RelayCellSpec('section-10-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-10-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-10-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-10-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-10-row-01-item-03', 'group', 10, [new RelayCellSpec('section-10-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-10-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-10-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-10-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-10-row-01-item-05', 'group', 10, [new RelayCellSpec('section-10-row-01-item-05-cell-01', 'label', '复压元件：', 5), new RelayCellSpec('section-10-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-10-row-01-item-05-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-10-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-10-row-01-item-07', 'group', 10, [new RelayCellSpec('section-10-row-01-item-07-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-10-row-01-item-07-cell-02', 'select', '投入', 1), new RelayCellSpec('section-10-row-01-item-07-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-10-row-01-item-08', 'spacer', 2),
        new RelayRowItemSpec('section-10-row-01-item-09', 'group', 10, [new RelayCellSpec('section-10-row-01-item-09-cell-01', 'label', '涌流抑制：', 5), new RelayCellSpec('section-10-row-01-item-09-cell-02', 'select', '投入', 1), new RelayCellSpec('section-10-row-01-item-09-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-10-row-02', 40, 0, [
        new RelayRowItemSpec('section-10-row-02-item-01', 'group', 10, [new RelayCellSpec('section-10-row-02-item-01-cell-01', 'label', '电流定值：', 10), new RelayCellSpec('section-10-row-02-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-10-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-10-row-02-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-10-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-10-row-02-item-03', 'group', 10, [new RelayCellSpec('section-10-row-02-item-03-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-10-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-10-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-10-row-02-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-10-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-11', '【反时限过电流保护】', [
    new RelayRowSpec('section-11-row-01', 40, 0, [
        new RelayRowItemSpec('section-11-row-01-item-01', 'group', 10, [new RelayCellSpec('section-11-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-11-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-11-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-11-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-11-row-01-item-03', 'group', 10, [new RelayCellSpec('section-11-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-11-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-11-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-11-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-11-row-01-item-05', 'group', 10, [new RelayCellSpec('section-11-row-01-item-05-cell-01', 'label', '复压元件：', 5), new RelayCellSpec('section-11-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-11-row-01-item-05-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-11-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-11-row-01-item-07', 'group', 10, [new RelayCellSpec('section-11-row-01-item-07-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-11-row-01-item-07-cell-02', 'select', '投入', 1), new RelayCellSpec('section-11-row-01-item-07-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-11-row-01-item-08', 'spacer', 2),
        new RelayRowItemSpec('section-11-row-01-item-09', 'group', 10, [new RelayCellSpec('section-11-row-01-item-09-cell-01', 'label', '涌流抑制：', 5), new RelayCellSpec('section-11-row-01-item-09-cell-02', 'select', '投入', 1), new RelayCellSpec('section-11-row-01-item-09-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-11-row-02', 40, 0, [
        new RelayRowItemSpec('section-11-row-02-item-01', 'group', 10, [new RelayCellSpec('section-11-row-02-item-01-cell-01', 'label', '反时限特性：', 5), new RelayCellSpec('section-11-row-02-item-01-cell-02', 'select', '一般反时限', 1), new RelayCellSpec('section-11-row-02-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-11-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-11-row-02-item-03', 'group', 10, [new RelayCellSpec('section-11-row-02-item-03-cell-01', 'label', '电流基准值：', 10), new RelayCellSpec('section-11-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-11-row-02-item-03-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-11-row-02-item-03-cell-04', 'spacer', '', 4)]),
        new RelayRowItemSpec('section-11-row-02-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-11-row-02-item-05', 'group', 9, [new RelayCellSpec('section-11-row-02-item-05-cell-01', 'label', '反时限时间定值：', 10), new RelayCellSpec('section-11-row-02-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-11-row-02-item-05-cell-03', 'unit', 's', 1), new RelayCellSpec('section-11-row-02-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-11-row-02-item-06', 'spacer', 1)
    ])
  ]),
  new RelaySectionSpec('section-12', '【PT断线相过电流保护】', [
    new RelayRowSpec('section-12-row-01', 40, 0, [
        new RelayRowItemSpec('section-12-row-01-item-01', 'group', 8, [new RelayCellSpec('section-12-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-12-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-12-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-12-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-12-row-01-item-03', 'group', 10, [new RelayCellSpec('section-12-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-12-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-12-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-12-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-12-row-01-item-05', 'group', 10, [new RelayCellSpec('section-12-row-01-item-05-cell-01', 'label', '电流定值：', 10), new RelayCellSpec('section-12-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-12-row-01-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-12-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-12-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-12-row-01-item-07', 'group', 10, [new RelayCellSpec('section-12-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-12-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-12-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-12-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-13', '【过电流保护加速段】', [
    new RelayRowSpec('section-13-row-01', 40, 0, [
        new RelayRowItemSpec('section-13-row-01-item-01', 'group', 11, [new RelayCellSpec('section-13-row-01-item-01-cell-01', 'label', '手合加速段投/退：', 5), new RelayCellSpec('section-13-row-01-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-13-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-13-row-01-item-03', 'group', 13, [new RelayCellSpec('section-13-row-01-item-03-cell-01', 'label', '手合加速段投入时间：', 12), new RelayCellSpec('section-13-row-01-item-03-cell-02', 'spacer', '', 10), new RelayCellSpec('section-13-row-01-item-03-cell-03', 'input', '820.00', 8), new RelayCellSpec('section-13-row-01-item-03-cell-04', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-13-row-01-item-04', 'spacer', 7)
    ]),
    new RelayRowSpec('section-13-row-02', 40, 0, [
        new RelayRowItemSpec('section-13-row-02-item-01', 'group', 11, [new RelayCellSpec('section-13-row-02-item-01-cell-01', 'label', '重合闸后加速段投/退：', 5), new RelayCellSpec('section-13-row-02-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-13-row-02-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-13-row-02-item-03', 'group', 13, [new RelayCellSpec('section-13-row-02-item-03-cell-01', 'label', '重合闸后加速段投入时间：', 12), new RelayCellSpec('section-13-row-02-item-03-cell-02', 'spacer', '', 10), new RelayCellSpec('section-13-row-02-item-03-cell-03', 'input', '820.00', 8), new RelayCellSpec('section-13-row-02-item-03-cell-04', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-13-row-02-item-04', 'spacer', 7)
    ]),
    new RelayRowSpec('section-13-row-03', 40, 0, [
        new RelayRowItemSpec('section-13-row-03-item-01', 'group', 10, [new RelayCellSpec('section-13-row-03-item-01-cell-01', 'label', '复压元件：', 5), new RelayCellSpec('section-13-row-03-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-13-row-03-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-13-row-03-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-13-row-03-item-03', 'group', 10, [new RelayCellSpec('section-13-row-03-item-03-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-13-row-03-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-13-row-03-item-03-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-13-row-03-item-03-cell-04', 'spacer', '', 18)]),
        new RelayRowItemSpec('section-13-row-03-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-13-row-03-item-05', 'group', 7, [new RelayCellSpec('section-13-row-03-item-05-cell-01', 'label', '时间定值：', 12), new RelayCellSpec('section-13-row-03-item-05-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-13-row-03-item-05-cell-03', 'unit', 's', 1), new RelayCellSpec('section-13-row-03-item-05-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-14', '【零序过流保护I段】', [
    new RelayRowSpec('section-14-row-01', 40, 0, [
        new RelayRowItemSpec('section-14-row-01-item-01', 'group', 10, [new RelayCellSpec('section-14-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-14-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-14-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-14-row-01-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-14-row-01-item-03', 'group', 10, [new RelayCellSpec('section-14-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-14-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-14-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-14-row-01-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-14-row-01-item-05', 'group', 10, [new RelayCellSpec('section-14-row-01-item-05-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-14-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-14-row-01-item-05-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-14-row-02', 40, 0, [
        new RelayRowItemSpec('section-14-row-02-item-01', 'group', 10, [new RelayCellSpec('section-14-row-02-item-01-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-14-row-02-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-14-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-14-row-02-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-14-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-14-row-02-item-03', 'group', 10, [new RelayCellSpec('section-14-row-02-item-03-cell-01', 'label', '时间定值：', 12), new RelayCellSpec('section-14-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-14-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-14-row-02-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-14-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-15', '【零序过流保护II段】', [
    new RelayRowSpec('section-15-row-01', 40, 0, [
        new RelayRowItemSpec('section-15-row-01-item-01', 'group', 10, [new RelayCellSpec('section-15-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-15-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-15-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-15-row-01-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-15-row-01-item-03', 'group', 10, [new RelayCellSpec('section-15-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-15-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-15-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-15-row-01-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-15-row-01-item-05', 'group', 10, [new RelayCellSpec('section-15-row-01-item-05-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-15-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-15-row-01-item-05-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-15-row-02', 40, 0, [
        new RelayRowItemSpec('section-15-row-02-item-01', 'group', 10, [new RelayCellSpec('section-15-row-02-item-01-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-15-row-02-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-15-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-15-row-02-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-15-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-15-row-02-item-03', 'group', 10, [new RelayCellSpec('section-15-row-02-item-03-cell-01', 'label', '时间定值：', 12), new RelayCellSpec('section-15-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-15-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-15-row-02-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-15-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-16', '【零序过流保护III段】', [
    new RelayRowSpec('section-16-row-01', 40, 0, [
        new RelayRowItemSpec('section-16-row-01-item-01', 'group', 10, [new RelayCellSpec('section-16-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-16-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-16-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-16-row-01-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-16-row-01-item-03', 'group', 10, [new RelayCellSpec('section-16-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-16-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-16-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-16-row-01-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-16-row-01-item-05', 'group', 10, [new RelayCellSpec('section-16-row-01-item-05-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-16-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-16-row-01-item-05-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-16-row-02', 40, 0, [
        new RelayRowItemSpec('section-16-row-02-item-01', 'group', 10, [new RelayCellSpec('section-16-row-02-item-01-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-16-row-02-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-16-row-02-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-16-row-02-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-16-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-16-row-02-item-03', 'group', 10, [new RelayCellSpec('section-16-row-02-item-03-cell-01', 'label', '时间定值：', 12), new RelayCellSpec('section-16-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-16-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-16-row-02-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-16-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-17', '【反时限零序过流保护】', [
    new RelayRowSpec('section-17-row-01', 40, 0, [
        new RelayRowItemSpec('section-17-row-01-item-01', 'group', 10, [new RelayCellSpec('section-17-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-17-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-17-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-17-row-01-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-17-row-01-item-03', 'group', 10, [new RelayCellSpec('section-17-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-17-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-17-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-17-row-01-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-17-row-01-item-05', 'group', 10, [new RelayCellSpec('section-17-row-01-item-05-cell-01', 'label', '方向元件：', 5), new RelayCellSpec('section-17-row-01-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-17-row-01-item-05-cell-03', 'spacer', '', 5)])
    ]),
    new RelayRowSpec('section-17-row-02', 40, 0, [
        new RelayRowItemSpec('section-17-row-02-item-01', 'group', 10, [new RelayCellSpec('section-17-row-02-item-01-cell-01', 'label', '反时限特性：', 5), new RelayCellSpec('section-17-row-02-item-01-cell-02', 'select', '一般反时限', 1), new RelayCellSpec('section-17-row-02-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-17-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-17-row-02-item-03', 'group', 10, [new RelayCellSpec('section-17-row-02-item-03-cell-01', 'label', '电流基准值：', 10), new RelayCellSpec('section-17-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-17-row-02-item-03-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-17-row-02-item-03-cell-04', 'spacer', '', 4)]),
        new RelayRowItemSpec('section-17-row-02-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-17-row-02-item-05', 'group', 9, [new RelayCellSpec('section-17-row-02-item-05-cell-01', 'label', '反时限时间定值：', 10), new RelayCellSpec('section-17-row-02-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-17-row-02-item-05-cell-03', 'unit', 's', 1), new RelayCellSpec('section-17-row-02-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-17-row-02-item-06', 'spacer', 1)
    ])
  ]),
  new RelaySectionSpec('section-18', '【零序过流保护加速段】', [
    new RelayRowSpec('section-18-row-01', 40, 0, [
        new RelayRowItemSpec('section-18-row-01-item-01', 'group', 12, [new RelayCellSpec('section-18-row-01-item-01-cell-01', 'label', '手合加速段投/退：', 5), new RelayCellSpec('section-18-row-01-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-18-row-01-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-18-row-01-item-03', 'group', 13, [new RelayCellSpec('section-18-row-01-item-03-cell-01', 'label', '手合加速段投入时间：', 10), new RelayCellSpec('section-18-row-01-item-03-cell-02', 'spacer', '', 8), new RelayCellSpec('section-18-row-01-item-03-cell-03', 'input', '820.00', 10), new RelayCellSpec('section-18-row-01-item-03-cell-04', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-18-row-01-item-04', 'spacer', 10)
    ]),
    new RelayRowSpec('section-18-row-02', 40, 0, [
        new RelayRowItemSpec('section-18-row-02-item-01', 'group', 12, [new RelayCellSpec('section-18-row-02-item-01-cell-01', 'label', '重合闸后加速段投/退：', 5), new RelayCellSpec('section-18-row-02-item-01-cell-02', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-18-row-02-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-18-row-02-item-03', 'group', 13, [new RelayCellSpec('section-18-row-02-item-03-cell-01', 'label', '重合闸后加速段投入时间：', 10), new RelayCellSpec('section-18-row-02-item-03-cell-02', 'spacer', '', 8), new RelayCellSpec('section-18-row-02-item-03-cell-03', 'input', '820.00', 10), new RelayCellSpec('section-18-row-02-item-03-cell-04', 'unit', 's', 1)]),
        new RelayRowItemSpec('section-18-row-02-item-04', 'spacer', 10)
    ]),
    new RelayRowSpec('section-18-row-03', 40, 0, [
        new RelayRowItemSpec('section-18-row-03-item-01', 'group', 10, [new RelayCellSpec('section-18-row-03-item-01-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-18-row-03-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-18-row-03-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-18-row-03-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-18-row-03-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-18-row-03-item-03', 'group', 10, [new RelayCellSpec('section-18-row-03-item-03-cell-01', 'label', '时间定值：', 12), new RelayCellSpec('section-18-row-03-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-18-row-03-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-18-row-03-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-18-row-03-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-19', '【自适应零序过流保护】', [
    new RelayRowSpec('section-19-row-01', 40, 0, [
        new RelayRowItemSpec('section-19-row-01-item-01', 'group', 10, [new RelayCellSpec('section-19-row-01-item-01-cell-01', 'label', '电流门槛值：', 12), new RelayCellSpec('section-19-row-01-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-19-row-01-item-01-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-19-row-01-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-19-row-01-item-02', 'spacer', 1),
        new RelayRowItemSpec('section-19-row-01-item-03', 'group', 12, [new RelayCellSpec('section-19-row-01-item-03-cell-01', 'label', '零序补偿系数：', 8), new RelayCellSpec('section-19-row-01-item-03-cell-02', 'input', '820.00', 1), new RelayCellSpec('section-19-row-01-item-03-cell-03', 'unit', '+j', 1), new RelayCellSpec('section-19-row-01-item-03-cell-04', 'input', '820.00', 1), new RelayCellSpec('section-19-row-01-item-03-cell-05', 'spacer', '', 7)]),
        new RelayRowItemSpec('section-19-row-01-item-04', 'spacer', 1),
        new RelayRowItemSpec('section-19-row-01-item-05', 'group', 12, [new RelayCellSpec('section-19-row-01-item-05-cell-01', 'label', '系统阻抗：', 8), new RelayCellSpec('section-19-row-01-item-05-cell-02', 'input', '820.00', 1), new RelayCellSpec('section-19-row-01-item-05-cell-03', 'unit', '+j', 1), new RelayCellSpec('section-19-row-01-item-05-cell-04', 'input', '820.00', 1), new RelayCellSpec('section-19-row-01-item-05-cell-05', 'spacer', '', 7)])
    ]),
    new RelayRowSpec('section-19-row-02', 40, 0, [
        new RelayRowItemSpec('section-19-row-02-item-01', 'group', 20, [new RelayCellSpec('section-19-row-02-item-01-cell-01', 'label', 'I段投/退：', 5), new RelayCellSpec('section-19-row-02-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-02-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-19-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-19-row-02-item-03', 'group', 20, [new RelayCellSpec('section-19-row-02-item-03-cell-01', 'label', 'II段投/退：', 5), new RelayCellSpec('section-19-row-02-item-03-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-02-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-19-row-02-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-19-row-02-item-05', 'group', 20, [new RelayCellSpec('section-19-row-02-item-05-cell-01', 'label', 'III段投/退：', 5), new RelayCellSpec('section-19-row-02-item-05-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-02-item-05-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-19-row-02-item-06', 'spacer', 3),
        new RelayRowItemSpec('section-19-row-02-item-07', 'group', 20, [new RelayCellSpec('section-19-row-02-item-07-cell-01', 'label', '反时限投投/退：', 5), new RelayCellSpec('section-19-row-02-item-07-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-02-item-07-cell-03', 'spacer', '', 10)])
    ]),
    new RelayRowSpec('section-19-row-03', 40, 0, [
        new RelayRowItemSpec('section-19-row-03-item-01', 'group', 20, [new RelayCellSpec('section-19-row-03-item-01-cell-01', 'label', '手合加速段投/退：', 8), new RelayCellSpec('section-19-row-03-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-03-item-01-cell-03', 'spacer', '', 7)]),
        new RelayRowItemSpec('section-19-row-03-item-02', 'spacer', 12),
        new RelayRowItemSpec('section-19-row-03-item-03', 'group', 20, [new RelayCellSpec('section-19-row-03-item-03-cell-01', 'label', '重合闸后加速段投/退：', 8), new RelayCellSpec('section-19-row-03-item-03-cell-02', 'select', '投入', 1), new RelayCellSpec('section-19-row-03-item-03-cell-03', 'spacer', '', 7)]),
        new RelayRowItemSpec('section-19-row-03-item-04', 'spacer', 10)
    ])
  ]),
  new RelaySectionSpec('section-20', '【重合闸保护】', [
    new RelayRowSpec('section-20-row-01', 40, 0, [
        new RelayRowItemSpec('section-20-row-01-item-01', 'group', 10, [new RelayCellSpec('section-20-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-20-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-20-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-20-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-01-item-03', 'group', 15, [new RelayCellSpec('section-20-row-01-item-03-cell-01', 'label', '重合闸方式：', 10), new RelayCellSpec('section-20-row-01-item-03-cell-02', 'select', '闭锁', 16), new RelayCellSpec('section-20-row-01-item-03-cell-03', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-20-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-01-item-05', 'group', 15, [new RelayCellSpec('section-20-row-01-item-05-cell-01', 'label', '重合闸后加速段投入时间：', 10), new RelayCellSpec('section-20-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-01-item-05-cell-03', 'unit', 's', 1), new RelayCellSpec('section-20-row-01-item-05-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-01-item-06', 'spacer', 1)
    ]),
    new RelayRowSpec('section-20-row-02', 40, 0, [
        new RelayRowItemSpec('section-20-row-02-item-01', 'group', 10, [new RelayCellSpec('section-20-row-02-item-01-cell-01', 'label', '开关偷跳：', 5), new RelayCellSpec('section-20-row-02-item-01-cell-02', 'select', '不重合', 1), new RelayCellSpec('section-20-row-02-item-01-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-20-row-02-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-02-item-03', 'group', 15, [new RelayCellSpec('section-20-row-02-item-03-cell-01', 'label', '大电流闭锁：', 10), new RelayCellSpec('section-20-row-02-item-03-cell-02', 'select', '投入', 5), new RelayCellSpec('section-20-row-02-item-03-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-20-row-02-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-02-item-05', 'group', 15, [new RelayCellSpec('section-20-row-02-item-05-cell-01', 'label', '大电流闭锁值：', 10), new RelayCellSpec('section-20-row-02-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-02-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-20-row-02-item-05-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-02-item-06', 'spacer', 1)
    ]),
    new RelayRowSpec('section-20-row-03', 40, 0, [
        new RelayRowItemSpec('section-20-row-03-item-01', 'group', 10, [new RelayCellSpec('section-20-row-03-item-01-cell-01', 'label', '检同期角度：', 10), new RelayCellSpec('section-20-row-03-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-03-item-01-cell-03', 'unit', '°', 1), new RelayCellSpec('section-20-row-03-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-03-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-03-item-03', 'group', 15, [new RelayCellSpec('section-20-row-03-item-03-cell-01', 'label', '检同期开发时间定值：', 10), new RelayCellSpec('section-20-row-03-item-03-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-03-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-20-row-03-item-03-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-03-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-20-row-03-item-05', 'group', 15, [new RelayCellSpec('section-20-row-03-item-05-cell-01', 'label', '检无压开放时间定值：', 10), new RelayCellSpec('section-20-row-03-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-03-item-05-cell-03', 'unit', 's', 1), new RelayCellSpec('section-20-row-03-item-05-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-03-item-06', 'spacer', 1)
    ]),
    new RelayRowSpec('section-20-row-04', 40, 0, [
        new RelayRowItemSpec('section-20-row-04-item-01', 'group', 10, [new RelayCellSpec('section-20-row-04-item-01-cell-01', 'label', '跳闸时间定值：', 10), new RelayCellSpec('section-20-row-04-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-20-row-04-item-01-cell-03', 'unit', 's', 1), new RelayCellSpec('section-20-row-04-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-20-row-04-item-02', 'spacer', 35)
    ])
  ]),
  new RelaySectionSpec('section-21', '【过负荷保护】', [
    new RelayRowSpec('section-21-row-01', 40, 0, [
        new RelayRowItemSpec('section-21-row-01-item-01', 'group', 10, [new RelayCellSpec('section-21-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-21-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-21-row-01-item-01-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-21-row-01-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-21-row-01-item-03', 'group', 10, [new RelayCellSpec('section-21-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-21-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-21-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-21-row-01-item-04', 'spacer', 3),
        new RelayRowItemSpec('section-21-row-01-item-05', 'group', 10, [new RelayCellSpec('section-21-row-01-item-05-cell-01', 'label', '电流定值：', 12), new RelayCellSpec('section-21-row-01-item-05-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-21-row-01-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-21-row-01-item-05-cell-04', 'spacer', '', 10)])
    ]),
    new RelayRowSpec('section-21-row-02', 40, 0, [
        new RelayRowItemSpec('section-21-row-02-item-01', 'group', 10, [new RelayCellSpec('section-21-row-02-item-01-cell-01', 'label', '跳闸时间定值：', 12), new RelayCellSpec('section-21-row-02-item-01-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-21-row-02-item-01-cell-03', 'unit', 's', 1), new RelayCellSpec('section-21-row-02-item-01-cell-04', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-21-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-21-row-02-item-03', 'group', 10, [new RelayCellSpec('section-21-row-02-item-03-cell-01', 'label', '告警时间定值：', 12), new RelayCellSpec('section-21-row-02-item-03-cell-02', 'input', '820.00', 8), new RelayCellSpec('section-21-row-02-item-03-cell-03', 'unit', 's', 1), new RelayCellSpec('section-21-row-02-item-03-cell-04', 'spacer', '', 0)]),
        new RelayRowItemSpec('section-21-row-02-item-04', 'spacer', 13)
    ])
  ]),
  new RelaySectionSpec('section-22', '【低电压保护】', [
    new RelayRowSpec('section-22-row-01', 40, 0, [
        new RelayRowItemSpec('section-22-row-01-item-01', 'group', 8, [new RelayCellSpec('section-22-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-22-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-22-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-22-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-01-item-03', 'group', 10, [new RelayCellSpec('section-22-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-22-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-22-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-22-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-01-item-05', 'group', 10, [new RelayCellSpec('section-22-row-01-item-05-cell-01', 'label', '电压定值：', 10), new RelayCellSpec('section-22-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-01-item-05-cell-03', 'unit', 'V', 1), new RelayCellSpec('section-22-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-22-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-01-item-07', 'group', 10, [new RelayCellSpec('section-22-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-22-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-22-row-01-item-07-cell-04', 'spacer', '', 0)])
    ]),
    new RelayRowSpec('section-22-row-02', 40, 0, [
        new RelayRowItemSpec('section-22-row-02-item-01', 'group', 10, [new RelayCellSpec('section-22-row-02-item-01-cell-01', 'label', '低压闭锁定值：', 10), new RelayCellSpec('section-22-row-02-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-02-item-01-cell-03', 'unit', 'V', 1), new RelayCellSpec('section-22-row-02-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-22-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-22-row-02-item-03', 'group', 10, [new RelayCellSpec('section-22-row-02-item-03-cell-01', 'label', '电压滑差闭锁：', 10), new RelayCellSpec('section-22-row-02-item-03-cell-02', 'select', '投入', 5), new RelayCellSpec('section-22-row-02-item-03-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-22-row-02-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-02-item-05', 'group', 11, [new RelayCellSpec('section-22-row-02-item-05-cell-01', 'label', '电压滑差闭锁定值：', 10), new RelayCellSpec('section-22-row-02-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-02-item-05-cell-03', 'unit', 'V/s', 1), new RelayCellSpec('section-22-row-02-item-05-cell-04', 'spacer', '', 8)])
    ]),
    new RelayRowSpec('section-22-row-03', 40, 0, [
        new RelayRowItemSpec('section-22-row-03-item-01', 'group', 11, [new RelayCellSpec('section-22-row-03-item-01-cell-01', 'label', '滑差解除闭锁定值：', 10), new RelayCellSpec('section-22-row-03-item-01-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-03-item-01-cell-03', 'unit', 'V/s', 1), new RelayCellSpec('section-22-row-03-item-01-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-22-row-03-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-03-item-03', 'group', 10, [new RelayCellSpec('section-22-row-03-item-03-cell-01', 'label', '无流闭锁：', 10), new RelayCellSpec('section-22-row-03-item-03-cell-02', 'select', '投入', 5), new RelayCellSpec('section-22-row-03-item-03-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-22-row-03-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-22-row-03-item-05', 'group', 11, [new RelayCellSpec('section-22-row-03-item-05-cell-01', 'label', '无流闭锁定值：', 10), new RelayCellSpec('section-22-row-03-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-22-row-03-item-05-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-22-row-03-item-05-cell-04', 'spacer', '', 8)])
    ])
  ]),
  new RelaySectionSpec('section-23', '【过电压保护】', [
    new RelayRowSpec('section-23-row-01', 40, 0, [
        new RelayRowItemSpec('section-23-row-01-item-01', 'group', 8, [new RelayCellSpec('section-23-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-23-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-23-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-23-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-23-row-01-item-03', 'group', 10, [new RelayCellSpec('section-23-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-23-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-23-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-23-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-23-row-01-item-05', 'group', 10, [new RelayCellSpec('section-23-row-01-item-05-cell-01', 'label', '电压定值：', 10), new RelayCellSpec('section-23-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-23-row-01-item-05-cell-03', 'unit', 'V', 1), new RelayCellSpec('section-23-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-23-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-23-row-01-item-07', 'group', 10, [new RelayCellSpec('section-23-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-23-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-23-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-23-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-24', '【低频保护】', [
    new RelayRowSpec('section-24-row-01', 40, 0, [
        new RelayRowItemSpec('section-24-row-01-item-01', 'group', 8, [new RelayCellSpec('section-24-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-24-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-24-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-24-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-24-row-01-item-03', 'group', 10, [new RelayCellSpec('section-24-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-24-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-24-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-24-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-24-row-01-item-05', 'group', 10, [new RelayCellSpec('section-24-row-01-item-05-cell-01', 'label', '频率定值：', 10), new RelayCellSpec('section-24-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-24-row-01-item-05-cell-03', 'unit', 'Hz', 1), new RelayCellSpec('section-24-row-01-item-05-cell-04', 'spacer', '', 2)]),
        new RelayRowItemSpec('section-24-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-24-row-01-item-07', 'group', 10, [new RelayCellSpec('section-24-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-24-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-24-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-24-row-01-item-07-cell-04', 'spacer', '', 0)])
    ]),
    new RelayRowSpec('section-24-row-02', 40, 0, [
        new RelayRowItemSpec('section-24-row-02-item-01', 'group', 10, [new RelayCellSpec('section-24-row-02-item-01-cell-01', 'label', '跳闸模式：', 5), new RelayCellSpec('section-24-row-02-item-01-cell-02', 'select', '解列', 1), new RelayCellSpec('section-24-row-02-item-01-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-24-row-02-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-24-row-02-item-03', 'group', 10, [new RelayCellSpec('section-24-row-02-item-03-cell-01', 'label', '频率滑流闭锁：', 10), new RelayCellSpec('section-24-row-02-item-03-cell-02', 'select', '投入', 5), new RelayCellSpec('section-24-row-02-item-03-cell-03', 'spacer', '', 10)]),
        new RelayRowItemSpec('section-24-row-02-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-24-row-02-item-05', 'group', 11, [new RelayCellSpec('section-24-row-02-item-05-cell-01', 'label', '频率滑差闭锁定值：', 10), new RelayCellSpec('section-24-row-02-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-24-row-02-item-05-cell-03', 'unit', 'Hz/s', 1), new RelayCellSpec('section-24-row-02-item-05-cell-04', 'spacer', '', 8)])
    ]),
    new RelayRowSpec('section-24-row-03', 40, 0, [
        new RelayRowItemSpec('section-24-row-03-item-01', 'group', 10, [new RelayCellSpec('section-24-row-03-item-01-cell-01', 'label', '无流闭锁：', 5), new RelayCellSpec('section-24-row-03-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-24-row-03-item-01-cell-03', 'spacer', '', 3)]),
        new RelayRowItemSpec('section-24-row-03-item-02', 'spacer', 3),
        new RelayRowItemSpec('section-24-row-03-item-03', 'group', 10, [new RelayCellSpec('section-24-row-03-item-03-cell-01', 'label', '无流闭锁定值：', 10), new RelayCellSpec('section-24-row-03-item-03-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-24-row-03-item-03-cell-03', 'unit', 'A', 1), new RelayCellSpec('section-24-row-03-item-03-cell-04', 'spacer', '', 8)]),
        new RelayRowItemSpec('section-24-row-03-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-24-row-03-item-05', 'group', 11, [new RelayCellSpec('section-24-row-03-item-05-cell-01', 'label', '低压闭锁定值：', 10), new RelayCellSpec('section-24-row-03-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-24-row-03-item-05-cell-03', 'unit', 'V', 1), new RelayCellSpec('section-24-row-03-item-05-cell-04', 'spacer', '', 8)])
    ])
  ]),
  new RelaySectionSpec('section-25', '【高频保护】', [
    new RelayRowSpec('section-25-row-01', 40, 0, [
        new RelayRowItemSpec('section-25-row-01-item-01', 'group', 8, [new RelayCellSpec('section-25-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-25-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-25-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-25-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-25-row-01-item-03', 'group', 10, [new RelayCellSpec('section-25-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-25-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-25-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-25-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-25-row-01-item-05', 'group', 10, [new RelayCellSpec('section-25-row-01-item-05-cell-01', 'label', '频率定值：', 10), new RelayCellSpec('section-25-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-25-row-01-item-05-cell-03', 'unit', 'Hz', 1), new RelayCellSpec('section-25-row-01-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-25-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-25-row-01-item-07', 'group', 10, [new RelayCellSpec('section-25-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-25-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-25-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-25-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-26', '【逆功率保护】', [
    new RelayRowSpec('section-26-row-01', 40, 0, [
        new RelayRowItemSpec('section-26-row-01-item-01', 'group', 8, [new RelayCellSpec('section-26-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-26-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-26-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-26-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-26-row-01-item-03', 'group', 10, [new RelayCellSpec('section-26-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-26-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-26-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-26-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-26-row-01-item-05', 'group', 10, [new RelayCellSpec('section-26-row-01-item-05-cell-01', 'label', '功率定值：', 10), new RelayCellSpec('section-26-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-26-row-01-item-05-cell-03', 'unit', 'kW', 1), new RelayCellSpec('section-26-row-01-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-26-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-26-row-01-item-07', 'group', 10, [new RelayCellSpec('section-26-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-26-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-26-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-26-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-27', '【谐波电流保护】', [
    new RelayRowSpec('section-27-row-01', 40, 0, [
        new RelayRowItemSpec('section-27-row-01-item-01', 'group', 8, [new RelayCellSpec('section-27-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-27-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-27-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-27-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-27-row-01-item-03', 'group', 10, [new RelayCellSpec('section-27-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-27-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-27-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-27-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-27-row-01-item-05', 'group', 10, [new RelayCellSpec('section-27-row-01-item-05-cell-01', 'label', 'THDu定值：', 10), new RelayCellSpec('section-27-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-27-row-01-item-05-cell-03', 'unit', '%', 1), new RelayCellSpec('section-27-row-01-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-27-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-27-row-01-item-07', 'group', 10, [new RelayCellSpec('section-27-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-27-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-27-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-27-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ]),
  new RelaySectionSpec('section-28', '【谐波电压保护】', [
    new RelayRowSpec('section-28-row-01', 40, 0, [
        new RelayRowItemSpec('section-28-row-01-item-01', 'group', 8, [new RelayCellSpec('section-28-row-01-item-01-cell-01', 'label', '投/退：', 5), new RelayCellSpec('section-28-row-01-item-01-cell-02', 'select', '投入', 1), new RelayCellSpec('section-28-row-01-item-01-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-28-row-01-item-02', 'spacer', 2),
        new RelayRowItemSpec('section-28-row-01-item-03', 'group', 10, [new RelayCellSpec('section-28-row-01-item-03-cell-01', 'label', '保护模式：', 5), new RelayCellSpec('section-28-row-01-item-03-cell-02', 'select', '跳闸', 1), new RelayCellSpec('section-28-row-01-item-03-cell-03', 'spacer', '', 5)]),
        new RelayRowItemSpec('section-28-row-01-item-04', 'spacer', 2),
        new RelayRowItemSpec('section-28-row-01-item-05', 'group', 10, [new RelayCellSpec('section-28-row-01-item-05-cell-01', 'label', 'THDu定值：', 10), new RelayCellSpec('section-28-row-01-item-05-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-28-row-01-item-05-cell-03', 'unit', '%', 1), new RelayCellSpec('section-28-row-01-item-05-cell-04', 'spacer', '', 1)]),
        new RelayRowItemSpec('section-28-row-01-item-06', 'spacer', 2),
        new RelayRowItemSpec('section-28-row-01-item-07', 'group', 10, [new RelayCellSpec('section-28-row-01-item-07-cell-01', 'label', '时间定值：', 10), new RelayCellSpec('section-28-row-01-item-07-cell-02', 'input', '820.00', 10), new RelayCellSpec('section-28-row-01-item-07-cell-03', 'unit', 's', 1), new RelayCellSpec('section-28-row-01-item-07-cell-04', 'spacer', '', 0)])
    ])
  ])
];
const RELAY_MONITOR_SECTIONS: RelayMonitorSectionSpec[] = [
  new RelayMonitorSectionSpec('bus-pt-monitor', '【母线PT断线监测】', [
    new RelayMonitorFieldSpec('bus-pt-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('bus-pt-block', '闭锁相关保护：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('bus-pt-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('line-pt-monitor', '【线路PT断线监测】', [
    new RelayMonitorFieldSpec('line-pt-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('line-pt-block', '闭锁相关保护：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('line-pt-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('ct-monitor', '【CT断线监测】', [
    new RelayMonitorFieldSpec('ct-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('ct-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('cb-monitor', '【控制回路断线监测】', [
    new RelayMonitorFieldSpec('cb-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('cb-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('spring-monitor', '【弹簧未储能监测】', [
    new RelayMonitorFieldSpec('spring-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('spring-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('twj-monitor', '【TWJ异常监测】', [
    new RelayMonitorFieldSpec('twj-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('twj-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('freq-monitor', '【频率异常监测】', [
    new RelayMonitorFieldSpec('freq-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('freq-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ]),
  new RelayMonitorSectionSpec('ground-monitor', '【接地监测】', [
    new RelayMonitorFieldSpec('ground-enable', '投/退：', '投入', '', 'select', 88),
    new RelayMonitorFieldSpec('ground-delay', '告警延时定值：', '820.00', 's', 'input', 116)
  ])
];

const RELAY_FIELD_BINDINGS: RelayFieldBinding[] = buildRelayFieldBindings(RELAY_MAIN_SECTIONS, RELAY_MONITOR_SECTIONS);

@Observed
class RelaySettingVM {
  headerMode: HeaderModeState = new HeaderModeState();
  noticeText: string = '';
  titleLeft: string = '定值管理';
  titleRight: string = '—整定 1 区保护定值';
  actions: BottomActionState = new BottomActionState();
  timeText: string = '2024/12/30\n12:12:30';
}

@Component
struct QtStaticCheck {
  @Prop checked: boolean = false;
  @Prop label: string = '';
  @Prop boxSize: number = 30;
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#000000';
  @Prop fontFamilyName: string = 'STKaiti';

  build() {
    Row() {
      Stack() {
        Row()
          .width(this.boxSize)
          .height(this.boxSize)
          .backgroundColor('#FFFFFF')
          .border({ width: 1.4, color: '#000000' })
          .borderRadius(1);

        if (this.checked) {
          Text('√')
            .fontSize(this.boxSize * 0.82)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .width(this.boxSize)
            .height(this.boxSize)
            .textAlign(TextAlign.Center);
        }
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .margin({ right: 6 });

      Text(this.label)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontFamily(this.fontFamilyName)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip });
    }
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start);
  }
}

@Entry
@Component
struct RelaySettingSet {
  @StorageLink('relay_setting_set_store') relaySettingStore: string = '';
  @StorageLink('relay_setting_profiles_store_v2') relaySettingProfilesStore: string = '';
  @State profilesStore: RelaySettingProfilesStore = new RelaySettingProfilesStore();
  @State vm: RelaySettingVM = new RelaySettingVM();
  @State uiScale: number = 1;
  @State modeInSelected: boolean = true;
  @State currentZoneCode: string = '00';
  @State currentProfileIndex: number = 0;
  @State selectOverlayVisible: boolean = false;
  @State selectOverlayTitle: string = '请选择';
  @State selectOverlayOptions: string[] = [];
  @State selectOverlayValue: string = '';
  @State selectOverlayTargetId: string = '';

  private readonly checkBoxSize: number = 28;
  private readonly noticeFontSize: number = 18;
  private readonly midFontSize: number = 18;
  private readonly titleFontSize: number = 20;
  private readonly sectionTitleFontSize: number = 18;
  private readonly fieldLabelFontSize: number = 18;
  private readonly fieldValueFontSize: number = 18;
  private readonly inputValueFontSize: number = 16;
  private readonly fieldUnitFontSize: number = 18;
  private readonly fieldMinFontSize: number = 15;
  private readonly inputBoxHeight: number = 34;
  private readonly sectionCardRadius: number = 3;
  private readonly fieldBoxRadius: number = 1;
  private readonly bottomButtonHeight: number = 46;
  private readonly bottomButtonRadius: number = 14;

  private s(v: number): number {
    return Math.round(v * this.uiScale);
  }

  private scopedValueKeyForZone(zoneCode: string, id: string): string {
    return zoneCode + '|' + id;
  }

  private findValueIndex(entries: RelayValueEntry[], key: string): number {
    for (let i = 0; i < entries.length; i++) {
      if (entries[i].key === key) {
        return i;
      }
    }
    return -1;
  }

  private deserializeValueEntries(raw: string): RelayValueEntry[] {
    let entries: RelayValueEntry[] = [];
    if (raw.length === 0) {
      return entries;
    }
    let lines = raw.split('\n');
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i];
      if (line.length === 0) {
        continue;
      }
      let splitIndex = line.indexOf('\t');
      if (splitIndex < 0) {
        continue;
      }
      let key = line.substring(0, splitIndex);
      let encodedValue = line.substring(splitIndex + 1);
      let value = encodedValue;
      try {
        value = decodeURIComponent(encodedValue);
      } catch (e) {
        value = encodedValue;
      }
      entries.push(new RelayValueEntry(key, value));
    }
    return entries;
  }

  private bindingForFieldId(fieldId: string): RelayFieldBinding | undefined {
    return relayFindFieldBinding(RELAY_FIELD_BINDINGS, fieldId);
  }

  private currentProfile(): RelaySettingProfile | undefined {
    if (this.currentProfileIndex < 0 || this.currentProfileIndex >= this.profilesStore.profiles.length) {
      return undefined;
    }
    return this.profilesStore.profiles[this.currentProfileIndex];
  }

  private syncCurrentZoneState(zoneCode?: string): void {
    this.currentZoneCode = relayNormalizeZoneCode(zoneCode ? zoneCode : this.currentZoneCode);
    this.currentProfileIndex = relayZoneCodeToIndex(this.currentZoneCode);
    this.syncCurrentZoneTitle();
  }

  private syncCurrentZoneTitle(): void {
    this.vm.titleRight = '—整定 ' + this.currentZoneCode + ' 区保护定值';
  }

  private findLegacyValue(entries: RelayValueEntry[], key: string): string | undefined {
    let index = this.findValueIndex(entries, key);
    if (index === -1) {
      return undefined;
    }
    return entries[index].value;
  }

  private migrateLegacyProfilesStore(): RelaySettingProfilesStore {
    let store = createDefaultRelaySettingProfilesStore(RELAY_FIELD_BINDINGS);
    let entries = this.deserializeValueEntries(this.relaySettingStore);
    if (entries.length === 0) {
      return store;
    }

    for (let entryIndex = 0; entryIndex < entries.length; entryIndex++) {
      let entry = entries[entryIndex];
      let splitIndex = entry.key.indexOf('|');
      if (splitIndex <= 0 || splitIndex >= entry.key.length - 1) {
        continue;
      }

      let rawZoneCode = entry.key.substring(0, splitIndex).trim();
      if (!/^\d{1,2}$/.test(rawZoneCode)) {
        continue;
      }

      let binding = this.bindingForFieldId(entry.key.substring(splitIndex + 1));
      if (!binding) {
        continue;
      }

      let normalizedZoneCode = relayNormalizeZoneCode(rawZoneCode);
      let targetProfile = store.profiles[relayZoneCodeToIndex(normalizedZoneCode)];
      let previousField = relayReadProfileField(targetProfile, binding);
      let nextField = relayParseStoredField(
        entry.value,
        binding,
        previousField ? previousField : relayDefaultStoredField(binding)
      );
      relayWriteProfileField(targetProfile, binding, nextField);
    }

    return store;
  }

  private loadValueEntries(): void {
    let nextStore = this.relaySettingProfilesStore.trim().length > 0
      ? relayDeserializeProfilesStore(this.relaySettingProfilesStore, RELAY_FIELD_BINDINGS)
      : undefined;

    if (nextStore) {
      this.profilesStore = nextStore;
      return;
    }

    if (this.relaySettingProfilesStore.trim().length === 0) {
      let migratedStore = this.migrateLegacyProfilesStore();
      this.profilesStore = migratedStore;
      this.relaySettingProfilesStore = relaySerializeProfilesStore(migratedStore);
      return;
    }

    this.profilesStore = createDefaultRelaySettingProfilesStore(RELAY_FIELD_BINDINGS);
  }

  private saveValueEntries(noticeText: string = ''): void {
    this.relaySettingProfilesStore = relaySerializeProfilesStore(this.profilesStore);
    this.vm.noticeText = noticeText;
  }

  private resetCurrentZoneValues(): void {
    let nextStore = cloneRelaySettingProfilesStoreForProfileUpdate(this.profilesStore, this.currentProfileIndex);
    nextStore.profiles[this.currentProfileIndex] = createDefaultRelaySettingProfile(this.currentZoneCode, RELAY_FIELD_BINDINGS);
    this.profilesStore = nextStore;
    this.saveValueEntries();
  }

  private sameStoredField(left: RelayStoredField | undefined, right: RelayStoredField): boolean {
    return !!left &&
      left.valueType === right.valueType &&
      left.textValue === right.textValue &&
      left.numberValue === right.numberValue &&
      left.enumValue === right.enumValue;
  }

  private readValue(fieldId: string, fallbackValue: string): string {
    let binding = this.bindingForFieldId(fieldId);
    if (!binding) {
      return fallbackValue;
    }
    let profile = this.currentProfile();
    if (!profile) {
      return fallbackValue;
    }
    return relayFormatStoredField(relayReadProfileField(profile, binding), binding);
  }

  private writeValue(fieldId: string, value: string): void {
    let binding = this.bindingForFieldId(fieldId);
    if (!binding) {
      return;
    }
    let profile = this.currentProfile();
    if (!profile) {
      return;
    }

    let currentField = relayReadProfileField(profile, binding);
    let nextField = relayParseStoredField(
      value,
      binding,
      currentField ? currentField : relayDefaultStoredField(binding)
    );
    if (this.sameStoredField(currentField, nextField)) {
      return;
    }

    let nextStore = cloneRelaySettingProfilesStoreForProfileUpdate(this.profilesStore, this.currentProfileIndex);
    let nextProfile = nextStore.profiles[this.currentProfileIndex];
    relayWriteProfileField(nextProfile, binding, nextField);
    this.profilesStore = nextStore;
    this.vm.noticeText = '';
  }

  private stripUnitSuffix(value: string, unit: string): string {
    let next = value.trim();
    if (unit.length === 0 || next.length === 0) {
      return next;
    }
    let spacedSuffix = ' ' + unit;
    if (next.endsWith(spacedSuffix)) {
      return next.substring(0, next.length - spacedSuffix.length).trim();
    }
    if (next.endsWith(unit)) {
      return next.substring(0, next.length - unit.length).trim();
    }
    return next;
  }

  private unitTextInCells(cells: RelayCellSpec[]): string {
    for (let cellIndex = 0; cellIndex < cells.length; cellIndex++) {
      if (cells[cellIndex].kind === 'unit') {
        return cells[cellIndex].text;
      }
    }
    return '';
  }

  private itemHasFieldContent(item: RelayRowItemSpec): boolean {
    for (let cellIndex = 0; cellIndex < item.cells.length; cellIndex++) {
      if (item.cells[cellIndex].kind === 'label' || item.cells[cellIndex].kind === 'input' || item.cells[cellIndex].kind === 'select') {
        return true;
      }
    }
    return false;
  }

  private findCellUnitText(cellId: string): string {
    for (let sectionIndex = 0; sectionIndex < RELAY_MAIN_SECTIONS.length; sectionIndex++) {
      let section = RELAY_MAIN_SECTIONS[sectionIndex];
      for (let rowIndex = 0; rowIndex < section.rows.length; rowIndex++) {
        let row = section.rows[rowIndex];
        for (let itemIndex = 0; itemIndex < row.items.length; itemIndex++) {
          let item = row.items[itemIndex];
          for (let cellIndex = 0; cellIndex < item.cells.length; cellIndex++) {
            if (item.cells[cellIndex].id !== cellId) {
              continue;
            }
            let localUnit = this.unitTextInCells(item.cells);
            if (localUnit.length > 0) {
              return localUnit;
            }
            for (let nextItemIndex = itemIndex + 1; nextItemIndex < row.items.length; nextItemIndex++) {
              let nextItem = row.items[nextItemIndex];
              let nextUnit = this.unitTextInCells(nextItem.cells);
              if (nextUnit.length > 0) {
                return nextUnit;
              }
              if (this.itemHasFieldContent(nextItem)) {
                break;
              }
            }
            return '';
          }
        }
      }
    }
    return '';
  }

  private normalizeCellInputValue(cell: RelayCellSpec, value: string): string {
    if (cell.kind !== 'input') {
      return value;
    }
    return this.stripUnitSuffix(value, this.findCellUnitText(cell.id));
  }

  private normalizeMonitorInputValue(field: RelayMonitorFieldSpec, value: string): string {
    if (field.kind !== 'input') {
      return value;
    }
    return this.stripUnitSuffix(value, field.unit);
  }

  private getCellValue(cell: RelayCellSpec): string {
    return this.readValue(cell.id, cell.text);
  }

  private setCellValue(cell: RelayCellSpec, value: string): void {
    this.writeValue(cell.id, this.normalizeCellInputValue(cell, value));
  }

  private getMonitorFieldValue(field: RelayMonitorFieldSpec): string {
    return this.readValue(field.id, field.value);
  }

  private setMonitorFieldValue(field: RelayMonitorFieldSpec, value: string): void {
    this.writeValue(field.id, this.normalizeMonitorInputValue(field, value));
  }

  private appendUniqueOption(options: string[], option: string): void {
    if (option.length === 0) {
      return;
    }
    for (let i = 0; i < options.length; i++) {
      if (options[i] === option) {
        return;
      }
    }
    options.push(option);
  }

  private defaultSelectOptions(defaultValue: string): string[] {
    return relayDefaultSelectOptions(defaultValue);
  }

  private selectOptionsForValue(defaultValue: string, currentValue: string): string[] {
    let options = this.defaultSelectOptions(defaultValue);
    this.appendUniqueOption(options, currentValue);
    return options;
  }

  private findCellLabel(cellId: string): string {
    for (let sectionIndex = 0; sectionIndex < RELAY_MAIN_SECTIONS.length; sectionIndex++) {
      let section = RELAY_MAIN_SECTIONS[sectionIndex];
      for (let rowIndex = 0; rowIndex < section.rows.length; rowIndex++) {
        let row = section.rows[rowIndex];
        for (let itemIndex = 0; itemIndex < row.items.length; itemIndex++) {
          let item = row.items[itemIndex];
          for (let cellIndex = 0; cellIndex < item.cells.length; cellIndex++) {
            let cell = item.cells[cellIndex];
            if (cell.id !== cellId) {
              continue;
            }
            for (let localIndex = 0; localIndex < item.cells.length; localIndex++) {
              if (item.cells[localIndex].kind === 'label') {
                return item.cells[localIndex].text;
              }
            }
            for (let prevItemIndex = itemIndex - 1; prevItemIndex >= 0; prevItemIndex--) {
              let prevItem = row.items[prevItemIndex];
              for (let prevCellIndex = prevItem.cells.length - 1; prevCellIndex >= 0; prevCellIndex--) {
                if (prevItem.cells[prevCellIndex].kind === 'label') {
                  return prevItem.cells[prevCellIndex].text;
                }
              }
            }
            return '请选择';
          }
        }
      }
    }
    return '请选择';
  }

  private openCellSelect(cell: RelayCellSpec): void {
    let currentValue = this.getCellValue(cell);
    this.selectOverlayTargetId = cell.id;
    this.selectOverlayTitle = this.findCellLabel(cell.id);
    this.selectOverlayOptions = this.selectOptionsForValue(cell.text, currentValue);
    this.selectOverlayValue = currentValue;
    this.selectOverlayVisible = true;
  }

  private openMonitorSelect(field: RelayMonitorFieldSpec): void {
    let currentValue = this.getMonitorFieldValue(field);
    this.selectOverlayTargetId = field.id;
    this.selectOverlayTitle = field.label;
    this.selectOverlayOptions = this.selectOptionsForValue(field.value, currentValue);
    this.selectOverlayValue = currentValue;
    this.selectOverlayVisible = true;
  }

  private closeSelectOverlay(): void {
    this.selectOverlayVisible = false;
  }

  private applySelectOverlayValue(value: string): void {
    this.writeValue(this.selectOverlayTargetId, value);
    this.selectOverlayValue = value;
    this.closeSelectOverlay();
  }

  private labelCellMinWidth(text: string): number {
    if (text.length >= 18) {
      return 248;
    }
    if (text.length >= 14) {
      return 210;
    }
    if (text.length >= 10) {
      return 178;
    }
    if (text.length >= 8) {
      return 158;
    }
    if (text.length >= 6) {
      return 126;
    }
    if (text.length >= 4) {
      return 104;
    }
    return 76;
  }

  private isRightEdgeTimeCell(cellId: string): boolean {
    return cellId.indexOf('section-10-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-11-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-12-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-13-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-14-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-15-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-16-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-17-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-18-row-03-item-03-cell-') === 0 ||
      cellId.indexOf('section-21-row-02-item-03-cell-') === 0 ||
      cellId.indexOf('section-22-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-23-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-24-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-25-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-26-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-27-row-01-item-07-cell-') === 0 ||
      cellId.indexOf('section-28-row-01-item-07-cell-') === 0;
  }

  private isRightEdgeWideUnitCell(cellId: string): boolean {
    return cellId.indexOf('section-20-row-03-item-03-cell-') === 0 ||
      cellId.indexOf('section-20-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-22-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-22-row-03-item-05-cell-') === 0 ||
      cellId.indexOf('section-24-row-02-item-05-cell-') === 0 ||
      cellId.indexOf('section-24-row-03-item-05-cell-') === 0;
  }

  private unitMinWidthForCell(cell: RelayCellSpec): number {
    if (this.isRightEdgeTimeCell(cell.id)) {
      return cell.text.length >= 2 ? 12 : 10;
    }
    if (this.isRightEdgeWideUnitCell(cell.id)) {
      return cell.text.length >= 4 ? 28 : 20;
    }
    if (cell.id.indexOf('section-01-row-') === 0) {
      return 28;
    }
    if (cell.text.length >= 4) {
      return 30;
    }
    if (cell.text.length >= 3) {
      return 26;
    }
    if (cell.text.length >= 2) {
      return 20;
    }
    return 16;
  }

  private unitLeftMarginForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-06-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-01-item-10-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-03-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-07-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-11-cell-01') === 0) {
      return 18;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-03') === 0 ||
      cell.id.indexOf('section-05-row-01-item-07-cell-03') === 0 ||
      cell.id.indexOf('section-06-row-01-item-05-cell-03') === 0 ||
      cell.id.indexOf('section-06-row-01-item-07-cell-03') === 0) {
      return 0;
    }
    if (cell.id.indexOf('section-01-row-') === 0) {
      return 8;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 0;
    }
    if (this.isRightEdgeWideUnitCell(cell.id)) {
      return 1;
    }
    return 2;
  }

  private selectCellMinWidth(text: string): number {
    if (text.length >= 16) {
      return 204;
    }
    if (text.length >= 12) {
      return 176;
    }
    if (text.length >= 8) {
      return 144;
    }
    if (text.length >= 5) {
      return 112;
    }
    if (text.length >= 3) {
      return 82;
    }
    return 64;
  }

  private valueCellMinWidth(text: string): number {
    if (text.length >= 18) {
      return 228;
    }
    if (text.length >= 12) {
      return 188;
    }
    if (text.length >= 9) {
      return 144;
    }
    if (text.length >= 6) {
      return 116;
    }
    return 92;
  }

  private labelMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-04-cell-01') === 0) {
      return 164;
    }
    if (cell.id.indexOf('section-01-row-01-item-08-cell-01') === 0) {
      return 154;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-05-cell-01') === 0) {
      return 82;
    }
    if (cell.id.indexOf('section-05-row-01-item-07-cell-01') === 0 || cell.id.indexOf('section-06-row-01-item-07-cell-01') === 0) {
      return 110;
    }
    if (cell.id.indexOf('section-07-row-01-item-01-cell-01') === 0) {
      return 124;
    }
    if (cell.id.indexOf('section-07-row-01-item-03-cell-01') === 0) {
      return 152;
    }
    if (cell.id.indexOf('section-11-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-01') === 0) {
      return 122;
    }
    if (cell.id.indexOf('section-13-row-03-item-05-cell-01') === 0) {
      return 90;
    }
    if (cell.id.indexOf('section-21-row-02-item-03-cell-01') === 0) {
      return 96;
    }
    if (cell.id.indexOf('section-20-row-03-item-03-cell-01') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-01') === 0) {
      return 126;
    }
    if (cell.id.indexOf('section-22-row-02-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-01') === 0) {
      return 128;
    }
    if (cell.id.indexOf('section-22-row-03-item-05-cell-01') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-01') === 0) {
      return 118;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 86;
    }
    if (cell.id.indexOf('section-19-row-01-item-03-cell-01') === 0 || cell.id.indexOf('section-19-row-01-item-05-cell-01') === 0) {
      return 98;
    }
    if (cell.id.indexOf('section-19-row-02-') === 0) {
      return cell.text.length >= 8 ? 104 : 88;
    }
    if (cell.id.indexOf('section-19-row-03-item-01-cell-01') === 0) {
      return 150;
    }
    if (cell.id.indexOf('section-19-row-03-item-03-cell-01') === 0) {
      return 192;
    }
    if (cell.id.indexOf('section-19-row-03-') === 0) {
      return 116;
    }
    return this.labelCellMinWidth(cell.text);
  }

  private selectMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-19-row-02-') === 0 || cell.id.indexOf('section-19-row-03-') === 0) {
      return 64;
    }
    return this.selectCellMinWidth(cell.text);
  }

  private valueMinWidthForCell(cell: RelayCellSpec): number {
    if (cell.id.indexOf('section-01-row-01-item-05-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-01-item-09-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-06-cell-01') === 0 ||
      cell.id.indexOf('section-01-row-02-item-10-cell-01') === 0) {
      return 76;
    }
    if (cell.id.indexOf('section-01-row-02-item-02-cell-01') === 0) {
      return 80;
    }
    if (cell.id.indexOf('section-07-row-01-item-01-cell-03') === 0 || cell.id.indexOf('section-07-row-01-item-03-cell-03') === 0) {
      return 72;
    }
    if (cell.id.indexOf('section-05-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-05-row-01-item-07-cell-02') === 0 ||
      cell.id.indexOf('section-06-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-06-row-01-item-07-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-11-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-17-row-02-item-05-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-13-row-03-item-05-cell-02') === 0) {
      return 72;
    }
    if (cell.id.indexOf('section-20-row-03-item-03-cell-02') === 0 || cell.id.indexOf('section-20-row-03-item-05-cell-02') === 0) {
      return 78;
    }
    if (cell.id.indexOf('section-21-row-02-item-03-cell-02') === 0) {
      return 82;
    }
    if (cell.id.indexOf('section-22-row-02-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-02-item-05-cell-02') === 0) {
      return 74;
    }
    if (cell.id.indexOf('section-22-row-03-item-05-cell-02') === 0 || cell.id.indexOf('section-24-row-03-item-05-cell-02') === 0) {
      return 78;
    }
    if (this.isRightEdgeTimeCell(cell.id)) {
      return 78;
    }
    if (cell.id.indexOf('section-19-row-01-item-01-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-03-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-03-cell-04') === 0 ||
      cell.id.indexOf('section-19-row-01-item-05-cell-02') === 0 ||
      cell.id.indexOf('section-19-row-01-item-05-cell-04') === 0) {
      return 76;
    }
    return this.valueCellMinWidth(cell.text);
  }

  private monitorFieldBoxWidth(field: RelayMonitorFieldSpec): number {
    let currentValue = this.getMonitorFieldValue(field);
    let minWidth = field.kind === 'select' ? this.selectCellMinWidth(currentValue) : this.valueCellMinWidth(currentValue);
    return field.boxWidth > minWidth ? field.boxWidth : minWidth;
  }

  private selectBoxMinWidth(cell: RelayCellSpec): number {
    let currentWidth = this.selectCellMinWidth(this.getCellValue(cell));
    let defaultWidth = this.selectMinWidthForCell(cell);
    return currentWidth > defaultWidth ? currentWidth : defaultWidth;
  }

  aboutToAppear(): void {
    this.modeInSelected = this.vm.headerMode.inMode.checked;
    this.syncCurrentZoneState('00');
    try {
      let d = display.getDefaultDisplaySync();
      let sx = d.width / 1024;
      let sy = d.height / 600;
      let val = Math.min(sx, sy);
      this.uiScale = val > 0 ? val : 1;
    } catch (e) {
      this.uiScale = 1;
    }

    try {
      let params = router.getParams() as RouterParams;
      this.syncCurrentZoneState(params.zoneCode?.trim());
    } catch (e) {
      this.syncCurrentZoneState();
    }

    this.loadValueEntries();
    this.syncCurrentZoneTitle();
  }

  private setMode(isIn: boolean): void {
    this.modeInSelected = isIn;
    this.vm.headerMode.inMode.checked = isIn;
    this.vm.headerMode.outMode.checked = !isIn;
  }

  build() {
    Stack() {
      Column() {
        this.HeaderBar();

        Scroll() {
          Column() {
            ForEach(RELAY_MAIN_SECTIONS, (section: RelaySectionSpec) => {
              this.SectionCard(section);
            }, (section: RelaySectionSpec) => section.id)

            this.MonitorSections();
          }
          .width('100%')
          .padding({ left: this.s(10), right: this.s(16), top: this.s(5), bottom: this.s(7) });
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#FFFFFF');

        this.BottomBar();
      }

      if (this.selectOverlayVisible) {
        this.SelectOverlay();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  HeaderBar() {
    Row() {
      Text(this.vm.noticeText)
        .layoutWeight(200)
        .minFontSize(12)
        .maxLines(1)
        .fontSize(this.s(this.noticeFontSize))
        .fontColor('#EF2929')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(40);

      Text(this.vm.titleLeft)
        .layoutWeight(120)
        .minFontSize(14)
        .maxLines(1)
        .fontSize(this.s(this.titleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('sans-serif-condensed')
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.End);

      Text(this.vm.titleRight)
        .layoutWeight(240)
        .minFontSize(14)
        .maxLines(1)
        .fontSize(this.s(this.titleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);

      Blank().layoutWeight(40);

      Button() {
        Image($r('app.media.return'))
          .width(this.s(24))
          .height(this.s(24));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });

      Button() {
        Image($r('app.media.close'))
          .width(this.s(20))
          .height(this.s(20));
      }
      .layoutWeight(80)
      .height(this.s(36))
      .padding(0)
      .backgroundColor('#D3D3D3')
      .border({ width: 0 })
      .onClick(() => {
        router.back();
      });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(10), right: this.s(10), top: this.s(8), bottom: this.s(8) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }

  @Builder
  SectionCard(section: RelaySectionSpec) {
    Column() {
      Text(section.title)
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .width('100%')
        .padding({ left: this.s(14), right: this.s(14) })
        .margin({ bottom: this.s(4) });

      ForEach(section.rows, (row: RelayRowSpec, rowIndex: number) => {
        this.SectionRow(row);
        if (rowIndex !== section.rows.length - 1) {
          Blank().height(this.s(3));
        }
      }, (row: RelayRowSpec) => row.id)
    }
    .width('100%')
    .padding({ top: this.s(6), bottom: this.s(6) })
    .margin({ bottom: this.s(6) })
    .backgroundColor('#FBFBFB')
    .border({ width: 1, color: '#DCDCDC' })
    .borderRadius(this.s(this.sectionCardRadius));
  }

  @Builder
  SectionRow(row: RelayRowSpec) {
    Row() {
      if (row.leftMargin > 0) {
        Blank().width(this.s(row.leftMargin));
      }

      ForEach(row.items, (item: RelayRowItemSpec) => {
        this.RowItem(item);
      }, (item: RelayRowItemSpec) => item.id)

      if (row.rightMargin > 0) {
        Blank().width(this.s(row.rightMargin));
      }
    }
    .width('100%')
    .constraintSize({ minHeight: this.s(34) })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  RowItem(item: RelayRowItemSpec) {
    if (item.kind === 'spacer') {
      Blank().layoutWeight(item.weight);
    } else {
      Row() {
        ForEach(item.cells, (cell: RelayCellSpec) => {
          this.RowCell(cell);
        }, (cell: RelayCellSpec) => cell.id)
      }
      .layoutWeight(item.weight)
      .alignItems(VerticalAlign.Center);
    }
  }

  @Builder
  RowCell(cell: RelayCellSpec) {
    if (cell.kind === 'spacer') {
      Blank().layoutWeight(cell.weight);
    } else if (cell.kind === 'label') {
      Text(cell.text)
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(this.labelMinWidthForCell(cell)) })
        .fontSize(this.s(this.fieldLabelFontSize))
        .minFontSize(this.s(this.fieldMinFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .textAlign(TextAlign.Start);
    } else if (cell.kind === 'unit') {
      Text(cell.text)
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(this.unitMinWidthForCell(cell)) })
        .fontSize(this.s(this.fieldUnitFontSize))
        .fontColor('#444444')
        .fontFamily('STKaiti')
        .maxLines(1)
        .margin({ left: this.s(this.unitLeftMarginForCell(cell)) })
        .textAlign(TextAlign.Start);
    } else if (cell.kind === 'select') {
      Row() {
        Text(this.getCellValue(cell))
          .layoutWeight(1)
          .fontSize(this.s(this.inputValueFontSize))
          .fontColor('#111111')
          .fontFamily('STKaiti')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
          .textAlign(TextAlign.Start);

        Image($r('app.media.right_black'))
          .width(this.s(10))
          .height(this.s(10))
          .margin({ left: this.s(3) });
      }
      .layoutWeight(cell.weight)
      .constraintSize({ minWidth: this.s(this.selectBoxMinWidth(cell)) })
      .height(this.s(this.inputBoxHeight))
      .padding({ left: this.s(5), right: this.s(5) })
      .backgroundColor('#FCFCFC')
      .border({ width: 1, color: '#C8C8C8' })
      .borderRadius(this.s(this.fieldBoxRadius))
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.openCellSelect(cell);
      });
    } else {
      TextInput({ text: this.getCellValue(cell), placeholder: '' })
        .layoutWeight(cell.weight)
        .constraintSize({ minWidth: this.s(this.valueMinWidthForCell(cell)) })
        .height(this.s(this.inputBoxHeight))
        .fontSize(this.s(this.inputValueFontSize))
        .fontColor('#111111')
        .fontFamily(cell.text.indexOf(':') !== -1 ? 'sans-serif' : 'monospace')
        .backgroundColor('#FCFCFC')
        .border({ width: 1, color: '#C8C8C8' })
        .borderRadius(this.s(this.fieldBoxRadius))
        .padding({ left: this.s(5), right: this.s(5), top: this.s(1), bottom: this.s(1) })
        .textAlign(TextAlign.Start)
        .onChange((value: string) => {
          this.setCellValue(cell, value);
        });
    }
  }

  @Builder
  MonitorSections() {
    Column() {
      ForEach(RELAY_MONITOR_SECTIONS, (section: RelayMonitorSectionSpec, index: number) => {
        this.MonitorSection(section, index === 0);
      }, (section: RelayMonitorSectionSpec) => section.id)
    }
    .width('100%')
    .padding({ left: this.s(16), right: this.s(16), bottom: this.s(5) });
  }

  @Builder
  MonitorSection(section: RelayMonitorSectionSpec, isFirst: boolean) {
    Column() {
      Divider()
        .strokeWidth(this.s(1))
        .color('#B8B8B8')
        .width('100%')
        .margin({ bottom: this.s(4), top: isFirst ? 0 : this.s(3) });

      Text(section.title)
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .width('100%')
        .margin({ bottom: this.s(4) });

      Row() {
        ForEach(section.fields, (field: RelayMonitorFieldSpec, index: number) => {
          this.MonitorField(field);
          if (index !== section.fields.length - 1) {
            Blank().width(this.s(section.fields.length === 3 ? 38 : 92));
          }
        }, (field: RelayMonitorFieldSpec) => field.id)

        Blank().layoutWeight(1);
      }
      .width('100%')
      .padding({ left: this.s(32), right: this.s(6), bottom: this.s(1) })
      .alignItems(VerticalAlign.Center);
    }
    .width('100%');
  }

  @Builder
  MonitorField(field: RelayMonitorFieldSpec) {
    Row() {
      Text(field.label)
        .fontSize(this.s(this.fieldLabelFontSize))
        .minFontSize(this.s(this.fieldMinFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .margin({ right: this.s(6) });

      Row() {
        if (field.kind === 'select') {
          Text(this.getMonitorFieldValue(field))
            .layoutWeight(1)
            .fontSize(this.s(this.inputValueFontSize))
            .fontColor('#111111')
            .fontFamily('STKaiti')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })
            .textAlign(TextAlign.Start);

          Image($r('app.media.right_black'))
            .width(this.s(12))
            .height(this.s(12))
            .margin({ left: this.s(4) });
        } else {
          TextInput({ text: this.getMonitorFieldValue(field), placeholder: '' })
            .layoutWeight(1)
            .height('100%')
            .fontSize(this.s(this.inputValueFontSize))
            .fontColor('#111111')
            .fontFamily('monospace')
            .backgroundColor('#00000000')
            .border({ width: 0 })
            .padding({ left: 0, right: 0, top: this.s(1), bottom: this.s(1) })
            .textAlign(TextAlign.Start)
            .onChange((value: string) => {
              this.setMonitorFieldValue(field, value);
            });
        }
      }
      .width(this.s(this.monitorFieldBoxWidth(field)))
      .height(this.s(this.inputBoxHeight))
      .padding({ left: this.s(5), right: this.s(5) })
      .backgroundColor('#FCFCFC')
      .border({ width: 1, color: '#C8C8C8' })
      .borderRadius(this.s(this.fieldBoxRadius))
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        if (field.kind === 'select') {
          this.openMonitorSelect(field);
        }
      });

      if (field.kind !== 'select' && field.unit !== '') {
        Text(field.unit)
          .fontSize(this.s(this.fieldUnitFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .margin({ left: this.s(6) });
      }
    }
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SelectOverlay() {
    Stack() {
      Row() {
      }
        .width('100%')
        .height('100%')
        .backgroundColor('#55000000')
        .onClick(() => {
          this.closeSelectOverlay();
        });

      Column() {
        Text(this.selectOverlayTitle)
          .width('100%')
          .fontSize(this.s(this.sectionTitleFontSize))
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .textAlign(TextAlign.Center)
          .margin({ bottom: this.s(10) });

        ForEach(this.selectOverlayOptions, (option: string) => {
          Button() {
            Text(option)
              .fontSize(this.s(this.fieldLabelFontSize))
              .fontColor('#000000')
              .fontFamily('STKaiti');
          }
          .width('100%')
          .height(this.s(42))
          .margin({ bottom: this.s(6) })
          .backgroundColor(option === this.selectOverlayValue ? '#D9E9F8' : '#FFFFFF')
          .border({ width: 1, color: option === this.selectOverlayValue ? '#7A9CC0' : '#BEBEBE' })
          .borderRadius(4)
          .onClick(() => {
            this.applySelectOverlayValue(option);
          });
        }, (option: string) => option)

        Button('取消')
          .width('100%')
          .height(this.s(40))
          .margin({ top: this.s(4) })
          .fontSize(this.s(this.fieldLabelFontSize))
          .fontColor('#000000')
          .fontFamily('STKaiti')
          .backgroundColor('#E5E5E5')
          .border({ width: 0 })
          .onClick(() => {
            this.closeSelectOverlay();
          });
      }
      .width(this.s(320))
      .padding({ left: this.s(14), right: this.s(14), top: this.s(14), bottom: this.s(14) })
      .backgroundColor('#F7F7F7')
      .border({ width: 1, color: '#D2D2D2' })
      .borderRadius(8);
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  BottomBar() {
    Row() {
      Blank().layoutWeight(5);

      Button(this.vm.actions.defaultText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          this.resetCurrentZoneValues();
        });

      Blank().layoutWeight(10);

      Button(this.vm.actions.confirmText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          this.saveValueEntries();
        });

      Blank().layoutWeight(5);

      Button(this.vm.actions.closeText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(5);

      Button(this.vm.actions.cancelText)
        .layoutWeight(20)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.sectionTitleFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#C7C7C7')
        .border({ width: 0 })
        .borderRadius(this.s(this.bottomButtonRadius))
        .onClick(() => {
          router.back();
        });

      Blank().layoutWeight(10);

      Text(this.vm.timeText)
        .layoutWeight(25)
        .height(this.s(this.bottomButtonHeight))
        .fontSize(this.s(this.midFontSize))
        .fontColor('#000000')
        .fontFamily('STKaiti')
        .textAlign(TextAlign.Center)
        .padding({ top: 0, bottom: 0 });
    }
    .width('100%')
    .height(this.s(70))
    .padding({ left: this.s(8), right: this.s(8), top: this.s(6), bottom: this.s(5) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#D3D3D3');
  }
}
