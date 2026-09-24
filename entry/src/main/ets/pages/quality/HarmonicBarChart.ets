import { HARMONIC_COUNT, harmonicAxisMaximum } from './HarmonicData';

@Component
export struct HarmonicBarChart {
  @Prop @Watch('redraw') values: number[] = [];
  @Prop @Watch('redraw') uiScale: number = 1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  private redraw(): void {
    if (!this.ready) {
      return;
    }
    const ctx = this.context;
    const width = ctx.width;
    const height = ctx.height;
    ctx.clearRect(0, 0, width, height);
    const left = 35 * this.uiScale;
    const right = 8 * this.uiScale;
    const top = 10 * this.uiScale;
    const bottom = 25 * this.uiScale;
    const plotWidth = width - left - right;
    const plotHeight = height - top - bottom;
    if (plotWidth <= 0 || plotHeight <= 0) {
      return;
    }
    const maximum = harmonicAxisMaximum(this.values);
    ctx.font = `${12 * this.uiScale}px sans-serif`;
    ctx.lineWidth = 1;
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    for (let tick = 0; tick <= 5; tick++) {
      const y = top + plotHeight * (1 - tick / 5);
      ctx.strokeStyle = '#d0d0d0';
      ctx.beginPath();
      ctx.moveTo(left, y);
      ctx.lineTo(width - right, y);
      ctx.stroke();
      ctx.fillStyle = '#666666';
      ctx.fillText((maximum * tick / 5).toFixed(0), left - 5 * this.uiScale, y);
    }

    // 保留全部次数的位置，零值和缺失值也不会使横轴错位。
    const slot = plotWidth / HARMONIC_COUNT;
    const spacing = Math.min(2 * this.uiScale, slot * 0.3);
    const barWidth = slot - spacing;
    for (let index = 0; index < HARMONIC_COUNT; index++) {
      const value = this.values[index];
      if (!Number.isFinite(value) || value <= 0) {
        continue;
      }
      const barHeight = Math.min(100, value) / maximum * plotHeight;
      ctx.fillStyle = index % 2 === 0 ? '#cc8800' : '#5a8fd8';
      ctx.fillRect(left + index * slot + spacing / 2, top + plotHeight - barHeight, barWidth, barHeight);
    }
    ctx.strokeStyle = '#b0b0b0';
    ctx.strokeRect(left, top, plotWidth, plotHeight);
    ctx.fillStyle = '#666666';
    ctx.textBaseline = 'top';
    const labels: number[] = [1, 10, 20, 30, 40, 50, 60, 63];
    labels.forEach((order: number) => {
      ctx.textAlign = order === 63 ? 'right' : 'center';
      const x = order === 63 ? width - right : left + (order - 0.5) * slot;
      ctx.fillText(order.toString(), x, top + plotHeight + 5 * this.uiScale);
    });
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .onReady(() => {
        this.ready = true;
        this.redraw();
      })
      .onAreaChange(() => {
        this.redraw();
      })
  }
}
