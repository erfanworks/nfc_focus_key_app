import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void signUp() async {
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
      // Simulate network register call
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      CustomSnackbar.show(
        title: 'Success',
        message: 'Verification code sent to your email!',
      );

      // Navigate to user verification route
      Get.toNamed(Routes.userVerify);
    }
  }
}
