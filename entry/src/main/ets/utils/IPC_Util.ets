/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import rpc from '@ohos.rpc';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

const TAG = 'IPC_Util';
const DOMAIN = 0x0000;

// Want对象类型定义
interface WantType {
  bundleName: string;
  abilityName: string;
}

// 请求配置类
export class IpcRequestConfig {
  api: string = '';
  params: IpcParams = new IpcParams();

  constructor(api: string, params?: IpcParams) {
    this.api = api;
    if (params) {
      this.params = params;
    }
  }

  // 获取参数的JSON表示
  getParamsRecord(): Record<string, Object> {
    return this.params.toRecord();
  }
}

// 基础响应数据类（用于名义类型约束）
export class IpcDataBase {
  // 保护的类型标记，用于名义类型检查
  protected readonly _ipcBrand: boolean = true;

  constructor() {}
}

// 字符串响应数据类
export class StringResponse extends IpcDataBase {
  data: string = '';
}

// Ashmem响应数据类
export class AshmemResponse extends IpcDataBase {
  ashmem: rpc.Ashmem | null = null;
  size: number = 0;
  data: Uint8Array | null = null;
}

// 通用请求参数类
export class IpcParams {
  // 使用显式属性代替索引签名
  projectCode: string = '';
  segment: number = 0;
  terminalId: string = '';
  platform: string = '';
  key: string = '';
  valueTest: string = '';
  filePath: string = '';
  deviceId: string = '';
  delay: number = 0;
  // 额外参数用于灵活扩展
  extraData: Record<string, string> = {};

  // 设置额外参数
  setExtra(key: string, value: string): IpcParams {
    this.extraData[key] = value;
    return this;
  }

  // 获取额外参数
  getExtra(key: string): string | undefined {
    return this.extraData[key];
  }

  // 转换为JSON对象
  toRecord(): Record<string, Object> {
    const result: Record<string, Object> = {};
    if (this.projectCode !== '') {
      result['projectCode'] = this.projectCode;
    }
    if (this.segment !== 0) {
      result['segment'] = this.segment;
    }
    if (this.terminalId !== '') {
      result['terminalId'] = this.terminalId;
    }
    if (this.platform !== '') {
      result['platform'] = this.platform;
    }
    if (this.key !== '') {
      result['key'] = this.key;
    }
    if (this.valueTest !== '') {
      result['valueTest'] = this.valueTest;
    }
    if (this.filePath !== '') {
      result['filePath'] = this.filePath;
    }
    if (this.deviceId !== '') {
      result['deviceId'] = this.deviceId;
    }
    if (this.delay !== 0) {
      result['delay'] = this.delay;
    }
    // 添加额外参数 - 使用Object.keys代替for-in
    const extraKeys: string[] = Object.keys(this.extraData);
    const extraKeysLength: number = extraKeys.length;
    for (let i: number = 0; i < extraKeysLength; i++) {
      const k: string = extraKeys[i];
      const value: string | undefined = this.extraData[k];
      if (value !== undefined) {
        result[k] = value;
      }
    }
    return result;
  }
}

// 响应数据结构（使用类实现名义类型）
export class IpcResponse<T extends IpcDataBase> {
  success: boolean = false;
  data?: T = undefined;
  error?: string = undefined;

  // 私有构造函数，通过静态工厂方法创建
  private constructor() {}

  // 静态工厂方法 - 创建成功响应
  static createSuccess<T extends IpcDataBase>(data: T): IpcResponse<T> {
    const response: IpcResponse<T> = new IpcResponse<T>();
    response.success = true;
    response.data = data;
    return response;
  }

  // 静态工厂方法 - 创建失败响应
  static createError<T extends IpcDataBase>(error: string): IpcResponse<T> {
    const response: IpcResponse<T> = new IpcResponse<T>();
    response.success = false;
    response.error = error;
    return response;
  }
}

// 连接状态
export enum IpcConnectionState {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting'
}

// Parcelable对象
class IpcParcelable implements rpc.Parcelable {
  api: string = '';
  params: string = '';

  constructor(api: string, params: string) {
    this.api = api;
    this.params = params;
  }

  marshalling(messageSequence: rpc.MessageSequence): boolean {
    messageSequence.writeString(this.api);
    messageSequence.writeString(this.params);
    return true;
  }

  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    this.api = messageSequence.readString();
    this.params = messageSequence.readString();
    return true;
  }
}

// 服务连接配置
const want: WantType = {
  bundleName: 'com.samples.ipc_service',
  abilityName: 'IpcServiceExtAbility',
}

/**
 * IPC工具类
 * 提供统一的IPC通信接口，方便各个页面调用
 */
export class IpcUtil {
  private static proxy: rpc.IRemoteObject | undefined = undefined;
  private static connectId: number | undefined = undefined;
  private static globalContext: common.UIAbilityContext | undefined = undefined;
  private static connectionState: IpcConnectionState = IpcConnectionState.DISCONNECTED;

  /**
   * 初始化IPC连接
   * @param context UIAbilityContext
   * @returns Promise<void>
   */
  static async connect(context: common.UIAbilityContext): Promise<void> {
    if (IpcUtil.proxy) {
      hilog.info(DOMAIN, TAG, 'IPC已连接，无需重复连接');
      return;
    }

    if (IpcUtil.connectionState === IpcConnectionState.CONNECTING) {
      hilog.info(DOMAIN, TAG, 'IPC正在连接中，等待连接完成');
      await IpcUtil.waitForConnection();
      return;
    }

    IpcUtil.connectionState = IpcConnectionState.CONNECTING;
    IpcUtil.globalContext = context;

    return new Promise((resolve, reject) => {
      let connect: common.ConnectOptions = {
        onConnect: (elementName, remoteProxy) => {
          hilog.info(DOMAIN, TAG, 'IPC连接成功: %{public}s', JSON.stringify(elementName));
          IpcUtil.proxy = remoteProxy;
          IpcUtil.connectionState = IpcConnectionState.CONNECTED;
          resolve();
        },
        onDisconnect: (elementName) => {
          hilog.info(DOMAIN, TAG, 'IPC连接断开: %{public}s', JSON.stringify(elementName));
          IpcUtil.proxy = undefined;
          IpcUtil.connectionState = IpcConnectionState.DISCONNECTED;
        },
        onFailed: (code: number) => {
          hilog.error(DOMAIN, TAG, 'IPC连接失败，错误码: %{public}d', code);
          IpcUtil.connectionState = IpcConnectionState.DISCONNECTED;
          reject(new Error('连接失败，错误码: ' + code));
        },
      }

      try {
        IpcUtil.connectId = context.connectServiceExtensionAbility(want, connect);
        hilog.info(DOMAIN, TAG, 'IPC连接ID: %{public}d', IpcUtil.connectId);
      } catch (error) {
        IpcUtil.connectionState = IpcConnectionState.DISCONNECTED;
        hilog.error(DOMAIN, TAG, '连接服务扩展能力异常: %{public}s', JSON.stringify(error));
        reject(error);
      }
    });
  }

  /**
   * 等待连接完成
   */
  private static waitForConnection(): Promise<void> {
    return new Promise((resolve) => {
      const maxWaitTime: number = 5000; // 最大等待5秒
      const checkInterval: number = 50; // 每50毫秒检查一次
      let waitedTime: number = 0;

      const checkConnection = setInterval(() => {
        // 从类属性获取最新状态
        const currentState: IpcConnectionState = IpcUtil.connectionState;
        if (currentState === IpcConnectionState.CONNECTED) {
          clearInterval(checkConnection);
          resolve();
        } else if (currentState === IpcConnectionState.DISCONNECTED) {
          clearInterval(checkConnection);
          resolve(); // 连接失败也结束等待
        } else if (waitedTime >= maxWaitTime) {
          clearInterval(checkConnection);
          resolve();
        }
        waitedTime += checkInterval;
      }, checkInterval);
    });
  }

  /**
   * 断开IPC连接
   */
  static disconnect(): void {
    if (IpcUtil.connectId !== undefined && IpcUtil.globalContext) {
      IpcUtil.globalContext.disconnectServiceExtensionAbility(IpcUtil.connectId);
      IpcUtil.proxy = undefined;
      IpcUtil.connectId = undefined;
      IpcUtil.connectionState = IpcConnectionState.DISCONNECTED;
      hilog.info(DOMAIN, TAG, 'IPC连接已断开');
    }
  }

  /**
   * 获取连接状态
   */
  static getConnectionState(): IpcConnectionState {
    return IpcUtil.connectionState;
  }

  /**
   * 检查是否已连接
   */
  static isConnected(): boolean {
    return IpcUtil.proxy !== undefined && IpcUtil.connectionState === IpcConnectionState.CONNECTED;
  }

  /**
   * 发送请求并获取响应
   * @param config 请求配置
   * @returns Promise<IpcResponse<T>> 统一格式的响应对象
   */
  static async sendRequest<T extends IpcDataBase>(config: IpcRequestConfig): Promise<IpcResponse<T>> {
    // 检查连接状态
    if (!IpcUtil.proxy) {
      hilog.error(DOMAIN, TAG, 'IPC未连接，请先调用connect方法');
      return IpcResponse.createError<T>('IPC未连接，请先调用connect方法');
    }

    // 序列化请求参数
    const paramsStr: string = JSON.stringify(config.getParamsRecord());

    // 创建消息序列
    let option: rpc.MessageOption = new rpc.MessageOption();
    let data: rpc.MessageSequence = rpc.MessageSequence.create();
    let reply: rpc.MessageSequence = rpc.MessageSequence.create();

    // 创建Parcelable对象
    let parcelable: IpcParcelable = new IpcParcelable(config.api, paramsStr);

    try {
      // 进行校验
      data.writeInterfaceToken(IpcUtil.proxy.getDescriptor());
      // 写入Parcelable
      data.writeParcelable(parcelable);

      // 发送数据
      const result: Object = await IpcUtil.sendMessageInternal(1001, data, reply, option);

      return IpcResponse.createSuccess<T>(result as T);
    } catch (error) {
      let errorMsg: string = error instanceof Error ? error.message : String(error);
      hilog.error(DOMAIN, TAG, 'IPC请求失败: %{public}s', errorMsg);
      return IpcResponse.createError<T>(errorMsg);
    } finally {
      // 清理资源
      try {
        data.reclaim();
        reply.reclaim();
      } catch (e) {
        hilog.warn(DOMAIN, TAG, '资源清理异常: %{public}s', JSON.stringify(e));
      }
    }
  }

  /**
   * 发送请求并获取字符串响应（专门用于文件内容等返回字符串的场景）
   * @param config 请求配置
   * @returns Promise<IpcResponse<StringResponse>> 字符串响应对象
   */
  static async sendRequestString(config: IpcRequestConfig): Promise<IpcResponse<StringResponse>> {
    // 检查连接状态
    if (!IpcUtil.proxy) {
      hilog.error(DOMAIN, TAG, 'IPC未连接，请先调用connect方法');
      return IpcResponse.createError<StringResponse>('IPC未连接，请先调用connect方法');
    }

    // 序列化请求参数
    const paramsStr: string = JSON.stringify(config.getParamsRecord());

    // 创建消息序列
    let option: rpc.MessageOption = new rpc.MessageOption();
    let data: rpc.MessageSequence = rpc.MessageSequence.create();
    let reply: rpc.MessageSequence = rpc.MessageSequence.create();

    // 创建Parcelable对象
    let parcelable: IpcParcelable = new IpcParcelable(config.api, paramsStr);

    return new Promise((resolve, reject) => {
      if (!IpcUtil.proxy) {
        reject(new Error('代理对象为空'));
        return;
      }

      IpcUtil.proxy.sendMessageRequest(1001, data, reply, option)
        .then((result: rpc.RequestResult) => {
          if (result.errCode === 0) {
            try {
              let responseData: string = result.reply.readString();

              hilog.info(DOMAIN, TAG, '原始响应数据总长度: %{public}d', responseData.length);

              // 长字符串分块打印
              IpcUtil.printLongString(responseData, 'IPC响应数据: ');
              hilog.info(DOMAIN, TAG, 'IPC请求成功');

              const stringResponse: StringResponse = new StringResponse();
              
              // 解析JSON响应
              const parsedResponse: Record<string, Object> = JSON.parse(responseData) as Record<string, Object>;
              
              if (parsedResponse['data'] && typeof parsedResponse['data'] === 'string') {
                const dataStr: string = parsedResponse['data'] as string;
                hilog.info(DOMAIN, TAG, 'data字段是字符串，需要二次解析，长度: %{public}d', dataStr.length);
                const parsedData: Record<string, Object> = JSON.parse(dataStr) as Record<string, Object>;
                stringResponse.data = JSON.stringify(parsedData);
                hilog.info(DOMAIN, TAG, '二次解析成功，最终数据长度: %{public}d', stringResponse.data.length);
              } else {
                stringResponse.data = responseData;
              }
              
              resolve(IpcResponse.createSuccess<StringResponse>(stringResponse));
            } catch (error) {
              let e: BusinessError = error as BusinessError;
              hilog.error(DOMAIN, TAG, '读取响应数据异常: errorCode %{public}d, errorMessage: %{public}s',
                e.code, e.message);
              reject(error);
            }
          } else {
            hilog.error(DOMAIN, TAG, 'IPC请求失败，错误码: %{public}d', result.errCode);
            reject(new Error('请求失败，错误码: ' + result.errCode));
          }
        })
        .catch((e: Error) => {
          hilog.error(DOMAIN, TAG, 'IPC请求异常: %{public}s', e.message);
          reject(e);
        });
    });
  }

  /**
   * 发送消息到服务端（内部方法）
   * @param code 消息码
   * @param data 消息数据
   * @param reply 响应数据
   * @param options 选项
   */
  private static sendMessageInternal(code: number, data: rpc.MessageSequence,
    reply: rpc.MessageSequence, options: rpc.MessageOption): Promise<Object> {
    return new Promise((resolve, reject) => {
      if (!IpcUtil.proxy) {
        reject(new Error('代理对象为空'));
        return;
      }

      IpcUtil.proxy.sendMessageRequest(code, data, reply, options)
        .then((result: rpc.RequestResult) => {
          if (result.errCode === 0) {
            try {
              let responseData: string = result.reply.readString();

              hilog.info(DOMAIN, TAG, '原始响应数据总长度: %{public}d', responseData.length);

              // 长字符串分块打印
              IpcUtil.printLongString(responseData, 'IPC响应数据: ');
              hilog.info(DOMAIN, TAG, 'IPC请求成功');

              const stringResponse: StringResponse = new StringResponse();
              stringResponse.data = responseData;
              resolve(stringResponse);
            } catch (error) {
              let e: BusinessError = error as BusinessError;
              hilog.error(DOMAIN, TAG, '读取响应数据异常: errorCode %{public}d, errorMessage: %{public}s',
                e.code, e.message);
              reject(error);
            }
          } else {
            hilog.error(DOMAIN, TAG, 'IPC请求失败，错误码: %{public}d', result.errCode);
            reject(new Error('请求失败，错误码: ' + result.errCode));
          }
        })
        .catch((e: Error) => {
          hilog.error(DOMAIN, TAG, 'IPC请求异常: %{public}s', e.message);
          reject(e);
        });
    });
  }

  /**
   * 发送请求并等待响应（带自动重连）
   * @param config 请求配置
   * @param maxRetries 最大重试次数
   * @returns Promise<IpcResponse<T>>
   */
  static async sendRequestWithRetry<T extends IpcDataBase>(config: IpcRequestConfig,
    maxRetries: number = 2): Promise<IpcResponse<T>> {
    let lastError: string = '';

    for (let retry: number = 0; retry <= maxRetries; retry++) {
      // 如果连接断开，尝试重连
      if (!IpcUtil.isConnected() && IpcUtil.globalContext) {
        hilog.info(DOMAIN, TAG, '连接已断开，尝试第 %{public}d 次重连', retry + 1);
        IpcUtil.connectionState = IpcConnectionState.RECONNECTING;

        try {
          await IpcUtil.connect(IpcUtil.globalContext);
        } catch (connectError) {
          lastError = connectError instanceof Error ? connectError.message : String(connectError);
          hilog.error(DOMAIN, TAG, '重连失败: %{public}s', lastError);
          continue;
        }
      }

      // 发送请求
      const result: IpcResponse<T> = await IpcUtil.sendRequest<T>(config);

      if (result.success) {
        return result;
      }

      lastError = result.error || '未知错误';

      if (retry < maxRetries) {
        hilog.warn(DOMAIN, TAG, '请求失败，%{public}ms后重试', 500);
        await IpcUtil.sleep(500);
      }
    }

    return IpcResponse.createError<T>('重试 ' + maxRetries + ' 次后仍失败: ' + lastError);
  }

  /**
   * 延迟函数
   */
  private static sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * 分块打印长字符串
   * @param longStr 要打印的长字符串
   * @param prefix 打印前缀
   */
  private static printLongString(longStr: string, prefix: string = ''): void {
    const MAX_LENGTH: number = 1000;
    const totalLength: number = longStr.length;

    if (totalLength <= MAX_LENGTH) {
      hilog.info(DOMAIN, TAG, '%{public}s%{public}s', prefix, longStr);
      return;
    }

    // 分块打印
    let startIndex: number = 0;
    let chunkIndex: number = 1;

    hilog.info(DOMAIN, TAG, '%{public}s总长度: %{public}d，将分为 %{public}d 块打印',
      prefix, totalLength, Math.ceil(totalLength / MAX_LENGTH));

    while (startIndex < totalLength) {
      const endIndex: number = Math.min(startIndex + MAX_LENGTH, totalLength);
      const chunk: string = longStr.substring(startIndex, endIndex);

      hilog.info(DOMAIN, TAG, '%{public}s第 %{public}d 块 [%{public}d-%{public}d]: %{public}s',
        prefix, chunkIndex, startIndex, endIndex, chunk);

      startIndex = endIndex;
      chunkIndex++;
    }
  }

  /**
   * 验证并修复JSON数据
   * @param jsonData JSON字符串
   * @returns 修复后的JSON字符串
   */
  private static validateAndFixJson(jsonData: string): string {
    if (!jsonData || jsonData.length === 0) {
      return jsonData;
    }

    const trimmed: string = jsonData.trim();

    try {
      JSON.parse(trimmed);
      return trimmed;
    } catch {
      hilog.warn(DOMAIN, TAG, 'JSON数据不完整，尝试修复');

      let openBraces: number = 0;
      let openBrackets: number = 0;
      let inString: boolean = false;
      let escapeNext: boolean = false;

      for (let i: number = 0; i < trimmed.length; i++) {
        const char: string = trimmed[i];

        if (escapeNext) {
          escapeNext = false;
          continue;
        }

        if (char === '\\') {
          escapeNext = true;
          continue;
        }

        if (char === '"') {
          inString = !inString;
          continue;
        }

        if (!inString) {
          if (char === '{') {
            openBraces++;
          } else if (char === '}') {
            openBraces--;
          } else if (char === '[') {
            openBrackets++;
          } else if (char === ']') {
            openBrackets--;
          }
        }
      }

      let fixedData: string = trimmed;

      while (openBrackets > 0) {
        fixedData += ']';
        openBrackets--;
        hilog.info(DOMAIN, TAG, '添加缺失的 ]');
      }

      while (openBraces > 0) {
        fixedData += '}';
        openBraces--;
        hilog.info(DOMAIN, TAG, '添加缺失的 }');
      }

      try {
        JSON.parse(fixedData);
        hilog.info(DOMAIN, TAG, 'JSON修复成功');
        return fixedData;
      } catch {
        hilog.error(DOMAIN, TAG, 'JSON修复失败，返回原始数据');
        return trimmed;
      }
    }
  }

  /**
   * 发送请求并获取Ashmem共享内存响应
   * @param config 请求配置
   * @returns Promise<IpcResponse<AshmemResponse>> Ashmem响应对象
   */
  static async sendRequestWithAshmem(config: IpcRequestConfig): Promise<IpcResponse<AshmemResponse>> {
    // 检查连接状态
    if (!IpcUtil.proxy) {
      hilog.error(DOMAIN, TAG, 'IPC未连接，请先调用connect方法');
      return IpcResponse.createError<AshmemResponse>('IPC未连接，请先调用connect方法');
    }

    // 序列化请求参数
    const paramsStr: string = JSON.stringify(config.getParamsRecord());

    // 创建消息序列
    let option: rpc.MessageOption = new rpc.MessageOption();
    let data: rpc.MessageSequence = rpc.MessageSequence.create();
    let reply: rpc.MessageSequence = rpc.MessageSequence.create();

    // 创建Parcelable对象
    let parcelable: IpcParcelable = new IpcParcelable(config.api, paramsStr);

    return new Promise((resolve, reject) => {
      if (!IpcUtil.proxy) {
        reject(new Error('代理对象为空'));
        return;
      }

      try {
        // 进行校验
        data.writeInterfaceToken(IpcUtil.proxy.getDescriptor());
        // 写入Parcelable
        data.writeParcelable(parcelable);

        // 发送数据，使用1003作为Ashmem请求码
        IpcUtil.proxy.sendMessageRequest(1003, data, reply, option)
          .then((result: rpc.RequestResult) => {
            if (result.errCode === 0) {
              try {
                // 读取字符串响应
                let responseData: string = result.reply.readString();
                hilog.info(DOMAIN, TAG, 'Ashmem响应字符串: %{public}s', responseData);

                // 读取Ashmem对象
                let ashmem: rpc.Ashmem = result.reply.readAshmem();
                let size: number = ashmem.getAshmemSize();
                hilog.info(DOMAIN, TAG, 'Ashmem接收成功，大小: %{public}d', size);

                // 读取Ashmem数据
                const readResult: Uint8Array = IpcUtil.readAshmemData(ashmem, size);

                const ashmemResponse: AshmemResponse = new AshmemResponse();
                ashmemResponse.ashmem = ashmem;
                ashmemResponse.size = size;
                ashmemResponse.data = readResult;

                hilog.info(DOMAIN, TAG, 'Ashmem数据读取完成，数据大小: %{public}d', readResult.length);
                resolve(IpcResponse.createSuccess<AshmemResponse>(ashmemResponse));
              } catch (error) {
                let e: BusinessError = error as BusinessError;
                hilog.error(DOMAIN, TAG, '读取Ashmem异常: errorCode %{public}d, errorMessage: %{public}s',
                  e.code, e.message);
                reject(error);
              }
            } else {
              hilog.error(DOMAIN, TAG, 'IPC请求失败，错误码: %{public}d', result.errCode);
              reject(new Error('请求失败，错误码: ' + result.errCode));
            }
          })
          .catch((e: Error) => {
            hilog.error(DOMAIN, TAG, 'IPC请求异常: %{public}s', e.message);
            reject(e);
          })
          .finally(() => {
            // 清理资源
            try {
              data.reclaim();
              reply.reclaim();
            } catch (e) {
              hilog.warn(DOMAIN, TAG, '资源清理异常: %{public}s', JSON.stringify(e));
            }
          });
      } catch (error) {
        let e: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, 'IPC请求准备失败: errorCode %{public}d, errorMessage: %{public}s',
          e.code, e.message);
        data.reclaim();
        reply.reclaim();
        reject(error);
      }
    });
  }

  /**
   * 从Ashmem读取数据
   * @param ashmem Ashmem对象
   * @param size 要读取的数据大小
   * @returns Uint8Array 读取的数据
   */
  static readAshmemData(ashmem: rpc.Ashmem, size: number): Uint8Array {
    try {
      // 映射共享内存为可读写
      ashmem.mapReadWriteAshmem();
      hilog.info(DOMAIN, TAG, 'Ashmem映射成功');

      // 从共享内存读取数据
      let readResult: ArrayBuffer = ashmem.readDataFromAshmem(size, 0);
      let readUint8Array: Uint8Array = new Uint8Array(readResult);

      hilog.info(DOMAIN, TAG, '验证读取共享内存成功，数据大小: %{public}d', readUint8Array.length);

      // 打印前16字节用于验证
      if (readUint8Array.length > 0) {
        const previewLength: number = Math.min(16, readUint8Array.length);
        const previewData: Uint8Array = readUint8Array.slice(0, previewLength);
        hilog.info(DOMAIN, TAG, '读取数据前%{public}d字节: %{public}s', previewLength, previewData.toString());
        
        // 尝试转换为字符串
        try {
          const previewStr: string = String.fromCharCode(...previewData);
          hilog.info(DOMAIN, TAG, '读取数据前%{public}d字节转换为字符串: %{public}s', previewLength, previewStr);
        } catch (e) {
          hilog.warn(DOMAIN, TAG, '无法转换为字符串');
        }
      }

      // 取消映射
      ashmem.unmapAshmem();
      hilog.info(DOMAIN, TAG, 'Ashmem取消映射成功');

      return readUint8Array;
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, '读取Ashmem数据失败: errorCode %{public}d, errorMessage: %{public}s',
        e.code, e.message);
      throw new Error('读取Ashmem数据失败: ' + e.message);
    }
  }

  /**
   * 创建Ashmem共享内存
   * @param name 共享内存名称
   * @param size 共享内存大小
   * @returns rpc.Ashmem Ashmem对象
   */
  static createAshmem(name: string, size: number): rpc.Ashmem {
    try {
      const ashmem: rpc.Ashmem = rpc.Ashmem.createAshmem(name, size);
      hilog.info(DOMAIN, TAG, '创建Ashmem成功，名称: %{public}s, 大小: %{public}d', name, size);
      return ashmem;
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, '创建Ashmem失败: errorCode %{public}d, errorMessage: %{public}s',
        e.code, e.message);
      throw new Error('创建Ashmem失败: ' + e.message);
    }
  }

  /**
   * 写入数据到Ashmem共享内存
   * @param ashmem Ashmem对象
   * @param data 要写入的数据
   * @param offset 写入偏移量
   */
  static writeAshmemData(ashmem: rpc.Ashmem, data: Uint8Array, offset: number = 0): void {
    try {
      // 映射共享内存为可读写
      ashmem.mapReadWriteAshmem();
      hilog.info(DOMAIN, TAG, 'Ashmem映射成功，准备写入数据');

      // 写入数据到共享内存
      ashmem.writeDataToAshmem(data.buffer, data.length, offset);
      hilog.info(DOMAIN, TAG, '写入Ashmem成功，数据大小: %{public}d, 偏移量: %{public}d', data.length, offset);

      // 取消映射
      ashmem.unmapAshmem();
      hilog.info(DOMAIN, TAG, 'Ashmem取消映射成功');
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, '写入Ashmem数据失败: errorCode %{public}d, errorMessage: %{public}s',
        e.code, e.message);
      throw new Error('写入Ashmem数据失败: ' + e.message);
    }
  }

  /**
   * 关闭Ashmem共享内存
   * @param ashmem Ashmem对象
   */
  static closeAshmem(ashmem: rpc.Ashmem): void {
    try {
      ashmem.closeAshmem();
      hilog.info(DOMAIN, TAG, 'Ashmem关闭成功');
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, '关闭Ashmem失败: errorCode %{public}d, errorMessage: %{public}s',
        e.code, e.message);
    }
  }

  /**
   * 将Uint8Array转换为字符串
   * @param data Uint8Array数据
   * @param encoding 编码格式，默认为'utf-8'
   * @returns 转换后的字符串
   */
  static uint8ArrayToString(data: Uint8Array, encoding: string = 'utf-8'): string {
    try {
      const decoder: util.TextDecoder = new util.TextDecoder(encoding);
      return decoder.decodeWithStream(data);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Uint8Array转字符串失败');
      return '';
    }
  }

  /**
   * 将字符串转换为Uint8Array
   * @param str 字符串
   * @param encoding 编码格式，默认为'utf-8'
   * @returns Uint8Array数据
   */
  static stringToUint8Array(str: string, encoding: string = 'utf-8'): Uint8Array {
    try {
      const encoder: util.TextEncoder = new util.TextEncoder();
      return encoder.encodeInto(str);
    } catch (error) {
      hilog.error(DOMAIN, TAG, '字符串转Uint8Array失败');
      return new Uint8Array(0);
    }
  }

  /**
   * 发送请求并获取Ashmem响应（带自动重连）
   * @param config 请求配置
   * @param maxRetries 最大重试次数
   * @returns Promise<IpcResponse<AshmemResponse>>
   */
  static async sendRequestWithAshmemRetry(config: IpcRequestConfig,
    maxRetries: number = 2): Promise<IpcResponse<AshmemResponse>> {
    let lastError: string = '';

    for (let retry: number = 0; retry <= maxRetries; retry++) {
      // 如果连接断开，尝试重连
      if (!IpcUtil.isConnected() && IpcUtil.globalContext) {
        hilog.info(DOMAIN, TAG, '连接已断开，尝试第 %{public}d 次重连', retry + 1);
        IpcUtil.connectionState = IpcConnectionState.RECONNECTING;

        try {
          await IpcUtil.connect(IpcUtil.globalContext);
        } catch (connectError) {
          lastError = connectError instanceof Error ? connectError.message : String(connectError);
          hilog.error(DOMAIN, TAG, '重连失败: %{public}s', lastError);
          continue;
        }
      }

      // 发送请求
      const result: IpcResponse<AshmemResponse> = await IpcUtil.sendRequestWithAshmem(config);

      if (result.success) {
        return result;
      }

      lastError = result.error || '未知错误';

      if (retry < maxRetries) {
        hilog.warn(DOMAIN, TAG, '请求失败，%{public}ms后重试', 500);
        await IpcUtil.sleep(500);
      }
    }

    return IpcResponse.createError<AshmemResponse>('重试 ' + maxRetries + ' 次后仍失败: ' + lastError);
  }
  // ==========================
  // 🔥 全局通用：获取事件列表 /api/events
  // ==========================
  static async getEvents(): Promise<IpcResponse<StringResponse>> {
    try {
      const params = new IpcParams();
      const config = new IpcRequestConfig("/api/events", params);

      // 发送 IPC 请求
      return await IpcUtil.sendRequestString(config);
    } catch (e) {
      hilog.error(DOMAIN, TAG, "获取事件失败：" + String(e));
      return IpcResponse.createError("请求失败");
    }
  }
}
