import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final result = await loginUseCase(
        LoginParams(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      result.fold(
        (failure) {
          CustomSnackbar.show(
            title: 'Login Error',
            message: failure.message,
            isError: true,
          );
          // If account is not verified, navigate to verification screen
          if (failure.message.toLowerCase().contains('verify') || 
              failure.message.toLowerCase().contains('unverified')) {
            Get.toNamed(Routes.userVerify, arguments: emailController.text.trim());
          }
        },
        (user) async {
          CustomSnackbar.show(
            title: 'Welcome Back', 
            message: 'Successfully signed in as ${user.name}',
          );
          
          // World-class experience: delay before transition
          await Future.delayed(const Duration(milliseconds: 1500));
          Get.offAllNamed(Routes.pairing); 
        },
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'Authentication Failed',
        message: 'Something went wrong during sign in. Please try again.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
