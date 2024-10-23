import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:odms/src/core/in_app_update/controller/in_app_update_controller.dart';
import 'package:odms/src/core/in_app_update/functions/get_device_info.dart';
import 'package:odms/src/core/in_app_update/functions/get_info_form_api.dart';
import 'package:odms/src/core/in_app_update/in_app_android_update/update_popup.dart';

import '../functions/compare_version.dart';
import '../functions/get_app_info.dart';
import '../model/latest_app_info.dart';

void inAppUpdateAndroid(BuildContext context) async {
  final inAppUpdateController = Get.put(InAppUpdateController());
  LatestAppInfoAPIModel latestAppInfo = await getInfoFormAPI();
  String? lastVersion = latestAppInfo.version;
  String? lastBuildNumber = latestAppInfo.buildNumber;
  if (lastVersion != null && lastBuildNumber != null) {
    List<String> currentVersionAndBuild = await getAppVersionAndBuildNumber();
    String currentVersion = currentVersionAndBuild[0];
    // String currentBuild = currentVersionAndBuild[1];
    if (compareVersion(
      currentVersion: currentVersion,
      latestVersion: lastVersion,
    )) {
      final supportedAbisByDevice = await getDeviceSupportedAbisInfo();
      final supportedAbisByApp =
          inAppUpdateController.supportedArchitectureList;
      String? architecture;
      for (int i = 0; i < supportedAbisByApp.length; i++) {
        if (supportedAbisByDevice.contains(supportedAbisByApp[i])) {
          architecture = supportedAbisByApp[i];
          break;
        }
      }
      String? apkDownloadLink;
      if (architecture == null) {
        apkDownloadLink = latestAppInfo.downloadLink;
      } else {
        for (int i = 0; i < latestAppInfo.downloadLinkList!.length; i++) {
          if (latestAppInfo.downloadLinkList![i].architecture == architecture) {
            apkDownloadLink = latestAppInfo.downloadLinkList![i].link;
            break;
          }
        }
      }
      if (apkDownloadLink != null) {
        log("Update Available on $apkDownloadLink");
        await showUpdatePopup(
          context,
          latestAppInfoAPIModel: latestAppInfo,
          currentVersion: currentVersion,
          apkDownloadLink: apkDownloadLink,
        );
      } else {
        // ignore
        log("No Update");
      }
    } else {
      // ignore
      log("No Update");
    }
  }
}
