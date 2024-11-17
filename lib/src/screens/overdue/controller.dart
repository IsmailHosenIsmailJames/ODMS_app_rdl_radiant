import 'package:get/get.dart';
import 'package:odms/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';

class OverdueCollectController extends GetxController {
  RxDouble previousDue = 0.0.obs;
  RxDouble collectAmount = 0.0.obs;
  RxDouble currentDue = 0.0.obs;

  late DeliveryRemaining x;
  late Rx<DeliveryRemaining> overdueRemaining;

  late Rx<DeliveryRemaining> constOverdueRemaining;

  OverdueCollectController(this.x) {
    overdueRemaining = x.obs;
    constOverdueRemaining = x.obs;
  }
}

class OverdueInvoiceListController extends GetxController {
  RxList<InvoiceList> invoiceList = (<InvoiceList>[]).obs;
}
