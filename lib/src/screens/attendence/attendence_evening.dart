import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:rdl_radiant/src/apis/apis.dart';

import '../../core/login/login_function.dart';
import '../auth/login/login_page.dart';

class AttendenceEvening extends StatefulWidget {
  const AttendenceEvening({super.key});

  @override
  State<AttendenceEvening> createState() => _AttendenceEveningState();
}

class _AttendenceEveningState extends State<AttendenceEvening> {
  Map<String, dynamic> jsonUserdata = {};
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserdata = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserdata = Map<String, dynamic>.from(jsonUserdata['result'] as Map);
    super.initState();
  }

  bool sendingData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            'SAP ID',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Text(
                          jsonUserdata['sap_id'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Text(
                          jsonUserdata['full_name'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
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
                            fontSize: 18,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Text(
                          jsonUserdata['user_type'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
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
                      // ignore: avoid_dynamic_calls
                      '$base$startWorkPath/${decodeData['result']['sap_id']}',
                    );
                    final request = http.MultipartRequest('PUT', uri);

                    request.fields['sap_id'] =
                        // ignore: avoid_dynamic_calls
                        decodeData['result']['sap_id'].toString();
                    final location = Location();

                    final locationData = await location.getLocation();

                    request.fields['start_latitude'] =
                        locationData.latitude.toString();

                    request.fields['start_longitude'] =
                        locationData.longitude.toString();
                    final response = await request.send();
                    setState(() {
                      sendingData = false;
                    });
                    if (response.statusCode == 200) {
                      unawaited(Fluttertoast.showToast(msg: 'Successfull'));
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
                      }
                    } else {
                      unawaited(
                        Fluttertoast.showToast(msg: 'Something went worng'),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
