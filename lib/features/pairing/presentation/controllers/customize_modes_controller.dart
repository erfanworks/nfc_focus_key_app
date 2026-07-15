import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class CustomizeModesController extends GetxController {
  void onContinue() {
    Get.toNamed(Routes.takeBreak);
  }
}
