import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/user_verify_controller.dart';

class UserVerifyPage extends GetView<UserVerifyController> {
  const UserVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 56.h,
      textStyle: AppTextStyles.heading1.copyWith(fontSize: 24.sp),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
    );

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),

              // Top-left Icon
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/lock_only.png',
                  width: 60.w,
                  height: 62.w,
                ),
              ),
              SizedBox(height: 32.h),

              // Title
              Text(AppStrings.checkYourEmail, style: AppTextStyles.heading1),
              SizedBox(height: 8.h),

              // Subtitle
              Text(AppStrings.weSentCode, style: AppTextStyles.body),
              SizedBox(height: 40.h),

              // Pinput for 6-digit code
              Pinput(
                length: 6,
                controller: controller.otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                showCursor: true,
                onCompleted: (pin) => controller.verifyAndSignIn(),
              ),
              SizedBox(height: 40.h),

              // Helper text
              Text(
                AppStrings.enterCodeToVerify,
                style: AppTextStyles.helperText,
              ),
              SizedBox(height: 24.h),

              // Sign In Button
              Obx(
                () => PrimaryButton(
                  label: AppStrings.signIn,
                  onTap: controller.verifyAndSignIn,
                  isLoading: controller.isLoading.value,
                ),
              ),
              SizedBox(height: 24.h),

              // Resend TextButton
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: controller.resendCode,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.resend,
                    style: AppTextStyles.helperText.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
