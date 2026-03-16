/*
 * Copyright (c) 2022-2025 Huawei Device Co., Ltd.
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
 * @kit LocationKit
 */
import { AsyncCallback, Callback } from './@ohos.base';
import { WantAgent } from './@ohos.wantAgent';
import { NotificationRequest } from './notification/notificationRequest';
/**
 * Provides interfaces for acquiring location information, managing location switches,
 * geocoding, reverse geocoding, country code, fencing and other functions.
 *
 * @namespace geoLocationManager
 * @since 9
 */
/**
 * Provides interfaces for acquiring location information, managing location switches,
 * geocoding, reverse geocoding, country code, fencing and other functions.
 *
 * @namespace geoLocationManager
 * @syscap SystemCapability.Location.Location.Core
 * @atomicservice
 * @since 11
 */
/**
 * Provides interfaces for acquiring location information, managing location switches,
 * geocoding, reverse geocoding, country code, fencing and other functions.
 *
 * @namespace geoLocationManager
 * @syscap SystemCapability.Location.Location.Core
 * @crossplatform
 * @atomicservice
 * @since 22
 */
declare namespace geoLocationManager {
    /**
     * Subscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { LocationRequest } request - Indicates the location request parameters.
     * @param { Callback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Subscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { LocationRequest } request - Indicates the location request parameters.
     * @param { Callback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Subscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { LocationRequest | ContinuousLocationRequest } request - Indicates the location request parameters.
     * @param { Callback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Subscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { LocationRequest | ContinuousLocationRequest } request - Indicates the location request parameters.
     * @param { Callback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 18
     */
    /**
     * Subscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { LocationRequest | ContinuousLocationRequest } request - Indicates the location request parameters.
     * @param { Callback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed.
     *     The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters
     *     are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function on(type: 'locationChange', request: LocationRequest | ContinuousLocationRequest, callback: Callback<Location>): void;
    /**
     * Unsubscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Location> } [callback] - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Unsubscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Location> } [callback] - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Unsubscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Location> } [callback] - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 18
     */
    /**
     * Unsubscribe location changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Location> } [callback] - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the
     *     permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left
     *     unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('locationChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function off(type: 'locationChange', callback?: Callback<Location>): void;
    /**
     * Subscribe continuous location error changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationError' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<LocationError> } callback - Indicates the callback for reporting the continuous location error.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationError')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
        */
    /**
     * Subscribe continuous location error changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationError' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<LocationError> } callback - Indicates the callback for reporting the
     *     continuous location error.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not
     *     have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters
     *     are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('locationError')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function on(type: 'locationError', callback: Callback<LocationError>): void;
    /**
     * Unsubscribe continuous location error changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationError' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<LocationError> } [callback] - Indicates the callback for reporting the continuous location error.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('locationError')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Unsubscribe continuous location error changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'locationError' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<LocationError> } [callback] - Indicates the callback for reporting the continuous
     *     location error.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the
     *     permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are
     *     left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('locationError')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function off(type: 'locationError', callback?: Callback<LocationError>): void;
    /**
     * Subscribe location switch changed.
     *
     * @param { 'locationEnabledChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<boolean> } callback - Indicates the callback for reporting the location switch status.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('locationEnabledChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Subscribe location switch changed.
     *
     * @param { 'locationEnabledChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<boolean> } callback - Indicates the callback for reporting the location switch status.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left
     *     unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('locationEnabledChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @crossplatform
     * @syscap SystemCapability.Location.Location.Core
     * @since 22
     */
    function on(type: 'locationEnabledChange', callback: Callback<boolean>): void;
    /**
     * Unsubscribe location switch changed.
     *
     * @param { 'locationEnabledChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<boolean> } [callback] - Indicates the callback for reporting the location switch status.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('locationEnabledChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Unsubscribe location switch changed.
     *
     * @param { 'locationEnabledChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<boolean> } [callback] - Indicates the callback for reporting the location switch status.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left
     *     unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('locationEnabledChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function off(type: 'locationEnabledChange', callback?: Callback<boolean>): void;
    /**
     * Subscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { CachedGnssLocationsRequest } request - Indicates the cached GNSS locations request parameters.
     * @param { Callback<Array<Location>> } callback - Indicates the callback for reporting the cached GNSS locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Subscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { CachedGnssLocationsRequest } request - Indicates the cached GNSS locations request parameters.
     * @param { Callback<Array<Location>> } callback - Indicates the callback for reporting the cached GNSS locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 18
     */
    /**
     * Subscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { CachedGnssLocationsRequest } request - Indicates the cached GNSS locations request parameters.
     * @param { Callback<Array<Location>> } callback - Indicates the callback for reporting the cached GNSS locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission
     *     required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
     *     2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function on(type: 'cachedGnssLocationsChange', request: CachedGnssLocationsRequest, callback: Callback<Array<Location>>): void;
    /**
     * Unsubscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Array<Location>> } [callback] - Indicates the callback for reporting the cached gnss locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Unsubscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Array<Location>> } [callback] - Indicates the callback for reporting the cached gnss locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 18
     */
    /**
     * Unsubscribe to cache GNSS locations update messages.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'cachedGnssLocationsChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<Array<Location>> } [callback] - Indicates the callback for reporting the cached gnss locations.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('cachedGnssLocationsChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function off(type: 'cachedGnssLocationsChange', callback?: Callback<Array<Location>>): void;
    /**
     * Subscribe satellite status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'satelliteStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<SatelliteStatusInfo> } callback - Indicates the callback for reporting the satellite status.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('satelliteStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Subscribe satellite status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'satelliteStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<SatelliteStatusInfo> } callback - Indicates the callback for reporting the satellite status.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('satelliteStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function on(type: 'satelliteStatusChange', callback: Callback<SatelliteStatusInfo>): void;
    /**
     * Unsubscribe satellite status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'satelliteStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<SatelliteStatusInfo> } [callback] - Indicates the callback for reporting the satellite status.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('satelliteStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Unsubscribe satellite status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'satelliteStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<SatelliteStatusInfo> } [callback] - Indicates the callback for reporting the satellite status.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('satelliteStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function off(type: 'satelliteStatusChange', callback?: Callback<SatelliteStatusInfo>): void;
    /**
     * Subscribe nmea message changed.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'nmeaMessage' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<string> } callback - Indicates the callback for reporting the nmea message.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('nmeaMessage')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Subscribe nmea message changed.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'nmeaMessage' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<string> } callback - Indicates the callback for reporting the nmea message.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('nmeaMessage')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function on(type: 'nmeaMessage', callback: Callback<string>): void;
    /**
     * Unsubscribe nmea message changed.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'nmeaMessage' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<string> } [callback] - Indicates the callback for reporting the nmea message.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('nmeaMessage')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Unsubscribe nmea message changed.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'nmeaMessage' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<string> } [callback] - Indicates the callback for reporting the nmea message.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('nmeaMessage')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function off(type: 'nmeaMessage', callback?: Callback<string>): void;
    /**
     * Add a geofence and subscribe geofence status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'gnssFenceStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { GeofenceRequest } request - Indicates the Geofence configuration parameters.
     * @param { WantAgent } want - Indicates which ability to start when the geofence event is triggered.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('gnssFenceStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301600 - Failed to operate the geofence.
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 9
     */
    function on(type: 'gnssFenceStatusChange', request: GeofenceRequest, want: WantAgent): void;
    /**
     * Remove a geofence and unsubscribe geofence status changed.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'gnssFenceStatusChange' } type - Indicates the location service event to be subscribed to.
     * @param { GeofenceRequest } request - Indicates the Geofence configuration parameters.
     * @param { WantAgent } want - Indicates which ability to start when the geofence event is triggered.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('gnssFenceStatusChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301600 - Failed to operate the geofence.
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 9
     */
    function off(type: 'gnssFenceStatusChange', request: GeofenceRequest, want: WantAgent): void;
    /**
     * Registering the callback function for listening to country code changes.
     *
     * @param { 'countryCodeChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<CountryCode> } callback - Indicates the callback for reporting country code changes.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('countryCodeChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Registering the callback function for listening to country code changes.
     *
     * @param { 'countryCodeChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<CountryCode> } callback - Indicates the callback for reporting country code changes.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('countryCodeChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function on(type: 'countryCodeChange', callback: Callback<CountryCode>): void;
    /**
     * Unregistering the callback function for listening to country code changes.
     *
     * @param { 'countryCodeChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<CountryCode> } [callback] - Indicates the callback for reporting country code changes.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('countryCodeChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Unregistering the callback function for listening to country code changes.
     *
     * @param { 'countryCodeChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<CountryCode> } [callback] - Indicates the callback for reporting country code changes.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('countryCodeChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function off(type: 'countryCodeChange', callback?: Callback<CountryCode>): void;
    /**
     * Registers and listens to bluetooth scanning results for location services.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'bluetoothScanResultChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<BluetoothScanResult> } callback - Indicates the callback for reporting Bluetooth scan info.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.on('bluetoothScanResultChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Core
     * @since 16
     */
    /**
     * Registers and listens to bluetooth scanning results for location services.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'bluetoothScanResultChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<BluetoothScanResult> } callback - Indicates the callback for reporting Bluetooth scan info.
     * @throws { BusinessError } 201 - Permission verification failed. The application does
     *     not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.on('bluetoothScanResultChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function on(type: 'bluetoothScanResultChange', callback: Callback<BluetoothScanResult>): void;
    /**
     * Stop bluetooth scanning and unregister to listen to bluetooth scanning result changes.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'bluetoothScanResultChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<BluetoothScanResult> } [callback] - Indicates the callback for reporting Bluetooth scan info.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.off('bluetoothScanResultChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 16
     */
    /**
     * Stop bluetooth scanning and unregister to listen to bluetooth scanning result changes.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { 'bluetoothScanResultChange' } type - Indicates the location service event to be subscribed to.
     * @param { Callback<BluetoothScanResult> } [callback] - Indicates the callback for reporting Bluetooth scan info.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.off('bluetoothScanResultChange')} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function off(type: 'bluetoothScanResultChange', callback?: Callback<BluetoothScanResult>): void;
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest } request - Indicates the location request parameters.
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest } request - Indicates the location request parameters.
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest | SingleLocationRequest } request - Indicates the location request parameters.
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest | SingleLocationRequest } request - Indicates the location request parameters.
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function getCurrentLocation(request: CurrentLocationRequest | SingleLocationRequest, callback: AsyncCallback<Location>): void;
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<Location> } callback - Indicates the callback for reporting the location result.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the
     *     permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left
     *     unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function getCurrentLocation(callback: AsyncCallback<Location>): void;
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest } [request] - Indicates the location request parameters.
     * @returns { Promise<Location> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest } [request] - Indicates the location request parameters.
     * @returns { Promise<Location> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest | SingleLocationRequest } [request] - Indicates the location request parameters.
     * @returns { Promise<Location> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Obtain current location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { CurrentLocationRequest | SingleLocationRequest } [request] - Indicates the location request parameters.
     * @returns { Promise<Location> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does
     *     not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCurrentLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function getCurrentLocation(request?: CurrentLocationRequest | SingleLocationRequest): Promise<Location>;
    /**
     * Obtain last known location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Location } The last known location information.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getLastLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain last known location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Location } The last known location information.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getLastLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Obtain last known location.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Location } The last known location information.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getLastLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function getLastLocation(): Location;
    /**
     * Obtain current location switch status.
     *
     * @returns { boolean } Returns {@code true} if the location switch on, returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.isLocationEnabled} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain current location switch status.
     *
     * @returns { boolean } Returns {@code true} if the location switch on, returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.isLocationEnabled} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Obtain current location switch status.
     *
     * @returns { boolean } Returns {@code true} if the location switch on, returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.isLocationEnabled} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function isLocationEnabled(): boolean;
    /**
     * Obtain address info from location.
     *
     * @param { ReverseGeoCodeRequest } request - Indicates the reverse geocode query parameters.
     * @param { AsyncCallback<Array<GeoAddress>> } callback - Indicates the callback for reporting the address info.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getAddressesFromLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301300 - Reverse geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Obtain address info from location.
     *
     * @param { ReverseGeoCodeRequest } request - Indicates the reverse geocode query parameters.
     * @param { AsyncCallback<Array<GeoAddress>> } callback - Indicates the callback for reporting the address info.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getAddressesFromLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301300 - Reverse geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    function getAddressesFromLocation(request: ReverseGeoCodeRequest, callback: AsyncCallback<Array<GeoAddress>>): void;
    /**
     * Obtain address info from location.
     *
     * @param { ReverseGeoCodeRequest } request - Indicates the reverse geocode query parameters.
     * @returns { Promise<Array<GeoAddress>> } The promise returned by the function.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getAddressesFromLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301300 - Reverse geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Obtain address info from location.
     *
     * @param { ReverseGeoCodeRequest } request - Indicates the reverse geocode query parameters.
     * @returns { Promise<Array<GeoAddress>> } The promise returned by the function.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getAddressesFromLocation} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301300 - Reverse geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    function getAddressesFromLocation(request: ReverseGeoCodeRequest): Promise<Array<GeoAddress>>;
    /**
     * Obtain latitude and longitude info from location address.
     *
     * @param { GeoCodeRequest } request - Indicates the geocode query parameters.
     * @param { AsyncCallback<Array<GeoAddress>> } callback - Indicates the callback for reporting the latitude and longitude result.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getAddressesFromLocationName} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301400 - Geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Obtain latitude and longitude info from location address.
     *
     * @param { GeoCodeRequest } request - Indicates the geocode query parameters.
     * @param { AsyncCallback<Array<GeoAddress>> } callback - Indicates the callback for reporting the
     *     latitude and longitude result.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are
     *     left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getAddressesFromLocationName} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301400 - Geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    function getAddressesFromLocationName(request: GeoCodeRequest, callback: AsyncCallback<Array<GeoAddress>>): void;
    /**
     * Obtain latitude and longitude info from location address.
     *
     * @param { GeoCodeRequest } request - Indicates the geocode query parameters.
     * @returns { Promise<Array<GeoAddress>> } The promise returned by the function.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getAddressesFromLocationName} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301400 - Geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Obtain latitude and longitude info from location address.
     *
     * @param { GeoCodeRequest } request - Indicates the geocode query parameters.
     * @returns { Promise<Array<GeoAddress>> } The promise returned by the function.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getAddressesFromLocationName} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301400 - Geocoding query failed.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    function getAddressesFromLocationName(request: GeoCodeRequest): Promise<Array<GeoAddress>>;
    /**
     * Obtain geocoding service status.
     *
     * @returns { boolean } Returns {@code true} if geocoding service is available, returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.isGeocoderAvailable} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Obtain geocoding service status.
     *
     * @returns { boolean } Returns {@code true} if geocoding service is available,
     *     returns {@code false} otherwise.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.isGeocoderAvailable} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    function isGeocoderAvailable(): boolean;
    /**
     * Obtain the number of cached GNSS locations reported at a time.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<number> } callback - Indicates the callback for reporting the cached GNSS locations size.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCachedGnssLocationsSize} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Obtain the number of cached GNSS locations reported at a time.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<number> } callback - Indicates the callback for reporting the cached GNSS locations size.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission
     *     required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
     *     2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCachedGnssLocationsSize} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function getCachedGnssLocationsSize(callback: AsyncCallback<number>): void;
    /**
     * Obtain the number of cached GNSS locations.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Promise<number> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCachedGnssLocationsSize} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Obtain the number of cached GNSS locations.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Promise<number> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCachedGnssLocationsSize} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function getCachedGnssLocationsSize(): Promise<number>;
    /**
     * All prepared GNSS locations are returned to the application through the callback function,
     * and the bottom-layer buffer is cleared.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<void> } callback - Indicates the callback for reporting the error message.
     * If the function fails to execute, the error message will be carried in the first parameter err of AsyncCallback,
     * If the function executes successfully, execute the callback function only, no data will be returned.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.flushCachedGnssLocations} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * All prepared GNSS locations are returned to the application through the callback function,
     * and the bottom-layer buffer is cleared.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @param { AsyncCallback<void> } callback - Indicates the callback for reporting the error message.
     *     If the function fails to execute, the error message will be carried in the first parameter
     *     err of AsyncCallback,
     *     If the function executes successfully, execute the callback function only, no data will be returned.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission
     *     required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
     *     2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.flushCachedGnssLocations} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function flushCachedGnssLocations(callback: AsyncCallback<void>): void;
    /**
     * All prepared GNSS locations are returned to the application,
     * and the bottom-layer buffer is cleared.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.flushCachedGnssLocations} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * All prepared GNSS locations are returned to the application,
     * and the bottom-layer buffer is cleared.
     *
     * @permission ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.flushCachedGnssLocations} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301200 - Failed to obtain the geographical location.
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    function flushCachedGnssLocations(): Promise<void>;
    /**
     * Send extended commands to location subsystem.
     *
     * @param { LocationCommand } command - Indicates the extended command message body.
     * @param { AsyncCallback<void> } callback - Indicates the callback for reporting the error message.
     * If the function fails to execute, the error message will be carried in the first parameter err of AsyncCallback,
     * If the function executes successfully, execute the callback function only, no data will be returned.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.sendCommand} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    function sendCommand(command: LocationCommand, callback: AsyncCallback<void>): void;
    /**
     * Send extended commands to location subsystem.
     *
     * @param { LocationCommand } command - Indicates the extended command message body.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.sendCommand} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    function sendCommand(command: LocationCommand): Promise<void>;
    /**
     * Obtain the current country code.
     *
     * @param { AsyncCallback<CountryCode> } callback - Indicates the callback for reporting the country code.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCountryCode} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain the current country code.
     *
     * @param { AsyncCallback<CountryCode> } callback - Indicates the callback for reporting the country code.
     * @throws { BusinessError } 401 - Parameter error. Possible causes:
     *     1. Mandatory parameters are left unspecified; 2. Incorrect parameter types;
     *     3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCountryCode} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function getCountryCode(callback: AsyncCallback<CountryCode>): void;
    /**
     * Obtain the current country code.
     *
     * @returns { Promise<CountryCode> } The promise returned by the function.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCountryCode} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Obtain the current country code.
     *
     * @returns { Promise<CountryCode> } The promise returned by the function.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getCountryCode} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301500 - Failed to query the area information.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    function getCountryCode(): Promise<CountryCode>;
    /**
     * Add a geofence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { GnssGeofenceRequest } fenceRequest - Indicates the Geofence configuration parameters.
     * @returns { Promise<number> } The promise returned by the function, for reporting the ID of geofence.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.addGnssGeofence} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301601 - The number of geofences exceeds the maximum.
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Add a geofence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { GnssGeofenceRequest } fenceRequest - Indicates the Geofence configuration parameters.
     * @returns { Promise<number> } The promise returned by the function, for reporting the ID of geofence.
     * @throws { BusinessError } 201 - Permission verification failed. The application
     *     does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory
     *     parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.addGnssGeofence} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301601 - The number of geofences exceeds the maximum.
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    function addGnssGeofence(fenceRequest: GnssGeofenceRequest): Promise<number>;
    /**
     * Remove a geofence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { number } geofenceId - Indicates the ID of geofence.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.removeGnssGeofence} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301602 - Failed to delete a geofence due to an incorrect ID.
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Remove a geofence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { number } geofenceId - Indicates the ID of geofence.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not
     *     have the permission required to call the API.
     * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters
     *     are left unspecified; 2. Incorrect parameter types; 3. Parameter verification failed.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.removeGnssGeofence} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301602 - Failed to delete a geofence due to an incorrect ID.
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    function removeGnssGeofence(geofenceId: number): Promise<void>;
    /**
     * Obtains the coordinate system types supported by geofence.
     *
     * @returns { Array<CoordinateSystemType> } Return the coordinate system types supported by geofence.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getGeofenceSupportedCoordTypes} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Obtains the coordinate system types supported by geofence.
     *
     * @returns { Array<CoordinateSystemType> } Return the coordinate system types supported by geofence.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     *     ${geoLocationManager.getGeofenceSupportedCoordTypes} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    function getGeofenceSupportedCoordTypes(): Array<CoordinateSystemType>;
    /**
     * Obtains the BSSID of the connected Wi-Fi hotspot.
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @returns {string} Returns the BSSID of the connected Wi-Fi hotspot.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getCurrentWifiBssidForLocating()} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301900 - Failed to obtain the BSSID of the Wi-Fi hotspot. The Wi-Fi network is not connected.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 14
     */
    function getCurrentWifiBssidForLocating(): string;
    /**
     * Obtains the distance between two locations.
     *
     * @param { Location } location1 - Indicates first location.
     * @param { Location } location2 - Indicates second location.
     * @returns { number } Returns the distance between two locations.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 20
     */
    /**
     * Obtains the distance between two locations.
     *
     * @param { Location } location1 - Indicates first location.
     * @param { Location } location2 - Indicates second location.
     * @returns { number } Returns the distance between two locations.
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    function getDistanceBetweenLocations(location1: Location, location2: Location): number;
    /**
     * Check whether the POI service is supported.
     *
     * @returns { boolean } Returns {@code true} if POI service is available, returns {@code false} otherwise.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 20
     */
    function isPoiServiceSupported(): boolean;
    /**
     * Obtaining POI Information.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @returns { Promise<PoiInfo> } The promise returned by the function, for reporting POI info.
     *
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.getPoiInfo} due to limited device capabilities.
     * @throws { BusinessError } 3301000 - The location service is unavailable.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 20
     */
    function getPoiInfo(): Promise<PoiInfo>;
    /**
     * Add a beacon fence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { BeaconFenceRequest } fenceRequest - Indicates the details of the beacon fence.
     * @returns { Promise<number> } The promise returned by the function, for reporting the ID of beacon fence.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the
     * permission required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.addBeaconFence}
     * due to limited device capabilities.
     * @throws { BusinessError } 3501100 - Failed to add a beacon fence because the location switch is off.
     * @throws { BusinessError } 3501101 - Failed to add a beacon fence because the bluetooth switch is off.
     * @throws { BusinessError } 3501601 - The number of beacon fence exceeds the maximum.
     * @throws { BusinessError } 3501603 - Duplicate beacon fence information.
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    function addBeaconFence(fenceRequest: BeaconFenceRequest): Promise<number>;
    /**
     * Remove a beacon fence.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { BeaconFence } [beaconFence] - Indicates the details of the beacon fence.
     * @returns { Promise<void> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission
     * required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call ${geoLocationManager.removeBeaconFence}
     * due to limited device capabilities.
     * @throws { BusinessError } 3501602 - Failed to delete the fence due to incorrect beacon fence information.
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    function removeBeaconFence(beaconFence?: BeaconFence): Promise<void>;
    /**
     * Check whether the BeaconFence service is supported.
     *
     * @returns { boolean } Returns {@code true} if BeaconFence service is available, returns {@code false} otherwise.
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    function isBeaconFenceSupported(): boolean;
    /**
     * Check whether the WLAN scan results match the WLAN BSSID list.
     *
     * @permission ohos.permission.LOCATION and ohos.permission.APPROXIMATELY_LOCATION
     * @param { Array<string> } wlanBssidArray - Indicates the list of WLAN BSSIDs that need to be matched.
     * @param { number } rssiThreshold - Indicates the WLAN RSSI threshold, only matching WLAN BSSID with
     * RSSI greater than this threshold.
     * @param { boolean } needStartScan - Indicates whether a WLAN scan needs to be initiated.
     * @returns { Promise<boolean> } The promise returned by the function.
     * @throws { BusinessError } 201 - Permission verification failed. The application does not have the permission
     * required to call the API.
     * @throws { BusinessError } 801 - Capability not supported. Failed to call
     * ${geoLocationManager.isWlanBssidMatched} due to limited device capabilities.
     * @throws { BusinessError } 3301100 - The location switch is off.
     * @throws { BusinessError } 3301800 - Failed to start WiFi scanning.
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 21
     */
    function isWlanBssidMatched(wlanBssidArray: Array<string>, rssiThreshold: number, needStartScan: boolean): Promise<boolean>;
    /**
     * Satellite status information.
     *
     * @typedef SatelliteStatusInfo
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Satellite status information.
     *
     * @typedef SatelliteStatusInfo
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    export interface SatelliteStatusInfo {
        /**
         * Number of satellites.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Number of satellites.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        satellitesNumber: number;
        /**
         * Satellite ID array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Satellite ID array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        satelliteIds: Array<number>;
        /**
         * Carrier to noise density array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Carrier to noise density array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        carrierToNoiseDensitys: Array<number>;
        /**
         * Satellite altitude array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Satellite altitude array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        altitudes: Array<number>;
        /**
         * Satellite azimuth array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Satellite azimuth array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        azimuths: Array<number>;
        /**
         * Satellite carrier frequency array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Satellite carrier frequency array.
         *
         * @type { Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        carrierFrequencies: Array<number>;
        /**
         * Satellite constellation type array.
         *
         * @type { ?Array<SatelliteConstellationCategory> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Satellite constellation type array.
         *
         * @type { ?Array<SatelliteConstellationCategory> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        satelliteConstellation?: Array<SatelliteConstellationCategory>;
        /**
         * Satellite additional information array.
         *
         * @type { ?Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Satellite additional information array.
         *
         * @type { ?Array<number> }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        satelliteAdditionalInfo?: Array<number>;
    }
    /**
     * Parameters for requesting to report cache location information.
     *
     * @typedef CachedGnssLocationsRequest
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 9
     */
    /**
     * Parameters for requesting to report cache location information.
     *
     * @typedef CachedGnssLocationsRequest
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    export interface CachedGnssLocationsRequest {
        /**
         * GNSS cache location report period.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * GNSS cache location report period.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        reportingPeriodSec: number;
        /**
         * Indicates whether to wake up the listener when the GNSS cache location queue is full.
         *
         * @type { boolean }
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 9
         */
        /**
         * Indicates whether to wake up the listener when the GNSS cache location queue is full.
         *
         * @type { boolean }
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        wakeUpCacheQueueFull: boolean;
    }
    /**
     * Configuring parameters in GNSS geofence requests.
     *
     * @typedef GnssGeofenceRequest
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Configuring parameters in GNSS geofence requests.
     *
     * @typedef GnssGeofenceRequest
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    export interface GnssGeofenceRequest {
        /**
         * Circular fence information.
         *
         * @type { Geofence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Circular fence information.
         *
         * @type { Geofence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        geofence: Geofence;
        /**
         * Indicates geofence transition status monitored.
         *
         * @type { Array<GeofenceTransitionEvent> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Indicates geofence transition status monitored.
         *
         * @type { Array<GeofenceTransitionEvent> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        monitorTransitionEvents: Array<GeofenceTransitionEvent>;
        /**
         * Indicates the geofence notifications to publish.
         *
         * @type { ?Array<NotificationRequest> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Indicates the geofence notifications to publish.
         *
         * @type { ?Array<NotificationRequest> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        notifications?: Array<NotificationRequest>;
        /**
         * Indicates the callback for reporting the geofence transition status.
         *
         * @type { AsyncCallback<GeofenceTransition> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Indicates the callback for reporting the geofence transition status.
         *
         * @type { AsyncCallback<GeofenceTransition> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        geofenceTransitionCallback: AsyncCallback<GeofenceTransition>;
    }
    /**
     * Configuring parameters in geofence requests.
     *
     * @typedef GeofenceRequest
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 9
     */
    export interface GeofenceRequest {
        /**
         * Indicate the user scenario.
         *
         * @type { LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        scenario: LocationRequestScenario;
        /**
         * Circular fence information.
         *
         * @type { Geofence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        geofence: Geofence;
    }
    /**
     * Circular fence information.
     *
     * @typedef Geofence
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 9
     */
    /**
     * Circular fence information.
     *
     * @typedef Geofence
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    export interface Geofence {
        /**
         * Latitude of the center point of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        /**
         * Latitude of the center point of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        latitude: number;
        /**
         * Longitude of the center point of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        /**
         * Longitude of the center point of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        longitude: number;
        /**
         * Coordinate system type.
         *
         * @type { ?CoordinateSystemType }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Coordinate system type.
         *
         * @type { ?CoordinateSystemType }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        coordinateSystemType?: CoordinateSystemType;
        /**
         * Radius of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        /**
         * Radius of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        radius: number;
        /**
         * Expiration of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 9
         */
        /**
         * Expiration of the circular fence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        expiration: number;
    }
    /**
     * Configuring parameters in reverse geocode requests.
     *
     * @typedef ReverseGeoCodeRequest
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Configuring parameters in reverse geocode requests.
     *
     * @typedef ReverseGeoCodeRequest
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    export interface ReverseGeoCodeRequest {
        /**
         * Indicates the language area information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the language area information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        locale?: string;
        /**
         * Indicates the country information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 12
         */
        /**
         * Indicates the country information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        country?: string;
        /**
         * Latitude for reverse geocoding query.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Latitude for reverse geocoding query.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        latitude: number;
        /**
         * Longitude for reverse geocoding query.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Longitude for reverse geocoding query.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        longitude: number;
        /**
         * Indicates the maximum number of addresses returned by reverse geocoding query.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the maximum number of addresses returned by reverse geocoding query.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        maxItems?: number;
    }
    /**
     * Configuring parameters in geocode requests.
     *
     * @typedef GeoCodeRequest
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Configuring parameters in geocode requests.
     *
     * @typedef GeoCodeRequest
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    export interface GeoCodeRequest {
        /**
         * Indicates the language area information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the language area information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        locale?: string;
        /**
         * Indicates the country information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 12
         */
        /**
         * Indicates the country information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        country?: string;
        /**
         * Address information.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Address information.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        description: string;
        /**
         * Indicates the maximum number of geocode query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the maximum number of geocode query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        maxItems?: number;
        /**
         * Indicates the minimum latitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the minimum latitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        minLatitude?: number;
        /**
         * Indicates the minimum longitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the minimum longitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        minLongitude?: number;
        /**
         * Indicates the maximum latitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the maximum latitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        maxLatitude?: number;
        /**
         * Indicates the maximum longitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the maximum longitude for geocoding query results.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        maxLongitude?: number;
    }
    /**
     * Data struct describes geographic locations.
     *
     * @typedef GeoAddress
     * @syscap SystemCapability.Location.Location.Geocoder
     * @since 9
     */
    /**
     * Data struct describes geographic locations.
     *
     * @typedef GeoAddress
     * @syscap SystemCapability.Location.Location.Geocoder
     * @crossplatform
     * @since 22
     */
    export interface GeoAddress {
        /**
         * Indicates latitude information.
         * A positive value indicates north latitude,
         * and a negative value indicates south latitude.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates latitude information.
         * A positive value indicates north latitude,
         * and a negative value indicates south latitude.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        latitude?: number;
        /**
         * Indicates longitude information.
         * A positive value indicates east longitude ,
         * and a negative value indicates west longitude.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates longitude information.
         * A positive value indicates east longitude ,
         * and a negative value indicates west longitude.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        longitude?: number;
        /**
         * Indicates language used for the location description.
         * zh indicates Chinese, and en indicates English.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates language used for the location description.
         * zh indicates Chinese, and en indicates English.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        locale?: string;
        /**
         * Indicates detailed address information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates detailed address information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        placeName?: string;
        /**
         * Indicates country code.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates country code.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        countryCode?: string;
        /**
         * Indicates country name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates country name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        countryName?: string;
        /**
         * Indicates administrative region name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates administrative region name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        administrativeArea?: string;
        /**
         * Indicates sub-administrative region name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates sub-administrative region name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        subAdministrativeArea?: string;
        /**
         * Indicates locality information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates locality information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        locality?: string;
        /**
         * Indicates sub-locality information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates sub-locality information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        subLocality?: string;
        /**
         * Indicates road name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates road name.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        roadName?: string;
        /**
         * Indicates auxiliary road information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates auxiliary road information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        subRoadName?: string;
        /**
         * Indicates house information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates house information.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        premises?: string;
        /**
         * Indicates postal code.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates postal code.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        postalCode?: string;
        /**
         * Indicates phone number.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates phone number.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        phoneNumber?: string;
        /**
         * Indicates website URL.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates website URL.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        addressUrl?: string;
        /**
         * Indicates additional information.
         *
         * @type { ?Array<string> }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates additional information.
         *
         * @type { ?Array<string> }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        descriptions?: Array<string>;
        /**
         * Indicates the amount of additional descriptive information.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @since 9
         */
        /**
         * Indicates the amount of additional descriptive information.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Geocoder
         * @crossplatform
         * @since 22
         */
        descriptionsSize?: number;
    }
    /**
     * Configuring parameters in location requests.
     *
     * @typedef LocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Configuring parameters in location requests.
     *
     * @typedef LocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Configuring parameters in location requests.
     *
     * @typedef LocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export interface LocationRequest {
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        priority?: LocationRequestPriority;
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        scenario?: LocationRequestScenario;
        /**
         * Location report interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Location report interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Location report interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        timeInterval?: number;
        /**
         * Location report distance interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Location report distance interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Location report distance interval.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        distanceInterval?: number;
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        maxAccuracy?: number;
    }
    /**
     * Configuring parameters in current location requests.
     *
     * @typedef CurrentLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Configuring parameters in current location requests.
     *
     * @typedef CurrentLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Configuring parameters in current location requests.
     *
     * @typedef CurrentLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export interface CurrentLocationRequest {
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Priority of the location request.
         *
         * @type { ?LocationRequestPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        priority?: LocationRequestPriority;
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * User scenario of the location request.
         *
         * @type { ?LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        scenario?: LocationRequestScenario;
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Accuracy requirements for reporting locations.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        maxAccuracy?: number;
        /**
         * Timeout interval of a single location request.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Timeout interval of a single location request.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Timeout interval of a single location request.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        timeoutMs?: number;
    }
    /**
     * Geofence transition status.
     *
     * @typedef GeofenceTransition
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Geofence transition status.
     *
     * @typedef GeofenceTransition
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    export interface GeofenceTransition {
        /**
         * ID of the geofence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * ID of the geofence.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        geofenceId: number;
        /**
         * Indicates the geofence transition status.
         *
         * @type { GeofenceTransitionEvent }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * Indicates the geofence transition status.
         *
         * @type { GeofenceTransitionEvent }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        transitionEvent: GeofenceTransitionEvent;
        /**
         * Indicate the beaconFence which transitionEvent occurs.
         *
         * @type { ?BeaconFence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 20
         */
        /**
         * Indicate the beaconFence which transitionEvent occurs.
         *
         * @type { ?BeaconFence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        beaconFence?: BeaconFence;
    }
    /**
     * Configuring parameters in continuous location requests.
     *
     * @typedef ContinuousLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Configuring parameters in continuous location requests.
     *
     * @typedef ContinuousLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export interface ContinuousLocationRequest {
        /**
         * Location report interval, in seconds.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Location report interval, in seconds.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        interval: number;
        /**
         * Location scenario. You can select a user activity scenario or power consumption scenario.
         *
         * @type { UserActivityScenario | PowerConsumptionScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Location scenario. You can select a user activity scenario or power consumption scenario.
         *
         * @type { UserActivityScenario | PowerConsumptionScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        locationScenario: UserActivityScenario | PowerConsumptionScenario;
        /**
         * Indicates whether to obtain POI information near the current location.
         *
         * @type { ?boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        /**
         * Indicates whether to obtain POI information near the current location.
         *
         * @type { ?boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        needPoi?: boolean;
    }
    /**
     * Configuring parameters in single location requests.
     *
     * @typedef SingleLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Configuring parameters in single location requests.
     *
     * @typedef SingleLocationRequest
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export interface SingleLocationRequest {
        /**
         * Priority of the location request.
         *
         * @type { LocatingPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Priority of the location request.
         *
         * @type { LocatingPriority }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        locatingPriority: LocatingPriority;
        /**
         * Timeout of a single location request, in milliseconds.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Timeout of a single location request, in milliseconds.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        locatingTimeoutMs: number;
        /**
         * Indicates whether to obtain POI information near the current location.
         *
         * @type { ?boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        /**
         * Indicates whether to obtain POI information near the current location.
         *
         * @type { ?boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        needPoi?: boolean;
    }
    /**
     * Provides information about geographic locations.
     *
     * @typedef Location
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Provides information about geographic locations.
     *
     * @typedef Location
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Provides information about geographic locations.
     *
     * @typedef Location
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export interface Location {
        /**
         * Indicates latitude information.
         * A positive value indicates north latitude,
         * and a negative value indicates south latitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates latitude information.
         * A positive value indicates north latitude,
         * and a negative value indicates south latitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates latitude information.
         * A positive value indicates north latitude,
         * and a negative value indicates south latitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        latitude: number;
        /**
         * Indicates Longitude information.
         * A positive value indicates east longitude ,
         * and a negative value indicates west longitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates Longitude information.
         * A positive value indicates east longitude ,
         * and a negative value indicates west longitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates Longitude information.
         * A positive value indicates east longitude ,
         * and a negative value indicates west longitude.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        longitude: number;
        /**
         * Indicates location altitude, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates location altitude, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates location altitude, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        altitude: number;
        /**
         * Indicates location accuracy, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates location accuracy, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates location accuracy, in meters.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        accuracy: number;
        /**
         * Indicates speed, in m/s.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates speed, in m/s.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates speed, in m/s.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        speed: number;
        /**
         * Indicates location timestamp in the UTC format.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates location timestamp in the UTC format.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates location timestamp in the UTC format.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        timeStamp: number;
        /**
         * Indicates direction information.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates direction information.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates direction information.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        direction: number;
        /**
         * Indicates location timestamp since boot.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates location timestamp since boot.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates location timestamp since boot.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        timeSinceBoot: number;
        /**
         * Indicates additional information.
         *
         * @type { ?Array<string> }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates additional information.
         *
         * @type { ?Array<string> }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates additional information.
         *
         * @type { ?Array<string> }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        additions?: Array<string>;
        /**
         * Indicates additional information map.
         *
         * @type { ?Map<string, string> }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Indicates additional information map.
         *
         * @type { ?Map<string, string> }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        additionsMap?: Map<string, string>;
        /**
         * Indicates the amount of additional descriptive information.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Indicates the amount of additional descriptive information.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Indicates the amount of additional descriptive information.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        additionSize?: number;
        /**
         * Indicates vertical position accuracy in meters.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Indicates vertical position accuracy in meters.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        altitudeAccuracy?: number;
        /**
         * Indicates speed accuracy in meter per seconds.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Indicates speed accuracy in meter per seconds.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        speedAccuracy?: number;
        /**
         * Indicates direction accuracy in degrees.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Indicates direction accuracy in degrees.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        directionAccuracy?: number;
        /**
         * Time uncertainty Of timeSinceBoot in nanosecond.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Time uncertainty Of timeSinceBoot in nanosecond.
         *
         * @type { ?number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        uncertaintyOfTimeSinceBoot?: number;
        /**
         * Indicates the source of the location.
         *
         * @type { ?LocationSourceType }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Indicates the source of the location.
         *
         * @type { ?LocationSourceType }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        sourceType?: LocationSourceType;
        /**
         * Indicates the poi information.
         *
         * @type { ?PoiInfo }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        /**
         * Indicates the poi information.
         *
         * @type { ?PoiInfo }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        poi?: PoiInfo;
    }
    /**
     * Describes the contents of the bluetooth scan results.
     *
     * @typedef BluetoothScanResult
     * @syscap SystemCapability.Location.Location.Core
     * @since 16
     */
    /**
     * Describes the contents of the bluetooth scan results.
     *
     * @typedef BluetoothScanResult
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    export interface BluetoothScanResult {
        /**
         * Address of the scanned device
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @since 16
         */
        /**
         * Address of the scanned device
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        deviceId: string;
        /**
         * RSSI of the scanned device
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @since 16
         */
        /**
         * RSSI of the scanned device
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        rssi: number;
        /**
         * The raw data of broadcast packet
         *
         * @type { ?ArrayBuffer }
         * @syscap SystemCapability.Location.Location.Core
         * @since 16
         */
        /**
         * The raw data of broadcast packet
         *
         * @type { ?ArrayBuffer }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        data?: ArrayBuffer;
        /**
         * The local name of the scanned device
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @since 16
         */
        /**
         * The local name of the scanned device
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        deviceName: string;
        /**
         * Connectable of the scanned device
         *
         * @type { boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @since 16
         */
        /**
         * Connectable of the scanned device
         *
         * @type { boolean }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        connectable: boolean;
    }
    /**
     * Describes the information about a single POI.
     *
     * @typedef Poi
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 19
     */
    export interface Poi {
        /**
         * Indicates the ID of a POI.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        id: string;
        /**
         * Indicates the confidence of POI information.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        confidence: number;
        /**
         * Indicates the name of the POI.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        name: string;
        /**
         * Indicates the latitude of POI.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        latitude: number;
        /**
         * Indicates the longitude of POI.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        longitude: number;
        /**
         * Indicates administrative region name.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        administrativeArea: string;
        /**
         * Indicates sub-administrative region name.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        subAdministrativeArea: string;
        /**
         * Indicates locality information.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        locality: string;
        /**
         * Indicates sub-locality information.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        subLocality: string;
        /**
         * Indicates the detailed address of the POI.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        address: string;
    }
    /**
     * Describes the POI information struct.
     *
     * @typedef PoiInfo
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 19
     */
    export interface PoiInfo {
        /**
         * Indicates POI information list.
         *
         * @type { Array<Poi> }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        poiArray: Array<Poi>;
        /**
         * Indicates the timestamp when the POI information is obtained.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 19
         */
        timestamp: number;
    }
    /**
     * Beacon equipment manufacturer data.
     *
     * @typedef BeaconManufactureData
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    export interface BeaconManufactureData {
        /**
         * Manufacture id.
         *
         * @type { number }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        manufactureId: number;
        /**
         * Manufacture data.
         *
         * @type { ArrayBuffer }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        manufactureData: ArrayBuffer;
        /**
         * Manufacture data mask.
         *
         * @type { ArrayBuffer }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        manufactureDataMask: ArrayBuffer;
    }
    /**
     * Beacon fence details.
     *
     * @typedef BeaconFence
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    export interface BeaconFence {
        /**
         * Identifier of the beacon fence.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        identifier: string;
        /**
         * Beacon fence information type.
         *
         * @type { BeaconFenceInfoType }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        beaconFenceInfoType: BeaconFenceInfoType;
        /**
         * Beacon equipment manufacture data.
         *
         * @type { ?BeaconManufactureData }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        manufactureData?: BeaconManufactureData;
    }
    /**
     * Configuring parameters in BeaconFence request.
     *
     * @typedef BeaconFenceRequest
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    export interface BeaconFenceRequest {
        /**
         * Beacon fence information.
         *
         * @type { BeaconFence }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        beacon: BeaconFence;
        /**
         * Indicates the callback for reporting the BeaconFence transition status.
         *
         * @type { ?Callback<GeofenceTransition> }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        transitionCallback?: Callback<GeofenceTransition>;
        /**
         * Indicates the name of FenceExtensionAbility.
         *
         * @type { ?string }
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        fenceExtensionAbilityName?: string;
    }
    /**
     * Enum for the source of the location.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Enum for the source of the location.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum LocationSourceType {
        /**
         * The location is obtained from the GNSS.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * The location is obtained from the GNSS.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        GNSS = 1,
        /**
         * The location comes from the network positioning technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * The location comes from the network positioning technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        NETWORK = 2,
        /**
         * The location comes from the indoor positioning technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * The location comes from the indoor positioning technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        INDOOR = 3,
        /**
         * The location comes from the GNSS RTK technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * The location comes from the GNSS RTK technology.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        RTK = 4
    }
    /**
     * Enum for coordinate system type.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Enum for coordinate system type.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    export enum CoordinateSystemType {
        /**
         * WGS84 coordinates system.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * WGS84 coordinates system.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        WGS84 = 1,
        /**
         * GCJ-02 coordinates system.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * GCJ-02 coordinates system.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        GCJ02 = 2
    }
    /**
     * Enum for location error code.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Enum for location error code.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum LocationError {
        /**
         * Default cause for location failure.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Default cause for location failure.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOCATING_FAILED_DEFAULT = -1,
        /**
         * Locating failed because the location permission fails to be verified.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Locating failed because the location permission fails to be verified.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOCATING_FAILED_LOCATION_PERMISSION_DENIED = -2,
        /**
         * Locating failed because the app is in the background and the background location permission verification failed.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Locating failed because the app is in the background and the background location permission verification failed.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOCATING_FAILED_BACKGROUND_PERMISSION_DENIED = -3,
        /**
         * Locating failed because the location switch is turned off.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Locating failed because the location switch is turned off.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOCATING_FAILED_LOCATION_SWITCH_OFF = -4,
        /**
         * Locating failed because internet access failure.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Locating failed because internet access failure.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOCATING_FAILED_INTERNET_ACCESS_FAILURE = -5
    }
    /**
     * Enum for geofence transition status.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Geofence
     * @since 12
     */
    /**
     * Enum for geofence transition status.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Geofence
     * @crossplatform
     * @since 22
     */
    export enum GeofenceTransitionEvent {
        /**
         * The device is within the geofence.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * The device is within the geofence.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        GEOFENCE_TRANSITION_EVENT_ENTER = 1,
        /**
         * The device is out of the geofence.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * The device is out of the geofence.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        GEOFENCE_TRANSITION_EVENT_EXIT = 2,
        /**
         * The device is in the geographical fence for a period of time.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @since 12
         */
        /**
         * The device is in the geographical fence for a period of time.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @crossplatform
         * @since 22
         */
        GEOFENCE_TRANSITION_EVENT_DWELL = 4
    }
    /**
     * Enum for satellite constellation category.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 12
     */
    /**
     * Enum for satellite constellation category.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    export enum SatelliteConstellationCategory {
        /**
         * Invalid value.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Invalid value.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_UNKNOWN = 0,
        /**
         * GPS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * GPS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_GPS = 1,
        /**
         * SBAS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * SBAS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_SBAS = 2,
        /**
         * GLONASS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * GLONASS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_GLONASS = 3,
        /**
         * QZSS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * QZSS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_QZSS = 4,
        /**
         * BEIDOU.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * BEIDOU.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_BEIDOU = 5,
        /**
         * GALILEO.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * GALILEO.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_GALILEO = 6,
        /**
         * IRNSS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * IRNSS.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        CONSTELLATION_CATEGORY_IRNSS = 7
    }
    /**
     * Enum for satellite additional information.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Gnss
     * @since 12
     */
    /**
     * Enum for satellite additional information.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Gnss
     * @crossplatform
     * @since 22
     */
    export enum SatelliteAdditionalInfo {
        /**
         * Default value.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Default value.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        SATELLITES_ADDITIONAL_INFO_NULL = 0,
        /**
         * Ephemeris data exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Ephemeris data exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        SATELLITES_ADDITIONAL_INFO_EPHEMERIS_DATA_EXIST = 1,
        /**
         * Almanac data exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Almanac data exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        SATELLITES_ADDITIONAL_INFO_ALMANAC_DATA_EXIST = 2,
        /**
         * This satellite is being used in location fix.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * This satellite is being used in location fix.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        SATELLITES_ADDITIONAL_INFO_USED_IN_FIX = 4,
        /**
         * Carrier frequency exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @since 12
         */
        /**
         * Carrier frequency exist.
         *
         * @syscap SystemCapability.Location.Location.Gnss
         * @crossplatform
         * @since 22
         */
        SATELLITES_ADDITIONAL_INFO_CARRIER_FREQUENCY_EXIST = 8
    }
    /**
     * Enum for user activity scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Enum for user activity scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum UserActivityScenario {
        /**
         * Navigation scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Navigation scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        NAVIGATION = 0x401,
        /**
         * Sport scenario. High positioning precision is required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Sport scenario. High positioning precision is required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        SPORT = 0x402,
        /**
         * Transport scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Transport scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        TRANSPORT = 0x403,
        /**
         * Daily life scenarios. Low requirements on positioning precision.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Daily life scenarios. Low requirements on positioning precision.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        DAILY_LIFE_SERVICE = 0x404
    }
    /**
     * Enum for locating priority.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Enum for locating priority.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum LocatingPriority {
        /**
         * Preferentially ensure the highest locating accuracy.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Preferentially ensure the highest locating accuracy.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        PRIORITY_ACCURACY = 0x501,
        /**
         * Preferentially ensure the fastest locating speed.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Preferentially ensure the fastest locating speed.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        PRIORITY_LOCATING_SPEED = 0x502
    }
    /**
     * Enum for location priority.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Enum for location priority.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Enum for location priority.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum LocationRequestPriority {
        /**
         * Default priority.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Default priority.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Default priority.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        UNSET = 0x200,
        /**
         * Preferentially ensure the locating accuracy.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Preferentially ensure the locating accuracy.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Preferentially ensure the locating accuracy.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        ACCURACY,
        /**
         * Preferentially ensure low power consumption for locating.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Preferentially ensure low power consumption for locating.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Preferentially ensure low power consumption for locating.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOW_POWER,
        /**
         * Preferentially ensure that the first location is time-consuming.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Preferentially ensure that the first location is time-consuming.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Preferentially ensure that the first location is time-consuming.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        FIRST_FIX
    }
    /**
     * Enum for location scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Enum for location scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 11
     */
    /**
     * Enum for location scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum LocationRequestScenario {
        /**
         * Default scenario.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Default scenario.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Default scenario.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        UNSET = 0x300,
        /**
         * Navigation scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Navigation scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Navigation scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        NAVIGATION,
        /**
         * Trajectory tracking scenario. High positioning precision is required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Trajectory tracking scenario. High positioning precision is required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Trajectory tracking scenario. High positioning precision is required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        TRAJECTORY_TRACKING,
        /**
         * Car hailing scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Car hailing scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Car hailing scenario. High positioning precision and real-time performance are required.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        CAR_HAILING,
        /**
         * Daily life scenarios. Low requirements on positioning precision and real-time performance.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Daily life scenarios. Low requirements on positioning precision and real-time performance.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Daily life scenarios. Low requirements on positioning precision and real-time performance.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        DAILY_LIFE_SERVICE,
        /**
         * Power saving scenarios.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Power saving scenarios.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 11
         */
        /**
         * Power saving scenarios.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        NO_POWER
    }
    /**
     * Enum for power consumption scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 12
     */
    /**
     * Enum for power consumption scenario.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum PowerConsumptionScenario {
        /**
         * High power consumption mode.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * High power consumption mode.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        HIGH_POWER_CONSUMPTION = 0x601,
        /**
         * Low power consumption mode.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Low power consumption mode.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        LOW_POWER_CONSUMPTION = 0x602,
        /**
         * Power saving scenarios.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 12
         */
        /**
         * Power saving scenarios.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        NO_POWER_CONSUMPTION = 0x603
    }
    /**
     * Enum for sports type
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @atomicservice
     * @since 18
     */
    /**
     * Enum for sports type
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @atomicservice
     * @since 22
     */
    export enum SportsType {
        /**
         * Indicates running.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 18
         */
        /**
         * Indicates running.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        RUNNING = 1,
        /**
         * Indicates walking.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 18
         */
        /**
         * Indicates walking.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        WALKING,
        /**
         * Indicates cycling.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @atomicservice
         * @since 18
         */
        /**
         * Indicates cycling.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @atomicservice
         * @since 22
         */
        CYCLING
    }
    /**
     * Location subsystem command structure.
     *
     * @typedef LocationCommand
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    export interface LocationCommand {
        /**
         * Information about the scenario where the command is sent.
         *
         * @type { LocationRequestScenario }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        scenario: LocationRequestScenario;
        /**
         * Sent command content.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        command: string;
    }
    /**
     * Country code structure.
     *
     * @typedef CountryCode
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Country code structure.
     *
     * @typedef CountryCode
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    export interface CountryCode {
        /**
         * Country code character string.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Country code character string.
         *
         * @type { string }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        country: string;
        /**
         * Country code source.
         *
         * @type { CountryCodeType }
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Country code source.
         *
         * @type { CountryCodeType }
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        type: CountryCodeType;
    }
    /**
     * Enum for country code type.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @since 9
     */
    /**
     * Enum for country code type.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Core
     * @crossplatform
     * @since 22
     */
    export enum CountryCodeType {
        /**
         * Country code obtained from the locale setting.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Country code obtained from the locale setting.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        COUNTRY_CODE_FROM_LOCALE = 1,
        /**
         * Country code obtained from the SIM information.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Country code obtained from the SIM information.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        COUNTRY_CODE_FROM_SIM,
        /**
         * Query the country code information from the reverse geocoding result.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Query the country code information from the reverse geocoding result.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        COUNTRY_CODE_FROM_LOCATION,
        /**
         * Obtain the country code from the cell registration information.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @since 9
         */
        /**
         * Obtain the country code from the cell registration information.
         *
         * @syscap SystemCapability.Location.Location.Core
         * @crossplatform
         * @since 22
         */
        COUNTRY_CODE_FROM_NETWORK
    }
    /**
     * Enum for the beacon fence information type.
     *
     * @enum { number }
     * @syscap SystemCapability.Location.Location.Geofence
     * @atomicservice
     * @since 20
     */
    export enum BeaconFenceInfoType {
        /**
         * Identifies a beacon device using beacon device manufacture data.
         *
         * @syscap SystemCapability.Location.Location.Geofence
         * @atomicservice
         * @since 20
         */
        BEACON_MANUFACTURE_DATA = 1
    }
}
export default geoLocationManager;
