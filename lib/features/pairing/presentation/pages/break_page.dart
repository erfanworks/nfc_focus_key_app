import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/break_controller.dart';

class BreakPage extends GetView<BreakController> {
  const BreakPage({super.key});

  static const String _breakIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="3" width="14" height="18" rx="3" stroke="currentColor" stroke-width="1.5" fill="none"/>
  <path d="M5 12H19" stroke="currentColor" stroke-width="1.5" stroke-dasharray="3 2"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / App bar custom row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF1A1814),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Break',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1814),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    // Settings Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4EE),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE8E3DA),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Title
                          Text(
                            'Take a break',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 27.5 / 22.0,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            'A limited release valve for when you truly need those apps. Few, short, and spent intentionally.',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8278),
                              height: 22.75 / 14.0,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Breaks per day section
                          Text(
                            'Breaks per session',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 20.0 / 14.0,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Breaks per day options wrap
                          Obx(() {
                            final selectedVal = controller.breaksPerDay.value;
                            return Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                _buildPill(
                                  label: 'None',
                                  isSelected: selectedVal == null,
                                  onTap: () =>
                                      controller.selectBreaksPerDay(null),
                                ),
                                _buildPill(
                                  label: '1',
                                  isSelected: selectedVal == 1,
                                  onTap: () => controller.selectBreaksPerDay(1),
                                ),
                                _buildPill(
                                  label: '2',
                                  isSelected: selectedVal == 2,
                                  onTap: () => controller.selectBreaksPerDay(2),
                                ),
                                _buildPill(
                                  label: '3',
                                  isSelected: selectedVal == 3,
                                  onTap: () => controller.selectBreaksPerDay(3),
                                ),
                                _buildPill(
                                  label: '4',
                                  isSelected: selectedVal == 4,
                                  onTap: () => controller.selectBreaksPerDay(4),
                                ),
                                _buildPill(
                                  label: '5',
                                  isSelected: selectedVal == 5,
                                  onTap: () => controller.selectBreaksPerDay(5),
                                ),
                              ],
                            );
                          }),
                          SizedBox(height: 24.h),

                          // Break length section
                          Text(
                            'Break length',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 20.0 / 14.0,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Break length options wrap
                          Obx(() {
                            final selectedLength =
                                controller.breakLengthMinutes.value;
                            return Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: controller.breakLengthOptions.map((
                                length,
                              ) {
                                return _buildPill(
                                  label: '$length min',
                                  isSelected: selectedLength == length,
                                  onTap: () =>
                                      controller.selectBreakLength(length),
                                );
                              }).toList(),
                            );
                          }),
                          SizedBox(height: 24.h),

                          // Helper bottom text
                          Text(
                            'Breaks are limited and reset each session.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8278),
                              height: 18.0 / 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Continue Button
            // Bottom Continue Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Obx(() {
                final isSaving = controller.isSaving.value;
                return GestureDetector(
                  onTap: isSaving ? null : controller.onContinue,
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Center(
                      child: isSaving
                          ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFFF7F4EE)),
                        ),
                      )
                          : Text(
                        'Continue',
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF7F4EE),
                        ),
                      ),
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

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC4A97D) : const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(9999.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC4A97D)
                : const Color(0xFFE8E3DA),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 2.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF8A8278),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
