import 'dart:io';

import 'package:get/get.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../settings/presentation/controllers/key_status_controller.dart';

class PairedSuccessController extends GetxController {
  @override
  void onReady() {
    super.onReady();

    if (Get.arguments is Map && Get.arguments['fromSettings'] == true) {
      if (Get.isRegistered<KeyStatusController>()) {
        Get.find<KeyStatusController>().loadPairedStatus();
      }
    }

    // Proactively request iOS Screen Time authorization after successful pairing
    if (Platform.isIOS) {
      _requestIOSPermissions();
    }

    // Auto-navigate to "Let's unlock" screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.arguments is Map && Get.arguments['fromSettings'] == true) {
        Get.back();
      } else {
        Get.offNamed(
          Platform.isAndroid ? Routes.enablePermissions : Routes.letsUnlock,
        );
      }
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
