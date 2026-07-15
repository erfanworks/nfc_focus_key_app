import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class EmptyWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyWidget({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.w, color: AppColors.hint),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.hint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
