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
 * @file Identify sensitive file
 * @kit DataProtectionKit
 */
/**
 * identifySensitiveContent
 * @namespace identifySensitiveContent
 * @syscap SystemCapability.Security.DataLossPrevention
 * @since 21
 */
declare namespace identifySensitiveContent {
    /**
     * Identify Policy
     * @typedef Policy
     * @syscap SystemCapability.Security.DataLossPrevention
     * @since 21
     */
    export interface Policy {
        /**
         * Sensitive Label
         * Label Length:[1, 30]
         * @type { string }
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        sensitiveLabel: string;
        /**
         * Collection of keyword
         * Keyword Length:[1, 30]
         * Array Length:[0,50]
         * @type { Array<string> }
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        keywords: Array<string>;
        /**
         * Regular expression
         * Regex Length:[0, 512]
         * @type { string }
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        regex: string;
    }
    /**
     * Match result
     * @typedef MatchResult
     * @syscap SystemCapability.Security.DataLossPrevention
     * @since 21
     */
    export interface MatchResult {
        /**
         * Identify Label
         * @type { string }
         * @readonly
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        readonly sensitiveLabel: string;
        /**
         * Match content
         * @type { string }
         * @readonly
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        readonly matchContent: string;
        /**
         * Total number of identified content
         * @type { number }
         * @readonly
         * @syscap SystemCapability.Security.DataLossPrevention
         * @since 21
         */
        readonly matchNumber: number;
    }
    /**
     * Identify sensitive content from file based on policy.
     * @permission ohos.permission.ENTERPRISE_DATA_IDENTIFY_FILE
     * @param { string } filePath - To be idetified file path
     * @param { Array<Policy> } identifyPolicies - Identify Policy
     * @returns { Promise<Array<MatchResult>> } Identify result of Sensitive content
     * @throws { BusinessError } 201 - permission denied.
     * @throws { BusinessError } 801 - Capability not supported.
     * @throws { BusinessError } 19110001 - Parameter error. Possible causes:
     *     1. Incorrect policy format.
     *     2. Invalid parameter range.
     * @throws { BusinessError } 19110002 - Sensitive file content identification timed out.
     * @throws { BusinessError } 19110003 - The file is not supported. Possible causes:
     *     1. The file path does not exist.
     *     2. The file type is not supported.
     *     3. The file permission is not supported.
     * @throws { BusinessError } 19110004 - A system error has occurred.
     * @syscap SystemCapability.Security.DataLossPrevention
     * @since 21
     */
    function scanFile(filePath: string, identifyPolicies: Array<Policy>): Promise<Array<MatchResult>>;
}
export default identifySensitiveContent;
