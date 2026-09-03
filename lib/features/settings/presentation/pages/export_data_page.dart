import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/export_data_controller.dart';

class ExportDataPage extends GetView<ExportDataController> {
  const ExportDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.sp,
                        color: const Color(0xFF1A1814),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Export data',
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
                SizedBox(height: 16.h),
                Text(
                  'Export your focus history as a CSV file. Your data never leaves your phone automatically — this is a manual export only.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    height: 20 / 14,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      _buildRow(
                        'Sessions',
                        '${controller.totalSessions.value}',
                        showBottomBorder: true,
                      ),
                      _buildRow(
                        'Total time',
                        controller.totalFocusTime.value,
                        showBottomBorder: true,
                      ),
                      _buildRow(
                        'Data range',
                        controller.dateRangeText.value,
                        showBottomBorder: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: controller.isExporting.value ? null : controller.exportCsv,
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1814),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Center(
                      child: controller.isExporting.value
                          ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF7F4EE),
                        ),
                      )
                          : Text(
                        'Export as CSV',
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF7F4EE),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRow(
      String label,
      String value, {
        required bool showBottomBorder,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? Border(
          bottom: BorderSide(color: const Color(0xFFE8E3DA), width: 1),
        )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              height: 20 / 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8A8278),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}