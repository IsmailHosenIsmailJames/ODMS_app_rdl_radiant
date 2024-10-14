import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../attendance/attendance_page.dart';
import '../home/home_page.dart';
import 'check_and_request_permissions.dart';

class CheckLocationService extends StatefulWidget {
  final Map<String, dynamic> responseMapData;
  const CheckLocationService({super.key, required this.responseMapData});

  @override
  State<CheckLocationService> createState() => _CheckLocationServiceState();
}

class _CheckLocationServiceState extends State<CheckLocationService> {
  String? accessStatusText;
  @override
  void initState() {
    Geolocator.getServiceStatusStream().listen(
      (event) {
        if (event == ServiceStatus.enabled) {
          nextStep();
        }
      },
    );
    super.initState();
  }

  void nextStep() async {
    final locationAlwaysStatus = await Geolocator.checkPermission();

    if (locationAlwaysStatus == LocationPermission.whileInUse ||
        locationAlwaysStatus == LocationPermission.always) {
      if ((widget.responseMapData['is_start_work'] ?? false) == true) {
        unawaited(
          Get.offAll(
            () => const HomePage(),
          ),
        );
      } else {
        unawaited(
          Get.offAll(
            () => const AttendancePage(),
          ),
        );
      }
    } else {
      await Get.off(() => const CheckAndRequestPermissions());
    }
    if (kDebugMode) {
      print(widget.responseMapData);
    }

    unawaited(
      Fluttertoast.showToast(
        msg: 'Login Successfully',
        toastLength: Toast.LENGTH_LONG,
      ),
    );
  }

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
          const Text(
            'Please enabled location service',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          Text(
            'We must need location data for running this\napp with essential features. Please enabled location\nservice, then you can go next step.',
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
              Geolocator.openLocationSettings();
            },
            label: const Text('Go to Location Settings'),
            icon: const Icon(
              FluentIcons.settings_24_regular,
            ),
          ),
          const Gap(30),
          Text(accessStatusText ?? ''),
          if (accessStatusText != null)
            Text(
              'Go to app settings and allow all the time location access',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
