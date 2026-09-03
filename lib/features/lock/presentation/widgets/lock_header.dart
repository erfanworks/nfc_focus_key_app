import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/lock_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';
import '../../../notifications/presentation/controller/notification_controller.dart';

String _formatParticipantNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  if (names.length == 2) return '${names[0]} and ${names[1]}';
  return '${names[0]} and ${names.length - 1} others';
}

class LockHeader extends StatelessWidget {
  final LockController controller;

  const LockHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Key',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1814),
                  letterSpacing: 0.18.w,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.notification),
                child: Builder(builder: (_) {
                  final notificationsController = Get.isRegistered<NotificationController>()
                      ? Get.find<NotificationController>()
                      : Get.put<NotificationController>(NotificationController());
                  return Obx(() {
                    final unread = notificationsController.unreadCount.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          color: const Color(0xFF1A1814),
                          size: 24.sp,
                        ),
                        if (unread > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5722),
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                              child: Center(
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  });
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.center,
            child: controller.isOnBreak.value
                ? Builder(builder: (_) {
              final friendsController = Get.find<FriendsController>();
              return Obx(() {
                final nudge = friendsController.currentNudge.value;
                final isNudgeActive = nudge != null && nudge.isActive;

                // Personal (non-nudge) break — no "friend also
                // focusing" data exists for this case, so show nothing
                // rather than fake it.
                if (!isNudgeActive) return const SizedBox.shrink();

                final stillFocusingNames = nudge.participants
                    .where((p) => p.isFocused)
                    .map((p) => p.name)
                    .toList();

                if (stillFocusingNames.isEmpty) return const SizedBox.shrink();

                return Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5722),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          '${_formatParticipantNames(stillFocusingNames)} still focusing',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A1814),
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              });
            })
                : controller.isLocked.value
                ? Builder(builder: (_) {
              final friendsController = Get.find<FriendsController>();
              return Obx(() {
                final nudge = friendsController.currentNudge.value;
                final isNudgeActive = nudge != null && nudge.isActive;

                return Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        color: const Color(0xFF8A8278),
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          isNudgeActive
                              ? 'Focusing with ${_formatParticipantNames(nudge.participants.map((p) => p.name).toList())}'
                              : 'You are focusing',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A1814),
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (isNudgeActive && nudge.nudgeId != null) ...[
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => friendsController.leaveNudge(nudge.nudgeId!),
                          child: Text(
                            'Leave',
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC0392B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              });
            })
                : Builder(builder: (_) {
              final friendsController = Get.find<FriendsController>();
              return Obx(() {
                final nudge = friendsController.currentNudge.value;
                final canJoin = nudge != null && nudge.isActive && !nudge.isLocked;

                if (!canJoin) return const SizedBox.shrink();

                final names = nudge.participants.map((p) => p.name).toList();
                final label = names.isEmpty
                    ? 'A friend is focusing. Join them?'
                    : '${_formatParticipantNames(names)} is focusing. Join?';

                return GestureDetector(
                  onTap: friendsController.joinCurrentNudge,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5722),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }),
          ),
        ],
      );
    });
  }
}