import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';

class LockStatusSection extends StatelessWidget {
  final LockController controller;
  final bool isLocked;

  const LockStatusSection({
    super.key,
    required this.controller,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: isLocked,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                controller.formattedSessionTime,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1814),
                  height: 60.0 / 40.0,
                  letterSpacing: -1.0.w,
                ),
              ),
            ),
          ),
          Text(
            controller.isOnBreak.value
                ? 'On Break'
                : (isLocked ? 'Locked' : 'Unlocked'),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              height: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.isOnBreak.value
                ? 'Apps are available now'
                : (isLocked
                      ? 'Tap your key to unlock'
                      : 'Hold to lock - or tap your key.'),
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8A8278),
              height: 18.0 / 14.0,
            ),
          ),
        ],
      );
    });
  }
}
