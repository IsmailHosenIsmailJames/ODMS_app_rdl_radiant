// The callback function should always be a top-level function.
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:rdl_radiant/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket;

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  final socketConnectionStateGetx = Get.put(SocketConnectionState());
  int count = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) {
    if (kDebugMode) {
      print('onStart');
    }
  }

  // Called every [ForegroundTaskOptions.interval] milliseconds.
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    if (socket.io('http://174.138.120.140:6044').active) {
      count++;
      print("Going to access location");
    }

    await FlutterForegroundTask.updateService(
      notificationText: 'Your location accessed: $count times',
    );

    FlutterForegroundTask.sendDataToMain(count);
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp) {
    print('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}
