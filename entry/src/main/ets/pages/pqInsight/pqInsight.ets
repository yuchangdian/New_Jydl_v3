import { WaveformChart } from './WaveformChart';
import { WAVEFORM_COLORS, WAVEFORM_NAMES, WaveformFrame, emptyWaveformFrame } from './WaveformData';

@Component
export struct PQInsight {
  @Prop frame: WaveformFrame = emptyWaveformFrame();
  @Prop visible: boolean[] = [true, true, true, true, true, true];
  @Prop uiScale: number = 1;
  private readonly rows: number[] = [0, 1];
  private readonly columns: number[] = [0, 1, 2];

  @Builder
  legendItem(index: number) {
    Row({ space: 5 * this.uiScale }) {
      Rect()
        .width(50 * this.uiScale)
        .height((index < 3 ? 2 : 1) * this.uiScale)
        .fill(this.visible[index] ? WAVEFORM_COLORS[index] : '#c0c0c0')
      Text(WAVEFORM_NAMES[index])
        .fontSize(16 * this.uiScale)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.visible[index] ? '#000000' : '#c0c0c0')
      Text(this.frame.rms[index])
        .fontSize(16 * this.uiScale)
        .minFontSize(12 * this.uiScale)
        .maxFontSize(16 * this.uiScale)
        .maxLines(1)
        .layoutWeight(1)
        .fontColor(this.visible[index] ? '#000000' : '#c0c0c0')
    }
    .layoutWeight(1)
    .height('100%')
    .accessibilityText(WAVEFORM_NAMES[index] + ' 有效值 ' + this.frame.rms[index])
  }

  build() {
    Column() {
      WaveformChart({ samples: this.frame.samples, visible: this.visible, uiScale: this.uiScale })
        .width('100%')
        .layoutWeight(1)
      Column({ space: 2 * this.uiScale }) {
        ForEach(this.rows, (row: number) => {
          Row({ space: 10 * this.uiScale }) {
            ForEach(this.columns, (column: number) => {
              this.legendItem(row * 3 + column)
            }, (column: number) => column.toString())
          }
          .width('100%')
          .layoutWeight(1)
        }, (row: number) => row.toString())
      }
      .width('100%')
      .height(75 * this.uiScale)
      .padding({ left: 35 * this.uiScale, right: 35 * this.uiScale, top: 5 * this.uiScale, bottom: 5 * this.uiScale })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 5 * this.uiScale, left: 5 * this.uiScale, right: 5 * this.uiScale, bottom: 5 * this.uiScale })
    .backgroundColor('#f0f0f0')
  }
}
