import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/core/distance_calculator/calculate_distance_with_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/login/login_function.dart';
import '../../theme/text_scaler_theme.dart';
import '../auth/login/login_page.dart';

class AttendanceEvening extends StatefulWidget {
  const AttendanceEvening({super.key});

  @override
  State<AttendanceEvening> createState() => _AttendanceEveningState();
}

class _AttendanceEveningState extends State<AttendanceEvening> {
  Map<String, dynamic> jsonUserData = {};
  bool isEveningDoneToday = false;
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserData = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserData = Map<String, dynamic>.from(jsonUserData['result'] as Map);
    int lastEveningAttendanceDate = box.get('lastEveningAttendanceDate') ?? -1;
    int todayDate = DateTime.now().day;
    if (lastEveningAttendanceDate == todayDate) {
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
                if (isEveningDoneToday)
                  Text(
                    'Your attendance for today is already done',
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
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.reload();
                              await prefs.setBool('isOnWorking', false);
                              await box.put('lastEveningAttendanceDate',
                                  DateTime.now().day);

                              List<String> entireDayPositionRaw =
                                  prefs.getStringList(
                                          'entire_working_day_position') ??
                                      [];

                              List<Position> listOfPositionOfEntireDay =
                                  entireDayPositionRaw
                                      .map((e) =>
                                          Position.fromMap(jsonDecode(e)))
                                      .toList();
                              PositionCalculationResult
                                  positionCalculationResult =
                                  PositionPointsCalculator(
                                          rawPositions:
                                              listOfPositionOfEntireDay)
                                      .processData();

                              try {
                                final response = await http.post(
                                  Uri.parse('$base$saveMovementInfo'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    {
                                      'da_code': decodeData['result']['sap_id'],
                                      'mv_date': DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now()),
                                      'time_duration': positionCalculationResult
                                          .totalDistance,
                                      'distance': positionCalculationResult
                                          .totalDuration.inMilliseconds
                                    }
                                  }),
                                );
                                if (response.statusCode == 200) {
                                  log('Successfully saved movement info');
                                }
                              } catch (e) {
                                log(e.toString());
                              }

                              unawaited(
                                  Fluttertoast.showToast(msg: 'Successful'));
                              final userLoginDataCredential =
                                  Map<String, dynamic>.from(
                                Hive.box('info').get(
                                  'userLoginCradintial',
                                  defaultValue: Map<String, dynamic>.from({}),
                                ) as Map,
                              );

                              if (userLoginDataCredential.isNotEmpty) {
                                unawaited(
                                  loginAndGetJsonResponse(
                                          userLoginDataCredential)
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
                              setState(() {
                                sendingData = false;
                              });
                            } else {
                              if (kDebugMode) {
                                print(response.statusCode);
                              }
                              unawaited(
                                Fluttertoast.showToast(
                                    msg: 'Something went wrong'),
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
