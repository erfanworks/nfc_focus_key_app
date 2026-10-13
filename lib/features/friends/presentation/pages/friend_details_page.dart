import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controllers/friends_controller.dart';

class FriendDetailsPage extends StatefulWidget {
  const FriendDetailsPage({super.key});

  @override
  State<FriendDetailsPage> createState() => _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  final FriendsController controller = Get.find<FriendsController>();

  // ---- Mode A: single-friend accountability card (from Friends Hub tap) ----
  FriendModel? _singleFriend;
  bool _showRemoveConfirm = false;
  bool _isRemoving = false;
  bool _isSendingNudge = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is FriendModel) {
      _singleFriend = args;
    }
  }

  // ==================== Mode A actions ====================

  Future<void> _sendNudgeToSingleFriend() async {
    if (_singleFriend == null || _isSendingNudge) return;
    setState(() => _isSendingNudge = true);
    await controller.sendNudge(_singleFriend!.id);
    if (mounted) setState(() => _isSendingNudge = false);
  }

  Future<void> _confirmRemoveFriend() async {
    if (_singleFriend == null || _isRemoving) return;
    setState(() => _isRemoving = true);
    await controller.removeFriend(_singleFriend!.id);
    setState(() => _isRemoving = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: _buildSingleFriendView(),
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
          Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: const Color(0xFF1A1814)),
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

  // ==================== Mode A: single-friend accountability card ====================

  Widget _buildSingleFriendView() {
    final friend = _singleFriend!;
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 32.h),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: friend.isDarkAvatar ? const Color(0xFF1A1814) : const Color(0xFFE8E3DA),
          ),
          child: Center(
            child: Text(
              friend.initials,
              style: GoogleFonts.dmSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: friend.isDarkAvatar ? const Color(0xFFF7F4EE) : const Color(0xFF1A1814),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          friend.name,
          style: GoogleFonts.cormorantGaramond(fontSize: 28.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1814)),
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
                color: friend.isFocusing ? const Color(0xFFE67124) : const Color(0xFF8A8278),
              ),
            ),
            SizedBox(width: 6.w),
            Text(friend.status, style: GoogleFonts.dmSans(fontSize: 11.sp, color: const Color(0xFF8A8278))),
          ],
        ),
        const Spacer(),
        _showRemoveConfirm ? _buildRemoveConfirmCard() : _buildSingleFriendActions(),
      ],
    );
  }

  Widget _buildSingleFriendActions() {
    final bool isBusy = _singleFriend!.isFocusing;

    return Column(
      children: [
        InkWell(
          onTap: isBusy
              ? () {
                  CustomSnackbar.show(
                    title: 'Friend Busy',
                    message: '${_singleFriend!.name} is currently focusing. You can nudge them once they finish.',
                    isError: true,
                  );
                }
              : (_isSendingNudge ? null : _sendNudgeToSingleFriend),
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: isBusy ? const Color(0xFFCCC8C0) : const Color(0xFF1A1814),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Center(
              child: _isSendingNudge
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF7F4EE)),
                      ),
                    )
                  : Text(
                      isBusy ? 'Friend is focusing' : 'Send a nudge',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        color: isBusy ? const Color(0xFF8A8278) : const Color(0xFFF7F4EE),
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () => setState(() => _showRemoveConfirm = true),
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: const Color(0xFFE8E3DA)),
            ),
            child: Center(
              child: Text(
                'Remove friend',
                style: GoogleFonts.dmSans(fontSize: 14.sp, color: const Color(0xFFC0392B)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Mirrors the existing unpair-confirmation pattern used on the Key Status
  // page, so destructive actions look/behave consistently across the app.
  Widget _buildRemoveConfirmCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: const Color(0xFFF0EBE2), borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remove ${_singleFriend!.name}?',
            style: GoogleFonts.cormorantGaramond(fontSize: 24.sp, fontWeight: FontWeight.w400, color: const Color(0xFF1A1814)),
          ),
          SizedBox(height: 8.h),
          Text(
            "You'll need to add them again before you can nudge each other.",
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: const Color(0xFF8A8278), height: 20 / 14),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: _isRemoving ? null : _confirmRemoveFriend,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(color: const Color(0xFFC0392B), borderRadius: BorderRadius.circular(28.r)),
              child: Center(
                child: _isRemoving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFFF7F4EE))),
                      )
                    : Text('Yes, remove', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFFF7F4EE))),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => setState(() => _showRemoveConfirm = false),
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(color: const Color(0xFFCCC8C0), borderRadius: BorderRadius.circular(28.r)),
              child: Center(
                child: Text('Cancel', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1814))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
