import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rdl_radiant/src/screens/attendence/attendence_evening.dart';

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
        ],
      ),
    );
  }
}
