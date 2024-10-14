import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/apis/apis.dart';

import '../../core/login/login_function.dart';
import '../../theme/text_scaler_theme.dart';
import '../auth/login/login_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<String, dynamic> jsonUserData = {};
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserData = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserData = Map<String, dynamic>.from(jsonUserData['result'] as Map);
    super.initState();
  }

  bool sendingData = false;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScalerValue)),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Good Morning',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                    color: Color(0xFF666870),
                    height: 1,
                    letterSpacing: 3,
                  ),
                ),
                const Gap(20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'SAP ID',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          Text(
                            ":  ${jsonUserData['sap_id']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Full Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              ":  ${jsonUserData['full_name']}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          Text(
                            ":  ${jsonUserData['mobile_number']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'User Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                          Text(
                            ":  ${jsonUserData['user_type']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        sendingData = true;
                      });
                      final box = Hive.box('info');
                      final data = await box.get('userData') as String;
                      final decodeData =
                          Map<String, dynamic>.from(jsonDecode(data) as Map);
                      final uri = Uri.parse(
                        base + startWorkPath,
                      );
                      final request = http.MultipartRequest('POST', uri);

                      request.fields['sap_id'] =
                          // ignore: avoid_dynamic_calls
                          decodeData['result']['sap_id'].toString();

                      final locationData =
                          await Geolocator.getCurrentPosition();

                      request.fields['start_latitude'] =
                          locationData.latitude.toString();

                      request.fields['start_longitude'] =
                          locationData.longitude.toString();
                      final response = await request.send();
                      setState(() {
                        sendingData = false;
                      });
                      if (response.statusCode == 200) {
                        unawaited(Fluttertoast.showToast(msg: 'Successful'));
                        final userLoginDataCredential =
                            Map<String, dynamic>.from(
                          Hive.box('info').get(
                            'userLoginCradintial',
                            defaultValue: Map<String, dynamic>.from({}),
                          ) as Map,
                        );
                        if (userLoginDataCredential.isNotEmpty) {
                          unawaited(
                            loginAndGetJsonResponse(userLoginDataCredential)
                                .then(
                              (value) async {
                                await analyzeResponseLogin(
                                  value,
                                  userLoginDataCredential,
                                );
                              },
                            ),
                          );
                        }
                      } else {
                        unawaited(
                          Fluttertoast.showToast(msg: 'Something went wrong'),
                        );
                      }
                    },
                    icon: sendingData
                        ? null
                        : const Icon(
                            Icons.start,
                          ),
                    label: sendingData
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Start Work',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
