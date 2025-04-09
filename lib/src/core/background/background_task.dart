import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart'
    as activity_recognition;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:odms/src/core/background/socket_manager/socket_manager.dart';
import 'package:odms/src/core/distance_calculator/calculate_distance_with_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  final socketConnectionStateGetx = Get.put(SocketConnectionState());

  int count = 0;

  SocketManager? _socketManager;
  StreamSubscription? _activitySubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('MyTaskHandler onStart');
    _socketManager = SocketManager();
    _socketManager?.connect();

    _activitySubscription = activity_recognition
        .FlutterActivityRecognition.instance.activityStream
        .listen((event) async {
      if (event.type != activity_recognition.ActivityType.UNKNOWN) {
        log('Activity Update: ${event.type.name}');
        try {
          final SharedPreferences sharedPrefs =
              await SharedPreferences.getInstance();
          await sharedPrefs.setString('last_activity', event.type.name);
        } catch (e) {
          log('Error saving activity: $e');
        }
      }
    }, onError: (error) {
      log('Activity Stream Error: $error');
    });
    log('Activity Recognition started.');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    count++;
    try {
      log('onRepeatEvent triggered at $timestamp');
      final SharedPreferences sharedPrefs =
          await SharedPreferences.getInstance();
      await sharedPrefs.reload();
      bool? isOnWorking = sharedPrefs.getBool('isOnWorking');
      if (isOnWorking == false) {
        log('Service is not working, stopping task.');
        _socketManager?.disconnect();
        _activitySubscription?.cancel();
        FlutterForegroundTask.stopService();
        log('Service stopped.');
        return;
      }
      final minimumDistance = sharedPrefs.getInt('minimum_distance');
      final lastActivity = sharedPrefs.getString('last_activity');
      double? lastPositionLat = sharedPrefs.getDouble('last_position_lat');
      double? lastPositionLon = sharedPrefs.getDouble('last_position_lon');

      if (!SocketManager().isConnected()) {
        log('Socket disconnected, attempting reconnect...');
        SocketManager().connect();
      }

      log('Attempting to get current position...');
      final position = await Geolocator.getCurrentPosition();
      bool? conveyanceStatus = sharedPrefs.getBool('conveyance_status');
      if (conveyanceStatus == true) {
        List<String> conveyanceLocationPoints =
            (sharedPrefs.getStringList('conveyance_location_points')) ?? [];
        conveyanceLocationPoints.add(jsonEncode(position.toJson()));
        sharedPrefs.setStringList(
            'conveyance_location_points', conveyanceLocationPoints);
        log('Conveyance location point saved: ${position.toJson()} Len${conveyanceLocationPoints.length}',
            name: 'conveyance_location_points_background');
      }

      List<String> entireWorkingDayPosition =
          sharedPrefs.getStringList('entire_working_day_position') ?? [];
      entireWorkingDayPosition.add(jsonEncode(position.toJson()));
      await sharedPrefs.setStringList(
          'entire_working_day_position', entireWorkingDayPosition);
      log('Len : ${entireWorkingDayPosition.length}',
          name: 'entireWorkingDayPosition');
      log('Position obtained: ${position.latitude}, ${position.longitude}');

      sharedPrefs.get('conveyance_status');

      if (lastPositionLon == null || lastPositionLat == null) {
        lastPositionLon = position.longitude;
        lastPositionLat = position.latitude;
        await sharedPrefs.setDouble('last_position_lat', position.latitude);
        await sharedPrefs.setDouble('last_position_lon', position.longitude);
        log('Initial position saved.');
      }

      if (DateTime.now().hour > 22) {
        if (sharedPrefs.getString('date_of_upload_day_activity') !=
            DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          List<String> entireDayPositionRaw =
              sharedPrefs.getStringList('entire_working_day_position') ?? [];

          List<Position> listOfPositionOfEntireDay = entireDayPositionRaw
              .map((e) => Position.fromMap(jsonDecode(e)))
              .toList();
          PositionCalculationResult positionCalculationResult =
              PositionPointsCalculator(rawPositions: listOfPositionOfEntireDay)
                  .processData();

          try {
            int? sapID = sharedPrefs.getInt('user_sap_id');
            final response = await post(
              Uri.parse('$base$saveMovementInfo'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                {
                  'da_code': sapID,
                  'mv_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'time_duration': positionCalculationResult.totalDistance,
                  'distance':
                      positionCalculationResult.totalDuration.inMilliseconds
                }
              }),
            );
            if (response.statusCode == 200) {
              await sharedPrefs
                  .setStringList('entire_working_day_position', []);
              await sharedPrefs.setString('date_of_upload_day_activity',
                  DateFormat('yyyy-MM-dd').format(DateTime.now()));

              log('Successfully saved movement info');
            }
          } catch (e) {
            log(e.toString());
          }
        }
      }

      double distance = Geolocator.distanceBetween(
        lastPositionLat,
        lastPositionLon,
        position.latitude,
        position.longitude,
      );

      if (distance > (minimumDistance ?? 5)) {
        await sharedPrefs.setDouble('last_position_lat', position.latitude);
        await sharedPrefs.setDouble('last_position_lon', position.longitude);
        count++;
        log('Distance threshold exceeded. Sending location via socket...');

        if (SocketManager().isConnected()) {
          await SocketManager().sendLocationViaSocket(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            accuracy: position.accuracy,
            bearing: 0,
            speed: position.speed,
            activity: lastActivity,
          );
          count++;
          log('Location sent and saved. count : $count');
        } else {
          log('Socket disconnected before sending location.');
        }
      } else {
        log('Distance threshold not met. Ignoring.');
      }

      FlutterForegroundTask.sendDataToMain(count);
      log('onRepeatEvent finished successfully.');
    } catch (e, stackTrace) {
      log('!!!!!!!!!! ERROR in onRepeatEvent !!!!!!!!!!');
      log('Error: $e');
      log('StackTrace: $stackTrace');

      FlutterForegroundTask.updateService(
        notificationTitle: 'Foreground Task Error!',
        notificationText: 'Error occurred: $e',
      );
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('MyTaskHandler onDestroy');

    await _activitySubscription?.cancel();
    _socketManager?.disconnect();
    _socketManager = null;
    log('Resources cleaned up.');
  }

  @override
  void onReceiveData(Object data) {
    if (kDebugMode) {
      print('onReceiveData: $data');
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (kDebugMode) {
      print('onNotificationButtonPressed: $id');
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    if (kDebugMode) {
      print('onNotificationPressed');
    }
  }

  @override
  void onNotificationDismissed() {
    if (kDebugMode) {
      print('onNotificationDismissed');
    }
  }
}
