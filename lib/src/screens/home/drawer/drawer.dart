import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rdl_radiant/src/screens/attendence/attendence_evening.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              color: Colors.blue.shade900,
              child: const Center(
                child: Text(
                  'Under dev',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const Gap(10),
          SizedBox(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.to(
                  () => const AttendenceEvening(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(Icons.verified),
                  Gap(20),
                  Text('Evening Attendence'),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Hive.deleteBoxFromDisk('info');
                await Hive.openBox('info');
                unawaited(
                  Get.offAll(
                    () => const LoginPage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(Icons.logout),
                  Gap(20),
                  Text('Log Out'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
