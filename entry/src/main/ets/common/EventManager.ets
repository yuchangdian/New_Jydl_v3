// common/EventManager.ets
import { ComponentContent, PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { EventDialog } from './EventDialog';

const DOMAIN = 0x0000;

// 定义接口
interface EventResponse {
  code: number;
  success: boolean;
  message: string;
  data: string;
}

// ✅ 定义返回结果类
class ParseResult {
  shouldShow: boolean;
  content: string;

  constructor(shouldShow: boolean, content: string) {
    this.shouldShow = shouldShow;
    this.content = content;
  }
}

@Builder
function EventDialogBuilder(content: string) {
  EventDialog({ content: content })
}

export class EventManager {
  private static instance: EventManager | null = null;
  private uiContext: UIContext | null = null;
  private promptAction: PromptAction | null = null;
  private currentContentNode: ComponentContent<string> | null = null;
  private isDialogShowing: boolean = false;
  private pendingEventData: string | null = null;

  private constructor() {}

  static getInstance(): EventManager {
    if (EventManager.instance === null) {
      EventManager.instance = new EventManager();
    }
    return EventManager.instance;
  }

  setUIContext(uiContext: UIContext): void {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
    hilog.info(DOMAIN, 'testTag', 'EventManager: UIContext 和 PromptAction 已设置');

    if (this.pendingEventData !== null) {
      hilog.info(DOMAIN, 'testTag', '检测到待显示事件，立即显示');
      this.showEventDialog(this.pendingEventData);
      this.pendingEventData = null;
    }
  }

  isReady(): boolean {
    return this.uiContext !== null && this.promptAction !== null;
  }

  // ✅ 解析事件数据，返回 ParseResult 对象
  private parseEventData(rawData: string | object): ParseResult {
    try {
      let eventResponse: EventResponse;

      // 如果是字符串，先解析
      if (typeof rawData === 'string') {
        eventResponse = JSON.parse(rawData);
      } else {
        eventResponse = rawData as EventResponse;
      }

      // 检查 success 是否为 true
      if (eventResponse.success === true && eventResponse.data) {
        hilog.info(DOMAIN, 'testTag', '有效事件数据: %{public}s', eventResponse.data);
        return new ParseResult(true, eventResponse.data);
      } else {
        hilog.info(DOMAIN, 'testTag', '无需弹窗: success=%{public}s, message=%{public}s',
          String(eventResponse.success), eventResponse.message);
        return new ParseResult(false, '');
      }
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', '解析事件数据失败: %{public}s', String(e));
      return new ParseResult(false, '');
    }
  }

  async showEventDialog(eventDataStr: string | object): Promise<void> {
    if (!this.isReady()) {
      hilog.warn(DOMAIN, 'testTag', 'EventManager 未初始化，缓存事件数据');
      this.pendingEventData = typeof eventDataStr === 'string' ? eventDataStr : JSON.stringify(eventDataStr);
      return;
    }

    // 解析数据，判断是否需要显示弹窗
    const result: ParseResult = this.parseEventData(eventDataStr);

    if (!result.shouldShow) {
      hilog.info(DOMAIN, 'testTag', 'success=false，不显示弹窗');
      return;
    }

    // 如果弹窗已存在，先关闭旧弹窗
    if (this.isDialogShowing && this.currentContentNode) {
      hilog.info(DOMAIN, 'testTag', '弹窗已存在，先关闭旧弹窗再打开新弹窗');
      await this.closeCurrentDialog();
    }

    // 打开新弹窗
    try {
      this.isDialogShowing = true;

      this.currentContentNode = new ComponentContent<string>(
        this.uiContext!,
        wrapBuilder(EventDialogBuilder),
        result.content
      );

      await this.promptAction!.openCustomDialog(this.currentContentNode, {
        alignment: 0,
        isModal: true,
        maskColor: '#33000000'
      });

      hilog.info(DOMAIN, 'testTag', '事件弹窗显示成功');

    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', '显示弹窗失败: code=%{public}d, message=%{public}s', err.code, err.message);

      if (err.code === 100001) {
        this.uiContext = null;
        this.promptAction = null;
        this.pendingEventData = typeof eventDataStr === 'string' ? eventDataStr : JSON.stringify(eventDataStr);
      }
      this.isDialogShowing = false;
      this.currentContentNode = null;
    }
  }

  // 关闭当前弹窗
  async closeCurrentDialog(): Promise<void> {
    if (this.currentContentNode && this.promptAction) {
      try {
        await this.promptAction.closeCustomDialog(this.currentContentNode);
        this.currentContentNode = null;
        hilog.info(DOMAIN, 'testTag', '弹窗已关闭');
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', '关闭弹窗失败: %{public}s', String(error));
      }
    }
    this.isDialogShowing = false;
  }

  // 强制关闭并重置
  async forceReset(): Promise<void> {
    await this.closeCurrentDialog();
    this.pendingEventData = null;
    hilog.info(DOMAIN, 'testTag', 'EventManager 已完全重置');
  }

  isShowing(): boolean {
    return this.isDialogShowing;
  }
}