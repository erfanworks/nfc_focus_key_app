import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendCode() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.forgotPassword,
        body: {"email": emailController.text.trim()},
      );

      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: 'Success!',
          message: response["message"] ?? 'Reset code sent to your email.',
        );
        
        // Brief delay for feedback
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.toNamed(Routes.emailVerify, arguments: emailController.text.trim());
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: response?["message"] ?? 'Account not found or server error.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Issue',
        message: 'Could not reach server. Please check your connection.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
