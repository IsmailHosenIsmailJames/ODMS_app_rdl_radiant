import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SummeryPageWebview extends StatefulWidget {
  const SummeryPageWebview({super.key});

  @override
  State<SummeryPageWebview> createState() => _SummeryPageWebviewState();
}

class _SummeryPageWebviewState extends State<SummeryPageWebview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
                'http://172.16.16.149:6042/api/v1/web_view/summary/${Hive.box("info").get("sap_id")}'),
          ),
        ),
      ),
    );
  }
}
