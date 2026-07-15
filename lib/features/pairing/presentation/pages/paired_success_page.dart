import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/paired_success_controller.dart';

class PairedSuccessPage extends GetView<PairedSuccessController> {
  const PairedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force controller instantiation to trigger auto-navigation onReady
    final _ = controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circle: 120×120, radius 60, border 1.5px #C4A97D
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC4A97D),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: const Color(0xFFC4A97D),
                      size: 32.w,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // "Paired" — Cormorant Garamond, w500, 32px, lh 26px, ls 1.5%, #1A1814
                Text(
                  AppStrings.pairedTitle,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1814),
                    height: 26.0 / 32.0,
                    letterSpacing: 32.sp * 0.015,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),

                // "You're ready to begin" — DM Sans, w400, 14px, #8A8278
                Text(
                  AppStrings.readyToBegin,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    height: 18.0 / 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
