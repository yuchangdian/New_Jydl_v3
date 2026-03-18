@Observed
export class DigitalOutputTestItem {
  key: string = '';
  label: string = '';
  x: number = 0;
  y: number = 0;
  checked: boolean = false;
}

interface DigitalOutputTestDefaultItem {
  key: string;
  label: string;
  x: number;
  y: number;
}

const DIGITAL_OUTPUT_TEST_DEFAULT_ITEMS: DigitalOutputTestDefaultItem[] = [
  { key: 'Box_QDJ1', label: '启动继电器1', x: 50, y: 24 },
  { key: 'Box_BTJ1', label: '保护跳闸1', x: 50, y: 74 },
  { key: 'Box_BHJ1', label: '保护合闸1', x: 50, y: 124 },
  { key: 'Box_YTJ1', label: '遥控跳闸1', x: 50, y: 174 },
  { key: 'Box_YHJ1', label: '遥控合闸1', x: 50, y: 224 },
  { key: 'Box_QDJ2', label: '启动继电器2', x: 290, y: 24 },
  { key: 'Box_BTJ2', label: '保护跳闸2', x: 290, y: 74 },
  { key: 'Box_BHJ2', label: '保护合闸2', x: 290, y: 124 },
  { key: 'Box_YTJ2', label: '遥控跳闸2', x: 290, y: 174 },
  { key: 'Box_YHJ2', label: '遥控合闸2', x: 290, y: 224 },
  { key: 'Box_QDJ3', label: '启动继电器3', x: 530, y: 24 },
  { key: 'Box_CKJ1', label: '开出继电器1', x: 530, y: 74 },
  { key: 'Box_CKJ2', label: '开出继电器2', x: 530, y: 124 },
  { key: 'Box_CKJ3', label: '开出继电器3', x: 530, y: 174 },
  { key: 'Box_GJJ', label: '告警继电器', x: 770, y: 24 },
  { key: 'Box_YCJ', label: '异常继电器', x: 770, y: 74 },
  { key: 'Box_SGZJ', label: '事故总继电器', x: 770, y: 124 },
  { key: 'Box_BTXJ', label: '跳闸信号继电器', x: 770, y: 174 },
  { key: 'Box_BHXJ', label: '合闸信号继电器', x: 770, y: 224 },
  { key: 'Box_MC1', label: '母差保护开出1', x: 770, y: 274 },
  { key: 'Box_MC2', label: '母差保护开出2', x: 770, y: 324 },
  { key: 'Box_FGJ', label: '复归继电器', x: 770, y: 374 }
];

function createDigitalOutputTestItem(config: DigitalOutputTestDefaultItem): DigitalOutputTestItem {
  let item = new DigitalOutputTestItem();
  item.key = config.key;
  item.label = config.label;
  item.x = config.x;
  item.y = config.y;
  item.checked = false;
  return item;
}

export function createDefaultDigitalOutputTestItems(): DigitalOutputTestItem[] {
  return DIGITAL_OUTPUT_TEST_DEFAULT_ITEMS.map((item: DigitalOutputTestDefaultItem) => {
    return createDigitalOutputTestItem(item);
  });
}

export function serializeDigitalOutputTestItems(items: DigitalOutputTestItem[]): string {
  let data: Record<string, boolean> = {};
  items.forEach((item: DigitalOutputTestItem) => {
    data[item.key] = item.checked;
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
        item.checked = value;
      }
    });
    return items;
  } catch (error) {
    return undefined;
  }
}
