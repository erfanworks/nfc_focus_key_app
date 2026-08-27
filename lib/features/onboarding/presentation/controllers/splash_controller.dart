import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    try {
      final hasCompletedOnboarding = await StorageServices.instance.hasCompletedOnboarding();

      if (!hasCompletedOnboarding) {
        Get.offAllNamed(Routes.onboarding);
        return;
      }

      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final isPaired = await StorageServices.instance.hasPairedKey();
      Get.offAllNamed(isPaired ? Routes.lock : Routes.pairing);
    } catch (e) {
      Get.offAllNamed(Routes.login);
    }
  }
}