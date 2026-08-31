import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/underline_textfield.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20.w,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),

                // Top-left Icon
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Image.asset(
                //     'assets/images/lock_only.png',
                //     width: 60.w,
                //     height: 62.w,
                //   ),
                // ),
                SizedBox(height: 32.h),

                // Title
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: AppTextStyles.heading1,
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Text(AppStrings.forgotPasswordDesc, style: AppTextStyles.body),
                SizedBox(height: 48.h),

                // Email Field
                UnderlineTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: controller.emailController,
                  validator: Validators.emailValidator,
                ),
                SizedBox(height: 48.h),

                // Send Code Button
                Obx(
                  () => PrimaryButton(
                    label: AppStrings.sendCode,
                    onTap: controller.sendCode,
                    isLoading: controller.isLoading.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
