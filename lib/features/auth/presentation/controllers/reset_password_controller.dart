import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> confirm() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.show(
        title: 'Validation Error',
        message: 'Passwords do not match. Please re-enter.',
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    try {
      final resetToken = await StorageServices.instance.getResetToken();

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.resetPassword,
        body: {
          "newPassword": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
        },
        options: Options(headers: {"resettoken": resetToken}),
      );

      if (response != null && response["success"] == true) {
        await StorageServices.instance.clearResetToken();
        CustomSnackbar.show(
          title: 'All Done!',
          message: response["message"] ?? 'Password has been reset successfully.',
        );
        
        // Premium transition delay
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(Routes.login);
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: response?["message"] ?? 'Failed to reset password. Link may be expired.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Could not connect to server. Please try again.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
