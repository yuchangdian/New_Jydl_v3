import { PowerQualityAlarmRow } from '../models/PowerQualityAlarmSetting';
import { QtAlarmSettingSelect } from './QtAlarmSettingSelect';

const ENABLE_OPTIONS: SelectOption[] = [{ value: '投入' }, { value: '退出' }];

@Component
export struct PowerQualityAlarmSettingRow {
  // 单行直接观察模型，读取回包和手动修改都能同步到控件。
  @ObjectLink row: PowerQualityAlarmRow;
  @Prop uiScale: number = 1;
  onChanged: () => void = () => {};

  build() {
    Row({ space: 8 * this.uiScale }) {
      Text('【' + this.row.label + '】')
        .width(220 * this.uiScale).fontSize(18 * this.uiScale)
        .fontWeight(FontWeight.Normal).fontColor('#111111').maxLines(1)
        .minFontSize(15 * this.uiScale).maxFontSize(18 * this.uiScale)
        .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST);
      Text('投/退：').width(62 * this.uiScale).fontSize(18 * this.uiScale).fontColor('#111111');
      QtAlarmSettingSelect({
        options: ENABLE_OPTIONS,
        selectedIndex: this.row.enabled === '投入' ? 0 : 1,
        controlWidth: 65,
        uiScale: this.uiScale,
        onSelect: (selected: number) => {
          const enabled = selected === 0 ? '投入' : '退出';
          if (this.row.enabled !== enabled) {
            this.row.enabled = enabled;
            this.onChanged();
          }
        }
      });
      Blank().layoutWeight(1);
      Text('动作定值：').width(101 * this.uiScale).fontSize(18 * this.uiScale).fontColor('#111111');
      TextInput({ text: this.row.value })
        .width(70 * this.uiScale).height(38 * this.uiScale)
        .padding({ left: 3 * this.uiScale, right: 3 * this.uiScale, top: 0, bottom: 0 })
        .type(InputType.NUMBER_DECIMAL).fontSize(18 * this.uiScale).fontColor('#111111')
        .backgroundColor('#FFFFFF')
        .border({ width: this.uiScale, color: '#999999' }).borderRadius(3 * this.uiScale)
        .onChange((text: string) => {
          if (text !== this.row.value) {
            this.row.value = text;
            this.onChanged();
          }
        });
      Text(this.row.unit).width(100 * this.uiScale).fontSize(18 * this.uiScale).fontColor('#111111');
    }
    .width('100%').height(50 * this.uiScale)
    .padding({ left: 4 * this.uiScale, right: 4 * this.uiScale })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: this.uiScale }, color: '#5D5D5D', style: BorderStyle.Dashed });
  }
}
