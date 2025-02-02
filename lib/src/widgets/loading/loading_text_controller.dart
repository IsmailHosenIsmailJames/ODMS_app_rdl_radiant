import 'package:get/get.dart';

class LoadingTextController extends GetxController {
  RxString loadingText = 'Loading...'.obs;
  RxInt currentState =
      0.obs; // 0 means process on going, 1 means success, -1 means error
}
