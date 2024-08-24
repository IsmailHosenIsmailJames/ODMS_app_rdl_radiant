import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:simple_icons/simple_icons.dart';

import '../attendence/attendence_page.dart';
import '../home/home_page.dart';

class CheakAndRequestPermissions extends StatefulWidget {
  const CheakAndRequestPermissions({super.key});

  @override
  State<CheakAndRequestPermissions> createState() =>
      _CheakAndRequestPermissionsState();
}

class _CheakAndRequestPermissionsState
    extends State<CheakAndRequestPermissions> {
  String? accestStatusText;
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
              final location = Location();

              var serviceEnabled = await location.serviceEnabled();
              if (!serviceEnabled) {
                serviceEnabled = await location.requestService();
                if (!serviceEnabled) {
                  return;
                }
              }

              var status = await location.hasPermission();
              if (status == PermissionStatus.denied) {
                status = await location.requestPermission();
              }
              if (status == PermissionStatus.granted) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You did allow location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                final userLoginDataCridential = Map<String, dynamic>.from(
                  jsonDecode(
                    Hive.box('info').get(
                      'userData',
                      defaultValue: '{}',
                    ) as String,
                  ) as Map,
                );
                if ((userLoginDataCridential['is_start_work'] ?? false) ==
                    true) {
                  unawaited(
                    Get.offAll(
                      () => const HomePage(),
                    ),
                  );
                } else {
                  unawaited(
                    Get.offAll(
                      () => const AttendencePage(),
                    ),
                  );
                }
              } else if (status == PermissionStatus.denied) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You denied location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'You denied location access';
                });
              } else if (status == PermissionStatus.grantedLimited) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You Granted Limited location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'You restricted location access';
                });
              } else if (status == PermissionStatus.deniedForever) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You permanently denied location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'You permanently denied location acces';
                });
              } else {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'Something Went Worng!',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'Something Went Worng!';
                });
              }
            },
            label: const Text('All the time location access'),
            icon: const Icon(
              SimpleIcons.googlemaps,
            ),
          ),
          const Gap(30),
          Text(accestStatusText ?? ''),
          if (accestStatusText != null)
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
