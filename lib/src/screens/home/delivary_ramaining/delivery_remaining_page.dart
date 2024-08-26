import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeliveryRemainingPage extends StatefulWidget {
  const DeliveryRemainingPage({super.key});

  @override
  State<DeliveryRemainingPage> createState() => _DeliveryRemainingPageState();
}

class _DeliveryRemainingPageState extends State<DeliveryRemainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery Remaining"),
      ),
    );
  }
}
