import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final int? maxLines;
  final String? helperText;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.maxLines = 1,
    this.helperText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: AppTextStyles.body,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.textFieldHint,
            counterText: '', // Hide default counter
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.textFieldBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.textFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        if (helperText != null || maxLength != null) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (helperText != null)
                Text(helperText!, style: AppTextStyles.helperText)
              else
                const SizedBox(),
              if (maxLength != null)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/$maxLength',
                      style: AppTextStyles.helperText,
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}
