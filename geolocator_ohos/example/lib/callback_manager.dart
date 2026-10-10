// callback_manager.dart
class CallbackManager {
  static void Function(int, String)? updatePositionListCallback;
  static void Function()? clearLogsCallback;
  
  static void setUpdatePositionListCallback(void Function(int, String) callback) {
    updatePositionListCallback = callback;
  }
  
  static void setClearLogsCallback(void Function() callback) {
    clearLogsCallback = callback;
  }
  
  static void removeAllCallbacks() {
    updatePositionListCallback = null;
    clearLogsCallback = null;
  }
}