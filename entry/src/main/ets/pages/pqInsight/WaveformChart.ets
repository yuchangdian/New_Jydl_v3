import { WAVEFORM_COLORS, WAVEFORM_POINT_COUNT, emptyWaveformFrame,
  validWaveformSamples, waveformRange, waveformY } from './WaveformData';

@Component
export struct WaveformChart {
  @Prop @Watch('redraw') samples: number[][] = emptyWaveformFrame().samples;
  @Prop @Watch('redraw') visible: boolean[] = [true, true, true, true, true, true];
  @Prop @Watch('redraw') uiScale: number = 1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  private redraw(): void {
    if (!this.ready) {
      return;
    }
    const ctx = this.context;
    const width: number = ctx.width;
    const height: number = ctx.height;
    const left: number = 64 * this.uiScale;
    const right: number = 64 * this.uiScale;
    const top: number = 12 * this.uiScale;
    const plotWidth: number = width - left - right;
    const plotHeight: number = height - top - 20 * this.uiScale;
    ctx.clearRect(0, 0, width, height);
    if (plotWidth <= 0 || plotHeight <= 0) {
      return;
    }
    const voltage = waveformRange(this.samples, this.visible, true);
    const current = waveformRange(this.samples, this.visible, false);
    const hasVoltage: boolean = this.visible.slice(0, 3).some((value: boolean) => value);
    const hasCurrent: boolean = this.visible.slice(3, 6).some((value: boolean) => value);
    ctx.lineWidth = Math.max(0.5, this.uiScale);
    ctx.strokeStyle = '#e0e0e0';
    ctx.setLineDash([4 * this.uiScale, 3 * this.uiScale]);
    ctx.beginPath();
    for (let tick: number = 1; tick < 5; tick++) {
      const y: number = top + plotHeight * tick / 5;
      const x: number = left + plotWidth * tick / 5;
      ctx.moveTo(left, y);
      ctx.lineTo(left + plotWidth, y);
      ctx.moveTo(x, top);
      ctx.lineTo(x, top + plotHeight);
    }
    ctx.stroke();
    ctx.setLineDash([]);
    ctx.strokeStyle = '#666666';
    ctx.strokeRect(left, top, plotWidth, plotHeight);
    ctx.font = `${11 * this.uiScale}px sans-serif`;
    ctx.textBaseline = 'middle';
    for (let tick: number = 0; tick <= 5; tick++) {
      const y: number = top + plotHeight * tick / 5;
      if (hasVoltage) {
        ctx.fillStyle = '#0055cc';
        ctx.textAlign = 'right';
        ctx.fillText((voltage.max - (voltage.max - voltage.min) * tick / 5).toFixed(1) + 'V',
          left - 5 * this.uiScale, y);
      }
      if (hasCurrent) {
        ctx.fillStyle = '#cc5500';
        ctx.textAlign = 'left';
        ctx.fillText((current.max - (current.max - current.min) * tick / 5).toFixed(2) + 'A',
          left + plotWidth + 5 * this.uiScale, y);
      }
    }
    ctx.save();
    ctx.beginPath();
    ctx.rect(left, top, plotWidth, plotHeight);
    ctx.clip();
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    for (let channel: number = 0; channel < 6; channel++) {
      const values: number[] = this.samples[channel];
      if (!this.visible[channel] || !values || !validWaveformSamples(values)) {
        continue;
      }
      const isVoltage: boolean = channel < 3;
      const range = isVoltage ? voltage : current;
      ctx.strokeStyle = WAVEFORM_COLORS[channel];
      ctx.lineWidth = (isVoltage ? 2 : 1) * this.uiScale;
      ctx.beginPath();
      for (let index: number = 0; index < WAVEFORM_POINT_COUNT; index++) {
        const x: number = left + index / (WAVEFORM_POINT_COUNT - 1) * plotWidth;
        const y: number = waveformY(values[index], range, isVoltage, top, plotHeight);
        if (index === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.stroke();
    }
    ctx.restore();
    if (!hasVoltage && !hasCurrent || !this.samples.some((values: number[]) => validWaveformSamples(values))) {
      ctx.fillStyle = '#888888';
      ctx.textAlign = 'center';
      ctx.font = `${16 * this.uiScale}px sans-serif`;
      ctx.fillText(!hasVoltage && !hasCurrent ? '请选择波形通道' : '等待设备波形数据',
        left + plotWidth / 2, top + plotHeight / 2);
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor('#ffffff')
      .onReady(() => {
        this.ready = true;
        this.redraw();
      })
      .onAreaChange(() => this.redraw())
  }
}
