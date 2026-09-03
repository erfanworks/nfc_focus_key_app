import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/friend_list_item.dart';
import '../controllers/friends_controller.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  final FriendsController controller = Get.put(FriendsController());

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
              _AnimatedEntrance(
                delay: 100,
                child: _buildTitle(),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: Obx(
                  () => controller.addedFriends.isNotEmpty
                      ? _buildFriendsList()
                      : _AnimatedEntrance(
                          delay: 300,
                          type: EntranceType.scale,
                          child: _buildEmptyState(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Friends',
      style: GoogleFonts.cormorantGaramond(
        fontSize: 24.sp,
        fontWeight: FontWeight.w300,
        color: const Color(0xFF1A1814),
        height: 1.0,
        letterSpacing: 0.4.w,
      ),
    );
  }

  Widget _buildFriendsList() {
    final lockController = Get.find<LockController>();
    return Column(
      children: [
        Obx(() {
          if (!lockController.isLocked.value) return const SizedBox.shrink();
          return _AnimatedEntrance(
            delay: 150,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBE2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 16.sp, color: const Color(0xFF8A8278)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "You're focusing right now. End your session to start a nudge.",
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: const Color(0xFF8A8278),
                          height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Expanded(
          child: Obx(
            () => ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ...controller.addedFriends.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final friend = entry.value;
                    return _AnimatedEntrance(
                      delay: 200 + (index * 50),
                      child: FriendListItem(
                        name: friend.name,
                        initials: friend.initials,
                        isDarkAvatar: friend.isDarkAvatar,
                        status: friend.status,
                        isFocusing: friend.isFocusing,
                        isSelected: controller.isSelectedForNudge(friend.id),
                        onSelectToggle: () =>
                            controller.toggleNudgeSelection(friend.id),
                        disabledMessage: lockController.isLocked.value
                            ? "End your focus session first."
                            : null,
                        onTap: () {
                          Get.toNamed(Routes.friendDetails, arguments: friend);
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _AnimatedEntrance(
                  delay: 250 + (controller.addedFriends.length * 50),
                  child: Obx(
                    () => controller.selectedForNudge.isEmpty
                        ? _buildAddFriendsOutlineButton()
                        : _buildSelectModeButton(lockController),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddFriendsOutlineButton() {
    return InkWell(
      onTap: () => Get.toNamed(Routes.addPartner),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18.sp, color: const Color(0xFF1A1814)),
            SizedBox(width: 8.w),
            Text(
              'Add friends',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1814),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectModeButton(LockController lockController) {
    return Obx(() {
      final isBlocked = lockController.isLocked.value;
      return InkWell(
        onTap: () {
          if (isBlocked) {
            CustomSnackbar.show(
              title: 'Focus session active',
              message: 'End your focus session first to start a nudge.',
              isError: true,
            );
            return;
          }
          Get.toNamed(
            Routes.modes,
            arguments: {
              'isNudgeFlow': true,
              'participantIds': controller.selectedForNudge.toList(),
            },
          );
        },
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
            color:
                isBlocked ? const Color(0xFFCCC8C0) : const Color(0xFF1A1814),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Center(
            child: Text(
              'Select Mood',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF7F4EE),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconPlaceholder(),
          SizedBox(height: 24.h),
          _buildDescription(),
          SizedBox(height: 32.h),
          _buildAddPartnerButton(),
          SizedBox(height: 48.h),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF8A8278).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.supervisor_account_outlined,
          size: 32.sp,
          color: const Color(0xFF8A8278),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Add up to 5 friends to keep each other\naccountable.',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8A8278),
          height: 27.2 / 16,
        ),
      ),
    );
  }

  Widget _buildAddPartnerButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.addPartner),
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: const Color(0xFF1A1814), width: 1.0),
          ),
          child: Text(
            'Add a partner',
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              height: 19.5 / 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

enum EntranceType { slide, scale }

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final EntranceType type;

  const _AnimatedEntrance({
    required this.child,
    this.delay = 0,
    this.type = EntranceType.slide,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform(
            alignment: Alignment.center,
            transform: type == EntranceType.scale
                ? (Matrix4.identity()..scale(0.9 + (0.1 * value)))
                : (Matrix4.identity()..translate(0.0, 15 * (1.0 - value))),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
