import 'dart:io';

import 'package:get/get.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../routes/app_routes.dart';

class PairedSuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();

    // Proactively request iOS Screen Time authorization after successful pairing
    if (Platform.isIOS) {
      _requestIOSPermissions();
    }

    // Auto-navigate to "Let's unlock" screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Get.offNamed(
          Platform.isAndroid ? Routes.enablePermissions : Routes.letsUnlock,
      );
    });
  }

  Future<void> _requestIOSPermissions() async {
    try {
      final native = Get.find<AppLockNativeService>();
      final isAuthorized = await native.isIOSAuthorized();
      if (!isAuthorized) {
        // This will trigger the Apple FamilyControls system dialog
        await native.requestIOSAuthorization();
      }
    } catch (_) {}
  }
}
