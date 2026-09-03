import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/underline_textfield.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/signup_controller.dart';
import '../../../../routes/app_routes.dart';

class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),



                  // Title
                  Text(
                    AppStrings.createAccountTitle,
                    style: AppTextStyles.heading1,
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(AppStrings.dataStaysOnDevice, style: AppTextStyles.body),
                  SizedBox(height: 48.h),

                  // Name Field
                  UnderlineTextField(
                    label: 'NAME',
                    hint: 'Enter your name',
                    controller: controller.nameController,
                    validator: Validators.nameValidator,
                  ),
                  SizedBox(height: 32.h),
                  UnderlineTextField(
                    label: 'EMAIL',
                    hint: 'you@example.com',
                    controller: controller.emailController,
                    validator: Validators.emailValidator,
                  ),
                  SizedBox(height: 32.h),

                  // Password Field
                  UnderlineTextField(
                    label: 'PASSWORD',
                    hint: '••••••••',
                    controller: controller.passwordController,
                    obscure: true,
                    validator: Validators.passwordValidator,
                  ),
                  SizedBox(height: 32.h),

                  // Confirm Password Field
                  UnderlineTextField(
                    label: 'CONFIRM PASSWORD',
                    hint: '••••••••',
                    controller: controller.confirmPasswordController,
                    obscure: true,
                    validator: Validators.passwordValidator,
                  ),
                  SizedBox(height: 48.h),

                  // Continue Button
                  Obx(
                    () => PrimaryButton(
                      label: AppStrings.continueBtn,
                      onTap: controller.signUp,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Already have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.helperText.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offAllNamed(Routes.login);
                        },
                        child: Text(
                          AppStrings.signIn,
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
      ),
    );
  }
}
