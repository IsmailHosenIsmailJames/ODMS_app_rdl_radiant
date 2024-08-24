import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/core/login/login_function.dart';
import 'package:rdl_radiant/src/screens/attendence/attendence_page.dart';
import 'package:rdl_radiant/src/screens/home/home_page.dart';
import 'package:rdl_radiant/src/screens/permissions/unable_to_connect.dart';

import '../../../theme/textfield_theme.dart';
import '../../permissions/cheak_and_request_permissions.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// input form controller
  FocusNode sapIDFocusNode = FocusNode();
  TextEditingController sapIDController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(20),
              Center(
                child: Container(
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
                  child: Container(
                    height: 200,
                    width: 200,
                    margin: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/ic_logo_color.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: textFiendBoxDecoration,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if (int.tryParse(value ?? '') == null) {
                              return 'SAP ID is not valid';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          focusNode: sapIDFocusNode,
                          controller: sapIDController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'SAP ID',
                          ),
                          style: textStyleForField,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        decoration: textFiendBoxDecoration,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if ((value ?? '').length >= 4) {
                              return null;
                            } else {
                              return 'Password is short';
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          focusNode: passwordFocusNode,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          ),
                          obscureText: true,
                          style: textStyleForField,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final response = await loginAndGetJsonResponse(
                                {
                                  'sap_id': sapIDController.text.trim(),
                                  'password': passwordController.text.trim(),
                                },
                              );
                              await analyzeResponseLogin(
                                response,
                                {
                                  'sap_id': sapIDController.text.trim(),
                                  'password': passwordController.text.trim(),
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Gap(10),
                          TextButton(
                            onPressed: () {
                              Get.off(
                                () => const RegisterPage(),
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> analyzeResponseLogin(
  http.Response? response,
  Map<String, dynamic> userCrid,
) async {
  if (response == null) {
    if (kDebugMode) {
      print('Response was null');
    }
    unawaited(
      Get.to(
        () => const UnableToConnect(),
      ),
    );
  } else {
    try {
      final jsonMapData = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      if ((jsonMapData['success'] ?? false) == true) {
        final box = Hive.box('info');
        await box.put('userData', response.body);
        await box.put(
          'userLoginCradintial',
          userCrid,
        );

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return;
        }

        final locationAlwaysStatus = await Geolocator.checkPermission();

        if (locationAlwaysStatus == LocationPermission.whileInUse ||
            locationAlwaysStatus == LocationPermission.always) {
          if ((jsonMapData['is_start_work'] ?? false) == true) {
            unawaited(
              Get.offAll(
                () => const HomePage(),
              ),
            );
          } else {
            unawaited(
              Get.offAll(
                () => const AttendencePage(),
              ),
            );
          }
        } else {
          await Get.off(() => const CheakAndRequestPermissions());
        }
        if (kDebugMode) {
          print(response.body);
        }
        unawaited(
          Fluttertoast.showToast(
            msg: 'Login Successfull',
            toastLength: Toast.LENGTH_LONG,
          ),
        );
      } else {
        unawaited(
          Fluttertoast.showToast(
            msg: (jsonMapData['message'] ?? 'Something Went Worng').toString(),
            toastLength: Toast.LENGTH_LONG,
          ),
        );
        if (Get.currentRoute != 'LoginPage') {
          unawaited(
            Get.offAll(
              () => const LoginPage(),
            ),
          );
        }
      }
    } catch (e) {
      unawaited(
        Fluttertoast.showToast(
          msg: 'Something Went Worng',
          toastLength: Toast.LENGTH_LONG,
        ),
      );
      if (Get.currentRoute != 'LoginPage') {
        unawaited(
          Get.offAll(
            () => const LoginPage(),
          ),
        );
      }
    }
  }
}
