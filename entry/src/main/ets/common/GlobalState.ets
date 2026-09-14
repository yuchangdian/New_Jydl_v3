/**
 * 全局状态管理
 * 提供固定的项目代码和终端ID
 */

// 固定的项目代码
export const PROJECT_CODE = "dnzl";

// 固定的终端ID
export const TERMINAL_ID = "JYSDT-121-20260401001";

// 默认密码
export const DEFAULT_PASSWORD = "admin";

// 终端信息接口
interface TerminalInfo {
  TerminalId: string;
  ProjectCode: string;
}

// 全局状态类
class GlobalState {
  getCurrentTerminal(): TerminalInfo {
    return {
      TerminalId: TERMINAL_ID,
      ProjectCode: PROJECT_CODE
    };
  }

  getProjectCode(): string {
    return PROJECT_CODE;
  }

  getTerminalId(): string {
    return TERMINAL_ID;
  }

  getDefaultPassword(): string {
    return DEFAULT_PASSWORD;
  }
}

// 全局状态对象
export const globalState = new GlobalState();
