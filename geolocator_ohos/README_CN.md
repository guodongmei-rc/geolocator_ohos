<p align="center">
  <h1 align="center"> <code>flutter_geolocator_ohos</code> </h1>
</p>




本项目基于 [geolocator@14.0.2](https://pub.dev/packages/geolocator) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

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

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [geolocator_ohos/example](./geolocator_ohos/example/)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.27.5-ohos-1.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 6.0.1.260;  ROM: 6.0.0.120 SP6;
2. Flutter: 3.35.7-ohos-0.0.1;  SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260;  ROM: 6.0.0.120 SP6;

### 2.2 权限要求

以下权限中有`system_basic` 权限，而默认的应用权限是 `normal` ，只能使用 `normal` 等级的权限，所以可能会在安装hap包时报错**9568289**，请参考 [文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/bm-tool-V5#ZH-CN_TOPIC_0000001884757326__安装hap时提示code9568289-error-install-failed-due-to-grant-request-permissions-failed) 修改应用等级为 `system_basic`

#### 在 entry 目录下的module.json5中添加权限

打开 `entry/src/main/module.json5`，添加：

```yaml
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

#### 在 entry 目录下添加申请以上权限的原因

打开 `entry/src/main/resources/base/element/string.json`，添加：

```
{
  "string": [
    {
      "name": "location",
      "value": "使用定位"
    },
    {
      "name": "locationbackground",
      "value": "使用locationbackground"
    },
    {
      "name": "locationapprox",
      "value": "使用locationapprox"
    }
  ]
}
```

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name                | return          | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|-------------------|-------------------|
| checkPermission()                                            | Future<[LocationPermission](#LocationPermission)>         | function | yes          |
| requestPermission()                                          | Future<[LocationPermission](#LocationPermission)>         | function | yes          |
| isLocationServiceEnabled()                                   | Future<bool>                                              | function | yes          |
| getLastKnownPosition({bool forceLocationManager = false,})   | Future<[Position](#Position)?>                            | function | yes          |
| getLocationAccuracy()                                        | Future<[LocationAccuracyStatus](#LocationAccuracyStatus)> | function | yes          |
| getCurrentPosition({[LocationSettings](#LocationSettings)? locationSettings, String? requestId,}) | Future<[Position](#Position)>                             | function | yes          |
| getServiceStatusStream()                                     | Stream<[ServiceStatus](#ServiceStatus)>                   | function | no           |
| getPositionStream({[LocationSettings](#LocationSettings)? locationSettings,}) | Stream<[Position](#Position)>                             | function | no           |
| requestTemporaryFullAccuracy({required String purposeKey,})  | Future<[LocationAccuracyStatus](#LocationAccuracyStatus)> | function | no           |
| openAppSettings()                                            | Future<bool>                                              | function | yes          |
| openLocationSettings()                                       | Future<bool>                                              | function | yes          |

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

## LocationPermission

| Name              | Description                                                  | Type  | ohos Support |
| ----------------- | ------------------------------------------------------------ | ----- | ------------ |
| denied            | 访问设备位置的权限被拒绝，应用程序应尝试使用“Geolocator.requestPermission（）”方法请求权限。 | enums | yes          |
| deniedForever     | 访问设备位置的权限被永久拒绝。当请求权限时，权限对话框将不会显示，直到用户在应用程序设置中更新权限。 | enums | yes          |
| whileInUse        | 仅当应用程序正在使用时，才允许访问设备的位置。               | enums | yes          |
| always            | 即使应用程序在后台运行，也允许访问设备位置的权限。           | enums | yes          |
| unableToDetermine | 无法确定权限状态。对于未实现permission API的浏览器，此权限仅由web平台上的“Geolocator.checkPermission（）”方法返回（请参阅https://developer.mozilla.org/en-US/docs/Web/API/Permissions_API). | enums | no           |

## LocationSettings

| Name           | return               | Description                                                  | Type                                  | ohos Support |
| -------------- | -------------------- | ------------------------------------------------------------ | ------------------------------------- | ------------ |
| toJson()       | Map<String, dynamic> | 将 [PlatformSpecificSettings] 序列化为地图消息               | function                              | yes          |
| accuracy       |                      | 定义用于确定位置数据的所需精度。                             | [LocationAccuracy](#LocationAccuracy) | yes          |
| distanceFilter |                      | 在生成更新事件之前，设备必须水平移动的最小距离（以米为单位）。 | int                                   | yes          |
| timeLimit      |                      | [timeLimit]参数允许您指定超时间隔（默认情况下未配置时间限制）。 | Duration?                             | no           |

## LocationAccuracy

| Name              | Description                                                  | Type  | ohos Support |
| ----------------- | ------------------------------------------------------------ | ----- | ------------ |
| lowest            | 位置在iOS上精确到3000米，在Android上精确到500米。            | enums | yes          |
| low               | 位置在iOS上精确到1000米，在Android上精确到500米。            | enums | yes          |
| medium            | 在iOS上，位置准确度在100米以内，在Android上在100米到500米之间。 | enums | yes          |
| high              | 在iOS上，位置精确到0米以内，在Android上精确到0到100米之间。  | enums | yes          |
| best              | 位置精度针对iOS上的导航进行了优化，并与Android上的[LocationAccuracy.best]相匹配。 | enums | yes          |
| bestForNavigation | iOS 14+设备的位置精度降低，与iOS 13及以下版本和所有其他平台上的[LocationAccuracy.lowest]相匹配。 | enums | yes          |
| reduced           | [timeLimit]参数允许您指定超时间隔（默认情况下未配置时间限制）。 | enums | no           |

## ServiceStatus

| Name    | Description                      | Type  | ohos Support |
| ------- | -------------------------------- | ----- | ------------ |
| lowest  | 表示本机平台上的位置服务已禁用。 | enums | yes          |
| enabled | 表示本机平台上的位置服务已启用。 | enums | yes          |

## LocationAccuracyStatus

| Name    | Description                                                  | Type  | ohos Support |
| ------- | ------------------------------------------------------------ | ----- | ------------ |
| reduced | 将返回大致位置（近似位置）。                                 | enums | yes          |
| precise | 将返回设备的精确位置。                                       | enums | yes          |
| unknown | 当使用Android设备时，会返回“未知”状态，因为Android尚不支持近似位置。 | enums | no           |

## Position

| Name             | return                | Description                                                  | Type      | ohos Support |
| ---------------- | --------------------- | ------------------------------------------------------------ | --------- | ------------ |
| latitude         |                       | 该位置的纬度，以度为单位，标准化为-90.0至+90.0（包括两者）。 | double    | yes          |
| longitude        |                       | 位置的经度，单位为度，归一化为-180（不含）到+180（含）的区间。 | double    | yes          |
| timestamp        |                       | 确定这一立场的时间。                                         | DateTime? | yes          |
| altitude         |                       | 设备的海拔高度，单位为米。                                   | double    | yes          |
| altitudeAccuracy |                       | 位置的估计垂直精度，单位为米。                               | double    | yes          |
| accuracy         |                       | 位置的估计水平精度，单位为米。                               | double    | yes          |
| heading          |                       | 设备以度为单位行进的方向。                                   | double    | yes          |
| headingAccuracy  |                       | 位置的估计航向精度（度）。                                   | double    | no           |
| floor            |                       | 楼层指定设备所在建筑物的楼层。                               | int?      | no           |
| speed            |                       | 设备在地面上移动的速度，单位为米每秒。                       | double    | yes          |
| speedAccuracy    |                       | 此位置的估计速度精度，单位为米每秒。                         | double    | yes          |
| isMocked         |                       | 当位置来自模拟提供程序时，在Android上（从API级别18开始）将为true。 | bool      | yes          |
| fromMap          | [Position](#Position) | 将提供的[Map]转换为[Position]类的实例。                      | function  | yes          |
| toJson           | Map<String, dynamic>  | 将[Position]实例转换为可以序列化为JSON的[Map]实例。          | function  | yes          |

## 4. 遗留问题

无

## 5. 其他

## 6. 开源协议

本项目基于 [MIT开源协议](https://gitcode.com/CPF-Flutter/fluttertpc_geolocator/blob/br_v14.0.1_ohos/LICENSE) ，请自由地享受和参与开源。
