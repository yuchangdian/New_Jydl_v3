/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
 * @kit AbilityKit
 */
/**
 * The class of auto startup manager.
 *
 * @namespace autoStartupManager
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @since 21
 */
declare namespace autoStartupManager {
    /**
     * Retrieves the auto-start status of the current application.
     *
     * @returns { Promise<boolean> } Returns {@code true} if the current application has been enabled for
     *     auto-start on boot by the user; returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported.
     * @throws { BusinessError } 16000050 - Internal error. Possible causes: 1. Connect to system service failed;
     *     2.System service failed to communicate with dependency module.
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @since 21
     */
    function getAutoStartupStatusForSelf(): Promise<boolean>;
}
export default autoStartupManager;
