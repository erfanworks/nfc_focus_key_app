import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalFocusCard extends StatelessWidget {
  final String totalTime;
  final String sinceDate;

  const TotalFocusCard({
    super.key,
    required this.totalTime,
    required this.sinceDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 135.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF7F4EE).withValues(alpha: 0.05),
            offset: Offset.zero,
            blurRadius: 40.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TOTAL FOCUS TIME',
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8278),
              height: 1.5,
              letterSpacing: 0.6.w,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            totalTime,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF1A1814),
              height: 1.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            sinceDate,
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFFB5AFA5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
