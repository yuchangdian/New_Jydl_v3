/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License"),
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
/**
 * @file
 * @kit NotificationKit
 */
import type UIAbilityContext from './application/UIAbilityContext';
import { BundleOption as _BundleOption, GrantedBundleInfo as _GrantedBundleInfo } from './notification/NotificationCommonDef';
import { NotificationExtensionSubscriptionInfo as _NotificationExtensionSubscriptionInfo } from './notification/NotificationExtensionSubscriptionInfo';
import { NotificationInfo as _NotificationInfo } from './notification/NotificationInfo';
/**
 * Manages notifications extension subscription.
 *
 * @namespace notificationExtensionSubscription
 * @syscap SystemCapability.Notification.Notification
 * @since 22
 */
declare namespace notificationExtensionSubscription {
    /**
     * Opens the notification extension subscription settings page of the application, which is displayed in
     * semi-modal mode and can be used to set the notification enabling and notification mode.
     * This API uses a promise to return the result.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @param { UIAbilityContext } context - Ability context bound to the notification settings page.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600018 - The notification settings window is already displayed.
     * @throws { BusinessError } 1600023 - The application does not implement the NotificationSubscriberExtensionAbility.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function openSubscriptionSettings(context: UIAbilityContext): Promise<void>;
    /**
     * Subscribe the notification extension when the bluetooth addr is connected.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @param { NotificationExtensionSubscriptionInfo[] } info - The info to be subscribe.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600003 - Failed to connect to the service.
     * @throws { BusinessError } 1600023 - The application does not implement the NotificationSubscriberExtensionAbility.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function subscribe(info: NotificationExtensionSubscriptionInfo[]): Promise<void>;
    /**
     * Unsubscribe the notification extension.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600003 - Failed to connect to the service.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function unsubscribe(): Promise<void>;
    /**
     * Obtains the subscribe info.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @returns { Promise<NotificationExtensionSubscriptionInfo[]> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600003 - Failed to connect to the service.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function getSubscribeInfo(): Promise<NotificationExtensionSubscriptionInfo[]>;
    /**
     * Obtains whether the notification extension subscription is granted by user.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @returns { Promise<boolean> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600003 - Failed to connect to the service.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function isUserGranted(): Promise<boolean>;
    /**
     * Obtains the list of grantedBundleInfo that have been granted by the user.
     *
     * @permission ohos.permission.SUBSCRIBE_NOTIFICATION
     * @returns { Promise<GrantedBundleInfo[]> } Return the list of bundleInfo which is enabled.
     * @throws { BusinessError } 201 - Permission denied.
     * @throws { BusinessError } 1600001 - Internal error.
     * @throws { BusinessError } 1600003 - Failed to connect to the service.
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    function getUserGrantedEnabledBundles(): Promise<GrantedBundleInfo[]>;
    /**
     * Enum for notification extension subscribe type.
     *
     * @enum { number }
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    export enum SubscribeType {
        /**
         * Subscribe notification extension by bluetooth.
         *
         * @syscap SystemCapability.Notification.Notification
         * @since 22
         */
        BLUETOOTH = 0
    }
    /**
     * Describes a bundleOption.
     *
     * @typedef { _BundleOption } BundleOption
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    export type BundleOption = _BundleOption;
    /**
     * Describes a grantedBundleInfo.
     *
     * @typedef { _GrantedBundleInfo } GrantedBundleInfo
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    export type GrantedBundleInfo = _GrantedBundleInfo;
    /**
     * the notification extension subscription info.
     *
     * @typedef { _NotificationExtensionSubscriptionInfo } NotificationExtensionSubscriptionInfo
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    export type NotificationExtensionSubscriptionInfo = _NotificationExtensionSubscriptionInfo;
    /**
     * Describes the notification info.
     *
     * @typedef { _NotificationInfo } NotificationInfo
     * @syscap SystemCapability.Notification.Notification
     * @since 22
     */
    export type NotificationInfo = _NotificationInfo;
}
export default notificationExtensionSubscription;
