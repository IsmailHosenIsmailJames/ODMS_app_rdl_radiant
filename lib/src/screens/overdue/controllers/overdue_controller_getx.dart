import 'package:get/get.dart';
import 'package:delivery/src/screens/overdue/models/overdue_response_model.dart';

class OverdueControllerGetx extends GetxController {
  RxDouble previousDue = 0.0.obs;
  RxDouble collectAmount = 0.0.obs;
  RxDouble currentDue = 0.0.obs;

  late OverdueResponseModel x;
  late Rx<OverdueResponseModel> overdueRemaining;

  late Rx<OverdueResponseModel> constOverdueRemaining;

  OverdueControllerGetx(this.x) {
    overdueRemaining = x.obs;
    constOverdueRemaining = x.obs;
  }
}

class OverdueDocsListController extends GetxController {
  RxList<BillingDoc> docsList = (<BillingDoc>[]).obs;
}
