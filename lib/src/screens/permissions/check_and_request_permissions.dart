import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:simple_icons/simple_icons.dart';

import '../attendance/attendance_page.dart';
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
          const Text(
            'Allow Background Location Access',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          Text(
            'We must need location data for running this\napp with essential features. Please allow location\naccess, then you can go next step.',
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

              var status = await Geolocator.checkPermission();

              if (status == LocationPermission.denied) {
                status = await Geolocator.requestPermission();
              }
              if (status == LocationPermission.whileInUse ||
                  status == LocationPermission.always) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You did allow location access',
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
                      () => const AttendancePage(),
                    ),
                  );
                }
              } else if (status == LocationPermission.denied) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You denied location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'You denied location access';
                });
              } else if (status == LocationPermission.deniedForever) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You permanently denied location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accessStatusText = 'You permanently denied location access';
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
              SimpleIcons.googlemaps,
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
