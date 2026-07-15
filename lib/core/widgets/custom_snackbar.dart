import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final context = Get.overlayContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(bottom: 24.h, left: 24.w, right: 24.w),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isError ? AppColors.error : AppColors.primary,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isError ? Colors.white : AppColors.accent,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      style: AppTextStyles.helperText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
