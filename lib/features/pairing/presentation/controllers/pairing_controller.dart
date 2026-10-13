import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';

class PairingController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Auto-navigate to pairing scanner after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Get.offNamed(Routes.pairingScanner, arguments: Get.arguments);
    });
  }
}
