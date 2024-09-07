import 'package:get/get.dart';

import 'dash_board_model.dart';

class DashboardControllerGetx extends GetxController {
  Rx<DashBoardModel> dashboardData = DashBoardModel().obs;
}
