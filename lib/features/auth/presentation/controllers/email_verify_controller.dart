import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class EmailVerifyController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;
  final isResending = false.obs;

  late final String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments is String ? Get.arguments as String : '';
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  Future<void> verify() async {
    if (otpController.text.length != 6) {
      CustomSnackbar.show(
        title: 'Incomplete Code',
        message: 'Please enter the 6-digit verification code.',
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
          title: 'Success!',
          message: response["message"] ?? 'Code verified successfully.',
        );

        final resetToken = response["data"];
        if (resetToken is String && resetToken.isNotEmpty) {
          await StorageServices.instance.setResetToken(resetToken);
        }

        // Premium feel transition delay
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(Routes.resetPassword);
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: response?["message"] ?? 'Invalid verification code. Try again.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Failed to verify. Please check your internet connection.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    isResending.value = true;
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.resendOtp,
        body: {"email": email},
      );

      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: 'Code Sent',
          message: response["message"] ?? 'A new verification code has been sent.',
        );
      } else {
        CustomSnackbar.show(
          title: 'Failed',
          message: response?["message"] ?? 'Could not resend code. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Network Error',
        message: 'Please check your connection and try again.',
        isError: true,
      );
    } finally {
      isResending.value = false;
    }
  }
}
