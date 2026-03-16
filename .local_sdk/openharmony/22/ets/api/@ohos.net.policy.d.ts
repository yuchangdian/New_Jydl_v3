/*
 * Copyright (C) 2023 Huawei Device Co., Ltd.
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
 * @kit NetworkKit
 */
import type connection from './@ohos.net.connection';
import Context from './application/Context';
/**
 * Provides interfaces to manage network policy rules.
 * @namespace policy
 * @syscap SystemCapability.Communication.NetManager.Core
 * @since 10
 */
declare namespace policy {
    /**
     * Get network bear type.
     * @typedef { connection.NetBearType }
     * @syscap SystemCapability.Communication.NetManager.Core
     * @since 10
     */
    type NetBearType = connection.NetBearType;
    /**
    * Open the network settings interface of the application, which is presented in a semi-modal form and can
    *     be used to configure the network connection method. This API uses a promise to return the result.
    * @param { Context } context - Indicates Context instance.
    * @returns { Promise<void> } The promise returned by the function.
    * @syscap SystemCapability.Communication.NetManager.Core
    * @stagemodelonly
    * @since 22
    */
    function showAppNetPolicySettings(context: Context): Promise<void>;
}
export default policy;
