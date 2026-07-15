import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class KeyDetailCard extends StatelessWidget {
  const KeyDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildRow('Paired on', 'Apr 1, 2026', showBorder: true),
          _buildRow('Total unlocks', '142', showBorder: true),
          _buildRow('NFC chip', 'NTAG216', showBorder: false),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {required bool showBorder}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE8E3DA), width: 1),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              height: 21 / 14,
              letterSpacing: 0,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8A8278),
              height: 19.5 / 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
