import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/storage_services.dart';

class ShieldPage extends StatelessWidget {
  const ShieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4A97D).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded, size: 30.sp, color: const Color(0xFFC4A97D)),
              ),
              SizedBox(height: 28.h),
              Text(
                'App Locked',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1814),
                ),
              ),
              SizedBox(height: 12.h),
              FutureBuilder<String>(
                future: StorageServices.instance.getCachedReminderMessage(),
                builder: (context, snapshot) {
                  final message = (snapshot.data?.isNotEmpty ?? false)
                      ? snapshot.data!
                      : 'You pity the moth for confusing a lamp for the moon, yet here you are confusing a screen for the world…';
                  return Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 14.sp, color: const Color(0xFF8A8278), height: 1.5),
                  );
                },
              ),
              SizedBox(height: 8.h),
              Text(
                'Open Focus Key and scan your NFC key to unlock.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13.sp, color: const Color(0xFFB5AFA5)),
              ),
              SizedBox(height: 36.h),
              GestureDetector(
                onTap: () => SystemNavigator.pop(),
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1814),
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Center(
                    child: Text(
                      'Got it',
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF7F4EE),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}