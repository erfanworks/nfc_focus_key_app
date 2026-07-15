import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class LegalInformationPage extends StatelessWidget {
  const LegalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Get.parameters['title'] ?? 'Terms & Condition';
    final showDate = title == 'Terms & Condition';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(title),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Last Updated: October 24, 2026',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    _buildSectionTitle('1. Acceptance of Terms'),
                    SizedBox(height: 16.h),
                    _buildParagraph(
                        'By accessing or using FocusKey, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions. Our service is designed to promote deep work and presence; your use of the platform signifies your commitment to these digital quietude principles.'),
                    SizedBox(height: 16.h),
                    _buildParagraph(
                        'If you do not agree with any part of these terms, you are requested to discontinue use of the application immediately to preserve the integrity of your own focus.'),
                    SizedBox(height: 24.h),
                    _buildDivider(),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('2. User Conduct'),
                    SizedBox(height: 16.h),
                    _buildParagraph(
                        'FocusKey is a sanctuary for productivity. Users are expected to interact with the platform in a way that respects the intentional design of the software. This includes:'),
                    SizedBox(height: 16.h),
                    _buildBulletPoint(
                        'Respecting the focus intervals and avoiding attempts to bypass the "Quiet Mode" restrictions.'),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                        'Using the \'Friends\' feature solely for collaborative accountability and encouragement.'),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                        'Refraining from any behavior that compromises the platform\'s security or performance.'),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 8.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.back(),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: const Color(0xFF1A1814),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24.sp,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF1A1814),
                height: 1.0,
                letterSpacing: 0.4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1814),
        letterSpacing: 0.2.w,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF8A8278),
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h, left: 16.w, right: 8.w),
          child: Container(
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: Color(0xFF8A8278),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8278),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      color: const Color(0xFFE8E3DA),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
    );
  }
}
