import 'dart:developer';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:odms/main.dart';
import 'package:odms/src/core/in_app_update/controller/in_app_update_controller.dart';
import 'package:odms/src/core/in_app_update/model/latest_app_info.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopupWidget extends StatefulWidget {
  final LatestAppInfoAPIModel latestAppInfoAPIModel;
  final String currentAppVersion;
  final String apkDownloadLink;
  final bool isExitsSameVersionAPK;

  final PermissionStatus apkInstallPermission;
  const PopupWidget({
    super.key,
    required this.latestAppInfoAPIModel,
    required this.currentAppVersion,
    required this.apkDownloadLink,
    required this.isExitsSameVersionAPK,
    required this.apkInstallPermission,
  });

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget> {
  final InAppUpdateController controllerGetx = Get.find();
  bool isDownloaded = false;
  bool isGranted = false;
  bool isDownloading = false;
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        // height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue.shade900,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gap(40),
                  Icon(Icons.download, color: Colors.white),
                  Gap(10),
                  Text(
                    "Update Available",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Gap(15),
                  Obx(
                    () {
                      return SizedBox(
                        height: 25,
                        width: 25,
                        child: controllerGetx.downloadProgress.value == 0
                            ? (controllerGetx.downloadProgress.value > 0.99 ||
                                    isDownloaded ||
                                    widget.isExitsSameVersionAPK)
                                ? Icon(
                                    Icons.download_done,
                                    color: Colors.white,
                                  )
                                : null
                            : (controllerGetx.downloadProgress.value > 0.99 ||
                                    isDownloaded ||
                                    widget.isExitsSameVersionAPK)
                                ? Icon(
                                    Icons.download_done,
                                    color: Colors.white,
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                    value:
                                        controllerGetx.downloadProgress.value,
                                    strokeWidth: 3,
                                  ),
                      );
                    },
                  )
                ],
              ),
            ),
            Container(
              // height: 145,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current App version : ${widget.currentAppVersion}"),
                  Text(
                      "Latest App version : ${widget.latestAppInfoAPIModel.version}"),
                  if (widget.latestAppInfoAPIModel.forceToUpdate == true)
                    Text(
                      "You have to update to latest version anyway",
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  Gap(10),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "Having trouble with the update?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down_sharp,
                          color: Colors.grey.shade600,
                        )
                      ],
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          SelectableText(
                            "Try a fresh install. Uninstall the current version, then download and install the latest one. Copy the link and download apk file.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          Gap(8),
                          SelectableText(
                            "URL:  ${widget.apkDownloadLink}",
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          Gap(8),
                          SizedBox(
                            height: 25,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                FlutterClipboard.copy(widget.apkDownloadLink)
                                    .then(
                                  (value) {
                                    Fluttertoast.showToast(msg: "Copied");
                                  },
                                );
                              },
                              label: Text(
                                "Copy",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              icon: Icon(
                                Icons.copy,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed:
                            widget.latestAppInfoAPIModel.forceToUpdate == true
                                ? null
                                : () {
                                    isUpdateChecked = true;
                                    Navigator.pop(context);
                                  },
                        child: Text("Not Now"),
                      ),
                      Gap(10),
                      ElevatedButton(
                        onPressed: () async {
                          if (isDownloading) return;
                          await onProceedButtonClick();
                        },
                        child: (isDownloaded || widget.isExitsSameVersionAPK)
                            ? (widget.apkInstallPermission ==
                                        PermissionStatus.granted ||
                                    isGranted)
                                ? Text("Install Now")
                                : Row(
                                    children: [
                                      Icon(
                                        FluentIcons.settings_24_filled,
                                        size: 20,
                                      ),
                                      Gap(6),
                                      Text("Allow"),
                                    ],
                                  )
                            : isDownloading
                                ? Text("Downloading...")
                                : Text("Download Now"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onProceedButtonClick() async {
    Directory directory = await getApplicationCacheDirectory();
    String filePath =
        '${directory.path}/apk-${widget.latestAppInfoAPIModel.version}.apk';

    if (widget.isExitsSameVersionAPK == false && isDownloaded == false) {
      setState(() {
        isDownloading = true;
      });
      Dio().download(
        widget.apkDownloadLink,
        filePath,
        onReceiveProgress: (count, total) {
          controllerGetx.downloadProgress.value = count / total;
        },
      ).then((value) {
        setState(() {
          isDownloaded = true;
          isDownloading = false;
        });
      });
    } else if (!(widget.apkInstallPermission == PermissionStatus.granted ||
        isGranted)) {
      await Permission.requestInstallPackages.request().then(
        (value) {
          if (value == PermissionStatus.granted) {
            setState(() {
              isGranted = true;
            });
          }
        },
      );
    } else if ((widget.apkInstallPermission == PermissionStatus.granted ||
            isGranted) &&
        (isDownloaded || widget.isExitsSameVersionAPK)) {
      try {
        if (widget.latestAppInfoAPIModel.removeCacheAndDataOnUpdate == true) {
          SharedPreferences info = await SharedPreferences.getInstance();
          await info.clear();
          await Hive.box("info").clear();
        } else {
          if (widget.latestAppInfoAPIModel.removeCacheOnUpdate == true) {
            SharedPreferences info = await SharedPreferences.getInstance();
            await info.clear();
          }
          if (widget.latestAppInfoAPIModel.removeDataOnUpdate == true) {
            await Hive.box("info").clear();
          }
        }

        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        log(result.message);
      } catch (e) {
        log("Error clearing cache: $e");
      }
    }
  }
}
