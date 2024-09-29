import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

class AttendenceEvening extends StatefulWidget {
  const AttendenceEvening({super.key});

  @override
  State<AttendenceEvening> createState() => _AttendenceEveningState();
}

class _AttendenceEveningState extends State<AttendenceEvening> {
  Map<String, dynamic> jsonUserdata = {};
  bool isEveningDoneToday = false;
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserdata = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserdata = Map<String, dynamic>.from(jsonUserdata['result'] as Map);
    int lastEveningAttendenceDate = box.get('lastEveningAttendenceDate') ?? -1;
    int todayDate = DateTime.now().day;
    if (lastEveningAttendenceDate == todayDate) {
      isEveningDoneToday = true;
    }
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
                  'Good Evening',
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
                            jsonUserdata['sap_id'].toString(),
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
                              jsonUserdata['full_name'].toString(),
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
                            jsonUserdata['mobile_number'].toString(),
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
                            jsonUserdata['user_type'].toString(),
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
                if (isEveningDoneToday)
                  Text(
                    "Your attendence for today is already done",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
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
                    onPressed: isEveningDoneToday
                        ? null
                        : () async {
                            setState(() {
                              sendingData = true;
                            });
                            final box = Hive.box('info');
                            final data = await box.get('userData') as String;
                            final decodeData = Map<String, dynamic>.from(
                                jsonDecode(data) as Map);
                            final uri = Uri.parse(
                              // ignore: avoid_dynamic_calls
                              '$base$endWorkPath/${decodeData['result']['sap_id']}',
                            );
                            final request = http.MultipartRequest('PUT', uri);

                            final locationData =
                                await Geolocator.getCurrentPosition();

                            request.fields['end_latitude'] =
                                locationData.latitude.toString();

                            request.fields['end_longitude'] =
                                locationData.longitude.toString();
                            final response = await request.send();

                            if (response.statusCode == 200) {
                              await box.put('lastEveningAttendenceDate',
                                  DateTime.now().day);

                              unawaited(
                                  Fluttertoast.showToast(msg: 'Successfull'));
                              final userLoginDataCridential =
                                  Map<String, dynamic>.from(
                                Hive.box('info').get(
                                  'userLoginCradintial',
                                  defaultValue: Map<String, dynamic>.from({}),
                                ) as Map,
                              );

                              if (userLoginDataCridential.isNotEmpty) {
                                unawaited(
                                  loginAndGetJsonResponse(
                                          userLoginDataCridential)
                                      .then(
                                    (value) async {
                                      await analyzeResponseLogin(
                                        value,
                                        userLoginDataCridential,
                                      );
                                    },
                                  ),
                                );
                              }
                              setState(() {
                                sendingData = false;
                              });
                            } else {
                              if (kDebugMode) {
                                print(response.statusCode);
                              }
                              unawaited(
                                Fluttertoast.showToast(
                                    msg: 'Something went worng'),
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
                            'Finish Work',
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
