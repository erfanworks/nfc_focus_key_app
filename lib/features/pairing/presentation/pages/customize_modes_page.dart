import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/customize_modes_controller.dart';

class CustomizeModesPage extends GetView<CustomizeModesController> {
  const CustomizeModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              const Spacer(),

              // Title: "Customize your modes"
              // Cormorant Garamond, w600, 36px, lh 120%, ls 1.5%, #1A1814
              Text(
                AppStrings.customizeModesTitle,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1814),
                  height: 1.2,
                  letterSpacing: 36.sp * 0.015,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Subtitle: "Remember what deserves your focus"
              // DM Sans, w400, 15px, lh 24px, ls 0, #8A8278
              Text(
                AppStrings.customizeModesSubtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                  height: 1.5,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Continue Button — border 1px #C4A97D, radius 28, height 52
              GestureDetector(
                onTap: controller.onContinue,
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: const Color(0xFFC4A97D),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.continueBtn,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8278),
                        height: 1.0,
                      ),
                    ),
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
