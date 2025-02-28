// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:odms/src/core/login/login_function.dart';
import 'package:odms/src/screens/attendance/attendance_page.dart';
import 'package:odms/src/screens/home/home_page.dart';
import 'package:odms/src/screens/permissions/unable_to_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/textfield_theme.dart';
import '../../permissions/check_and_request_permissions.dart';
import '../../permissions/check_location_service.dart';
import '../registration/register_page.dart';

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
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) => Scaffold(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  body: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 74, 174, 255),
                                    ),
                                  ),
                                ),
                              );

                              final response = await loginAndGetJsonResponse(
                                {
                                  'sap_id': sapIDController.text.trim(),
                                  'password': passwordController.text.trim(),
                                },
                              );

                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              if (response != null) {
                                await analyzeResponseLogin(
                                  response,
                                  {
                                    'sap_id': sapIDController.text.trim(),
                                    'password': passwordController.text.trim(),
                                  },
                                );
                              } else {
                                Get.to(
                                  () => const UnableToConnect(),
                                );
                              }
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
  Map<String, dynamic> userCredential,
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
        await box.put('sap_id', jsonMapData['result']['sap_id']);
        await box.put(
          'userLoginCradintial',
          userCredential,
        );

        await SharedPreferences.getInstance().then((instance) async {
          await instance.setString(
            'userLoginCradintial',
            jsonEncode(userCredential),
          );
          await instance.setString('userData', response.body);
        });

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.offAll(
            () => CheckLocationService(
              responseMapData: jsonMapData,
            ),
          );
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
                () => const AttendancePage(),
              ),
            );
          }
        } else {
          await Get.off(() => const CheckAndRequestPermissions());
        }
        if (kDebugMode) {
          print(response.body);
        }

        unawaited(
          Fluttertoast.showToast(
            msg: 'Login Successfully',
            toastLength: Toast.LENGTH_LONG,
          ),
        );
      } else {
        unawaited(
          Fluttertoast.showToast(
            msg: (jsonMapData['message'] ?? 'Something Went Wrong').toString(),
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
          msg: 'Something Went Wrong',
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
