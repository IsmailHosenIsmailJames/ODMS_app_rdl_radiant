import 'dart:convert';
import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/apis/apis.dart';
import 'package:rdl_radiant/src/screens/home/drawer/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              child: FutureBuilder(
                future: http.get(
                  Uri.parse(
                    '$base$dashBoardGetDataPath/${jsonUserdata['sap_id']}',
                  ),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    if (snapshot.data!.statusCode == 200) {
                      if (kDebugMode) {
                        print(snapshot.data!.body);
                      }
                      var data = Map<String, dynamic>.from(
                        jsonDecode(snapshot.data!.body) as Map,
                      );
                      // ignore: avoid_dynamic_calls
                      data = data['result'][0] as Map<String, dynamic>;
                      return ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          getCardView(
                            data['delivery_remaining'].toString(),
                            Image.asset('assets/delivery-truck.png'),
                            'Delivary Remaining',
                            0,
                          ),
                          getCardView(
                            data['delivery_done'].toString(),
                            Image.asset('assets/delivery_done.png'),
                            'Delivary Done',
                            1,
                          ),
                          getCardView(
                            data['cash_remaining'].toString(),
                            Image.asset('assets/cash_collection.png'),
                            'Cash Collection Remaining',
                            0,
                          ),
                          getCardView(
                            data['cash_done'].toString(),
                            const Icon(
                              FluentIcons.money_hand_20_filled,
                              size: 40,
                            ),
                            'Cash Collection Done',
                            1,
                          ),
                          getCardView(
                            data['total_return_quantity'].toString(),
                            Image.asset(
                              'assets/delivery_back.png',
                            ),
                            'Returned',
                            0,
                          ),
                        ],
                      );
                    } else {
                      return Text(snapshot.data!.body);
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
                        ),
                        getCardView(
                          null,
                          Image.asset('assets/delivery_done.png'),
                          'Delivary Done',
                          1,
                        ),
                        getCardView(
                          null,
                          Image.asset('assets/cash_collection.png'),
                          'Cash Collection Remaining',
                          0,
                        ),
                        getCardView(
                          null,
                          const Icon(
                            FluentIcons.money_hand_20_filled,
                            size: 40,
                          ),
                          'Cash Collection Done',
                          1,
                        ),
                        getCardView(
                          null,
                          Image.asset(
                            'assets/delivery_back.png',
                          ),
                          'Returned',
                          0,
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

  Widget getCardView(
    String? count,
    Widget iconWidget,
    String titleText,
    int colorIndex,
  ) {
    final color = [
      Colors.blue.withOpacity(0.15),
      Colors.blue.withOpacity(0.15),
    ][colorIndex];
    return Container(
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
    );
  }
}
