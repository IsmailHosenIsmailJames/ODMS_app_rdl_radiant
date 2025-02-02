import 'package:get/get.dart';
import 'package:odms/src/core/in_app_update/model/latest_app_info.dart';

class InAppUpdateController extends GetxController {
  RxList<LatestAppInfoAPIModel> latestAppInfoApiModel =
      <LatestAppInfoAPIModel>[].obs;
  List<String> supportedArchitectureList = <String>[
    'arm64-v8a',
    'armeabi-v7a',
    'x86_64',
  ];
  RxDouble downloadProgress = 0.0.obs;
}
