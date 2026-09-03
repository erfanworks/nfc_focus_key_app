import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/history_controller.dart';
import '../widgets/total_focus_card.dart';
import '../widgets/history_list_section.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF1A1814),
                    height: 1.0,
                    letterSpacing: 0.4.w,
                  ),
                ),
                SizedBox(height: 16.h),
                TotalFocusCard(
                  totalTime: controller.totalFocusTime.value,
                  sinceDate: controller.sinceDate.value,
                ),
                // SizedBox(height: 8.h),
                // Row(
                //   children: [
                //     Expanded(
                //       child: LockStatCard(
                //         title: 'TODAY',
                //         value: controller.todayTime,
                //       ),
                //     ),
                //     SizedBox(width: 8.w),
                //     Expanded(
                //       child: LockStatCard(
                //         title: 'THIS WEEK',
                //         value: controller.thisWeekTime,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 16.h),
                if (controller.historyGroups.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Center(
                      child: Text(
                        'No focus sessions yet',
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: controller.historyGroups.length,
                    itemBuilder: (context, index) {
                      final group = controller.historyGroups[index];
                      return HistoryListSection(group: group);
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}