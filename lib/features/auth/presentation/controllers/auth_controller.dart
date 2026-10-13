import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/services/push_notification_service.dart';
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
          Get.toNamed(
            Routes.userVerify,
            arguments: emailController.text.trim(),
          );
        }
      },
          (user) async {
        final isPaired = await StorageServices.instance.hasPairedKey();

        // [NUDGE-FIX] Retry FCM token sync now that an auth token exists.
        // init() at app startup runs before login, so its first attempt
        // may have failed silently without this.
        if (Get.isRegistered<PushNotificationService>()) {
          unawaited(
            Get.find<PushNotificationService>().resyncTokenAfterLogin(),
          );
        }

        CustomSnackbar.show(title: 'Success', message: 'Welcome ${user.name}');

        await Future.delayed(const Duration(milliseconds: 1000));

        if (isPaired) {
          Get.offAllNamed(Routes.lock);
        } else {
          Get.offAllNamed(Routes.pairing);
        }
      },

      //     (user) async {
      //   CustomSnackbar.show(title: 'Success', message: 'Welcome ${user.name}');
      //
      //   // --- TEMPORARY BYPASS FOR TESTING ---
      //   // await StorageServices.instance.savePairedKeyId("TEST_DEBUG_UID");
      //   // Get.offAllNamed(Routes.lock);
      //   // ------------------------------------
      //
      //   Get.offAllNamed(Routes.pairing); // Original flow
      // },
    );
  }
}