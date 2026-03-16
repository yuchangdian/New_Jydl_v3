warning: in the working copy of 'build-profile.json5', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'entry/src/main/cpp/CMakeLists.txt', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'entry/src/main/cpp/napi_init.cpp', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'entry/src/main/cpp/types/libentry/Index.d.ts', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'entry/src/main/ets/entryability/EntryAbility.ets', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/build-profile.json5 b/build-profile.json5[m
[1mindex 9240082..24eda1d 100644[m
[1m--- a/build-profile.json5[m
[1m+++ b/build-profile.json5[m
[36m@@ -13,13 +13,26 @@[m
           "storeFile": "C:\\Users\\Lenovo\\.ohos\\config\\default_New_Jydl_v3_KiKfqIjshuRUB-mF_6YhBHr-vpv-QibvUxuvbRh1wmA=.p12",[m
           "storePassword": "0000001B2535F8BC49C554B5BB1FF3B16D8A031C8CE4EB13A17482E0CD7C7648D71170E202DE36B705B582"[m
         }[m
[32m+[m[32m      },[m
[32m+[m[32m      {[m
[32m+[m[32m        "name": "openharmony",[m
[32m+[m[32m        "type": "OpenHarmony",[m
[32m+[m[32m        "material": {[m
[32m+[m[32m          "certpath": "C:\\Users\\Lenovo\\.ohos\\config\\default_New_Jydl_v3_KiKfqIjshuRUB-mF_6YhBHr-vpv-QibvUxuvbRh1wmA=.cer",[m
[32m+[m[32m          "keyAlias": "debugKey",[m
[32m+[m[32m          "keyPassword": "0000001B187BE9D622231ACAE5D363E3C53D05A2330B0CEF26F1110FF320CB1B70E4B0B7D9C98043C9266C",[m
[32m+[m[32m          "profile": "C:\\Users\\Lenovo\\.ohos\\config\\default_New_Jydl_v3_KiKfqIjshuRUB-mF_6YhBHr-vpv-QibvUxuvbRh1wmA=.p7b",[m
[32m+[m[32m          "signAlg": "SHA256withECDSA",[m
[32m+[m[32m          "storeFile": "C:\\Users\\Lenovo\\.ohos\\config\\default_New_Jydl_v3_KiKfqIjshuRUB-mF_6YhBHr-vpv-QibvUxuvbRh1wmA=.p12",[m
[32m+[m[32m          "storePassword": "0000001B2535F8BC49C554B5BB1FF3B16D8A031C8CE4EB13A17482E0CD7C7648D71170E202DE36B705B582"[m
[32m+[m[32m        }[m
       }[m
     ],[m
     "products": [[m
       {[m
         "name": "default",[m
         "signingConfig": "default",[m
[31m-        "targetSdkVersion": "6.0.1(21)",[m
[32m+[m[32m        "compileSdkVersion": "6.0.2(22)",[m
         "compatibleSdkVersion": "5.1.0(18)",[m
         "runtimeOS": "HarmonyOS",[m
         "buildOption": {[m
[36m@@ -29,6 +42,20 @@[m
             "useNormalizedOHMUrl": true[m
           }[m
         }[m
[32m+[m[32m      },[m
[32m+[m[32m      {[m
[32m+[m[32m        "name": "openharmony",[m
[32m+[m[32m        "signingConfig": "openharmony",[m
[32m+[m[32m        "compileSdkVersion": "6.0.2(22)",[m
[32m+[m[32m        "targetSdkVersion": "5.1.0(18)",[m
[32m+[m[32m        "compatibleSdkVersion": "5.1.0(18)",[m
[32m+[m[32m        "runtimeOS": "OpenHarmony",[m
[32m+[m[32m        "buildOption": {[m
[32m+[m[32m          "strictMode": {[m
[32m+[m[32m            "caseSensitiveCheck": true,[m
[32m+[m[32m            "useNormalizedOHMUrl": true[m
[32m+[m[32m          }[m
[32m+[m[32m        }[m
       }[m
     ],[m
     "buildModeSet": [[m
[36m@@ -48,7 +75,8 @@[m
         {[m
           "name": "default",[m
           "applyToProducts": [[m
[31m-            "default"[m
[32m+[m[32m            "default",[m
[32m+[m[32m            "openharmony"[m
           ][m
         }[m
       ][m
[1mdiff --git a/entry/build-profile.json5 b/entry/build-profile.json5[m
[1mindex b18e9c1..62b5795 100644[m
[1m--- a/entry/build-profile.json5[m
[1m+++ b/entry/build-profile.json5[m
[36m@@ -17,6 +17,10 @@[m
       "path": "./src/main/cpp/CMakeLists.txt",[m
       "arguments": "",[m
       "cppFlags": "",[m
[32m+[m[32m      "abiFilters": [[m
[32m+[m[32m        "armeabi-v7a",[m
[32m+[m[32m        "arm64-v8a"[m
[32m+[m[32m      ][m
     }[m
   },[m
   "buildOptionSet": [[m
[1mdiff --git a/entry/src/main/cpp/CMakeLists.txt b/entry/src/main/cpp/CMakeLists.txt[m
[1mindex 7adbcf1..bffb0f9 100644[m
[1m--- a/entry/src/main/cpp/CMakeLists.txt[m
[1m+++ b/entry/src/main/cpp/CMakeLists.txt[m
[36m@@ -11,5 +11,5 @@[m [mendif()[m
 include_directories(${NATIVERENDER_ROOT_PATH}[m
                     ${NATIVERENDER_ROOT_PATH}/include)[m
 [m
[31m-add_library(entry SHARED napi_init.cpp tcp_client.c)[m
[32m+[m[32madd_library(entry SHARED napi_init.c tcp_client.c)[m
 target_link_libraries(entry PUBLIC libace_napi.z.so libhilog_ndk.z.so)[m
[1mdiff --git a/entry/src/main/cpp/napi_init.cpp b/entry/src/main/cpp/napi_init.cpp[m
[1mindex b67bf3c..e676bd8 100644[m
[1m--- a/entry/src/main/cpp/napi_init.cpp[m
[1m+++ b/entry/src/main/cpp/napi_init.cpp[m
[36m@@ -4,6 +4,33 @@[m
 #include <string>[m
 #include <vector>[m
 [m
[32m+[m
[32m+[m[32mstatic napi_value Add(napi_env env, napi_callback_info info)[m
[32m+[m[32m{[m
[32m+[m[32m    size_t argc = 2;[m
[32m+[m[32m    napi_value args[2] = {nullptr};[m
[32m+[m
[32m+[m[32m    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);[m
[32m+[m
[32m+[m[32m    napi_valuetype valuetype0;[m
[32m+[m[32m    napi_typeof(env, args[0], &valuetype0);[m
[32m+[m
[32m+[m[32m    napi_valuetype valuetype1;[m
[32m+[m[32m    napi_typeof(env, args[1], &valuetype1);[m
[32m+[m
[32m+[m[32m    double value0;[m
[32m+[m[32m    napi_get_value_double(env, args[0], &value0);[m
[32m+[m
[32m+[m[32m    double value1;[m
[32m+[m[32m    napi_get_value_double(env, args[1], &value1);[m
[32m+[m
[32m+[m[32m    napi_value sum;[m
[32m+[m[32m    napi_create_double(env, value0 + value1, &sum);[m
[32m+[m
[32m+[m[32m    return sum;[m
[32m+[m
[32m+[m[32m}[m
[32m+[m
 namespace {[m
 bool GetRequiredString(napi_env env, napi_value value, std::string &result)[m
 {[m
[36m@@ -89,7 +116,8 @@[m [mstatic napi_value Init(napi_env env, napi_value exports)[m
     napi_property_descriptor desc[] = {[m
         {"startTcpClient", nullptr, StartTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},[m
         {"stopTcpClient", nullptr, StopTcpClient, nullptr, nullptr, nullptr, napi_default, nullptr},[m
[31m-        {"isTcpClientRunning", nullptr, IsTcpClientRunning, nullptr, nullptr, nullptr, napi_default, nullptr}[m
[32m+[m[32m        {"isTcpClientRunning", nullptr, IsTcpClientRunning, nullptr, nullptr, nullptr, napi_default, nullptr},[m
[32m+[m[32m        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr }[m
     };[m
     napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);[m
     return exports;[m
[1mdiff --git a/entry/src/main/cpp/types/libentry/Index.d.ts b/entry/src/main/cpp/types/libentry/Index.d.ts[m
[1mindex 13ef590..153906f 100644[m
[1m--- a/entry/src/main/cpp/types/libentry/Index.d.ts[m
[1m+++ b/entry/src/main/cpp/types/libentry/Index.d.ts[m
[36m@@ -1,3 +1,4 @@[m
 export const startTcpClient: (host: string, port: number) => boolean;[m
 export const stopTcpClient: () => void;[m
 export const isTcpClientRunning: () => boolean;[m
[32m+[m[32mexport const add: (a: number, b: number) => number;[m
\ No newline at end of file[m
[1mdiff --git a/entry/src/main/ets/entryability/EntryAbility.ets b/entry/src/main/ets/entryability/EntryAbility.ets[m
[1mindex d3c4cc5..0cf459a 100644[m
[1m--- a/entry/src/main/ets/entryability/EntryAbility.ets[m
[1m+++ b/entry/src/main/ets/entryability/EntryAbility.ets[m
[36m@@ -2,6 +2,7 @@[m [mimport { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.Ab[m
 import { hilog } from '@kit.PerformanceAnalysisKit';[m
 import { window } from '@kit.ArkUI';[m
 import * as tcpClientModule from 'libentry.so';[m
[32m+[m[32mimport testNapi from 'libentry.so';[m
 [m
 const DOMAIN = 0x0000;[m
 const ENTRY_TAG = 'JY_ENTRY';[m
[36m@@ -139,8 +140,10 @@[m [mexport default class EntryAbility extends UIAbility {[m
   }[m
 [m
   onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {[m
[32m+[m[32m    hilog.info(DOMAIN, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));[m
     try {[m
       this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);[m
[32m+[m[32m      //hilog.info(DOMAIN, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));[m
     } catch (err) {[m
       hilog.error(DOMAIN, ENTRY_TAG, '设置颜色模式失败: %{public}s', JSON.stringify(err));[m
     }[m
[1mdiff --git a/entry/src/main/ets/pages/Index.ets b/entry/src/main/ets/pages/Index.ets[m
[1mindex 411cdca..16a3bcd 100644[m
[1m--- a/entry/src/main/ets/pages/Index.ets[m
[1m+++ b/entry/src/main/ets/pages/Index.ets[m
[36m@@ -1,4 +1,5 @@[m
 import { TopMenu } from '../components/TopMenu'[m
[32m+[m[32mimport testNapi from 'libentry.so';[m
 [m
 interface PlateItem {[m
   name: string;[m
[36m@@ -69,6 +70,10 @@[m [mstruct Index {[m
   ];[m
 [m
   build() {[m
[32m+[m
[32m+[m
[32m+[m
[32m+[m
     Column() {[m
       TopMenu()[m
         .zIndex(9999)[m
[1mdiff --git a/entry/src/main/module.json5 b/entry/src/main/module.json5[m
[1mindex a2feb1a..844b4cb 100644[m
[1m--- a/entry/src/main/module.json5[m
[1m+++ b/entry/src/main/module.json5[m
[36m@@ -5,7 +5,7 @@[m
     "description": "$string:module_desc",[m
     "mainElement": "EntryAbility",[m
     "deviceTypes": [[m
[31m-      "phone"[m
[32m+[m[32m      "default"[m
     ],[m
     "deliveryWithInstall": true,[m
     "installationFree": false,[m
[36m@@ -48,7 +48,7 @@[m
             "name": "ohos.extension.backup",[m
             "resource": "$profile:backup_config"[m
           }[m
[31m-        ],[m
[32m+[m[32m        ][m
       }[m
     ][m
   }[m
[1mdiff --git a/entry/src/ohosTest/module.json5 b/entry/src/ohosTest/module.json5[m
[1mindex 509a3a2..8a49e99 100644[m
[1m--- a/entry/src/ohosTest/module.json5[m
[1m+++ b/entry/src/ohosTest/module.json5[m
[36m@@ -3,7 +3,7 @@[m
     "name": "entry_test",[m
     "type": "feature",[m
     "deviceTypes": [[m
[31m-      "phone"[m
[32m+[m[32m      "default"[m
     ],[m
     "deliveryWithInstall": true,[m
     "installationFree": false[m
