import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';

const DOMAIN = 0x0000;
const TAG = 'PreferencesUtil';

export interface UserInfo {
  account: string;
  password?: string;
  companyId: string;
  roleId: number;
  CurrentRole: number;
  token?: string;
  userName?: string;
}

export class PreferencesUtil {
  private static preferences: preferences.Preferences | undefined = undefined;
  private static context: common.Context | undefined = undefined;

  static init(context: common.Context): void {
    PreferencesUtil.context = context;
  }

  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!PreferencesUtil.preferences && PreferencesUtil.context) {
      PreferencesUtil.preferences = await preferences.getPreferences(PreferencesUtil.context, 'smartPlatform');
    }
    return PreferencesUtil.preferences!;
  }

  static async get(key: string, defaultValue: string = ''): Promise<string> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      const value = await prefs.get(key, defaultValue);
      return value as string;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '获取数据失败: %{public}s, key: %{public}s', String(error), key);
      return defaultValue;
    }
  }

  static async put(key: string, value: string): Promise<void> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      await prefs.put(key, value);
      await prefs.flush();
    } catch (error) {
      hilog.error(DOMAIN, TAG, '保存数据失败: %{public}s, key: %{public}s', String(error), key);
    }
  }

  static async delete(key: string): Promise<void> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      await prefs.delete(key);
      await prefs.flush();
    } catch (error) {
      hilog.error(DOMAIN, TAG, '删除数据失败: %{public}s, key: %{public}s', String(error), key);
    }
  }

  static async clear(): Promise<void> {
    try {
      const prefs = await PreferencesUtil.getPreferences();
      await prefs.clear();
      await prefs.flush();
      hilog.info(DOMAIN, TAG, '清空所有数据成功');
    } catch (error) {
      hilog.error(DOMAIN, TAG, '清空数据失败: %{public}s', String(error));
    }
  }

  static async getUserInfo(): Promise<UserInfo> {
    try {
      const userInfoStr = await PreferencesUtil.get('userInfo', '');
      if (userInfoStr && typeof userInfoStr === 'string') {
        const userInfo = JSON.parse(userInfoStr) as UserInfo;
        return userInfo;
      }
      return PreferencesUtil.getDefaultUserInfo();
    } catch (error) {
      hilog.error(DOMAIN, TAG, '获取用户信息失败: %{public}s', String(error));
      return PreferencesUtil.getDefaultUserInfo();
    }
  }

  static async saveUserInfo(userInfo: UserInfo): Promise<void> {
    try {
      const userInfoStr = JSON.stringify(userInfo);
      await PreferencesUtil.put('userInfo', userInfoStr);
      hilog.info(DOMAIN, TAG, '用户信息保存成功');
    } catch (error) {
      hilog.error(DOMAIN, TAG, '保存用户信息失败: %{public}s', String(error));
    }
  }

  // 获取默认用户信息
  static getDefaultUserInfo(): UserInfo {
    return {
      account: 'admin',
      password: 'admin',
      companyId: '1',
      roleId: 2,
      CurrentRole: 2,
      token: '',
      userName: 'admin'
    };
  }
}

