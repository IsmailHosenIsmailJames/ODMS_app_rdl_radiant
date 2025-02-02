import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:odms/src/apis/apis.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportsPageWebview extends StatefulWidget {
  const ReportsPageWebview({super.key});

  @override
  State<ReportsPageWebview> createState() => _ReportsPageWebviewState();
}

class _ReportsPageWebviewState extends State<ReportsPageWebview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: InAppWebView(
        onDownloadStartRequest: (controller, downloadStartRequest) async {
          await launchUrl(downloadStartRequest.url,
              mode: LaunchMode.externalApplication);
        },
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
              '$base$reportsAPI/${Hive.box("info").get("sap_id")}',
            ),
          ),
        ),
      ),
    );
  }
}
