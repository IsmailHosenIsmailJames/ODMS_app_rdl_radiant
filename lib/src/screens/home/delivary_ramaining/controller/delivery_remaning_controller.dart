import 'package:get/get.dart';
import 'package:rdl_radiant/src/screens/home/delivary_ramaining/models/deliver_remaing_model.dart';

class DeliveryRemaningController extends GetxController {
  RxString pageType = "".obs;
  late DeliveryRemaing x;
  late Rx<DeliveryRemaing> deliveryRemaing;

  late Rx<DeliveryRemaing> constDeliveryRemaing;

  DeliveryRemaningController(this.x) {
    deliveryRemaing = x.obs;
    constDeliveryRemaing = x.obs;
  }
}
