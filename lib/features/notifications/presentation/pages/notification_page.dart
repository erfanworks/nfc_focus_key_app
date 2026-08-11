import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controller/notification_controller.dart';
import '../widgets/notification_item.dart';

class NotificationPage extends GetView<NotificationController> {
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groups = controller.groupedNotifications;

                if (groups.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications yet',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: const Color(0xFF8A8278),
                      ),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 100) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final group in groups) ...[
                          _buildSectionHeader(group.label),
                          SizedBox(height: 12.h),
                          _buildNotificationGroup(group: group),
                          SizedBox(height: 32.h),
                        ],
                        if (controller.isLoadingMore.value)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                );
              }),
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

  Widget _buildNotificationGroup({required NotificationGroup group}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: group.items.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color(0xFFE8E3DA),
          height: 1.0,
          thickness: 1.0,
        ),
        itemBuilder: (context, index) {
          final n = group.items[index];
          return NotificationItem(
            data: NotificationItemModel(
              avatarInitials: n.title.isNotEmpty ? n.title[0] : '?',
              title: n.title,
              subtitle: n.text,
              hasUnreadDot: !n.read,
              trailingWidget: n.isJoinableNudge ? _buildJoinButton(n) : null,
              trailingText: n.isJoinableNudge
                  ? null
                  : n.isExpiredNudge
                  ? 'Expired'
                  : null,
              isExpired: n.isExpiredNudge,
            ),
            onTap: () => controller.markAsRead(n.id),
          );
        },
      ),
    );
  }

  Widget _buildJoinButton(NotificationModel n) {
    return GestureDetector(
      onTap: () {
        final nudgeId = n.referenceId?['_id'] as String?;
        final modeId = n.referenceId?['modeId'] as String?;

        if (nudgeId == null || modeId == null) {
          CustomSnackbar.show(
            title: 'Error',
            message: 'This invitation is no longer valid',
            isError: true,
          );
          return;
        }

        controller.markAsRead(n.id);
        Get.toNamed(
          Routes.joinFocus,
          arguments: {'nudgeId': nudgeId, 'modeId': modeId},
        );
      },
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