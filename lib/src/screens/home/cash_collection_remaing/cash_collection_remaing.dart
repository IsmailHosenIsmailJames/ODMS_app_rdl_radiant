import 'package:flutter/material.dart';

class CashCollectionRemaing extends StatefulWidget {
  const CashCollectionRemaing({super.key});

  @override
  State<CashCollectionRemaing> createState() => _CashCollectionRemaingState();
}

class _CashCollectionRemaingState extends State<CashCollectionRemaing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Collection Remaning"),
      ),
    );
  }
}
