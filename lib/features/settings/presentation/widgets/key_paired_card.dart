import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class KeyPairedCard extends StatelessWidget {
  const KeyPairedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Key icon box — 56×56, radius 12, color #2D6A4F at 10%
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.vpn_key_outlined,
                size: 24.sp,
                color: const Color(0xFF2D6A4F),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // PAIRED label — DM Sans 500, 11px, green, uppercase, spacing 0.66
          Text(
            'PAIRED',
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D6A4F),
              letterSpacing: 0.66.w,
              height: 16.5 / 11,
            ),
          ),
          SizedBox(height: 8.h),

          // Focus Key #001 — Cormorant Garamond Light 300, 22px
          Text(
            'Focus Key #001',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF1A1814),
              height: 33 / 22,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 4.h),

          // Last used — DM Sans 300, small, grey
          Text(
            'Last used · Today, 9:41 AM',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8A8278),
            ),
          ),
        ],
      ),
    );
  }
}
