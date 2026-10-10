// main.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_geolocator_ohos/geolocator_ohos.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'template/globals.dart';
import 'template/info_page.dart';
import 'geolocator_widget.dart';
import 'callback_manager.dart'; // 添加这行

// 定义主题颜色
final MaterialColor themeMaterialColor = MaterialColor(
  const Color.fromRGBO(48, 49, 60, 1).value,
  const <int, Color>{
    50: Color.fromRGBO(48, 49, 60, 0.1),
    100: Color.fromRGBO(48, 49, 60, 0.2),
    200: Color.fromRGBO(48, 49, 60, 0.3),
    300: Color.fromRGBO(48, 49, 60, 0.4),
    400: Color.fromRGBO(48, 49, 60, 0.5),
    500: Color.fromRGBO(48, 49, 60, 0.6),
    600: Color.fromRGBO(48, 49, 60, 0.7),
    700: Color.fromRGBO(48, 49, 60, 0.8),
    800: Color.fromRGBO(48, 49, 60, 0.9),
    900: Color.fromRGBO(48, 49, 60, 1),
  },
);

void main() {
  runApp(BaseflowPluginExample());
}

/// A Flutter application demonstrating the functionality of this plugin
class BaseflowPluginExample extends StatelessWidget {
  /// Seed color for the app [ThemeData]
  final Color themeSeedColor = const Color.fromRGBO(48, 49, 60, 1);

  /// Constructs the [BaseflowPluginExample] class
  BaseflowPluginExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baseflow $pluginName',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSeedColor,
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color.fromRGBO(48, 49, 60, 0.8),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(48, 49, 60, 0.8),

        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(48, 49, 60, 1),
          disabledColor: Color.fromRGBO(200, 49, 60, 1),
          splashColor: Color.fromRGBO(48, 49, 60, 0.1),
          textTheme: ButtonTextTheme.primary,
        ),
        hintColor: const Color.fromRGBO(48, 49, 60, 1),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.3,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.2,
          ),
          labelLarge: TextStyle(color: Colors.white),
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color.fromRGBO(37, 37, 37, 1),
          filled: true,
        ),
      ),
      home: const AppHome(title: 'Baseflow $pluginName example app'),
    );
  }
}

/// A Flutter example demonstrating how the [pluginName] plugin could be used
class AppHome extends StatefulWidget {
  /// Constructs the [AppHome] class
  const AppHome({Key? key, required this.title}) : super(key: key);

  /// The [title] of the application, which is shown in the application's
  /// title bar.
  final String title;

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final GeolocatorPlatform geolocatorOhos = GeolocatorPlatform.instance;
  final _pageController = PageController(initialPage: 0);
  var _currentPage = 0;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription!.cancel();
      _serviceStatusStreamSubscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Center(
          child: Image.asset(
            'res/images/baseflow_logo_def_light-02.png',
            width: 140,
          ),
        ),
        centerTitle: true,
        // 只在第一页（geolocator_widget界面）显示三个点菜单
        actions: _shouldShowMenuButton() ? [_buildMenuButton()] : [],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          GeolocatorWidget(), // 现在使用标准的 geolocator_widget
          const InfoPage(),
        ],
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
      bottomNavigationBar: _bottomAppBar(),
    );
  }

  // 判断是否应该显示菜单按钮
  bool _shouldShowMenuButton() {
    return _currentPage == 0;
  }

  // 构建菜单按钮
  Widget _buildMenuButton() {
    return PopupMenuButton(
      elevation: 40,
      onSelected: (value) async {
        switch (value) {
          case 1:
            try {
              final status = await geolocatorOhos.getLocationAccuracy();
              String locationAccuracyStatusValue;
              if (status == LocationAccuracyStatus.precise) {
                locationAccuracyStatusValue = 'Precise';
              } else if (status == LocationAccuracyStatus.reduced) {
                locationAccuracyStatusValue = 'Reduced';
              } else {
                locationAccuracyStatusValue = 'Unknown';
              }
              // 使用回调管理器更新 geolocator_widget 中的日志
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                '$locationAccuracyStatusValue location accuracy granted.',
              );
            } catch (e) {
            }
            break;
          case 2:
            try {
              final status = await geolocatorOhos.requestTemporaryFullAccuracy(
                purposeKey: "TemporaryPreciseAccuracy",
              );
              String locationAccuracyStatusValue;
              if (status == LocationAccuracyStatus.precise) {
                locationAccuracyStatusValue = 'Precise';
              } else if (status == LocationAccuracyStatus.reduced) {
                locationAccuracyStatusValue = 'Reduced';
              } else {
                locationAccuracyStatusValue = 'Unknown';
              }
              // 使用回调管理器更新 geolocator_widget 中的日志
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                '$locationAccuracyStatusValue location accuracy granted.',
              );
            } catch (e) {
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                'Error requesting temporary full accuracy: $e',
              );
            }
            break;
          case 3:
            try {
              final opened = await geolocatorOhos.openAppSettings();
              String displayValue;
              if (opened) {
                displayValue = 'Opened Application Settings.';
              } else {
                displayValue = 'Error opening Application Settings.';
              }
              // 使用回调管理器更新 geolocator_widget 中的日志
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                displayValue,
              );
            } catch (e) {
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                'Error opening app settings: $e',
              );
            }
            break;
          case 4:
            try {
              final opened = await geolocatorOhos.openLocationSettings();
              String displayValue;
              if (opened) {
                displayValue = 'Opened Location Settings';
              } else {
                displayValue = 'Error opening Location Settings';
              }
              // 使用回调管理器更新 geolocator_widget 中的日志
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                displayValue,
              );
            } catch (e) {
              CallbackManager.updatePositionListCallback?.call(
                0, // log type
                'Error opening location settings: $e',
              );
            }
            break;
          case 5:
            // 清除日志 - 使用回调管理器
            CallbackManager.clearLogsCallback?.call();
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text("Get Location Accuracy"),
        ),
        if (Platform.isIOS)
        const PopupMenuItem(
          value: 2,
          child: Text("Request Temporary Full Accuracy"),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text("Open App Settings"),
        ),
        const PopupMenuItem(
          value: 4,
          child: Text("Open Location Settings"),
        ),
        const PopupMenuItem(
          value: 5,
          child: Text("Clear"),
        ),
      ],
    );
  }

  BottomAppBar _bottomAppBar() {
    return BottomAppBar(
      elevation: 5,
      color: const Color.fromRGBO(57, 58, 71, 1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.location_on),
              color: _bottomAppBarIconColor(0),
              onPressed: () => _animateToPage(0),
            ),
          ),
          Expanded(
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.info),
              color: _bottomAppBarIconColor(1),
              onPressed: () => _animateToPage(1),
            ),
          ),
        ],
      ),
    );
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  Color _bottomAppBarIconColor(int page) {
    return _currentPage == page
        ? Colors.white
        : Theme.of(context).colorScheme.secondary;
  }
}