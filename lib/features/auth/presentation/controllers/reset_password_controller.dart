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
        title: 'Error',
        message: 'Passwords do not match',
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
          title: 'Success',
          message: response["message"] ?? 'Password reset successfully',
        );
        Get.offAllNamed(Routes.login);
      }
    } finally {
      isLoading.value = false;
    }
  }
}