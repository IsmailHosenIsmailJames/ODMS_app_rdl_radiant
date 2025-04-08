// The callback function should always be a top-level function.
// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart'
    as activity_recognition;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:odms/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:odms/src/core/background/socket_manager/socket_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  final socketConnectionStateGetx = Get.put(SocketConnectionState());

  int count = 0;

  SocketManager? _socketManager; // Hold instance locally
  StreamSubscription? _activitySubscription; // Hold subscription

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('MyTaskHandler onStart');
    _socketManager = SocketManager(); // Initialize here
    _socketManager?.connect(); // Attempt initial connection

    // Store the subscription to cancel it later
    _activitySubscription = activity_recognition
        .FlutterActivityRecognition.instance.activityStream
        .listen((event) async {
      if (event.type != activity_recognition.ActivityType.UNKNOWN) {
        log('Activity Update: ${event.type.name}');
        try {
          final SharedPreferences info = await SharedPreferences.getInstance();
          await info.setString('last_activity', event.type.name);
        } catch (e) {
          log('Error saving activity: $e');
        }
      }
    }, onError: (error) {
      log('Activity Stream Error: $error');
    });
    log('Activity Recognition started.');
  }

  // Called every [ForegroundTaskOptions.interval] milliseconds.
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    count++;
    try {
      // <--- Add try
      log('onRepeatEvent triggered at $timestamp'); // Log entry point
      final SharedPreferences info = await SharedPreferences.getInstance();
      final minimumDistance = info.getInt('minimum_distance');
      final lastActivity = info.getString('last_activity');
      double? lastPositionLat = info.getDouble('last_position_lat');
      double? lastPositionLon = info.getDouble('last_position_lon');

      // Check socket connection BEFORE getting location if possible
      if (!SocketManager().isConnected()) {
        log('Socket disconnected, attempting reconnect...');
        SocketManager().connect();
      }

      log('Attempting to get current position...');
      final position = await Geolocator.getCurrentPosition(
          // Consider adding a timeout to prevent hangs
          // timeLimit: Duration(seconds: 15)
          );
      log('Position obtained: ${position.latitude}, ${position.longitude}');

      if (lastPositionLon == null || lastPositionLat == null) {
        lastPositionLon = position.longitude;
        lastPositionLat = position.latitude;
        await info.setDouble('last_position_lat', position.latitude);
        await info.setDouble('last_position_lon', position.longitude);
        log('Initial position saved.');
      }

      double distance = Geolocator.distanceBetween(
        lastPositionLat,
        lastPositionLon,
        position.latitude,
        position.longitude,
      );

      // log('Calculated distance: $distance meters. Minimum: ${minimumDistance ?? 5}');

      if (distance > (minimumDistance ?? 5)) {
        await info.setDouble('last_position_lat', position.latitude);
        await info.setDouble('last_position_lon', position.longitude);
        count++;
        log('Distance threshold exceeded. Sending location via socket...');
        // Re-check socket connection just before sending
        if (SocketManager().isConnected()) {
          await SocketManager().sendLocationViaSocket(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            accuracy: position.accuracy,
            bearing: 0, // Consider using position.heading if available/needed
            speed: position.speed,
            activity: lastActivity,
          );
          count++;
          log('Location sent and saved. count : $count');
        } else {
          log('Socket disconnected before sending location.');
          // Optionally attempt reconnect again here
        }
      } else {
        log('Distance threshold not met. Ignoring.');
      }

      FlutterForegroundTask.sendDataToMain(count);
      log('onRepeatEvent finished successfully.');
    } catch (e, stackTrace) {
      // <--- Add catch
      log('!!!!!!!!!! ERROR in onRepeatEvent !!!!!!!!!!');
      log('Error: $e');
      log('StackTrace: $stackTrace');
      // Optionally update notification to show error state
      FlutterForegroundTask.updateService(
        notificationTitle: 'Foreground Task Error!',
        notificationText: 'Error occurred: $e',
      );
      // Depending on the error, you might want to stop the service or attempt recovery
    }
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('MyTaskHandler onDestroy');
    // Clean up resources
    await _activitySubscription?.cancel();
    _socketManager?.disconnect(); // Add a disconnect method if needed
    _socketManager = null;
    log('Resources cleaned up.');
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
