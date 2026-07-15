import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class EmailVerifyController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  void verify() async {
    if (otpController.text.length == 6) {
      isLoading.value = true;
      // Simulate network call
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      CustomSnackbar.show(
        title: 'Success',
        message: 'Email verified successfully',
      );
      // Navigate to reset password
      Get.offAllNamed(Routes.resetPassword);
    } else {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter the 6-digit code',
        isError: true,
      );
    }
  }

  void resendCode() {
    CustomSnackbar.show(
      title: 'Sent',
      message: 'A new code has been sent to your email',
    );
  }
}
