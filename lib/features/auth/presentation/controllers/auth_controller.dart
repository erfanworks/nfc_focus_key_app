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

        // --- TEMPORARY BYPASS FOR TESTING ---
        // await StorageServices.instance.savePairedKeyId("TEST_DEBUG_UID");
        // Get.offAllNamed(Routes.lock);
        // ------------------------------------

        Get.offAllNamed(Routes.pairing); // Original flow
      },
    );
  }

///// When My apps is fully ready i can uncomment this code.
  // Future<void> login() async {
  //   if (!formKey.currentState!.validate()) return;
  //
  //   isLoading.value = true;
  //   try {
  //     final result = await loginUseCase(
  //       LoginParams(
  //         email: emailController.text.trim(),
  //         password: passwordController.text,
  //       ),
  //     );
  //
  //     result.fold(
  //       (failure) {
  //         CustomSnackbar.show(
  //           title: 'Login Error',
  //           message: failure.message,
  //           isError: true,
  //         );
  //         // If account is not verified, navigate to verification screen
  //         if (failure.message.toLowerCase().contains('verify') ||
  //             failure.message.toLowerCase().contains('unverified')) {
  //           Get.toNamed(Routes.userVerify, arguments: emailController.text.trim());
  //         }
  //       },
  //       (user) async {
  //         CustomSnackbar.show(
  //           title: 'Welcome Back',
  //           message: 'Successfully signed in as ${user.name}',
  //         );
  //
  //         final isPaired = await StorageServices.instance.hasPairedKey();
  //
  //         // World-class experience: delay before transition
  //         await Future.delayed(const Duration(milliseconds: 1500));
  //
  //         if (isPaired) {
  //           Get.offAllNamed(Routes.lock);
  //         } else {
  //           Get.offAllNamed(Routes.pairing);
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     CustomSnackbar.show(
  //       title: 'Authentication Failed',
  //       message: 'Something went wrong during sign in. Please try again.',
  //       isError: true,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
