import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class BreakController extends GetxController {
  final breaksPerDay = RxnInt(2); // null = "None"
  final breakLengthMinutes = 5.obs;

  final breakLengthOptions = [1, 3, 5, 10];

  void selectBreaksPerDay(int? value) {
    breaksPerDay.value = value;
  }

  void selectBreakLength(int minutes) {
    breakLengthMinutes.value = minutes;
  }

  void onContinue() {
    if (Get.previousRoute == Routes.customizeModes) {
      Get.toNamed(Routes.modes);
    } else {
      Get.back();
    }
  }
}
