import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';

import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class UserVerifyController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;
  final String email = Get.arguments ?? '';

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  void verifyAndSignIn() async {
    if (otpController.text.length == 6) {
      if (email.isEmpty) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Email not found. Please try signing up again.',
          isError: true,
        );
        return;
      }

      isLoading.value = true;
      try {
        final response = await ApiServices.instance.postServices(
          url: AppApiUrl.instance.verifyEmailOtp,
          body: {
            "email": email,
            "oneTimeCode": int.parse(otpController.text),
          },
        );

        if (response != null && response["success"] == true) {
          CustomSnackbar.show(
            title: 'Success',
            message: response["message"] ?? 'Account verified successfully!',
          );

          // Navigate to login screen
          Get.offAllNamed(Routes.login);
        }
      } finally {
        isLoading.value = false;
      }
    } else {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter the 6-digit code',
        isError: true,
      );
    }
  }

  void resendCode() async {
    if (email.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.resendOtp,
        body: {"email": email},
      );

      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: 'Sent',
          message: response["message"] ?? 'A new verification code has been sent to your email',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
