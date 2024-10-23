// The callback function should always be a top-level function.
// ignore_for_file: avoid_dynamic_calls

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart'
    as activity_recognition;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:rdl_radiant/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:rdl_radiant/src/core/background/socket_manager/socket_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    activity_recognition.FlutterActivityRecognition.instance.activityStream
        .listen(
      (event) async {
        if (event.type != activity_recognition.ActivityType.UNKNOWN) {
          log("Activity: ${event.type.name}");
          final SharedPreferences info = await SharedPreferences.getInstance();
          await info.setString("last_activity", event.type.name);
        }
      },
    );
  }

  // Called every [ForegroundTaskOptions.interval] milliseconds.
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    log("count: $count");
    final SharedPreferences info = await SharedPreferences.getInstance();
    final minimumDistance = info.getInt("minimum_distance");
    final lastActivity = info.getString("last_activity");
    double? lastPositionLat = info.getDouble("last_position_lat");
    double? lastPositionLon = info.getDouble("last_position_lon");
    if (SocketManager().isConnected()) {
      await Geolocator.getCurrentPosition().then(
        (position) async {
          if (lastPositionLon == null || lastPositionLat == null) {
            lastPositionLon = position.longitude;
            lastPositionLat = position.latitude;
            await info.setDouble("last_position_lat", position.latitude);
            await info.setDouble("last_position_lon", position.longitude);
          }
          double distance = Geolocator.distanceBetween(
            lastPositionLat ?? position.latitude,
            lastPositionLon ?? position.longitude,
            position.latitude,
            position.longitude,
          );
          if (distance > (minimumDistance ?? 5)) {
            await info.setDouble("last_position_lat", position.latitude);
            await info.setDouble("last_position_lon", position.longitude);
            count++;
            await SocketManager().sendLocationViaSocket(
              latitude: position.latitude,
              longitude: position.longitude,
              altitude: position.altitude,
              accuracy: position.accuracy,
              bearing: 0,
              speed: position.speed,
              activity: lastActivity,
            );
            log("Send and saved as distance is $distance > $minimumDistance");
          } else {
            // ignore
            log("Ignored as distance is $distance < $minimumDistance");
          }
        },
      );
    }
    await FlutterForegroundTask.updateService(
      notificationText: 'Your location is tracking!',
    );
    FlutterForegroundTask.sendDataToMain(count);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    if (kDebugMode) {
      print('onDestroy');
    }
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    if (kDebugMode) {
      print('onReceiveData: $data');
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    if (kDebugMode) {
      print('onNotificationButtonPressed: $id');
    }
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    if (kDebugMode) {
      print('onNotificationPressed');
    }
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    if (kDebugMode) {
      print('onNotificationDismissed');
    }
  }
}
