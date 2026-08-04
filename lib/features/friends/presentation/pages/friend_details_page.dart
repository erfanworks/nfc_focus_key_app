import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/friends_controller.dart';

class FriendDetailsPage extends StatefulWidget {
  const FriendDetailsPage({super.key});

  @override
  State<FriendDetailsPage> createState() => _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  final FriendsController controller = Get.find<FriendsController>();

  List<String> _participantIds = [];
  String _modeId = '';
  int _breaksPerDay = 3;
  int _breakDurationMinutes = 10;

  NudgePreview? _preview;
  bool _isLoadingPreview = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _participantIds = List<String>.from(args['selectedFriends'] ?? []);
      _modeId = args['modeId'] ?? '';
      _breaksPerDay = args['breaksPerDay'] ?? 3;
      _breakDurationMinutes = args['breakDurationMinutes'] ?? 10;
    }
    _loadPreview();
  }

  String? _loadError;

  Future<void> _loadPreview() async {
    if (_participantIds.isEmpty || _modeId.isEmpty) {
      setState(() => _isLoadingPreview = false);
      return;
    }
    final preview = await controller.initiateNudge(
      participantIds: _participantIds,
      modeId: _modeId,
      breaksPerDay: _breaksPerDay,
      breakDurationMinutes: _breakDurationMinutes,
    );
    setState(() {
      _preview = preview;
      _loadError = preview == null ? controller.lastError.value : null;
      _isLoadingPreview = false;
    });
  }

  Future<void> _removeParticipant(PreviewParticipant participant) async {
    if (_preview == null) return;
    await controller.removeParticipant(
      previewId: _preview!.previewId,
      participantId: participant.id,
    );
    setState(() {
      _preview!.participants.remove(participant);
    });
  }

  Future<void> _sendNudge() async {
    if (_isSending || _preview == null) return;
    if (_preview!.participants.isEmpty) {
      CustomSnackbar.show(
        title: "Can't send nudge",
        message: "At least one friend must remain selected.",
        isError: true,
      );
      return;
    }

    setState(() => _isSending = true);
    final success = await controller.confirmNudge(_preview!.previewId);
    setState(() => _isSending = false);

    if (success) {
      CustomSnackbar.show(
        title: 'Request sent',
        message: 'Your partner${_preview!.participants.length > 1 ? "s" : ""} will get a notification.',
      );
      Get.offAllNamed(Routes.lock);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: _isLoadingPreview
              ? const Center(child: CircularProgressIndicator())
              : _preview == null
              ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _loadError ?? "Couldn't load nudge details.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: const Color(0xFF8A8278)),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          )
              : Column(
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildParticipants(),
              SizedBox(height: 32.h),
              if (_preview!.participants.length == 1) ...[
                _buildCards(_preview!.participants.first.sharedStats),
                SizedBox(height: 32.h),
              ],
              const Spacer(),
              _buildSendButton(),
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

  Widget _buildParticipants() {
    return Wrap(
      spacing: 24.w,
      runSpacing: 16.h,
      alignment: WrapAlignment.center,
      children: _preview!.participants.map((p) => _buildParticipantCard(p)).toList(),
    );
  }

  Widget _buildParticipantCard(PreviewParticipant participant) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: participant.isDarkAvatar
                    ? const Color(0xFF1A1814)
                    : const Color(0xFFE8E3DA),
              ),
              child: Center(
                child: Text(
                  participant.initials,
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: participant.isDarkAvatar
                        ? const Color(0xFFF7F4EE)
                        : const Color(0xFF1A1814),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => _removeParticipant(participant),
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A1814)),
                  child: Icon(Icons.close_rounded, size: 12.sp, color: const Color(0xFFF7F4EE)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          participant.name,
          style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1814)),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: participant.isFocusing ? const Color(0xFFE67124) : const Color(0xFF8A8278),
              ),
            ),
            SizedBox(width: 6.w),
            Text(participant.status, style: GoogleFonts.dmSans(fontSize: 11.sp, color: const Color(0xFF8A8278))),
          ],
        ),
      ],
    );
  }

  // Real shared-stats data — only shown for the 1:1 (single partner) case,
  // matching the original design. Flag for confirmation if multi-partner
  // needs an aggregate version of these two cards instead of hiding them.
  Widget _buildCards(SharedStats stats) {
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
                  Text(stats.togetherThisWeek, style: GoogleFonts.dmSans(fontSize: 24.sp, color: const Color(0xFF1A1814))),
                  SizedBox(height: 8.h),
                  Text(
                    'TOGETHER THIS WEEK',
                    style: GoogleFonts.dmSans(fontSize: 9.sp, fontWeight: FontWeight.w500, color: const Color(0xFF8A8278), letterSpacing: 0.36),
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
                  Text('${stats.streak}', style: GoogleFonts.dmSans(fontSize: 24.sp, color: const Color(0xFF1A1814))),
                  SizedBox(height: 14.h),
                  Text('DAY STREAK', style: GoogleFonts.dmSans(fontSize: 9.sp, fontWeight: FontWeight.w500, color: const Color(0xFF8A8278))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return InkWell(
      onTap: _isSending ? null : _sendNudge,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(color: const Color(0xFF1A1814), borderRadius: BorderRadius.circular(30.r)),
        child: Center(
          child: _isSending
              ? SizedBox(
            width: 18.w,
            height: 18.w,
            child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFFF7F4EE))),
          )
              : Text('Send a nudge', style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFFF7F4EE))),
        ),
      ),
    );
  }
}