export class DigitalInputTestItemPosition {
  x: number = 0;
  y: number = 0;

  constructor(x: number = 0, y: number = 0) {
    this.x = x;
    this.y = y;
  }
}

@Observed
export class DigitalInputTestItemState {
  checked: boolean = false;
}

@Observed
export class DigitalInputTestItem {
  key: string = '';
  label: string = '';
  position: DigitalInputTestItemPosition = new DigitalInputTestItemPosition();
  state: DigitalInputTestItemState = new DigitalInputTestItemState();
}

class DigitalInputTestDefaultItem {
  key: string = '';
  label: string = '';
  position: DigitalInputTestItemPosition = new DigitalInputTestItemPosition();

  constructor(key: string, label: string, x: number, y: number) {
    this.key = key;
    this.label = label;
    this.position = new DigitalInputTestItemPosition(x, y);
  }
}

const DIGITAL_INPUT_TEST_DEFAULT_ITEMS: DigitalInputTestDefaultItem[] = [
  new DigitalInputTestDefaultItem('Box_MonitoringKM', 'KM电压监测', 80, 19),
  new DigitalInputTestDefaultItem('Box_DisableReclose', '闭锁重合闸', 80, 69),
  new DigitalInputTestDefaultItem('Box_SprintLessEnergy', '弹簧未储能', 80, 119),
  new DigitalInputTestDefaultItem('Box_ExternalTrip', '外部跳闸', 80, 169),
  new DigitalInputTestDefaultItem('Box_ExternalClose', '外部合闸', 80, 219),
  new DigitalInputTestDefaultItem('Box_PWRboard24V', '24V电压监测', 80, 269),
  new DigitalInputTestDefaultItem('Box_TWJ_Flag', 'TWJ动作', 380, 19),
  new DigitalInputTestDefaultItem('Box_HWJ_Flag', 'HWJ动作', 380, 69),
  new DigitalInputTestDefaultItem('Box_HHJ_Flag', 'HHJ动作', 380, 119),
  new DigitalInputTestDefaultItem('Box_STJ_Flag', 'STJ动作', 380, 169),
  new DigitalInputTestDefaultItem('Box_RTJ_Flag', 'RTJ动作', 380, 219),
  new DigitalInputTestDefaultItem('Box_PilotProtection', '纵联保护硬压板', 680, 19),
  new DigitalInputTestDefaultItem('Box_LowFreqProtection', '低频减载保护硬压板', 680, 69),
  new DigitalInputTestDefaultItem('Box_LowVoltProtection', '低压减载保护硬压板', 680, 119),
  new DigitalInputTestDefaultItem('Box_OutageReclose', '停用重合闸硬压板', 680, 169),
  new DigitalInputTestDefaultItem('Box_ResetButton', '信号复归', 680, 219),
  new DigitalInputTestDefaultItem('Box_DeviceMaintain', '检修压板', 680, 269),
  new DigitalInputTestDefaultItem('Box_RemoteOrLocal', '远方/就地', 680, 319),
  new DigitalInputTestDefaultItem('Box_GroundingChoicTrip', '接地选跳', 680, 369)
];

function createDigitalInputTestItem(config: DigitalInputTestDefaultItem): DigitalInputTestItem {
  let item = new DigitalInputTestItem();
  item.key = config.key;
  item.label = config.label;
  item.position = new DigitalInputTestItemPosition(config.position.x, config.position.y);
  item.state.checked = false;
  return item;
}

export function createDefaultDigitalInputTestItems(): DigitalInputTestItem[] {
  return DIGITAL_INPUT_TEST_DEFAULT_ITEMS.map((item: DigitalInputTestDefaultItem) => {
    return createDigitalInputTestItem(item);
  });
}

export function cloneDigitalInputTestItem(source: DigitalInputTestItem): DigitalInputTestItem {
  let item = new DigitalInputTestItem();
  item.key = source.key;
  item.label = source.label;
  item.position = new DigitalInputTestItemPosition(source.position.x, source.position.y);
  item.state.checked = source.state.checked;
  return item;
}
