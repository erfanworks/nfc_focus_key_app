import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/pairing_controller.dart';

class PairingPage extends GetView<PairingController> {
  const PairingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force controller instantiation to trigger auto-navigation onInit/onReady
    final _ = controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.focusTitle,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1814),
                    height: 26.0 / 40.0,
                    letterSpacing: 40.sp * 0.015,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Subtitle "on what truly matters to you"
                Text(
                  AppStrings.focusSubtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
