import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:delivery/src/screens/permissions/internet_connection_off_notify.dart';
import 'package:delivery/src/widgets/loading/loading_text_controller.dart';

import 'src/core/in_app_update/in_app_android_update/in_app_update_android.dart';
import 'src/core/login/login_function.dart';
import 'src/screens/auth/login/login_page.dart';

bool isUpdateChecked = false;

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterForegroundTask.initCommunicationPort();
  await Hive.initFlutter();
  await Hive.openBox('info');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade900,
            shadowColor: Colors.transparent,
            iconColor: Colors.white,
          ),
        ),
      ),
      defaultTransition: Transition.leftToRight,
      home: const InitPage(),
      routes: {'/': (context) => InitPage()},
      onInit: () async {
        FlutterNativeSplash.remove();
        Get.put(LoadingTextController());
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.ethernet) ||
            connectivityResult.contains(ConnectivityResult.wifi)) {
          isUpdateChecked = false;
          while (!isUpdateChecked) {
            await Future.delayed(Duration(milliseconds: 100));
          }
          final userLoginDataCredential = Map<String, dynamic>.from(
            Hive.box('info').get(
              'userLoginCradintial',
              defaultValue: Map<String, dynamic>.from({}),
            ) as Map,
          );
          if (userLoginDataCredential.isNotEmpty) {
            unawaited(
              loginAndGetJsonResponse(userLoginDataCredential).then(
                (value) async {
                  await analyzeResponseLogin(
                    value,
                    userLoginDataCredential,
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
    inAppUpdateAndroid(context);
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
