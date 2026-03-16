/*
 * Copyright (c) 2023-2025 Huawei Device Co., Ltd.
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
 * @kit ArkUI
 */
/**
 * Declare Component ProgressButton
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Declare Component ProgressButton
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Declare Component ProgressButton
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 22
 */
@Component
export declare struct ProgressButton {
    /**
     * Sets the ProgressButton progress.
     * @type { number }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Sets the ProgressButton progress.
     * @type { number }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Sets the ProgressButton progress.
     * @type { number }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    @Prop
    progress: number;
    /**
     * Sets the ProgressButton content.
     * @type { string }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Sets the ProgressButton content.
     * @type { string }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Sets the ProgressButton content.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 20
     */
    @Prop
    content: ResourceStr;
    /**
     * Sets the ProgressButton progressButtonWidth.
     * @type { ?Length }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Sets the ProgressButton progressButtonWidth.
     * @type { ?Length }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Sets the ProgressButton progressButtonWidth.
     * @type { ?Length }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    progressButtonWidth?: Length;
    /**
     * Sets the ProgressButton clickCallback.
     * @type { () => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Sets the ProgressButton clickCallback.
     * @type { () => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Sets the ProgressButton clickCallback.
     * @type { () => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    clickCallback: () => void;
    /**
     * Sets the ProgressButton enable state.
     * @type { boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Sets the ProgressButton enable state.
     * @type { boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Sets the ProgressButton enable state.
     * @type { boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    @Prop
    enable: boolean;
    /**
     * Set Color options of the ProgressButton.
     *
     * @type { ?ProgressButtonColorOptions }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set Color options of the ProgressButton.
     *
     * @type { ?ProgressButtonColorOptions }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    @Prop
    colorOptions?: ProgressButtonColorOptions;
    /**
     * Set border rounded corner radius of progress.
     *
     * @type { ?LengthMetrics }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 18
     */
    @Prop
    progressButtonRadius?: LengthMetrics;
}
/**
 * Declare Color options of the ProgressButton.
 *
 * @interface ProgressButtonColorOptions
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 18
 */
/**
 * Declare Color options of the ProgressButton.
 *
 * @interface ProgressButtonColorOptions
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 22
 */
export declare interface ProgressButtonColorOptions {
    /**
     * Set progress color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set progress color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    progressColor?: ResourceColor;
    /**
     * Set border color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set border color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    borderColor?: ResourceColor;
    /**
     * Set text color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set text color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    textColor?: ResourceColor;
    /**
     * Set background color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set background color of the ProgressButton.
     *
     * @type { ?ResourceColor }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    backgroundColor?: ResourceColor;
}
