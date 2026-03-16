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
 * @kit BasicServicesKit
 */
/**
 * Available is an Annotation and it supports class function variable type interface namespace etc
 * Apply this annotation at the source code location, then call the corresponding source code (e.g., class).
 * During compilation, compatibility checks will be triggered. If minApiVersion exceeds the compatibleSDKVersion specified in build-profile.json5,
 * a compatibility warning will be generated.
 * @syscap SystemCapability.Base
 * @stagemodelonly
 * @crossplatform
 * @form
 * @atomicservice
 * @since 22
 */
export @interface Available {
    /**
     * minApiVersion is used to indicate the minimum Available version. Composed of two parts: System Type + Version Number. The system type can be omitted only when the type is OpenHarmony.For example: 'OpenHarmony 20' '20'
     * @type { string }
     * @syscap SystemCapability.Base
     * @stagemodelonly
     * @crossplatform
     * @form
     * @atomicservice
     * @since 22
     */
    minApiVersion: string = '';
}
