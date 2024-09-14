import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rdl_radiant/src/screens/attendence/attendence_evening.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';
import 'package:rdl_radiant/src/screens/coustomer_location/set_customer_location.dart';
import 'package:rdl_radiant/src/screens/journey/select_journey_end_location.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              child: TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
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
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Get.to(
                    () => const SetCustomerLocation(),
                  );
                },
                child: const Row(
                  children: [
                    Gap(20),
                    Icon(Icons.location_on),
                    Gap(20),
                    Text('Set Coustomer Location'),
                  ],
                ),
              ),
            ),
            SizedBox(
              child: TextButton(
                onPressed: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Get.to(
                    () => const SelectJourneyEndLocation(),
                  );
                },
                child: const Row(
                  children: [
                    Gap(20),
                    Icon(Icons.drive_eta),
                    Gap(20),
                    Text('Start Journey'),
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
      ),
    );
  }
}
