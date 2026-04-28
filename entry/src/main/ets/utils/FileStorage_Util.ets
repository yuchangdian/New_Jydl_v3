import fs from '@ohos.file.fs';
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import util from '@ohos.util';

const DOMAIN = 0x0000;
const TAG = 'FileStorage';

function bufferToString(buffer: ArrayBuffer, length: number): string {
  const uint8Array = new Uint8Array(buffer, 0, length);
  let result = '';
  for (let i = 0; i < uint8Array.length; i++) {
    result += String.fromCharCode(uint8Array[i]);
  }
  return result;
}

export class FileStorageUtil {
  private static cacheDir: string = '';

  static setCacheDir(dir: string): void {
    FileStorageUtil.cacheDir = dir;
  }

  static getCacheDir(): string {
    return FileStorageUtil.cacheDir;
  }

  static async downloadFile(url: string, localPath: string): Promise<boolean> {
    hilog.info(DOMAIN, TAG, '开始下载文件: %{public}s -> %{public}s', url, localPath);

    try {
      const httpRequest = http.createHttp();

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      hilog.info(DOMAIN, TAG, '下载响应状态码: %{public}d', response.responseCode);

      if (response.responseCode === 200 && response.result instanceof ArrayBuffer) {
        const arrayBuffer = response.result;
        hilog.info(DOMAIN, TAG, '文件大小: %{public}d bytes', arrayBuffer.byteLength);

        const dirPath = localPath.substring(0, localPath.lastIndexOf('/'));
        if (dirPath && dirPath !== localPath) {
          try {
            if (!FileStorageUtil.dirExists(dirPath)) {
              fs.mkdirSync(dirPath, true);
              hilog.info(DOMAIN, TAG, '创建目录: %{public}s', dirPath);
            }
          } catch (e) {
            hilog.warn(DOMAIN, TAG, '目录处理: %{public}s', String(e));
          }
        }

        if (FileStorageUtil.fileExists(localPath)) {
          FileStorageUtil.deleteFile(localPath);
        }

        try {
          const file = fs.openSync(localPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
          hilog.info(DOMAIN, TAG, '文件打开成功: %{public}s', localPath);
          const writeLen = fs.writeSync(file.fd, arrayBuffer, { length: arrayBuffer.byteLength });
          fs.closeSync(file);
          hilog.info(DOMAIN, TAG, '文件写入 %{public}d bytes', writeLen);
        } catch (e) {
          hilog.error(DOMAIN, TAG, '文件写入异常: %{public}s', String(e));
          throw new Error(String(e));
        }

        hilog.info(DOMAIN, TAG, '文件下载成功: %{public}s', localPath);
        httpRequest.destroy();
        return true;
      } else {
        hilog.error(DOMAIN, TAG, '下载失败，状态码: %{public}d', response.responseCode);
        httpRequest.destroy();
        return false;
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, '下载文件异常: %{public}s', String(error));
      return false;
    }
  }

  static async downloadFiles(urls: string[], basePath: string): Promise<Map<string, string>> {
    const result: Map<string, string> = new Map<string, string>();

    for (let i = 0; i < urls.length; i++) {
      let url = urls[i];
      while (url.includes('`')) {
        url = url.replace('`', '');
      }
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = `http://139.159.148.74/${url}`;
      }
      const fileName = url.substring(url.lastIndexOf('/') + 1);
      const localPath = `${basePath}/${fileName}`;

      hilog.info(DOMAIN, TAG, '准备下载: %{public}s -> %{public}s', url, localPath);

      const success = await FileStorageUtil.downloadFile(url, localPath);
      if (success) {
        result.set(url, localPath);
      }
    }

    return result;
  }

  static fileExists(path: string): boolean {
    try {
      fs.accessSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static dirExists(path: string): boolean {
    try {
      const stat = fs.statSync(path);
      return stat.isDirectory();
    } catch (e) {
      return false;
    }
  }

  static deleteFile(path: string): boolean {
    try {
      fs.unlinkSync(path);
      hilog.info(DOMAIN, TAG, '删除文件成功: %{public}s', path);
      return true;
    } catch (e) {
      hilog.error(DOMAIN, TAG, '删除文件失败: %{public}s', String(e));
      return false;
    }
  }

  static readFile(path: string): string {
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(path);
      const buffer = new ArrayBuffer(stat.size);
      const readLen = fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      return bufferToString(buffer, readLen);
    } catch (e) {
      hilog.error(DOMAIN, TAG, '读取文件失败: %{public}s', String(e));
      return '';
    }
  }
}