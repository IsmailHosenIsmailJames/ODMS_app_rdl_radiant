import 'package:get/get.dart';
import 'package:delivery/src/screens/home/delivery_remaining/models/deliver_remaining_model.dart';

class DeliveryRemainingController extends GetxController {
  RxString pageType = ''.obs;
  late DeliveryRemaining x;
  late Rx<DeliveryRemaining> deliveryRemaining;

  late Rx<DeliveryRemaining> constDeliveryRemaining;

  DeliveryRemainingController(this.x) {
    deliveryRemaining = x.obs;
    constDeliveryRemaining = x.obs;
  }
}
