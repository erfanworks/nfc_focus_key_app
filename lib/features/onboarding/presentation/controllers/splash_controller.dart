import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 0));

    Get.offAllNamed(Routes.onboarding);
  }
}
