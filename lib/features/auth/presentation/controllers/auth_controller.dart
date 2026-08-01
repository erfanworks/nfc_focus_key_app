import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
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
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final result = await loginUseCase(
      LoginParams(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );

    isLoading.value = false;

    result.fold(
      (failure) {
        CustomSnackbar.show(
          title: 'Error',
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
        CustomSnackbar.show(title: 'Success', message: 'Welcome ${user.name}');
        
        // // --- TEMPORARY BYPASS FOR TESTING ---
        // await StorageServices.instance.savePairedKeyId("TEST_DEBUG_UID");
        // Get.offAllNamed(Routes.lock);
        // // ------------------------------------
        
        Get.offAllNamed(Routes.pairing); // Original flow
      },
    );
  }
}
