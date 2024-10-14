import 'package:get/get.dart';

import '../model/conveyance_data_model.dart';

class ConveyanceDataController extends GetxController {
  RxList<SavePharmaceuticalsLocationData> convinceData =
      <SavePharmaceuticalsLocationData>[].obs;
  RxList<String> transportModes = <String>[].obs;
  RxBool isSummary = false.obs;
}
