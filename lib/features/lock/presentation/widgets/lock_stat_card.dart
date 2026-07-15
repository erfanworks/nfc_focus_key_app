import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LockStatCard extends StatelessWidget {
  final String title;
  final RxString value;

  const LockStatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 88.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8278),
              letterSpacing: 1.0,
              height: 15.0 / 10.0,
            ),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            return Text(
              value.value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1814),
              ),
            );
          }),
        ],
      ),
    );
  }
}
