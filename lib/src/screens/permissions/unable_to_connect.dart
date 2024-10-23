import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:odms/src/screens/auth/login/login_page.dart';

class UnableToConnect extends StatefulWidget {
  const UnableToConnect({super.key});

  @override
  State<UnableToConnect> createState() => _UnableToConnectState();
}

class _UnableToConnectState extends State<UnableToConnect> {
  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet) ||
          result.contains(ConnectivityResult.wifi)) {
        unawaited(
          Get.to(
            () => const LoginPage(),
          ),
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(10),
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
              ),
              child: const Image(
                image: AssetImage(
                  'assets/No_Internet_Connection.png',
                ),
              ),
            ),
          ),
          const Gap(20),
          const Text(
            'Unable to connect with server',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          Text(
            'Your internet connection is too slow to\nconnect with server. We must need stable internet\nconnection for running this app with essential features.\nPlease check your internet connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Gap(30),
        ],
      ),
    );
  }
}
