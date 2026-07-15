import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class JoinFocusPage extends StatelessWidget {
  const JoinFocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(),
              SizedBox(height: 24.h),
              Text(
                'Ethan is focusing.',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF1A1814),
                  height: 27.5 / 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Join him?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF1A1814),
                  height: 27.5 / 22,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Available for the next 8 minutes.',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFB5AFA5),
                  height: 18 / 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              _buildPrimaryButton(
                text: 'Tap to join',
                onTap: () {

                 Get.toNamed(Routes.modes);
                },
              ),
              SizedBox(height: 16.h),
              _buildSecondaryButton(
                text: 'Not now',
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: Stack(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1814),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'JK',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF7F4EE),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2.w,
            bottom: 2.w,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE67124),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(90.r),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFF141210),
          borderRadius: BorderRadius.circular(90.r),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF7F4EE),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(90.r),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(90.r),
          border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8278),
            ),
          ),
        ),
      ),
    );
  }
}
