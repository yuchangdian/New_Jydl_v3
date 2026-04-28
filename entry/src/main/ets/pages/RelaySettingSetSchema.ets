
export class RelayCellSpec {
  id: string;
  kind: string;
  text: string;
  weight: number;
  bindingIndex: number = -1;
  labelText: string = '请选择';
  unitText: string = '';
  labelMinWidth: number = 0;
  valueMinWidth: number = 0;
  selectMinWidth: number = 0;
  unitMinWidth: number = 0;
  unitLeftMargin: number = 0;
  inputFontFamily: string = 'monospace';

  constructor(id: string, kind: string, text: string, weight: number) {
    this.id = id;
    this.kind = kind;
    this.text = text;
    this.weight = weight;
  }
}

export class RelayRowItemSpec {
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

export class RelayRowSpec {
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

export class RelaySectionSpec {
  id: string;
  title: string;
  rows: RelayRowSpec[];

  constructor(id: string, title: string, rows: RelayRowSpec[]) {
    this.id = id;
    this.title = title;
    this.rows = rows;
  }
}

export class RelayMonitorFieldSpec {
  id: string;
  label: string;
  value: string;
  unit: string;
  kind: string;
  boxWidth: number;
  bindingIndex: number = -1;
  resolvedBoxWidth: number = 0;
  inputFontFamily: string = 'monospace';

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

export class RelayMonitorSectionSpec {
  id: string;
  title: string;
  fields: RelayMonitorFieldSpec[];

  constructor(id: string, title: string, fields: RelayMonitorFieldSpec[]) {
    this.id = id;
    this.title = title;
    this.fields = fields;
  }
}

export function createRelayMainSections(): RelaySectionSpec[] {
  return [
  new RelaySectionSpec('section-01', '【公共定值】', [
    new RelayRowSpec('section-01-row-01', 40, 0, [
        new RelayRowItemSpec('section-01-row-01-item-01', 'group', 8, [new RelayCellSpec('section-01-row-01-item-01-cell-01', 'label', '故障指示灯复位：', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-02', 'group', 5, [new RelayCellSpec('section-01-row-01-item-02-cell-01', 'select', '投入', 1)]),
        new RelayRowItemSpec('section-01-row-01-item-03', 'spacer', 2),
        new RelayRowItemSpec('section-01-row-01-item-05', 'group', 17, [
            new RelayCellSpec('section-01-row-01-item-05-cell-03', 'label', '故障指示灯复归时间：', 10),
            new RelayCellSpec('section-01-row-01-item-05-cell-01', 'input', '120.00', 3),
            new RelayCellSpec('section-01-row-01-item-05-cell-02', 'unit', 's', 2)
        ]),
        new RelayRowItemSpec('section-01-row-01-item-07', 'spacer', 3),
        new RelayRowItemSpec('section-01-row-01-item-09', 'group', 16, [
            new RelayCellSpec('section-01-row-01-item-09-cell-03', 'label', '故障遥信保持时间：', 10),
            new RelayCellSpec('section-01-row-01-item-09-cell-01', 'input', '120.00', 3),
            new RelayCellSpec('section-01-row-01-item-09-cell-02', 'unit', 's', 3)
        ]),
        new RelayRowItemSpec('section-01-row-01-item-11', 'spacer', 1)
    ]),
    new RelayRowSpec('section-01-row-02', 40, 0, [
        new RelayRowItemSpec('section-01-row-02-item-02', 'group', 14, [
            new RelayCellSpec('section-01-row-02-item-02-cell-03', 'label', '无压定值：', 8),
            new RelayCellSpec('section-01-row-02-item-02-cell-01', 'input', '120.00', 4),
            new RelayCellSpec('section-01-row-02-item-02-cell-02', 'unit', 'V', 2)
        ]),
        new RelayRowItemSpec('section-01-row-02-item-04', 'spacer', 1),
        new RelayRowItemSpec('section-01-row-02-item-06', 'group', 17, [
            new RelayCellSpec('section-01-row-02-item-06-cell-03', 'label', '无电流定值：', 10),
            new RelayCellSpec('section-01-row-02-item-06-cell-01', 'input', '120.00', 3),
            new RelayCellSpec('section-01-row-02-item-06-cell-02', 'unit', 'A', 2)
        ]),
        new RelayRowItemSpec('section-01-row-02-item-08', 'spacer', 3),
        new RelayRowItemSpec('section-01-row-02-item-10', 'group', 16, [
            new RelayCellSpec('section-01-row-02-item-10-cell-03', 'label', '有压定值：', 10),
            new RelayCellSpec('section-01-row-02-item-10-cell-01', 'input', '120.00', 3),
            new RelayCellSpec('section-01-row-02-item-10-cell-02', 'unit', 'V', 3)
        ]),
        new RelayRowItemSpec('section-01-row-02-item-12', 'spacer', 1)
    ]),
    new RelayRowSpec('section-01-row-03', 40, 0, [
        new RelayRowItemSpec('section-01-row-03-item-02', 'group', 15, [
            new RelayCellSpec('section-01-row-03-item-02-cell-02', 'label', '过量继电器返回系数：', 10),
            new RelayCellSpec('section-01-row-03-item-02-cell-01', 'input', '120.00', 5)
        ]),
        new RelayRowItemSpec('section-01-row-03-item-03', 'spacer', 10),
        new RelayRowItemSpec('section-01-row-03-item-05', 'group', 15, [
            new RelayCellSpec('section-01-row-03-item-05-cell-02', 'label', '欠量继电器返回系数：', 10),
            new RelayCellSpec('section-01-row-03-item-05-cell-01', 'input', '120.00', 5)
        ]),
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
}

export function createRelayMonitorSections(): RelayMonitorSectionSpec[] {
  return [
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
}
