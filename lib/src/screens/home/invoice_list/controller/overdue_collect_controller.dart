import 'package:get/get.dart';

class OverdueCollectController extends GetxController {
  RxDouble previousDue = 0.0.obs;
  RxDouble collectAmount = 0.0.obs;
  RxDouble currentDue = 0.0.obs;
}
