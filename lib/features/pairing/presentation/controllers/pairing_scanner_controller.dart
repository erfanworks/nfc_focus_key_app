import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class PairingScannerController extends GetxController {
  final isPairing = false.obs;
  final statusMessage =
      'Hold your key against the front camera of your phone'.obs;

  @override
  void onReady() {
    super.onReady();
    startPairing();
  }

  void startPairing() async {
    if (isPairing.value) return;

    isPairing.value = true;
    statusMessage.value =
        'Hold your key against the front camera of your phone';

    // Simulate pairing process for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    isPairing.value = false;
    statusMessage.value = 'Key Found!';

    // Trigger vibration to notify the user
    await HapticFeedback.vibrate();

    // Save a mock paired key ID to local storage
    await StorageService.savePairedKeyId("MOCK_FOCUS_KEY_ID");

    // Navigate to paired success screen
    Get.offNamed(Routes.paired);
  }
}
