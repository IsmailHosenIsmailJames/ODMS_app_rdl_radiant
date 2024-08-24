import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rdl_radiant/src/screens/permissions/internet_connection_off_notify.dart';

import 'src/core/login/login_function.dart';
import 'src/screens/auth/login/login_page.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterForegroundTask.initCommunicationPort();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade900,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
      defaultTransition: Transition.leftToRight,
      home: const InitPage(),
      onInit: () async {
        FlutterNativeSplash.remove();
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.ethernet) ||
            connectivityResult.contains(ConnectivityResult.wifi)) {
          final userLoginDataCridential = Map<String, dynamic>.from(
            Hive.box('info').get(
              'userLoginCradintial',
              defaultValue: Map<String, dynamic>.from({}),
            ) as Map,
          );
          if (userLoginDataCridential.isNotEmpty) {
            unawaited(
              loginAndGetJsonResponse(userLoginDataCridential).then(
                (value) async {
                  await analyzeResponseLogin(
                    value,
                    userLoginDataCridential,
                  );
                },
              ),
            );
          } else {
            unawaited(
              Get.to(
                () => const LoginPage(),
              ),
            );
          }
          return;
        } else {
          unawaited(
            Get.to(
              () => const InternetConnectionOffNotify(),
            ),
          );
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
