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
 * Declaration of the menu item on the right side.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Declaration of the menu item on the right side.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Declaration of the menu item on the right side.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 22
 */
export declare class EditableTitleBarMenuItem {
    /**
     * Icon resource for this menu item.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Icon resource for this menu item.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Icon resource for this menu item.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    value: ResourceStr;
    /**
     * Symbol style for this menu item.
     * @type { ?SymbolGlyphModifier }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Symbol style for this menu item.
     * @type { ?SymbolGlyphModifier }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    symbolStyle?: SymbolGlyphModifier;
    /**
     * Icon label for this menu item.
     * @type { ?ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 12
     */
    /**
     * Icon label for this menu item.
     * @type { ?ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    label?: ResourceStr;
    /**
     * Whether to enable this menu item.
     * @type { ?boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Whether to enable this menu item.
     * @type { ?boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Whether to enable this menu item.
     * @type { ?boolean }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    isEnabled?: boolean;
    /**
     * Callback function when click on this menu item.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Callback function when click on this menu item.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Callback function when click on this menu item.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    action?: () => void;
    /**
     * The accessibilityText of this menu item.
     * @type { ?ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * The accessibilityText of this menu item.
     * @type { ?ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    accessibilityText?: ResourceStr;
    /**
     * The accessibilityDescription of this menu item.
     * @type { ?ResourceStr }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * The accessibilityDescription of this menu item.
     * @type { ?ResourceStr }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    accessibilityDescription?: ResourceStr;
    /**
     * The accessibilityLevel of this menu item.
     * @type { ?string }
     * @default "auto"
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * The accessibilityLevel of this menu item.
     * @type { ?string }
     * @default "auto"
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    accessibilityLevel?: string;
    /**
     * Set the default focus state of this menu item.
     * @type { ?boolean }.
     * @default { false }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 18
     */
    /**
     * Set the default focus state of this menu item.
     * @type { ?boolean }.
     * @default { false }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    defaultFocus?: boolean;
}
/**
 * Declaration of the image item .
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export type EditableTitleBarItem = EditableTitleBarMenuItem;
/**
 * Declaration of the left icon type.
 * @enum { EditableLeftIconType }.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Declaration of the left icon type.
 * @enum { EditableLeftIconType }.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Declaration of the left icon type.
 * @enum { EditableLeftIconType }.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 22
 */
export declare enum EditableLeftIconType {
    /**
     * The back type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * The back type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * The back type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    Back = 0,
    /**
     * The cancel type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * The cancel type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * The cancel type.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    Cancel = 1
}
/**
 * Indicates the options of the editable title bar.
 *
 * @interface EditableTitleBarOptions
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 12
 */
export declare interface EditableTitleBarOptions {
    /**
     * Background color.
     *
     * @type { ?ResourceColor }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    backgroundColor?: ResourceColor;
    /**
     * Background blur style.
     *
     * @type { ?BlurStyle }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    backgroundBlurStyle?: BlurStyle;
    /**
     * Indicates the types of the safe area.
     *
     * @type { ?Array<SafeAreaType> }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    safeAreaTypes?: Array<SafeAreaType>;
    /**
     * Indicates the edges of the safe area.
     *
     * @type { ?Array<SafeAreaEdge> }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    safeAreaEdges?: Array<SafeAreaEdge>;
}
/**
 * Declaration of the editable title bar.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @since 10
 */
/**
 * Declaration of the editable title bar.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @atomicservice
 * @since 11
 */
/**
 * Declaration of the editable title bar.
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 * @crossplatform
 * @atomicservice
 * @since 22
 */
@Component
export declare struct EditableTitleBar {
    /**
     * Style of the left icon.
     * @type { EditableLeftIconType }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Style of the left icon.
     * @type { EditableLeftIconType }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Style of the left icon.
     * @type { EditableLeftIconType }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    leftIconStyle: EditableLeftIconType;
    /**
     * Image item between the left icon and the title.
     * @type { ?EditableTitleBarItem }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    imageItem?: EditableTitleBarItem;
    /**
     * Title of this title bar.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Title of this title bar.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Title of this title bar.
     * @type { ResourceStr }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    title: ResourceStr;
    /**
     * Sub-Title of this title bar.
     * @type { ?ResourceStr }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    subtitle?: ResourceStr;
    /**
     * Whether to required the save icon.
     * @type { boolean }
     * @default true
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    isSaveIconRequired: boolean;
    /**
     * Menu items on the right side.
     * @type { ?Array<EditableTitleBarMenuItem> }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Menu items on the right side.
     * @type { ?Array<EditableTitleBarMenuItem> }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Menu items on the right side.
     * @type { ?Array<EditableTitleBarMenuItem> }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    menuItems?: Array<EditableTitleBarMenuItem>;
    /**
     * Callback function when click on the save icon at the right side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Callback function when click on the save icon at the right side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Callback function when click on the save icon at the right side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    onSave?: () => void;
    /**
     * Callback function when click on the cancel icon at the left side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @since 10
     */
    /**
     * Callback function when click on the cancel icon at the left side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @atomicservice
     * @since 11
     */
    /**
     * Callback function when click on the cancel icon at the left side.
     * @type { ?() => void }.
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    onCancel?: () => void;
    /**
     * Indicates the options of titlebar.
     * @type { EditableTitleBarOptions }
     * @default {expandSafeAreaTypes: SafeAreaType.SYSTEM, expandSafeAreaEdges: SafeAreaEdge.TOP}
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    options: EditableTitleBarOptions;
    /**
     * Sets the content margin.
     * @type { ?LocalizedMargin }
     * @default {start: LengthMetrics.resource($r('sys.float.margin_left')),
     * <br> end: LengthMetrics.resource($r('sys.float.margin_right'))}
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 12
     */
    @Prop
    contentMargin?: LocalizedMargin;
    /**
     * Sets the default focus state of left icon.
     * @type { ?boolean }
     * @default { false }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 18
     */
    leftIconDefaultFocus?: boolean;
    /**
     * Sets the default focus state of save icon.
     * @type { ?boolean }
     * @default { false }
     * @syscap SystemCapability.ArkUI.ArkUI.Full
     * @crossplatform
     * @atomicservice
     * @since 18
     */
    saveIconDefaultFocus?: boolean;
}
