import http from '@ohos.net.http';
import hilog from '@ohos.hilog';

const DOMAIN = 0x0000;
const TAG = 'HTTP_Util';

export interface HttpResponseData<T> {
  success: boolean;
  data?: T;
  error?: string;
  statusCode?: number;
}

export interface HttpOptions {
  method?: http.RequestMethod;
  headers?: Record<string, string>;
  extraData?: Object | string | ArrayBuffer;
  expectDataType?: http.HttpDataType;
  connectTimeout?: number;
  readTimeout?: number;
}

export class HttpUtil {
  private static httpServerUrl: string = 'http://139.159.148.74:8093';

  static setServerUrl(url: string): void {
    HttpUtil.httpServerUrl = url;
  }

  static getServerUrl(): string {
    return HttpUtil.httpServerUrl;
  }

  static async request<T>(url: string, options?: HttpOptions): Promise<HttpResponseData<T>> {
    const httpRequest = http.createHttp();

    const defaultOptions: HttpOptions = {
      method: http.RequestMethod.POST,
      headers: {
        'Content-Type': 'application/json'
      },
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: 60000,
      readTimeout: 60000
    };

    if (options) {
      if (options.method !== undefined) {
        defaultOptions.method = options.method;
      }
      if (options.headers !== undefined) {
        defaultOptions.headers = options.headers;
      }
      if (options.extraData !== undefined) {
        defaultOptions.extraData = options.extraData;
      }
      if (options.expectDataType !== undefined) {
        defaultOptions.expectDataType = options.expectDataType;
      }
      if (options.connectTimeout !== undefined) {
        defaultOptions.connectTimeout = options.connectTimeout;
      }
      if (options.readTimeout !== undefined) {
        defaultOptions.readTimeout = options.readTimeout;
      }
    }

    const fullUrl = url.startsWith('http') ? url : `${HttpUtil.httpServerUrl}${url}`;

    hilog.info(DOMAIN, TAG, '发送HTTP请求: %{public}s', fullUrl);
    hilog.info(DOMAIN, TAG, '请求方法: %{public}s', defaultOptions.method?.toString() || 'POST');
    hilog.info(DOMAIN, TAG, '请求头: %{public}s', JSON.stringify(defaultOptions.headers));
    if (defaultOptions.extraData) {
      hilog.info(DOMAIN, TAG, '请求体: %{public}s', JSON.stringify(defaultOptions.extraData));
    }

    try {
      hilog.info(DOMAIN, TAG, '开始发送HTTP请求...');
      const response = await httpRequest.request(fullUrl, defaultOptions);
      hilog.info(DOMAIN, TAG, 'HTTP请求已返回');

      hilog.info(DOMAIN, TAG, 'HTTP响应状态码: %{public}d', response.responseCode);
      hilog.info(DOMAIN, TAG, 'HTTP响应类型: %{public}s', response.resultType);
      hilog.info(DOMAIN, TAG, 'HTTP响应头: %{public}s', JSON.stringify(response.header));

      if (response.responseCode === 200) {
        const responseData: string = response.result as string;
        hilog.info(DOMAIN, TAG, 'HTTP响应数据: %{public}s', responseData);

        try {
          const parsedData: T = JSON.parse(responseData);
          return HttpResponseWrapper.createSuccess<T>(parsedData, response.responseCode);
        } catch (error) {
          hilog.error(DOMAIN, TAG, '解析响应数据失败: %{public}s', String(error));
          return HttpResponseWrapper.createError<T>('解析响应数据失败', response.responseCode);
        }
      } else {
        const errorMsg = `HTTP请求失败，状态码: ${response.responseCode}`;
        hilog.error(DOMAIN, TAG, errorMsg);
        hilog.error(DOMAIN, TAG, '响应结果: %{public}s', JSON.stringify(response.result));
        return HttpResponseWrapper.createError<T>(errorMsg, response.responseCode);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'HTTP请求发生异常，开始解析错误信息');
      let errorMsg: string = '未知错误';
      let errorDetails: string = '';

      if (error instanceof Error) {
        errorMsg = error.message;
        errorDetails = `Error: ${error.message}, Stack: ${error.stack || 'no stack'}`;
      } else if (error !== null && typeof error === 'object') {
        try {
          errorDetails = JSON.stringify(error);
          errorMsg = errorDetails;
        } catch (e) {
          errorMsg = String(error);
          errorDetails = `String(error): ${errorMsg}`;
        }
      } else {
        errorMsg = String(error);
        errorDetails = `String(error): ${errorMsg}`;
      }

      hilog.error(DOMAIN, TAG, 'HTTP请求异常详情: %{public}s', errorDetails);
      hilog.error(DOMAIN, TAG, 'HTTP请求异常消息: %{public}s', errorMsg);
      return HttpResponseWrapper.createError<T>(errorMsg);
    } finally {
      httpRequest.destroy();
    }
  }

  static async get<T>(url: string, headers?: Record<string, string>): Promise<HttpResponseData<T>> {
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.GET,
      headers
    });
  }

  static async post<T>(url: string, data?: Object | string | ArrayBuffer, headers?: Record<string, string>): Promise<HttpResponseData<T>> {
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.POST,
      extraData: data,
      headers
    });
  }

  static async put<T>(url: string, data?: Object | string | ArrayBuffer, headers?: Record<string, string>): Promise<HttpResponseData<T>> {
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.PUT,
      extraData: data,
      headers
    });
  }

  static async delete<T>(url: string, headers?: Record<string, string>): Promise<HttpResponseData<T>> {
    return HttpUtil.request<T>(url, {
      method: http.RequestMethod.DELETE,
      headers
    });
  }
}

export class HttpResponseWrapper<T> {
  success: boolean;
  data?: T;
  error?: string;
  statusCode?: number;

  private constructor(success: boolean, data?: T, error?: string, statusCode?: number) {
    this.success = success;
    this.data = data;
    this.error = error;
    this.statusCode = statusCode;
  }

  static createSuccess<T>(data: T, statusCode: number = 200): HttpResponseWrapper<T> {
    return new HttpResponseWrapper<T>(true, data, undefined, statusCode);
  }

  static createError<T>(error: string, statusCode: number = 500): HttpResponseWrapper<T> {
    return new HttpResponseWrapper<T>(false, undefined, error, statusCode);
  }
}