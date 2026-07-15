import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class PairedSuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Auto-navigate to "Let's unlock" screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Get.offNamed(Routes.letsUnlock);
    });
  }
}
