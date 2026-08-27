import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/enable_permissions_controller.dart';

class EnablePermissionsPage extends GetView<EnablePermissionsController> {
  const EnablePermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Text(
                'One last step',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1814),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Focus Key needs these permissions to lock apps on this device.',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: const Color(0xFF8A8278),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              Obx(() => _PermissionRow(
                title: 'Accessibility',
                subtitle: 'Detects when a locked app opens',
                granted: controller.accessibilityGranted.value,
                onTap: controller.enableAccessibility,
              )),
              SizedBox(height: 12.h),
              Obx(() => _PermissionRow(
                title: 'Display over other apps',
                subtitle: 'Shows the lock screen on top',
                granted: controller.overlayGranted.value,
                onTap: controller.enableOverlay,
              )),
              const Spacer(),
              Obx(() => GestureDetector(
                onTap: controller.allGranted ? controller.continueToApp : null,
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: controller.allGranted
                        ? const Color(0xFF1A1814)
                        : const Color(0xFF1A1814).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Center(
                    child: Text(
                      controller.allGranted ? 'Continue' : 'Enable both to continue',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF7F4EE),
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onTap;

  const _PermissionRow({
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: granted
              ? const Color(0xFFC4A97D)
              : const Color(0xFFC4A97D).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1814))),
                SizedBox(height: 2.h),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12.sp, color: const Color(0xFF8A8278))),
              ],
            ),
          ),
          if (granted)
            Icon(Icons.check_circle, color: const Color(0xFFC4A97D), size: 22.sp)
          else
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1A1814)),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text('Enable', style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1814))),
              ),
            ),
        ],
      ),
    );
  }
}