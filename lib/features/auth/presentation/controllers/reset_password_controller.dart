import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';

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

  void confirm() async {
    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Passwords do not match',
          isError: true,
        );
        return;
      }

      isLoading.value = true;
      // Simulate network call
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      CustomSnackbar.show(
        title: 'Success',
        message: 'Password reset successfully',
      );
      // Navigate to login after reset
      Get.offAllNamed(Routes.login);
    }
  }
}
