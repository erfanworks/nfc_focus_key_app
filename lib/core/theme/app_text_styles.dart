import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.cormorantGaramond(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400, // Regular
    height: 36.4 / 28.0,
    color: AppColors.textDark,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle body = GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300, // Light
    height: 22.75 / 14.0,
    color: AppColors.textBody,
  );

  static TextStyle bodyLight = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.hint,
  );

  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400, // Regular
    height: 22.5 / 15.0,
    color: AppColors.textLight,
  );
  static TextStyle helperText = GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: AppColors.textHelper,
  );

  static TextStyle textFieldHint = GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 24.0 / 14.0,
    color: AppColors.textFieldHint,
  );
}
