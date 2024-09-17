import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:developer';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/core/background/socket_connection_state.dart/socket_connection_state.dart';
import 'package:rdl_radiant/src/core/background/socket_manager/socket_manager.dart';
import 'package:rdl_radiant/src/screens/home/conveyance/controller/conveyance_data_controller.dart';
import 'package:rdl_radiant/src/screens/home/conveyance/conveyance_page.dart';
import 'package:rdl_radiant/src/screens/home/dash_board_controller/dash_board_model.dart';
import 'package:rdl_radiant/src/screens/home/dash_board_controller/dashboard_controller_getx.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/controller/delivery_remaning_controller.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/delivery_remaining_page.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';
import 'package:rdl_radiant/src/screens/home/drawer/drawer.dart';
import 'package:rdl_radiant/src/widgets/loading/loading_popup_widget.dart';
import 'package:rdl_radiant/src/widgets/loading/loading_text_controller.dart';

import '../../core/background/background_setup.dart';
import 'conveyance/model/conveyance_data_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final socketConnectionStateGetx = Get.put(SocketConnectionState());
  final dashboardController = Get.put(DashboardControllerGetx());
  final LoadingTextController loadingTextController = Get.find();
  Map<String, dynamic> jsonUserdata = {};

  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserdata = Map<String, dynamic>.from(
      jsonDecode(box.get('userData', defaultValue: '{}') as String) as Map,
    );
    jsonUserdata = Map<String, dynamic>.from(jsonUserdata['result'] as Map);

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
                    stream: Stream.periodic(const Duration(seconds: 1), (i) {
                      return '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
                    }),
                    builder: (context, snapshot) {
                      return Text(
                        "Time: ${snapshot.data ?? ''}",
                        style: TextStyle(
                          fontSize: 15,
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
            const Gap(10),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello,',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(5),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    jsonUserdata['full_name'].toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    jsonUserdata['sap_id'].toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            Expanded(
              child: GetX<DashboardControllerGetx>(
                builder: (controller) {
                  if (controller.dashboardData.value.success != null) {
                    if (controller.dashboardData.value.result != null) {
                      DashBoardResult data =
                          controller.dashboardData.value.result![0];
                      return ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          getCardView(
                            data.deliveryRemaining.toString(),
                            Image.asset('assets/delivery-truck.png'),
                            'Delivary Remaining',
                            0,
                            onPressed: callDeliveryRemainingList,
                          ),
                          getCardView(
                            data.deliveryDone.toString(),
                            Image.asset('assets/delivery_done.png'),
                            'Delivary Done',
                            1,
                            onPressed: callDeliveryDoneList,
                          ),
                          getCardView(
                            data.cashRemaining.toString(),
                            Image.asset('assets/cash_collection.png'),
                            'Cash Collection Remaining',
                            0,
                            onPressed: callCashCollectionRemainingList,
                          ),
                          getCardView(
                            data.cashDone.toString(),
                            const Icon(
                              FluentIcons.money_hand_20_filled,
                              size: 40,
                            ),
                            'Cash Collection Done',
                            1,
                            onPressed: callCashCollectionDoneList,
                          ),
                          getCardView(
                            (data.totalReturnQuantity ?? 0).toInt().toString(),
                            Image.asset(
                              'assets/delivery_back.png',
                            ),
                            'Returned',
                            0,
                            onPressed: callReturnedList,
                          ),
                          getCardView(
                            0.toString(),
                            const Icon(Icons.emoji_transportation, size: 40),
                            'Conveyance',
                            0,
                            onPressed: callConveyanceList,
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text("Something went worng"),
                      );
                    }
                  } else {
                    return ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        getCardView(
                            null,
                            Image.asset('assets/delivery-truck.png'),
                            'Delivary Remaining',
                            0,
                            onPressed: callDeliveryRemainingList),
                        getCardView(
                          null,
                          Image.asset('assets/delivery_done.png'),
                          'Delivary Done',
                          1,
                          onPressed: callDeliveryDoneList,
                        ),
                        getCardView(
                          null,
                          Image.asset('assets/cash_collection.png'),
                          'Cash Collection Remaining',
                          0,
                          onPressed: callCashCollectionRemainingList,
                        ),
                        getCardView(
                          null,
                          const Icon(
                            FluentIcons.money_hand_20_filled,
                            size: 40,
                          ),
                          'Cash Collection Done',
                          1,
                          onPressed: callCashCollectionDoneList,
                        ),
                        getCardView(
                          null,
                          Image.asset(
                            'assets/delivery_back.png',
                          ),
                          'Returned',
                          0,
                          onPressed: callReturnedList,
                        ),
                        getCardView(
                          null,
                          const Icon(Icons.emoji_transportation, size: 40),
                          'Conveyance',
                          0,
                          onPressed: callConveyanceList,
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
      log("User Dashboard Data ${response.body}");
      var data = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
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
    Widget iconWidget,
    String titleText,
    int colorIndex, {
    void Function()? onPressed,
  }) {
    final color = [
      Colors.blue.withOpacity(0.15),
      Colors.blue.withOpacity(0.15),
    ][colorIndex];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
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
              ),
              height: 50,
              width: 50,
              child: iconWidget,
            ),
            const Gap(20),
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
                          .animate()
                          .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
                          .slide()
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
      "$base$getDelivaryList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      if (kDebugMode) {
        print("Got Delivery Remaning List");
        print(response.body);
      }

      final controller = Get.put(
        DeliveryRemaningController(
          DeliveryRemaing.fromJson(response.body),
        ),
      );
      controller.deliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.constDeliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
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
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callDeliveryDoneList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$getDelivaryList/${box.get('sap_id')}?type=Done&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      if (kDebugMode) {
        print("Got Delivery Remaning List");
        print(response.body);
      }

      final controller = Get.put(
        DeliveryRemaningController(
          DeliveryRemaing.fromJson(response.body),
        ),
      );
      controller.deliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.constDeliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
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
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callCashCollectionRemainingList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Remaining&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemaningController(
          DeliveryRemaing.fromJson(response.body),
        ),
      );
      controller.deliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.constDeliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
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
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callCashCollectionDoneList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Done&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemaningController(
          DeliveryRemaing.fromJson(response.body),
        ),
      );
      controller.deliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.constDeliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
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
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callReturnedList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$cashCollectionList/${box.get('sap_id')}?type=Return&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';
      dev.log(response.body);

      final controller = Get.put(
        DeliveryRemaningController(
          DeliveryRemaing.fromJson(response.body),
        ),
      );
      controller.deliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.constDeliveryRemaing.value =
          DeliveryRemaing.fromJson(response.body);
      controller.deliveryRemaing.value.result ??= [];
      controller.constDeliveryRemaing.value.result ??= [];
      controller.pageType.value = 'Returned';
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
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }

  void callConveyanceList() async {
    final box = Hive.box('info');
    final url = Uri.parse(
      "$base$conveyanceList?da_code=${box.get('sap_id')}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    );

    loadingTextController.currentState.value = 0;
    loadingTextController.loadingText.value = 'Loading Data\nPlease wait...';
    showCoustomPopUpLoadingDialog(context, isCuputino: true);

    final response = await http.get(url);
    log(response.body);

    if (response.statusCode == 200) {
      loadingTextController.currentState.value = 1;
      loadingTextController.loadingText.value = 'Successful';

      dev.log("Message with success: ${response.body}");

      Map decoded = jsonDecode(response.body);

      final conveyanceDataController = Get.put(ConveyanceDataController());
      var temList = <SavePharmaceuticalsLocationData>[];
      List<Map> tem = List<Map>.from(decoded['result']);
      for (int i = 0; i < tem.length; i++) {
        temList.add(SavePharmaceuticalsLocationData.fromMap(
            Map<String, dynamic>.from(tem[i])));
      }
      conveyanceDataController.convenceData.value = temList;

      await Future.delayed(const Duration(milliseconds: 100));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Get.to(
        () => const ConveyancePage(),
      );
      getDashBoardData();
    } else {
      loadingTextController.currentState.value = -1;
      loadingTextController.loadingText.value = 'Something went worng';
    }
  }
}
