// common/uiUtils.ts
import display from '@ohos.display';

const PAGE_BASE_WIDTH = 1280;
const PAGE_BASE_HEIGHT = 720;

/**
 * 计算UI缩放比例
 * @param layoutZoom 额外的缩放系数，默认1.2
 * @returns 计算后的缩放比例
 */
export function calculateScale(layoutZoom: number = 1.2): number {
  try {
    let d = display.getDefaultDisplaySync();
    let sx = d.width / PAGE_BASE_WIDTH;
    let sy = d.height / PAGE_BASE_HEIGHT;
    let val = Math.min(sx, sy);
    return (val > 0 ? val : 1) * layoutZoom;
  } catch (e) {
    return layoutZoom;
  }
}

/**
 * 创建缩放函数
 * @param scale 缩放比例
 * @returns 缩放函数
 */
export function createScaleFunction(scale: number): (v: number) => number {
  return (v: number) => Math.round(v * scale);
}