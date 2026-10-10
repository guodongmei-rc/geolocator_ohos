// geolocator_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geolocator_ohos/geolocator_ohos.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'callback_manager.dart'; // 添加这行

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {
  /// Creates a new GeolocatorWidget.
  const GeolocatorWidget({
    Key? key,
  }) : super(key: key);

  @override
  _GeolocatorWidgetState createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform geolocatorOhos = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  @override
  void initState() {
    super.initState();
    // 注册回调到管理器
    CallbackManager.setUpdatePositionListCallback(_updatePositionList);
    CallbackManager.setClearLogsCallback(_clearLogs);
    _toggleServiceStatusStream();
  }

  void _clearLogs() {
    setState(() {
      _positionItems.clear();
    });
  }

  @override
  void dispose() {
    // 从管理器中移除回调
    CallbackManager.removeAllCallbacks();
    
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
    const sizedBox = SizedBox(
      height: 10,
    );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(48, 49, 60, 1),
      body: _positionItems.isEmpty
          ? const Center(
              child: Text(
                '',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _positionItems.length,
              itemBuilder: (context, index) {
                final positionItem = _positionItems[index];

                if (positionItem.type == _PositionItemType.log) {
                  return ListTile(
                    title: Text(positionItem.displayValue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  );
                } else {
                  return Card(
                    child: ListTile(
                      tileColor: const Color.fromRGBO(48, 49, 60, 1),
                      title: Text(
                        positionItem.displayValue,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
            ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: (_positionStreamSubscription == null ||
                _positionStreamSubscription!.isPaused)
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
            onPressed: _toggleListening,
            tooltip: (_positionStreamSubscription == null)
                ? 'Start position updates'
                : _positionStreamSubscription!.isPaused
                ? 'Resume'
                : 'Pause',
            backgroundColor: _determineButtonColor(),
          ),
          sizedBox,
          FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: _getCurrentPosition,
          ),
          sizedBox,
          FloatingActionButton(
            child: const Icon(Icons.bookmark),
            onPressed: _getLastKnownPosition,
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    debugPrint(">>>>>>>>>>>>>hasPermission=$hasPermission");
    if (!hasPermission) {
      return;
    }

    final position = await geolocatorOhos.getCurrentPosition();
    _updatePositionList(
      1, // position type
      position.toString(),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geolocatorOhos.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        0, // log type
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await geolocatorOhos.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorOhos.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          0, // log type
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        0, // log type
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      0, // log type
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(int type, String displayValue) {
    // 将整数类型转换为 _PositionItemType
    _PositionItemType positionType = type == 0 ? _PositionItemType.log : _PositionItemType.position;
    setState(() {
      _positionItems.add(_PositionItem(positionType, displayValue));
    });
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = geolocatorOhos.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          serviceStatusValue = 'enabled';
        } else {
          serviceStatusValue = 'disabled';
        }
        _updatePositionList(
          0, // log type
          'Location service has been $serviceStatusValue',
        );
      });
    }
  }

  Future<void> _toggleListening() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    if (_positionStreamSubscription == null) {
      debugPrint(">>>>>>>>>>>>>_toggleListening==OhosSettings");
      final ohosSettings = OhosSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 1),
        forceLocationManager: false,
        useMSLAltitude: true,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationText:
          "Example app will continue to receive your location even when you aren't using it",
          //Explain to the user why we are showing this notification
          notificationTitle: "Running in Background",
          //Tell the user what we are doing
          enableWakeLock:
          false, //Keep the system awake to receive background location information.
        ),
      );
      final positionStream = geolocatorOhos.getPositionStream(
          locationSettings: ohosSettings);
      _positionStreamSubscription = positionStream.handleError((error) {
        debugPrint(">>>>>>>>>>>>>_toggleListening==cancel");
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) {
        debugPrint(">>>>>>>>>>>>>_toggleListening==alyitude=${position.altitude}");
        debugPrint(position.altitude.toString());
        _updatePositionList(
          1, // position type
          position.toString(),
        );
      });
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        debugPrint(">>>>>>>>>>>>>_toggleListening==resume");
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        debugPrint(">>>>>>>>>>>>>_toggleListening==pause");
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList(
        0, // log type
        'Listening for position updates $statusDisplayValue',
      );
    });
  }

  void _getLastKnownPosition() async {
    final position = await geolocatorOhos.getLastKnownPosition();
    if (position != null) {
      _updatePositionList(
        1, // position type
        position.toString(),
      );
    } else {
      _updatePositionList(
        0, // log type
        'No last known position available',
      );
    }
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}