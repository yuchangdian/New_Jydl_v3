/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
 * Define options for starting child process.
 *
 * @interface ChildProcessOptions
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @stagemodelonly
 * @since 12
 */
export interface ChildProcessOptions {
    /**
     * Controls whether the child process runs in an isolated data sandbox and network environment.
     *
     * - When `true`:
     *   - Child process runs in an independent data sandbox
     *   - Network access is disabled
     *   - Enables UID isolation functionality
     * - When `false` (default):
     *   - Shares parent process's data sandbox
     *   - Inherits parent's network permissions
     *   - Disables UID isolation control
     *
     * @type { ?boolean }
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @since 12
     */
    isolationMode?: boolean;
    /**
     * Controls UID isolation for the child process, effective only when `isolationMode=true`.
     *
     * - When `true`:
     *   - Child process uses independent UID
     * - When `false` (default):
     *   - Child process uses parent process's UID
     *
     * @type { ?boolean }
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @since 21
     */
    isolationUid?: boolean;
}
