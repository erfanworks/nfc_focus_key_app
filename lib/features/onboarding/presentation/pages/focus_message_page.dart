import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../controllers/focus_message_controller.dart';

class FocusMessagePage extends GetView<FocusMessageController> {
  const FocusMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),

              Text(
                AppStrings.focusMessageTitle,
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Text(
                AppStrings.focusMessageDesc,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              CustomTextField(
                controller: controller.messageController,
                hint: AppStrings.focusMessageHint,
                maxLines: 5,
                maxLength: 120,
                helperText: AppStrings.focusMessageHelper,
              ),

              const Spacer(),

              PrimaryButton(
                label: AppStrings.saveMessage,
                onTap: controller.saveMessage,
              ),

              SizedBox(height: 16.h),

              TextButton(
                onPressed: controller.skip,
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                ),
                child: Text(
                  AppStrings.skipForNow,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
