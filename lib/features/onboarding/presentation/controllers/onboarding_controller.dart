import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingController extends GetxController {
  final RxInt currentScreen = 1.obs;
  final RxInt hours = 0.obs;

  void setHours(int value) {
    hours.value = value;
  }

  void nextScreen() {
    if (currentScreen.value == 1) {
      currentScreen.value = 2;
    } else if (currentScreen.value == 2) {
      currentScreen.value = 3;
    }
  }

  void finishOnboarding() {
    StorageServices.instance.setCompletedOnboarding();
    Get.offAllNamed(Routes.focusMessage);
  }
}
