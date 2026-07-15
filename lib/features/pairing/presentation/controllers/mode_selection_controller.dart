import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class ModeSelectionController extends GetxController {
  /// Called when the user taps the Continue button.
  /// Navigates to the final lock/dashboard screen.
  void onContinue() {
    Get.offAllNamed(Routes.lock);
  }

  /// Example method that could be used to handle icon selection.
  /// Returns the selected mode index (0‑based).
  final RxInt selectedMode = 0.obs;
  void selectMode(int index) => selectedMode.value = index;
}
