import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class LetsUnlockController extends GetxController {
  void onContinue() {
    Get.offNamed(Routes.customizeModes);
  }
}
