import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> signUp() async {
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
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.singUp,
        body: {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "role": "USER",
        },
      );

      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: 'Account Created',
          message: response["message"] ?? 'Please verify your email to continue.',
        );
        
        // World-class delay for success feedback
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.toNamed(Routes.userVerify, arguments: emailController.text.trim());
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: response?["message"] ?? 'Something went wrong. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Failed to connect to server. Please check your internet.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
