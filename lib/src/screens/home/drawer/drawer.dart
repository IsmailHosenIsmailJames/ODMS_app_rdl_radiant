import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:odms/src/screens/attendance/attendance_evening.dart';
import 'package:odms/src/screens/auth/login/login_page.dart';
import 'package:odms/src/screens/customer_location/set_customer_location.dart';
import 'package:odms/src/screens/overdue/models/overdue_response_model.dart';
import 'package:odms/src/screens/overdue/overdue_cutomer_list.dart';
import 'package:odms/src/screens/visit%20customer/visits_customer_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../apis/apis.dart';
import '../../../widgets/loading/loading_popup_widget.dart';
import '../../../widgets/loading/loading_text_controller.dart';
import '../../overdue/controllers/overdue_controller_getx.dart';
import '../../reports/reports_page_webview.dart';
import '../conveyance/controller/conveyance_data_controller.dart';
import '../conveyance/conveyance_page.dart';
import '../conveyance/model/conveyance_data_model.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final LoadingTextController loadingTextController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    "assets/app_logo_big.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final v = snapshot.data?.version ?? "";
                    return Text(
                      v.isEmpty ? "" : 'v$v',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
                const Text(
                  "ODMS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 45,
                  ),
                ),
                Text(
                  "Outbound Delivery Management System",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                )
              ],
            ),
          ),
          const Gap(10),
          SizedBox(
            child: TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                Get.to(
                  () => const AttendanceEvening(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.verified_outlined,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Evening Attendance',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Get.to(
                  () => const SetCustomerLocation(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Set Customer Location',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Get.to(
                  () => const VisitsCustomerPage(),
                );
              },
              child: Row(
                children: [
                  Gap(20),
                  Container(
                    height: 35,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: const DecorationImage(
                        image: AssetImage("assets/visit.png"),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  Gap(20),
                  Text(
                    'Visit Customer',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: callOverDueList,
              child: Row(
                children: [
                  const Gap(20),
                  Container(
                    height: 35,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: const DecorationImage(
                        image: AssetImage("assets/overdue.jpg"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  const Gap(19),
                  const Text(
                    'Overdue',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                Get.to(
                  () => const ReportsPageWebview(),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.summarize_outlined,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Reports',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: callConveyanceList,
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.emoji_transportation,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Conveyance',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Hive.deleteBoxFromDisk('info');
                await Hive.openBox('info');
                unawaited(
                  Get.offAll(
                    () => const LoginPage(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Gap(20),
                  Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  Gap(20),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              launchUrl(
                Uri.parse("https://impalaintech.com/"),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(
              "Developed by © Impala Intech Limited. All Rights Reserved",
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          Gap(10),
        ],
      ),
    );
  }

  void callOverDueList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getOverdueListV2/${box.get('sap_id')}",
    );

    //

    log("$base$getOverdueListV2/${box.get('sap_id')}");

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await get(url);
    if (kDebugMode) {
      log("Got overdue Remaining List");
      log(response.statusCode.toString());
      log(response.body);
    }

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      final modelFormHTTPResponse =
          OverdueResponseModel.fromJson(response.body);

      final controller = Get.put(
        OverdueControllerGetx(modelFormHTTPResponse),
      );
      controller.overdueRemaining.value = modelFormHTTPResponse;
      controller.constOverdueRemaining.value = modelFormHTTPResponse;
      controller.overdueRemaining.value.result ??= [];
      controller.constOverdueRemaining.value.result ??= [];
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      log(modelFormHTTPResponse.toString());
      await Get.to(
        () => const OverdueCustomerList(),
      );
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  void callConveyanceList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$conveyanceList?da_code=${box.get('sap_id')}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      log("Message with success: ${response.body}");

      Map decoded = jsonDecode(response.body);

      final conveyanceDataController = Get.put(ConveyanceDataController());
      var temList = <SavePharmaceuticalsLocationData>[];
      List<Map> tem = List<Map>.from(decoded['result']);
      for (int i = 0; i < tem.length; i++) {
        temList.add(SavePharmaceuticalsLocationData.fromMap(
            Map<String, dynamic>.from(tem[i])));
      }
      conveyanceDataController.convinceData.value = temList.reversed.toList();

      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Get.to(
        () => const ConveyancePage(),
      );
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }
}
