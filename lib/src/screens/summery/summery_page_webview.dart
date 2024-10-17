import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        onDownloadStartRequest: (controller, downloadStartRequest) async {
          await launchUrl(downloadStartRequest.url,
              mode: LaunchMode.externalApplication);
        },
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
                'https://github.com/IsmailHosenIsmailJames/ODMS_app_rdl_radiant/releases/tag/v1.5.2'),
          ),
        ),
      ),
    );
  }
}
