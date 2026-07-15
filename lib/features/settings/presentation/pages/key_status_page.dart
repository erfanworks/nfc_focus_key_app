import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/key_paired_card.dart';
import '../widgets/key_detail_card.dart';

class KeyStatusPage extends StatelessWidget {
  KeyStatusPage({super.key});

  final RxBool _showConfirmUnpair = false.obs;
  final RxBool _isPaired = StorageService.hasPairedKey().obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                if (_isPaired.value) ...[
                  const KeyPairedCard(),
                  SizedBox(height: 16.h),
                  const KeyDetailCard(),
                  SizedBox(height: 16.h),
                  _showConfirmUnpair.value
                      ? _buildConfirmUnpairCard()
                      : _buildInitialUnpairButton(),
                ] else ...[
                  _buildUnpairedCard(),
                  SizedBox(height: 16.h),
                  _buildPairNewKeyButton(),
                ],
              ],
            ),
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
            'Key Status',
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

  Widget _buildInitialUnpairButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => _showConfirmUnpair.value = true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              'Unpair key',
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC0392B),
                height: 21 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmUnpairCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unpaired this key',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'ll need to pair a key again before you can lock sessions.',
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8278),
              height: 20 / 14,
            ),
          ),
          SizedBox(height: 24.h),
          _buildActionBtn(
            text: 'Yes, unpair',
            backgroundColor: const Color(0xFFC0392B),
            textColor: const Color(0xFFF7F4EE),
            onTap: () async {
              _showConfirmUnpair.value = false;
              await StorageService.clearPairedKeyId();
              _isPaired.value = false; // Transition to unpacked state
              Get.snackbar(
                'Unpaired',
                'Your Focus Key has been unpaired.',
                backgroundColor: const Color(0xFFF0EBE2),
                colorText: const Color(0xFF1A1814),
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(20.w),
                borderRadius: 14.r,
              );
            },
          ),
          SizedBox(height: 12.h),
          _buildActionBtn(
            text: 'Cancel',
            backgroundColor: const Color(0xFFCCC8C0),
            textColor: const Color(0xFF1A1814),
            onTap: () => _showConfirmUnpair.value = false,
          ),
        ],
      ),
    );
  }

  Widget _buildUnpairedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.vpn_key_off_outlined,
                size: 24.sp,
                color: const Color(0xFF2D6A4F),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'UNPAIRED',
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D6A4F),
              letterSpacing: 0.66.w,
              height: 16.5 / 11,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No key paired',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF1A1814),
              height: 33 / 22,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pair a key to start locking sessions.',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8A8278),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairNewKeyButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () {
            Get.toNamed(Routes.pairing);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              'Pair a new key',
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1814),
                height: 21 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
