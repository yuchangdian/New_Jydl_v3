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
 * @kit AbilityKit
 */
/**
 * Defines a onRequestSuccess function.
 *
 * @typedef {function} OnRequestSuccessFn
 * @param { string } name - Indicates the full ability name or system operation name.
 *     If the result is a normal ability, the format is '[bundleName]#[moduleName]#[abilityName]'.
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @stagemodelonly
 * @atomicservice
 * @since 21
 */
export type OnRequestSuccessFn = (name: string) => void;
/**
 * Defines a onRequestFailure function.
 *
 * @typedef {function} OnRequestFailureFn
 * @param { string } name - Indicates the full ability name or system operation name.
 *     If the result is a normal ability, the format is '[bundleName]#[moduleName]#[abilityName]'.
 *     For some failure scenarios, the name may be empty.
 * @param { AbilityStartFailureCode } failureCode - Indicates the failure code of startAbilityByType.
 * @param { string } failureMessage - Indicates the failure message of startAbilityByType.
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @stagemodelonly
 * @atomicservice
 * @since 21
 */
export type OnRequestFailureFn = (name: string, failureCode: AbilityStartFailureCode, failureMessage: string) => void;
/**
 * A handler to handle the completion events of startAbilityByType.
 *
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @stagemodelonly
 * @atomicservice
 * @since 21
 */
export class CompletionHandlerForAbilityStartCallback {
    /**
     * Notify the success result of startAbilityByType.
     *
     * @type { ?OnRequestSuccessFn }
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @atomicservice
     * @since 21
     */
    onRequestSuccess?: OnRequestSuccessFn;
    /**
     * Notify the failure result of startAbilityByType.
     *
     * @type { ?OnRequestFailureFn }
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @atomicservice
     * @since 21
     */
    onRequestFailure?: OnRequestFailureFn;
}
/**
 * Specific failure codes indicating failure of startAbilityByType.
 *
 * @enum { number }
 * @syscap SystemCapability.Ability.AbilityRuntime.Core
 * @stagemodelonly
 * @atomicservice
 * @since 21
*/
export enum AbilityStartFailureCode {
    /**
     * Indicates failed to startAbilityByType due to the system error, such as dialog crash, alloc memory failed.
     *
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @atomicservice
     * @since 21
     */
    FAILURE_CODE_SYSTEM_MALFUNCTION = 0,
    /**
     * Indicates the user cancelled the redirection.
     *
     * @syscap SystemCapability.Ability.AbilityRuntime.Core
     * @stagemodelonly
     * @atomicservice
     * @since 21
     */
    FAILURE_CODE_USER_CANCEL = 1
}
