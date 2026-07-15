import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/friends_controller.dart';

class AddPartnerPage extends StatelessWidget {
  AddPartnerPage({super.key});

  final FriendsController controller = Get.find<FriendsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildSearchInput(),
              SizedBox(height: 8.h),
              Text(
                'handles are lowercase, 3-15 characters',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFB5AFA5),
                  height: 16.5 / 11,
                  letterSpacing: -0.28.w,
                ),
              ),
              SizedBox(height: 32.h),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Column(
                      children: controller.demoFriends
                          .map(
                            (friend) => _buildUserItem(
                              friend.name,
                              friend.handle,
                              friend.initials,
                              friend.isDarkAvatar,
                              friend,
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 48.h),
                    _buildContactsSection(),
                  ],
                ),
              ),
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
            'Add Partner',
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

  Widget _buildSearchInput() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, size: 20.sp, color: const Color(0xFF8A8278)),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by email...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF8A8278),
                ),
              ),
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1814),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(
    String name,
    String handle,
    String initials,
    bool isDarkAvatar,
    FriendModel friend,
  ) {
    return Container(
      height: 69.h,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8E3DA), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkAvatar
                  ? const Color(0xFF1A1814)
                  : const Color(0xFFE8E3DA),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDarkAvatar
                      ? const Color(0xFFF7F4EE)
                      : const Color(0xFF1A1814),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1814),
                    height: 16.25 / 14,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 0.h),
                Text(
                  handle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF8A8278),
                    height: 16.5 / 11,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final isAdded = controller.isFriendAdded(friend.id);
            return InkWell(
              onTap: () {
                if (!isAdded) {
                  controller.addFriend(friend);
                }
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isAdded
                        ? const Color(0xFF8A8278)
                        : const Color(0xFF1A1814),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  isAdded ? 'Added' : 'Add',
                  style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: isAdded
                        ? const Color(0xFF8A8278)
                        : const Color(0xFF1A1814),
                    height: 15 / 10,
                    letterSpacing: 0,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactsSection() {
    return Column(
      children: [
        Text(
          'Or add from contacts',
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8A8278),
            height: 21 / 14,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Only shows contacts who have FocusKey',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF8A8278),
            height: 16.5 / 11,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 24.h),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
            ),
            child: Center(
              child: Text(
                'Allow contacts access',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1814),
                  height: 18 / 12,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
