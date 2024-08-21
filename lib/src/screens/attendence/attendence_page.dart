import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';

class AttendencePage extends StatefulWidget {
  const AttendencePage({super.key});

  @override
  State<AttendencePage> createState() => _AttendencePageState();
}

class _AttendencePageState extends State<AttendencePage> {
  String? jsonUserdata;
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserdata = box.get('userData', defaultValue: '') as String;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Attendence Page'),
              const Gap(30),
              Center(
                child: Text(
                  jsonUserdata ?? 'User Data not found',
                ),
              ),
              const Gap(30),
              ElevatedButton.icon(
                onPressed: () async {
                  await Hive.deleteBoxFromDisk('info');
                  await Hive.openBox('info');
                  unawaited(
                    Get.offAll(
                      () => const LoginPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
