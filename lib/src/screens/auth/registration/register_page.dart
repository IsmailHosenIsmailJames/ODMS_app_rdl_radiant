import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rdl_radiant/src/core/registration/registration.dart';
import 'package:rdl_radiant/src/screens/auth/login/login_page.dart';

import '../../../theme/textfield_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController sapCodeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? userType;

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
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/ic_logo_color.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
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
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 3) {
                              return 'Name is too small';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.name,
                          controller: fullNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Full Name',
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
                            if (value == null ||
                                int.tryParse(value) == null ||
                                value.length != 11) {
                              return 'Phone number must be in 11 digit';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.phone,
                          controller: phoneNumberController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone Number',
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
                            if (int.tryParse(value ?? '') == null) {
                              return 'SAP Code is not valid';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          controller: sapCodeController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'SAP Code',
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
                            if (value == null || value.length < 4) {
                              return 'Password is too short';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.visiblePassword,
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New Password',
                          ),
                          obscureText: true,
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
                            if ((value ?? '') != newPasswordController.text) {
                              return 'Password did not matched';
                            } else {
                              return null;
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm Password',
                          ),
                          obscureText: true,
                          style: textStyleForField,
                        ),
                      ),
                      const Gap(15),
                      const Row(
                        children: [
                          Gap(10),
                          Text(
                            'User Type',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(10),
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                userType = 'Delivery Assistant';
                              });
                            },
                            icon: (userType ?? '') == 'Delivery Assistant'
                                ? const Icon(
                                    Icons.radio_button_checked,
                                    color: Colors.blue,
                                  )
                                : const Icon(Icons.radio_button_off),
                            label: const Text(
                              'Delivery Assistant',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const Gap(20),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                userType = 'Driver';
                              });
                            },
                            icon: (userType ?? '') == 'Driver'
                                ? const Icon(
                                    Icons.radio_button_checked,
                                    color: Colors.blue,
                                  )
                                : const Icon(Icons.radio_button_off),
                            label: const Text(
                              'Driver',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (userType == null) {
                                unawaited(
                                  Fluttertoast.showToast(
                                    msg: 'Choice a user type first',
                                  ),
                                );
                                return;
                              }
                              if (kDebugMode) {
                                print(
                                  {
                                    'sap_id': int.parse(
                                      sapCodeController.text.trim(),
                                    ),
                                    'full_name': fullNameController.text.trim(),
                                    'mobile_number':
                                        phoneNumberController.text.trim(),
                                    'user_type': userType,
                                    'password':
                                        confirmPasswordController.text.trim(),
                                  },
                                );
                              }

                              await registrationAndGetJsonResponse(
                                {
                                  'sap_id':
                                      int.parse(sapCodeController.text.trim()),
                                  'full_name': fullNameController.text.trim(),
                                  'mobile_number':
                                      phoneNumberController.text.trim(),
                                  'user_type': userType,
                                  'password':
                                      confirmPasswordController.text.trim(),
                                },
                              ).then(
                                (value) async {
                                  await analyzeResponseLogin(
                                    value,
                                    {
                                      'sap_id': int.parse(
                                        sapCodeController.text.trim(),
                                      ),
                                      'password':
                                          confirmPasswordController.text.trim(),
                                    },
                                  );
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
                            'Register',
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
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Gap(10),
                          TextButton(
                            onPressed: () {
                              Get.off(
                                () => const LoginPage(),
                              );
                            },
                            child: const Text(
                              'Login',
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
