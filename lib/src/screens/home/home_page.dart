import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rdl_radiant/src/apis/apis.dart';

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
      drawer: const Drawer(),
      body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.85)),
        child: Column(
          children: [
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
                      return GridView(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        children: [
                          getCardView(
                            data['delivery_remaining'].toString(),
                            Image.asset('assets/delivery-truck.png'),
                            'Delivary Remaining',
                          ),
                          getCardView(
                            data['delivery_done'].toString(),
                            Image.asset('assets/delivery_done.png'),
                            'Delivary Done',
                          ),
                          getCardView(
                            data['cash_remaining'].toString(),
                            Image.asset('assets/cash_collection.png'),
                            'Cash Collection Remaining',
                          ),
                          getCardView(
                            data['cash_done'].toString(),
                            const Icon(
                              FluentIcons.money_hand_20_filled,
                              size: 60,
                            ),
                            'Cash Collection Done',
                          ),
                          getCardView(
                            data['total_return_quantity'].toString(),
                            Image.asset('assets/delivery_back.png'),
                            'Returned',
                          ),
                        ],
                      );
                    } else {
                      return Text(snapshot.data!.body);
                    }
                  } else {
                    return const CupertinoActivityIndicator(
                      radius: 14,
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

  Widget getCardView(String count, Widget iconWidget, String titleText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
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
          SizedBox(height: 60, width: 60, child: iconWidget),
          const Spacer(),
          Text(
            titleText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
