@Observed
export class DigitalInputTestItem {
  key: string = '';
  label: string = '';
  x: number = 0;
  y: number = 0;
  checked: boolean = false;
  enabled: boolean = false;
}

interface DigitalInputTestDefaultItem {
  key: string;
  label: string;
  x: number;
  y: number;
}

const DIGITAL_INPUT_TEST_DEFAULT_ITEMS: DigitalInputTestDefaultItem[] = [
  { key: 'Box_MonitoringKM', label: 'KM电压监测', x: 80, y: 19 },
  { key: 'Box_DisableReclose', label: '闭锁重合闸', x: 80, y: 69 },
  { key: 'Box_SprintLessEnergy', label: '弹簧未储能', x: 80, y: 119 },
  { key: 'Box_ExternalTrip', label: '外部跳闸', x: 80, y: 169 },
  { key: 'Box_ExternalClose', label: '外部合闸', x: 80, y: 219 },
  { key: 'Box_PWRboard24V', label: '24V电压监测', x: 80, y: 269 },
  { key: 'Box_TWJ_Flag', label: 'TWJ动作', x: 380, y: 19 },
  { key: 'Box_HWJ_Flag', label: 'HWJ动作', x: 380, y: 69 },
  { key: 'Box_HHJ_Flag', label: 'HHJ动作', x: 380, y: 119 },
  { key: 'Box_STJ_Flag', label: 'STJ动作', x: 380, y: 169 },
  { key: 'Box_RTJ_Flag', label: 'RTJ动作', x: 380, y: 219 },
  { key: 'Box_PilotProtection', label: '纵联保护硬压板', x: 680, y: 19 },
  { key: 'Box_LowFreqProtection', label: '低频减载保护硬压板', x: 680, y: 69 },
  { key: 'Box_LowVoltProtection', label: '低压减载保护硬压板', x: 680, y: 119 },
  { key: 'Box_OutageReclose', label: '停用重合闸硬压板', x: 680, y: 169 },
  { key: 'Box_ResetButton', label: '信号复归', x: 680, y: 219 },
  { key: 'Box_DeviceMaintain', label: '检修压板', x: 680, y: 269 },
  { key: 'Box_RemoteOrLocal', label: '远方/就地', x: 680, y: 319 },
  { key: 'Box_GroundingChoicTrip', label: '接地选跳', x: 680, y: 369 }
];

function createDigitalInputTestItem(config: DigitalInputTestDefaultItem): DigitalInputTestItem {
  let item = new DigitalInputTestItem();
  item.key = config.key;
  item.label = config.label;
  item.x = config.x;
  item.y = config.y;
  item.checked = false;
  item.enabled = false;
  return item;
}

export function createDefaultDigitalInputTestItems(): DigitalInputTestItem[] {
  return DIGITAL_INPUT_TEST_DEFAULT_ITEMS.map((item: DigitalInputTestDefaultItem) => {
    return createDigitalInputTestItem(item);
  });
}
