import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/underline_textfield.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),

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

                // Welcome Texts
                Text(AppStrings.welcomeBack, style: AppTextStyles.heading1),
                SizedBox(height: 8.h),
                Text(AppStrings.signInToContinue, style: AppTextStyles.body),
                SizedBox(height: 48.h),

                // Email Field
                UnderlineTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: controller.emailController,
                  validator: Validators.emailValidator,
                ),
                SizedBox(height: 32.h),

                // Password Field
                UnderlineTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: controller.passwordController,
                  obscure: true,
                  validator: Validators.passwordValidator,
                ),
                SizedBox(height: 12.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '/forgot-password',
                      ); // Using string fallback or import Routes
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.helperText.copyWith(
                        color: Color(0xFF8A8278),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 60),

                // Sign In Button
                Obx(
                  () => PrimaryButton(
                    label: AppStrings.signIn,
                    onTap: controller.login,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: 24.h),

                // Create Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.newHere,
                      style: AppTextStyles.helperText.copyWith(fontSize: 13.sp),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.signup);
                      },
                      child: Text(
                        AppStrings.createAccount,
                        style: AppTextStyles.helperText.copyWith(
                          color: AppColors.accent,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
