import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 52.h),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90.r),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24.h,
              width: 24.h,
              child: const CircularProgressIndicator(
                color: AppColors.textLight,
                strokeWidth: 2.5,
              ),
            )
          : Text(label, style: AppTextStyles.button),
    );
  }
}
