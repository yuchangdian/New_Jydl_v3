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
/**
 * @file
 * @kit ArkWeb
 */
import ExtensionContext from './application/ExtensionContext';
import Want from './@ohos.app.ability.Want';
import StartOptions from './@ohos.app.ability.StartOptions';
/**
 * The context of web native messaging extension. It allows access to WebNativeMessagingExtension-specific resources.
 *
 * @extends ExtensionContext
 * @syscap SystemCapability.Web.Webview.Core
 * @stagemodelonly
 * @since 21
 */
export default class WebNativeMessagingExtensionContext extends ExtensionContext {
    /**
     * Starts a new ability.
     *
     * @param { Want } want - Indicates the ability to start.
     * @param { StartOptions } [options] - Indicates the start options.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - The application does not have permission to call the interface.
     * @throws { BusinessError } 16000001 - The specified ability does not exist.
     * @throws { BusinessError } 16000002 - Incorrect ability type.
     * @throws { BusinessError } 16000004 - Cannot start an invisible component.
     * @throws { BusinessError } 16000005 - The specified process does not have the permission.
     * @throws { BusinessError } 16000008 - The crowdtesting application expires.
     * @throws { BusinessError } 16000009 - An ability cannot be started or stopped in Wukong mode.
     * @throws { BusinessError } 16000010 - The call with the continuation and prepare continuation flag is forbidden.
     * @throws { BusinessError } 16000011 - The context does not exist.
     * @throws { BusinessError } 16000012 - The application is controlled.
     * @throws { BusinessError } 16000013 - The application is controlled by EDM.
     * @throws { BusinessError } 16000019 - No matching ability is found.
     * @throws { BusinessError } 16000050 - Internal error. Possible causes: 1. Failed to connect to the system service;
     *     2. The system service failed to communicate with dependency module.
     * @throws { BusinessError } 16000055 - Installation-free timed out.
     * @throws { BusinessError } 16000071 - App clone is not supported.
     * @throws { BusinessError } 16000072 - App clone or multi-instance is not supported.
     * @throws { BusinessError } 16000073 - The app clone index is invalid.
     * @throws { BusinessError } 16000076 - The app instance key is invalid.
     * @throws { BusinessError } 16000077 - The number of app instances reaches the limit.
     * @throws { BusinessError } 16000078 - The multi-instance is not supported.
     * @throws { BusinessError } 16000079 - The APP_INSTANCE_KEY cannot be specified.
     * @throws { BusinessError } 16000080 - Creating a new instance is not supported.
     * @syscap SystemCapability.Web.Webview.Core
     * @stagemodelonly
     * @since 21
     */
    startAbility(want: Want, options?: StartOptions): Promise<void>;
    /**
     * Destroys this web native messaging extension.
     *
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 16000009 - An ability cannot be started or stopped in Wukong mode.
     * @throws { BusinessError } 16000011 - The context does not exist.
     * @throws { BusinessError } 16000050 - Internal error. Possible causes: 1. Failed to connect to the system service;
     *     2. The system service failed to communicate with dependency module.
     * @syscap SystemCapability.Web.Webview.Core
     * @stagemodelonly
     * @since 21
     */
    terminateSelf(): Promise<void>;
    /**
     * Stop the specified native connection.
     *
     * @param { number } connectionId - Indicates the id of the specified connection.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - The application does not have permission to call the interface.
     * @throws { BusinessError } 16000011 - The context does not exist.
     * @throws { BusinessError } 16000050 - Internal error. Possible causes: 1. Failed to connect to the system service;
     *     2. The system service failed to communicate with dependency module.
     * @syscap SystemCapability.Web.Webview.Core
     * @stagemodelonly
     * @since 21
     */
    stopNativeConnection(connectionId: number): Promise<void>;
}
