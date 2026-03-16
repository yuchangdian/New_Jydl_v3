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
import image from './@ohos.multimedia.image';
/**
 * The result of loading image.
 *
 * @typedef DrawableDescriptorLoadedResult
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 21
 */
export interface DrawableDescriptorLoadedResult {
    /**
     * The width of the image, in px.
     *
     * @type { number }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    imageWidth: number;
    /**
     * The height of the image, in px.
     *
     * @type { number }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    imageHeight: number;
}
/**
 * Use the DrawableDescriptor class to get drawable image.
 *
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Use the DrawableDescriptor class to get drawable image.
 *
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Use the DrawableDescriptor class to get drawable image.
 *
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export declare class DrawableDescriptor {
    /**
     * Get pixelMap of drawable image.
     *
     * @returns { image.PixelMap } Return the PixelMap of the calling DrawableDescriptor object.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Get pixelMap of drawable image.
     *
     * @returns { image.PixelMap } Return the PixelMap of the calling DrawableDescriptor object.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Get pixelMap of drawable image.
     *
     * @returns { image.PixelMap } Return the PixelMap of the calling DrawableDescriptor object.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    getPixelMap(): image.PixelMap;
    /**
     * Synchronously loads the image and returns the loading result.
     *
     * @returns { DrawableDescriptorLoadedResult } loading outcome.
     * @throws { BusinessError } 111001 - resource loading failed.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    loadSync(): DrawableDescriptorLoadedResult;
    /**
     * Asynchronously loads image and returns loading result.
     *
     * @returns { Promise<DrawableDescriptorLoadedResult> } The image loading result.
     * @throws { BusinessError } 111001 - resource loading failed.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    load(): Promise<DrawableDescriptorLoadedResult>;
}
/**
 * Use the LayeredDrawableDescriptor class to get the foreground, the background and the mask DrawableDescriptor.
 *
 * @extends DrawableDescriptor
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Use the LayeredDrawableDescriptor class to get the foreground, the background and the mask DrawableDescriptor.
 *
 * @extends DrawableDescriptor
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Use the LayeredDrawableDescriptor class to get the foreground, the background and the mask DrawableDescriptor.
 *
 * @extends DrawableDescriptor
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export declare class LayeredDrawableDescriptor extends DrawableDescriptor {
    /**
     * Creates a new LayeredDrawableDescriptor.
     *
     * @param { DrawableDescriptor } [foreground] - Indicates the foreground option to create LayeredDrawableDescriptor.
     * @param { DrawableDescriptor } [background] - Indicates the background option to create LayeredDrawableDescriptor.
     * @param { DrawableDescriptor } [mask] - Indicates the mask option to create LayeredDrawableDescriptor.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 12
     */
    constructor(foreground?: DrawableDescriptor, background?: DrawableDescriptor, mask?: DrawableDescriptor);
    /**
     * Get DrawableDescriptor for the foreground.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of foreground.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Get DrawableDescriptor for the foreground.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of foreground.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Get DrawableDescriptor for the foreground.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of foreground.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    getForeground(): DrawableDescriptor;
    /**
     * Get DrawableDescriptor for the background.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of background.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Get DrawableDescriptor for the background.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of background.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Get DrawableDescriptor for the background.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of background.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    getBackground(): DrawableDescriptor;
    /**
     * Get DrawableDescriptor for the mask.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Get DrawableDescriptor for the mask.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Get DrawableDescriptor for the mask.
     *
     * @returns { DrawableDescriptor } Return the DrawableDescriptor object of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    getMask(): DrawableDescriptor;
    /**
     * Get the clip path info of the adaptive icon mask.
     *
     * @returns { string } Return the clip path info of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Get the clip path info of the adaptive icon mask.
     *
     * @returns { string } Return the clip path info of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Get the clip path info of the adaptive icon mask.
     *
     * @returns { string } Return the clip path info of mask.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    static getMaskClipPath(): string;
}
/**
 * Use the PixelMapDrawableDescriptor class to get the resource of pixelmap or resource descriptor information.
 *
 * @extends DrawableDescriptor
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 12
 */
export declare class PixelMapDrawableDescriptor extends DrawableDescriptor {
    /**
     * Creates a new PixelMapDrawableDescriptor.
     * @param { image.PixelMap } src - Indicates the resource to create PixelMapDrawableDescriptor.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 12
     */
    constructor(src?: image.PixelMap);
}
/**
 * Animation control options
 *
 * @interface AnimationOptions
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export declare interface AnimationOptions {
    /**
     * The duration of animation playback once.
     *
     * @type { ?number }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    duration?: number;
    /**
     * Animation playback times.
     *
     * @type { ?number }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    iterations?: number;
    /**
     * Animation frames duration of playback once.
     *
     * @type { ?Array<number> }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    frameDurations?: Array<number>;
    /**
     * Auto play animated images, default value is true.
     *
     * @type { ?boolean }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    autoPlay?: boolean;
}
/**
 * Define the data structure for PixelMap animations.
 *
 * @interface AnimationController
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 21
 */
export interface AnimationController {
    /**
     * Start animtion playback.
     *
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    start(): void;
    /**
     * Stop animation playback, and reset to first frame.
     *
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    stop(): void;
    /**
     * Pause animation playback, and keep it to the current frame.
     *
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    pause(): void;
    /**
     * Resume animation playback from the current frame.
     *
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    resume(): void;
    /**
     * Get animtion status of the current component.
     *
     * @returns { AnimationStatus } Return the status of animation.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    getStatus(): AnimationStatus;
}
/**
 * Define the data structure for PixelMap animations.
 *
 * @extends DrawableDescriptor
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export declare class AnimatedDrawableDescriptor extends DrawableDescriptor {
    /**
     * Creates a new AnimatedDrawableDescriptor.
     *
     * @param { Array<image.PixelMap> } pixelMaps - PixelMap List.
     * @param { AnimationOptions } [options] - Animation control options.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    constructor(pixelMaps: Array<image.PixelMap>, options?: AnimationOptions);
    /**
     * Creates a new AnimatedDrawableDescriptor.
     *
     * @param { ResourceStr | Array<image.PixelMap> } src - animated images or local resource.
     * @param { AnimationOptions } [options] - Animation control options.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    constructor(src: ResourceStr | Array<image.PixelMap>, options?: AnimationOptions);
    /**
     * Get the animation controller of the component based on the component id.
     *
     * @param { string } [id] - component id.
     * @returns { AnimationController | undefined } Return the component of animation controller.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 21
     */
    getAnimationController(id?: string): AnimationController | undefined;
}
