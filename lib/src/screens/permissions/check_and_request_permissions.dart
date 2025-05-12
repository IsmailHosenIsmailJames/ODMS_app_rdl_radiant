import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

// import '../attendance/attendance_page.dart';
import '../home/home_page.dart';

class CheckAndRequestPermissions extends StatefulWidget {
  const CheckAndRequestPermissions({super.key});

  @override
  State<CheckAndRequestPermissions> createState() =>
      _CheckAndRequestPermissionsState();
}

class _CheckAndRequestPermissionsState
    extends State<CheckAndRequestPermissions> {
  String? accessStatusText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.4),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/allow_location.png'),
                ),
              ),
            ),
          ),
          const Gap(20),
          ListTile(
            title: Text('Allow Activity Recognition'),
            minTileHeight: 20,
            leading: SizedBox(
              height: 25,
              width: 25,
              child: Image.asset(
                'assets/activity.png',
                color: Colors.black,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            title: Text('Allow Always Location Access'),
            minTileHeight: 20,
            leading: SizedBox(
              height: 25,
              width: 25,
              child: Icon(Icons.location_on),
            ),
          ),
          ListTile(
            title: Text('Allow Push Notification'),
            minTileHeight: 20,
            leading: SizedBox(
              height: 25,
              width: 25,
              child: Icon(Icons.notifications),
            ),
          ),
          ListTile(
            title: Text('Allow Ignore Battery Optimization'),
            minTileHeight: 20,
            leading: SizedBox(
              height: 25,
              width: 25,
              child: Icon(Icons.battery_charging_full),
            ),
          ),
          const Gap(10),
          Text(
            'We must need these permissions to work properly. Please allow them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Gap(30),
          ElevatedButton.icon(
            onPressed: () async {
              final serviceEnabled =
                  await Geolocator.isLocationServiceEnabled();

              if (!serviceEnabled) {
                return;
              }
              var activityRecognition = await permission_handler
                  .Permission.activityRecognition.status;
              if (activityRecognition !=
                  permission_handler.PermissionStatus.granted) {
                activityRecognition = await permission_handler
                    .Permission.activityRecognition
                    .request();
              }

              var locationPermissionStatus =
                  await permission_handler.Permission.locationWhenInUse.status;

              if (locationPermissionStatus !=
                  permission_handler.PermissionStatus.granted) {
                locationPermissionStatus = await permission_handler
                    .Permission.locationWhenInUse
                    .request();
                log(locationPermissionStatus.toString(),
                    name: 'Location checking');
              }

              locationPermissionStatus =
                  await permission_handler.Permission.locationAlways.status;

              if (locationPermissionStatus !=
                  permission_handler.PermissionStatus.granted) {
                locationPermissionStatus = await permission_handler
                    .Permission.locationAlways
                    .request();
                log(locationPermissionStatus.toString(),
                    name: 'Location checking');
              }

              var notificationPermissionStatus =
                  await FlutterForegroundTask.checkNotificationPermission();
              if (notificationPermissionStatus !=
                  NotificationPermission.granted) {
                notificationPermissionStatus =
                    await FlutterForegroundTask.requestNotificationPermission();
              }

              ActivityPermission activityPermission =
                  await FlutterActivityRecognition.instance.checkPermission();

              if (activityPermission != ActivityPermission.GRANTED) {
                activityPermission = await FlutterActivityRecognition.instance
                    .requestPermission();
                log(activityPermission.name.toString());
              }

              var ignoreBatteryOpt = await permission_handler
                  .Permission.ignoreBatteryOptimizations.status;
              if (ignoreBatteryOpt !=
                  permission_handler.PermissionStatus.granted) {
                ignoreBatteryOpt = await permission_handler
                    .Permission.ignoreBatteryOptimizations
                    .request();
              }

              if (locationPermissionStatus ==
                      permission_handler.PermissionStatus.granted &&
                  notificationPermissionStatus ==
                      NotificationPermission.granted &&
                  activityPermission == ActivityPermission.GRANTED &&
                  ignoreBatteryOpt ==
                      permission_handler.PermissionStatus.granted) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You did allow location & activity access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                final userLoginDataCredential = Map<String, dynamic>.from(
                  jsonDecode(
                    Hive.box('info').get(
                      'userData',
                      defaultValue: '{}',
                    ) as String,
                  ) as Map,
                );
                if ((userLoginDataCredential['is_start_work'] ?? false) ==
                    true) {
                  unawaited(
                    Get.offAll(
                      () => const HomePage(),
                    ),
                  );
                } else {
                  unawaited(
                    Get.offAll(
                      () => const HomePage(),
                    ),
                  );
                }
              } else if (notificationPermissionStatus ==
                      NotificationPermission.denied ||
                  notificationPermissionStatus ==
                      NotificationPermission.permanently_denied) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You denied notification access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'You denied notification access';
                });
              } else if (locationPermissionStatus !=
                  permission_handler.PermissionStatus.granted) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You denied location or activity access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'You denied location or activity access';
                });
              } else if (activityPermission != ActivityPermission.GRANTED) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'Please allow activity recognition',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'Please allow activity recognition';
                });
              } else {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'Something Went Wrong!',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'Something Went Wrong!';
                });
              }
            },
            label: const Text('All the time location access'),
            icon: const Icon(
              Icons.done,
            ),
          ),
          const Gap(30),
          Text(accessStatusText ?? ''),
          if (accessStatusText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Go to app settings and allow all the permissions',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
