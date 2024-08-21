import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? jsonUserdata;
  @override
  void initState() {
    final box = Hive.box('info');
    jsonUserdata = box.get('userData', defaultValue: '') as String;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ODMS'),
      ),
      drawer: const Drawer(),
      body: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.85)),
        child: GridView(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            getCardView(
              '890',
              Image.asset('assets/delivery-truck.png'),
              'Delivary Remaining',
            ),
            getCardView(
              '890',
              Image.asset('assets/delivery_done.png'),
              'Delivary Done',
            ),
            getCardView(
              '890',
              Image.asset('assets/cash_collection.png'),
              'Cash Collection Remaining',
            ),
            getCardView(
              '890',
              const Icon(
                FluentIcons.money_hand_20_filled,
                size: 60,
              ),
              'Cash Collection Done',
            ),
            getCardView(
              '890',
              Image.asset('assets/delivery_back.png'),
              'Returned',
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
