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
import type NotificationSubscriberExtensionContext from './@ohos.application.NotificationSubscriberExtensionContext';
import { NotificationInfo } from './notification/NotificationInfo';
/**
 * class of notification subscriber extension ability.
 *
 * @syscap SystemCapability.Notification.Notification
 * @stagemodelonly
 * @since 22
 */
declare class NotificationSubscriberExtensionAbility {
    /**
     * Indicates configuration information about an ability context.
     *
     * @type { NotificationSubscriberExtensionContext }
     * @syscap SystemCapability.Notification.Notification
     * @stagemodelonly
     * @since 22
     */
    context: NotificationSubscriberExtensionContext;
    /**
     * Callback when the extensionAbility is destroyed
     *
     * @syscap SystemCapability.Notification.Notification
     * @stagemodelonly
     * @since 22
     */
    onDestroy(): void;
    /**
     * Callback when a notification is published.
     *
     * @param { NotificationInfo } notificationInfo - The notification info to be published.
     * @syscap SystemCapability.Notification.Notification
     * @stagemodelonly
     * @since 22
     */
    onReceiveMessage(notificationInfo: NotificationInfo): void;
    /**
     * Callback when notifications is cancelled.
     *
     * @param { Array<string> } hashCodes - The list of notification to be cancelled.
     * @syscap SystemCapability.Notification.Notification
     * @stagemodelonly
     * @since 22
     */
    onCancelMessages(hashCodes: Array<string>): void;
}
export default NotificationSubscriberExtensionAbility;
