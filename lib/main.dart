import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/screens/auth/login/login_page.dart';
import 'src/screens/permissions/cheak_and_request_permissions.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
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
