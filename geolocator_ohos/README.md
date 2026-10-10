<p align="center">
  <h1 align="center"> <code>flutter_geolocator_ohos</code> </h1>
</p>




This project is based on [geolocator@14.0.2](https://pub.dev/packages/geolocator).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  fluttertpc_geolocator:
    git:
      url: https://gitcode.com/CPF-Flutter/fluttertpc_geolocator.git
      path: "geolocator"
      ref: br_v14.0.2_ohos
  flutter_geolocator_ohos:
    git:
      url: "https://gitcode.com/CPF-Flutter/fluttertpc_geolocator.git"
      path: "geolocator_ohos"
      ref: br_v14.0.2_ohos
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [geolocator_ohos/example](./geolocator_ohos/example/)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 6.0.1.260;  ROM: 6.0.0.120 SP6;
2. Flutter: 3.35.7-ohos-0.0.1;  SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260;  ROM: 6.0.0.120 SP6;

### 2.2 **Permission Requirements**

The following permissions include the `system_basic` permission, but the default application permission is `normal`. Only the `normal` permission can be used. Therefore, the error **9568289** may be reported during the installation of the HAP package. For details, see [Document](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/bm-tool-V5#EN_TOPIC_0000001884757326__安装hap时提示code9568289-error-install-failed-due-to-grant-request-permissions-failed) Change the application level to `system_basic`.

#### 2.2.1 **Add permissions to the module.json5 file in the entry directory.**

Open `entry/src/main/module.json5` and add the following information:

```diff
"requestPermissions": [
      {"name" :  "ohos.permission.INTERNET"},
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:location",
        "usedScene": {
          "abilities": [
            "FormAbility"
          ],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.LOCATION_IN_BACKGROUND",
        "reason": "$string:locationbackground",
        "usedScene": {
          "abilities": [
            "FormAbility"
          ],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:locationapprox",
        "usedScene": {
          "abilities": [
            "FormAbility"
          ],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
      },
    ]
```

#### 2.2.2 **Add the reason for applying for the preceding permission to the entry directory.**

Open `entry/src/main/resources/base/element/string.json` and add the following information:

```diff
{
  "string": [
    {
      "name": "location",
      "value": "use location"
    },
    {
      "name": "locationbackground",
      "value": "use locationbackground"
    },
    {
      "name": "locationapprox",
      "value": "use locationapprox"
    }
  ]
}
```

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name                | return          | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|-------------------|-------------------|
| checkPermission() | Future<[LocationPermission](#LocationPermission)> | function | yes          |
| requestPermission() | Future<[LocationPermission](#LocationPermission)> | function | yes          |
| isLocationServiceEnabled() | Future<bool> | function | yes |
| getLastKnownPosition({bool forceLocationManager = false,}) | Future<[Position](#Position)?> | function | yes |
| getLocationAccuracy() | Future<[LocationAccuracyStatus](#LocationAccuracyStatus)> | function | yes |
## 3. API
| Name | return | Type | ohos Support |
| --- | --- | --- | --- | --- 
| getCurrentPosition({[LocationSettings](#LocationSettings)? locationSettings, String? requestId,}) | Future<[Position](#Position)> | function | yes |
| getServiceStatusStream() | Stream<[ServiceStatus](#ServiceStatus)> | function | yes |
| getPositionStream({[LocationSettings](#LocationSettings)? locationSettings,}) | Stream<[Position](#Position)> | function | yes |
| requestTemporaryFullAccuracy({required String purposeKey,}) | Future<[LocationAccuracyStatus](#LocationAccuracyStatus)> | function | partially |
| openAppSettings() | Future<bool> | function | yes |
| openLocationSettings() | Future<bool> | function | yes |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

## LocationPermission

| Name              | Description                                                  | Type  | ohos Support |
| ----------------- | ------------------------------------------------------------ | ----- | ------------ |
| denied            | Permission to access the device's location is denied, the App should try to request permission using the `Geolocator.requestPermission()` method. | enums | yes          |
| deniedForever     | Permission to access the device's location is permenantly denied. When  requestiong permissions the permission dialog will not been shown until the user updates the permission in the App settings. | enums | yes          |
| whileInUse        | Permission to access the device's location is allowed only while the App is in use. | enums | yes          |
| always            | Permission to access the device's location is allowed even when the App is running in the background. | enums | yes          |
| unableToDetermine | Permission status is cannot be determined. This permission is only returned by the `Geolocator.checkPermission()` method on the web platform for browsers that do not implement the Permission API (see https://developer.mozilla.org/en-US/docs/Web/API/Permissions_API). | enums | no           |

## LocationSettings

| Name           | return               | Description                                                  | Type                                  | ohos Support |
| -------------- | -------------------- | ------------------------------------------------------------ | ------------------------------------- | ------------ |
| toJson()       | Map<String, dynamic> | Serializes the [PlatformSpecificSettings] to a map message   | function                              | yes          |
| accuracy       |                      | Defines the desired accuracy that should be used to determine the location data. | [LocationAccuracy](#LocationAccuracy) | yes          |
| distanceFilter |                      | The minimum distance (measured in meters) a device must move horizontally before an update event is generated. | int                                   | yes          |
| timeLimit      |                      | The [timeLimit] parameter allows you to specify a timeout interval (by default no time limit is configured). | Duration?                             | no           |

## LocationAccuracy

| Name              | Description                                                  | Type  | ohos Support |
| ----------------- | ------------------------------------------------------------ | ----- | ------------ |
| lowest            | Location is accurate within a distance of 3000m on iOS and 500m on Android. | enums | yes          |
| low               | Location is accurate within a distance of 1000m on iOS and 500m on Android. | enums | yes          |
| medium            | Location is accurate within a distance of 100m on iOS and between 100m and 500m on Android. | enums | yes          |
| high              | Location is accurate within a distance of ~0m on iOS and between 0m and  100m on Android. | enums | yes          |
| best              | Location accuracy is optimized for navigation on iOS and matches the [LocationAccuracy.best] on Android. | enums | yes          |
| bestForNavigation | Location accuracy is reduced for iOS 14+ devices, matches the [LocationAccuracy.lowest] on iOS 13 and below and all other platforms. | enums | yes          |
| reduced           | The [timeLimit] parameter allows you to specify a timeout interval (by default no time limit is configured). | enums | no           |

## ServiceStatus

| Name    | Description                                                  | Type  | ohos Support |
| ------- | ------------------------------------------------------------ | ----- | ------------ |
| lowest  | Indicates that the location service on the native platform is disabled. | enums | yes          |
| enabled | Indicates that the location service on the native platform is enabled. | enums | yes          |

## LocationAccuracyStatus

| Name    | Description                                                  | Type  | ohos Support |
| ------- | ------------------------------------------------------------ | ----- | ------------ |
| reduced | A approximate location will be returned (Approximate location). | enums | yes          |
| precise | The precise location of the device will be returned.         | enums | yes          |
| unknown | When an Android device is used, an 'unknown' status is returned, since Android does not support Approximate Location yet. | enums | no           |

## Position

| Name             | return                | Description                                                  | Type      | ohos Support |
| ---------------- | --------------------- | ------------------------------------------------------------ | --------- | ------------ |
| latitude         |                       | The latitude of this position in degrees normalized to the interval -90.0 to +90.0 (both inclusive). | double    | yes          |
| longitude        |                       | The longitude of the position in degrees normalized to the interval -180 (exclusive) to +180 (inclusive). | double    | yes          |
| timestamp        |                       | The time at which this position was determined.              | DateTime? | yes          |
| altitude         |                       | The altitude of the device in meters.                        | double    | yes          |
| altitudeAccuracy |                       | The estimated vertical accuracy of the position in meters.   | double    | yes          |
| accuracy         |                       | The estimated horizontal accuracy of the position in meters. | double    | yes          |
| heading          |                       | he heading in which the device is traveling in degrees.      | double    | yes          |
| headingAccuracy  |                       | The estimated heading accuracy of the position in degrees.   | double    | no           |
| floor            |                       | The floor specifies the floor of the building on which the device is located. | int?      | no           |
| speed            |                       | The speed at which the devices is traveling in meters per second over ground. | double    | yes          |
| speedAccuracy    |                       | The estimated speed accuracy of this position, in meters per second. | double    | yes          |
| isMocked         |                       | Will be true on Android (starting from API lvl 18) when the location came from the mocked provider. | bool      | yes          |
| fromMap          | [Position](#Position) | Converts the supplied [Map] to an instance of the [Position] class. | function  | yes          |
| toJson           | Map<String, dynamic>  | Converts the [Position] instance into a [Map] instance that can be serialized to JSON. | function  | yes          |

## 5. Known Issues

not

## 6. Others

## 7. License

This project is licensed under  [MIT License](https://gitcode.com/CPF-Flutter/fluttertpc_geolocator/blob/br_v14.0.1_ohos/LICENSE) .
