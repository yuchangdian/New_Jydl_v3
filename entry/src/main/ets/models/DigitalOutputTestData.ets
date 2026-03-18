export class DigitalOutputTestItemPosition {
  x: number = 0;
  y: number = 0;

  constructor(x: number = 0, y: number = 0) {
    this.x = x;
    this.y = y;
  }
}

@Observed
export class DigitalOutputTestItemState {
  checked: boolean = false;
}

@Observed
export class DigitalOutputTestItem {
  key: string = '';
  label: string = '';
  position: DigitalOutputTestItemPosition = new DigitalOutputTestItemPosition();
  state: DigitalOutputTestItemState = new DigitalOutputTestItemState();
}

class DigitalOutputTestDefaultItem {
  key: string = '';
  label: string = '';
  position: DigitalOutputTestItemPosition = new DigitalOutputTestItemPosition();

  constructor(key: string, label: string, x: number, y: number) {
    this.key = key;
    this.label = label;
    this.position = new DigitalOutputTestItemPosition(x, y);
  }
}

const DIGITAL_OUTPUT_TEST_DEFAULT_ITEMS: DigitalOutputTestDefaultItem[] = [
  new DigitalOutputTestDefaultItem('Box_QDJ1', '启动继电器1', 50, 24),
  new DigitalOutputTestDefaultItem('Box_BTJ1', '保护跳闸1', 50, 74),
  new DigitalOutputTestDefaultItem('Box_BHJ1', '保护合闸1', 50, 124),
  new DigitalOutputTestDefaultItem('Box_YTJ1', '遥控跳闸1', 50, 174),
  new DigitalOutputTestDefaultItem('Box_YHJ1', '遥控合闸1', 50, 224),
  new DigitalOutputTestDefaultItem('Box_QDJ2', '启动继电器2', 290, 24),
  new DigitalOutputTestDefaultItem('Box_BTJ2', '保护跳闸2', 290, 74),
  new DigitalOutputTestDefaultItem('Box_BHJ2', '保护合闸2', 290, 124),
  new DigitalOutputTestDefaultItem('Box_YTJ2', '遥控跳闸2', 290, 174),
  new DigitalOutputTestDefaultItem('Box_YHJ2', '遥控合闸2', 290, 224),
  new DigitalOutputTestDefaultItem('Box_QDJ3', '启动继电器3', 530, 24),
  new DigitalOutputTestDefaultItem('Box_CKJ1', '开出继电器1', 530, 74),
  new DigitalOutputTestDefaultItem('Box_CKJ2', '开出继电器2', 530, 124),
  new DigitalOutputTestDefaultItem('Box_CKJ3', '开出继电器3', 530, 174),
  new DigitalOutputTestDefaultItem('Box_GJJ', '告警继电器', 770, 24),
  new DigitalOutputTestDefaultItem('Box_YCJ', '异常继电器', 770, 74),
  new DigitalOutputTestDefaultItem('Box_SGZJ', '事故总继电器', 770, 124),
  new DigitalOutputTestDefaultItem('Box_BTXJ', '跳闸信号继电器', 770, 174),
  new DigitalOutputTestDefaultItem('Box_BHXJ', '合闸信号继电器', 770, 224),
  new DigitalOutputTestDefaultItem('Box_MC1', '母差保护开出1', 770, 274),
  new DigitalOutputTestDefaultItem('Box_MC2', '母差保护开出2', 770, 324),
  new DigitalOutputTestDefaultItem('Box_FGJ', '复归继电器', 770, 374)
];

function createDigitalOutputTestItem(config: DigitalOutputTestDefaultItem): DigitalOutputTestItem {
  let item = new DigitalOutputTestItem();
  item.key = config.key;
  item.label = config.label;
  item.position = new DigitalOutputTestItemPosition(config.position.x, config.position.y);
  item.state.checked = false;
  return item;
}

export function createDefaultDigitalOutputTestItems(): DigitalOutputTestItem[] {
  return DIGITAL_OUTPUT_TEST_DEFAULT_ITEMS.map((item: DigitalOutputTestDefaultItem) => {
    return createDigitalOutputTestItem(item);
  });
}

export function cloneDigitalOutputTestItem(source: DigitalOutputTestItem): DigitalOutputTestItem {
  let item = new DigitalOutputTestItem();
  item.key = source.key;
  item.label = source.label;
  item.position = new DigitalOutputTestItemPosition(source.position.x, source.position.y);
  item.state.checked = source.state.checked;
  return item;
}

export function serializeDigitalOutputTestItems(items: DigitalOutputTestItem[]): string {
  let data: Record<string, boolean> = {};
  items.forEach((item: DigitalOutputTestItem) => {
    data[item.key] = item.state.checked;
  });
  return JSON.stringify(data);
}

export function deserializeDigitalOutputTestItems(raw: string): DigitalOutputTestItem[] | undefined {
  if (raw.trim().length === 0) {
    return undefined;
  }

  try {
    let parsed = JSON.parse(raw) as Record<string, boolean>;
    let items = createDefaultDigitalOutputTestItems();
    if (!parsed || typeof parsed !== 'object') {
      return items;
    }

    items.forEach((item: DigitalOutputTestItem) => {
      let value = parsed[item.key];
      if (typeof value === 'boolean') {
        item.state.checked = value;
      }
    });
    return items;
  } catch (error) {
    return undefined;
  }
}
