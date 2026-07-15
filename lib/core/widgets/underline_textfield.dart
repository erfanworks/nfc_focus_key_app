import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UnderlineTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const UnderlineTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.helperText.copyWith(
            letterSpacing: 1.2,
            fontSize: 12.sp,

            fontWeight: FontWeight.w500,

            color: Color(0xFF8A8278),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: AppTextStyles.body.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.hint),
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            isDense: true,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textFieldBorder),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textFieldBorder),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
