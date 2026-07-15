import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/notification_item.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('TODAY'),
                    SizedBox(height: 12.h),
                    _buildNotificationGroup(
                      backgroundColor: const Color(0xFFF0EBE2),
                      items: [
                        NotificationItemModel(
                          avatarInitials: 'E',
                          title: 'Ethan started a focus session',
                          subtitle: '10 minutes ago • Tap to join him',
                          hasUnreadDot: true,
                          trailingWidget: _buildJoinButton(),
                        ),
                        NotificationItemModel(
                          avatarInitials: 'J',
                          title: 'Jake sent you a nudge',
                          subtitle: '2 hours ago',
                          hasUnreadDot: false,
                          trailingText: '14:20',
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('YESTERDAY'),
                    SizedBox(height: 12.h),
                    _buildNotificationGroup(
                      backgroundColor: const Color(
                        0xFFFDF8F7,
                      ), // slightly tinted white
                      items: [
                        NotificationItemModel(
                          avatarInitials: 'S',
                          title: 'Sara accepted your partner request',
                          subtitle: 'Yesterday, 18:45',
                          hasUnreadDot: false,
                          trailingText: 'View',
                          trailingTextColor: const Color(0xFF8A8278),
                        ),
                        NotificationItemModel(
                          avatarInitials: 'T',
                          title: 'Tim started a session',
                          subtitle: 'Yesterday, 09:12 • Session expired',
                          hasUnreadDot: false,
                          trailingText: 'Expired',
                          isExpired: true,
                        ),
                      ],
                    ),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
      child: GestureDetector(
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
              'Notification',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF645D54),
        letterSpacing: 1.4,
        height: 14 / 14,
      ),
    );
  }

  Widget _buildNotificationGroup({
    required Color backgroundColor,
    required List<NotificationItemModel> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFFE8E3DA),
          height: 1.0,
          thickness: 1.0,
        ),
        itemBuilder: (context, index) {
          return NotificationItem(data: items[index]);
        },
      ),
    );
  }

  Widget _buildJoinButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.joinFocus),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(90.r),
        ),
        child: Text(
          'Join',
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF7F4EE),
          ),
        ),
      ),
    );
  }
}
