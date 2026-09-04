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
              onTap: () async {
                final notificationsController = Get.isRegistered<NotificationController>()
                    ? Get.find<NotificationController>()
                    : Get.put<NotificationController>(NotificationController());
                
                // World-class behavior: Clear badge immediately when opening notifications
                notificationsController.markAllAsRead();
                
                await Get.toNamed(Routes.notification);
                
                // Refresh when coming back to ensure sync
                notificationsController.fetchNotifications();
              },
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
        // --- REAL FRIEND FOCUS ALERT ---
        // This dynamically shows friends who are currently focusing
        Obx(() => _buildFriendFocusAlert(context)),
      ],
    );
  }

  Widget _buildFriendFocusAlert(BuildContext context) {
    // Get the FriendsController to access real data
    final friendsController = Get.isRegistered<FriendsController>()
        ? Get.find<FriendsController>()
        : Get.put(FriendsController());

    // Filter friends who are currently focusing based on real status
    final List<String> focusingFriendNames = friendsController.addedFriends
        .where((friend) => friend.isFocusing)
        .map((friend) => friend.name.split(' ').first) // Use first names for a cleaner look
        .toList();

    if (focusingFriendNames.isEmpty) return const SizedBox.shrink();

    final String displayNames = _formatParticipantNames(focusingFriendNames);
    final bool isPlural = focusingFriendNames.length > 1;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EE), // Soft background
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFC4A97D).withOpacity(0.2), // Subtle accent border
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Unique Pulsing Indicator
                  _PulsingIndicator(),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      '$displayNames ${isPlural ? 'are' : 'is'} focusing',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A8278),
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Unique World-Class Pulsing Animation for "Live" status
class _PulsingIndicator extends StatefulWidget {
  @override
  State<_PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC4A97D).withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4A97D).withOpacity(0.4 * _pulseController.value),
                blurRadius: 6 * _pulseController.value,
                spreadRadius: 4 * _pulseController.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
