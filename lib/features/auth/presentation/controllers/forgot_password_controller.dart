import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void sendCode() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // Simulate network call
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      CustomSnackbar.show(
        title: 'Success',
        message: 'Reset code sent to your email',
      );
      // Navigate to email verification screen
      Get.toNamed(Routes.emailVerify);
    }
  }
}
