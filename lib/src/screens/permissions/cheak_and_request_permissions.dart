import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';
import 'package:simple_icons/simple_icons.dart';

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
              final status = await Permission.locationAlways.request();
              if (status.isGranted) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You did allow location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                unawaited(
                  Get.off(
                    () => const LoginPage(),
                  ),
                );
              } else if (status.isDenied) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You denied location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'You denied location access';
                });
              } else if (status.isRestricted) {
                unawaited(
                  Fluttertoast.showToast(
                    msg: 'You restricted location access',
                    toastLength: Toast.LENGTH_LONG,
                  ),
                );
                setState(() {
                  accestStatusText = 'You restricted location access';
                });
              } else if (status.isPermanentlyDenied) {
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
