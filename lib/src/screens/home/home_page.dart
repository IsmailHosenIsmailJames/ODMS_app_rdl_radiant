import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
    );
  }
}
