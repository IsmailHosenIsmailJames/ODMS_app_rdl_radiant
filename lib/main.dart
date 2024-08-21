import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rdl_radiant/src/screens/permissions/internet_connection_off_notify.dart';

import 'src/screens/auth/login/login_page.dart';
import 'src/screens/permissions/cheak_and_request_permissions.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  await Hive.openBox('info');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
      home: const InitPage(),
      onInit: () async {
        FlutterNativeSplash.remove();

        final locationAlwaysStatus = await Permission.locationAlways.status;
        if (locationAlwaysStatus.isGranted) {
          final connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.mobile) ||
              connectivityResult.contains(ConnectivityResult.ethernet) ||
              connectivityResult.contains(ConnectivityResult.wifi)) {
            unawaited(
              Get.to(
                () => const LoginPage(),
              ),
            );
          } else {
            unawaited(
              Get.to(
                () => const InternetConnectionOffNotify(),
              ),
            );
          }

          await Get.off(() => const LoginPage());
        } else {
          await Get.off(() => const CheakAndRequestPermissions());
        }
      },
    );
  }
}

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(
          color: Colors.purple,
          radius: 15,
        ),
      ),
    );
  }
}
