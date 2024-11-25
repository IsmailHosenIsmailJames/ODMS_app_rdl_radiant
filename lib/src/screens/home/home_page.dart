import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:odms/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:odms/src/core/background/socket_manager/socket_manager.dart';
import 'package:odms/src/screens/home/dash_board_controller/dash_board_model.dart';
import 'package:odms/src/screens/home/dash_board_controller/dashboard_controller_getx.dart';
import 'package:odms/src/screens/home/delivery_remaining/delivery_remaining_page.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';
import 'package:odms/src/screens/home/drawer/drawer.dart';
import 'package:odms/src/widgets/loading/loading_popup_widget.dart';
import 'package:odms/src/widgets/loading/loading_text_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/background/background_setup.dart';
import 'delivery_remaining/controller/delivery_remaining_controller.dart';
import 'page_sate_definition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final socketConnectionStateGetx = Get.put(SocketConnectionState());
  final dashboardController = Get.put(DashboardControllerGetx());
  final LoadingTextController loadingTextController = Get.find();
  Map<String, dynamic> jsonUserData = {};

  final Map<String, dynamic> routeInfo = {
    "route_id": "400874",
    "route_name": "Tungipara, Gopalgonj",
    "total_gate_pass": 1,
    "total_gate_pass_amount": 112335.0,
    "total_customer": 17,
  };

  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserData = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserData = Map<String, dynamic>.from(jsonUserData['result'] as Map);

    FlutterForegroundTask.addTaskDataCallback(onReceiveTaskData);
    SocketManager().connect();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      requestPermissions().then((value) {
        initService().then((value) {
          startService();
        });
      });
    });

    getDashBoardData();
    super.initState();
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ODMS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.85)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) {
                      final now = DateTime.now();
                      return DateFormat('hh:mm:ss a')
                          .format(now); // 12-hour format with AM/PM
                    }),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                  Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.blue.shade100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Text(
                          jsonUserData['full_name'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(7),
                        Text(
                          "(${jsonUserData['sap_id'].toString()})",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    height: 0,
                  ),
                  // Info Rows
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.route_outlined,
                          label: "Route Name",
                          value: routeInfo["route_name"],
                          optional: routeInfo["route_id"],
                        ),
                        Divider(
                          color: Colors.white,
                          height: 0,
                        ),
                        _buildInfoRow(
                          icon: Icons.receipt,
                          label: "Total Gate Passes",
                          value: routeInfo["total_gate_pass"].toString(),
                        ),
                        Divider(
                          color: Colors.white,
                          height: 0,
                        ),
                        _buildInfoRow(
                          icon: Icons.attach_money,
                          label: "Gate Pass Amount",
                          value: routeInfo["total_gate_pass_amount"].toString(),
                        ),
                        Divider(
                          color: Colors.white,
                          height: 0,
                        ),
                        _buildInfoRow(
                          icon: Icons.people,
                          label: "Total Customers",
                          value: routeInfo["total_customer"].toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(15),
            Expanded(
              child: GetX<DashboardControllerGetx>(
                builder: (controller) {
                  if (controller.dashboardData.value.success != null) {
                    if (controller.dashboardData.value.result != null) {
                      DashBoardResult data =
                          controller.dashboardData.value.result![0];
                      return ListView(
                        padding: const EdgeInsets.all(5),
                        children: [
                          getCardView(
                            data.deliveryRemaining.toString(),
                            'assets/icons/truck.png',
                            'Delivery Remaining',
                            0,
                            onPressed: callDeliveryRemainingList,
                          ),
                          getCardView(
                            data.deliveryDone.toString(),
                            'assets/icons/package_delivered.png',
                            'Delivery Done',
                            1,
                            onPressed: callDeliveryDoneList,
                          ),
                          getCardView(
                            data.cashRemaining.toString(),
                            'assets/icons/cash_collection.png',
                            'Cash Collection Remaining',
                            0,
                            onPressed: callCashCollectionRemainingList,
                          ),
                          getCardView(
                            data.cashDone.toString(),
                            'assets/icons/cash_collection_done.png',
                            'Cash Collection Done',
                            1,
                            onPressed: callCashCollectionDoneList,
                          ),
                          getCardView(
                            (data.totalReturnQuantity ?? 0).toInt().toString(),
                            'assets/icons/return.png',
                            'Returned',
                            0,
                            onPressed: callReturnedList,
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }
                  } else {
                    return ListView(
                      padding: const EdgeInsets.all(5),
                      children: [
                        getCardView(null, 'assets/icons/truck.png',
                            'Delivery Remaining', 0,
                            onPressed: callDeliveryRemainingList),
                        getCardView(
                          null,
                          'assets/icons/package_delivered.png',
                          'Delivery Done',
                          1,
                          onPressed: callDeliveryDoneList,
                        ),
                        getCardView(
                          null,
                          'assets/icons/cash_collection.png',
                          'Cash Collection Remaining',
                          0,
                          onPressed: callCashCollectionRemainingList,
                        ),
                        getCardView(
                          null,
                          'assets/icons/cash_collection_done.png',
                          'Cash Collection Done',
                          1,
                          onPressed: callCashCollectionDoneList,
                        ),
                        getCardView(
                          null,
                          'assets/icons/return.png',
                          'Returned',
                          0,
                          onPressed: callReturnedList,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDashBoardData() async {
    if (dashboardController.dashboardData.value.success != null) {
      dashboardController.dashboardData.value = DashBoardModel();
    }
    final box = Hive.box('info');
    final sapID = box.get("sap_id");
    final response =
        await http.get(Uri.parse('$base$dashBoardGetDataPath/$sapID'));
    if (response.statusCode == 200) {
      log('$base$dashBoardGetDataPath/$sapID');
      log("User Dashboard Data ${response.body}");
      var data = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      final SharedPreferences info = await SharedPreferences.getInstance();
      await info.setInt("time_interval", data["result"][0]["time_interval"]);
      await info.setInt("minimum_distance", data["result"][0]["distance"]);

      if (data['success'] == true) {
        dashboardController.dashboardData.value = DashBoardModel.fromMap(data);
      } else {
        dashboardController.dashboardData.value =
            DashBoardModel(success: false);
      }
    }
  }

  Widget getCardView(
    String? count,
    String iconAssetName,
    String titleText,
    int colorIndex, {
    void Function()? onPressed,
  }) {
    final color = [
      Colors.blue.shade100,
      Colors.blue.shade100,
    ][colorIndex];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: AssetImage(iconAssetName),
                  fit: BoxFit.cover,
                ),
              ),
              height: 50,
              width: 50,
            ),
            const Gap(10),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  child: count == null
                      ? Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 1200.ms,
                            color: const Color(0xFF80DDFF),
                          )
                      : Text(
                          count,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  width: 1.5,
                  color: Colors.blue.shade900,
                ),
              ),
              child: Icon(
                CupertinoIcons.forward,
                color: Colors.blue.shade900,
                size: 15,
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  void callDeliveryRemainingList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getDeliveryList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      if (kDebugMode) {
        log("Got Delivery Remaining List");
        log(response.body);
      }

      final controller = Get.put(
        DeliveryRemainingController(
          DeliveryRemaining.fromJson(response.body),
        ),
      );
      controller.deliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.constDeliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = 'Delivery Remaining';
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await Get.to(
        () => const DeliveryRemainingPage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  void callDeliveryDoneList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getDeliveryList/${box.get('sap_id')}?type=Done&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      if (kDebugMode) {
        log("Got Delivery Remaining List");
        log(response.body);
      }

      final controller = Get.put(
        DeliveryRemainingController(
          DeliveryRemaining.fromJson(response.body),
        ),
      );
      controller.deliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.constDeliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = 'Delivery Done';
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await Get.to(
        () => const DeliveryRemainingPage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  void callCashCollectionRemainingList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await http.get(url);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemainingController(
          DeliveryRemaining.fromJson(response.body),
        ),
      );
      controller.deliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.constDeliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = 'Cash Collection Remaining';
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await Get.to(
        () => const DeliveryRemainingPage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  void callCashCollectionDoneList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Done&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await http.get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemainingController(
          DeliveryRemaining.fromJson(response.body),
        ),
      );
      controller.deliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.constDeliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = 'Cash Collection Done';

      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Get.to(
        () => const DeliveryRemainingPage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  void callReturnedList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Return&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCustomPopUpLoadingDialog(context, isCupertino: true);

    final response = await http.get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemainingController(
          DeliveryRemaining.fromJson(response.body),
        ),
      );
      controller.deliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.constDeliveryRemaining.value =
          DeliveryRemaining.fromJson(response.body);
      controller.deliveryRemaining.value.result ??= [];
      controller.constDeliveryRemaining.value.result ??= [];
      controller.pageType.value = pagesState[4];
      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await Get.to(
        () => const DeliveryRemainingPage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went wrong';
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? optional,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value.length > 30 ? "${value.substring(0, 30)}..." : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (optional != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      "($optional)",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
