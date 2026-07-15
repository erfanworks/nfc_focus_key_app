import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        background: AppColors.background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents the color tint when scrolling
        iconTheme: const IconThemeData(color: AppColors.textDark),
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading2,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
