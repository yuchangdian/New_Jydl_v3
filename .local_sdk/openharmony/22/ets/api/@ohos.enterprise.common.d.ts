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
 * @kit MDMKit
 */
/**
 * This module provides the common interface or enum.
 *
 * @namespace common
 * @syscap SystemCapability.Customization.EnterpriseDeviceManager
 * @stagemodelonly
 * @since 22
 */
declare namespace common {
    /**
     * Application instance data.
     *
     * @typedef ApplicationInstance
     * @syscap SystemCapability.Customization.EnterpriseDeviceManager
     * @stagemodelonly
     * @since 22
     */
    export interface ApplicationInstance {
        /**
         * Globally unique identifier of an application, which is allocated by the cloud.
         * AppIdentifier does not change along the application lifecycle, including version updates, certificate changes,
         * public and private key changes, and application transfer.
         *
         * @type { string }
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        appIdentifier: string;
        /**
         * Indicates the OS account identifier.
         *
         * @type { number }
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        accountId: number;
        /**
         * Indicates the index of clone app.
         *
         * @type { number }
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        appIndex: number;
    }
    /**
     * The managed policy of enterprise device
     *
     * @enum { number }
     * @syscap SystemCapability.Customization.EnterpriseDeviceManager
     * @stagemodelonly
     * @since 22
     */
    export enum ManagedPolicy {
        /**
         * Not managed the feature of the device
         *
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        DEFAULT = 0,
        /**
         * Disallow the feature of the device
         *
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        DISALLOW = 1,
        /**
         * Force open the feature of the device
         *
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        FORCE_OPEN = 2
    }
    /**
     * The result of application installation.
     *
     * @interface InstallationResult
     * @syscap SystemCapability.Customization.EnterpriseDeviceManager
     * @stagemodelonly
     * @since 22
     */
    export interface InstallationResult {
        /**
         * The result code of application installation.
         *
         * @type { Result }
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        result: Result;
        /**
         * The result message of application installation.
         *
         * @type { string }
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        message: string;
    }
    /**
     * Enum for result code.
     *
     * @enum { number }
     * @syscap SystemCapability.Customization.EnterpriseDeviceManager
     * @stagemodelonly
     * @since 22
     */
    export enum Result {
        /**
         * Indicates the action succeeded.
         *
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        SUCCESS = 0,
        /**
         * Indicates the action failed.
         *
         * @syscap SystemCapability.Customization.EnterpriseDeviceManager
         * @stagemodelonly
         * @since 22
         */
        FAIL = -1
    }
}
export default common;
