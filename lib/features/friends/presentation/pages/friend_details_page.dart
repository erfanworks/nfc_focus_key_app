import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/friends_controller.dart';

class FriendDetailsPage extends StatelessWidget {
  const FriendDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the friend argument
    final FriendModel friend = Get.arguments as FriendModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildProfile(friend),
              SizedBox(height: 32.h),
              _buildCards(),
              SizedBox(height: 32.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.back(),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: const Color(0xFF1A1814),
          ),
          SizedBox(width: 8.w),
          Text(
            'Details',
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
    );
  }

  Widget _buildProfile(FriendModel friend) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: friend.isDarkAvatar
                ? const Color(0xFF1A1814)
                : const Color(0xFFE8E3DA),
          ),
          child: Center(
            child: Text(
              friend.initials,
              style: GoogleFonts.dmSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: friend.isDarkAvatar
                    ? const Color(0xFFF7F4EE)
                    : const Color(0xFF1A1814),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          friend.name,
          style: GoogleFonts.dmSans(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1814),
            height: 35 / 28,
            letterSpacing: 0.56,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: friend.isFocusing
                    ? const Color(0xFFE67124)
                    : const Color(0xFF8A8278),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              friend.status,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF8A8278),
                height: 16.5 / 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBE2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '8.5h',
                    style: GoogleFonts.dmSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1814),
                      height: 36 / 24,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'TOGETHER THIS WEEK',
                    style: GoogleFonts.dmSans(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8278),
                      height: 13.5 / 9,
                      letterSpacing: 0.36,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBE2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStreakDot('M', true),
                      SizedBox(width: 4.w),
                      _buildStreakDot('T', true),
                      SizedBox(width: 4.w),
                      _buildStreakDot('W', true),
                      SizedBox(width: 4.w),
                      _buildStreakDot('T', true),
                      SizedBox(width: 4.w),
                      _buildStreakDot('F', false),
                      SizedBox(width: 4.w),
                      _buildStreakDot('S', false),
                      SizedBox(width: 4.w),
                      _buildStreakDot('S', false),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    '4 DAY STREAK',
                    style: GoogleFonts.dmSans(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8278),
                      height: 13.5 / 9,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDot(String day, bool isDone) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? const Color(0xFF1A1814) : const Color(0xFFE0DBD0),
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.dmSans(
            fontSize: 8.sp,
            fontWeight: FontWeight.w500,
            color: isDone ? const Color(0xFFF7F4EE) : const Color(0xFF8A8278),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1814),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: Text(
                'Send a nudge',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF7F4EE),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
            ),
            child: Center(
              child: Text(
                'Remove Partner',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE67124), // or 0xFFD95D24
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
