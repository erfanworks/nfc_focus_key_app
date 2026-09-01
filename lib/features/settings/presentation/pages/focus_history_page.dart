import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/focus_history_controller.dart';

class FocusHistoryPage extends StatelessWidget {
  FocusHistoryPage({super.key});

  final controller = Get.put(FocusHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchFocusHistory,
          color: const Color(0xFF1A1814),
          backgroundColor: const Color(0xFFF7F4EE),
          child: Obx(() {
            if (controller.isLoading.value && controller.historyGroups.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildTotalFocusCard(),
                  SizedBox(height: 24.h),
                  _buildFilters(),
                  SizedBox(height: 24.h),
                  _buildHistoryList(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: const Color(0xFF1A1814),
              ),
            ),
            SizedBox(width: 8.w),
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
          ],
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
      ],
    );
  }

  Widget _buildTotalFocusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL FOCUS TIME',
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8278),
              letterSpacing: 0.6.w,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
            controller.totalFocusTime.value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 36.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              height: 1.1,
            ),
          )),
          SizedBox(height: 4.h),
          Obx(() => Text(
            controller.sinceDate.value,
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB5AFA5),
            ),
          )),
          SizedBox(height: 24.h),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Obx(() {
      final stats = controller.sevenDaysStats;
      if (stats.isEmpty) return SizedBox(height: 60.h);

      final maxMinutes = stats
          .map((s) => s.totalMinutes)
          .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(stats.length, (index) {
          final stat = stats[index];
          final isLast = index == stats.length - 1;
          final barHeight = maxMinutes == 0
              ? 4.0
              : (stat.totalMinutes / maxMinutes) * 52.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24.w,
                height: (barHeight < 4 ? 4.0 : barHeight).h,
                decoration: BoxDecoration(
                  color: isLast
                      ? const Color(0xFFC4A97D)
                      : const Color(0xFF8A8278).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                stat.dayLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                  color: isLast
                      ? const Color(0xFF1A1814)
                      : const Color(0xFFB5AFA5),
                ),
              ),
            ],
          );
        }),
      );
    });
  }

  Widget _buildFilters() {
    return Obx(() {
      final filters = controller.filterLabels;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = f == controller.selectedFilter.value;
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => controller.selectFilter(f),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC4A97D)
                          : const Color(0xFFE8E3DA),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFC4A97D)
                          : const Color(0xFF8A8278),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildHistoryList() {
    return Obx(() {
      final groups = controller.filteredHistoryGroups;

      if (groups.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Center(
            child: Text(
              'No sessions found',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8278),
              ),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groups.length,
        separatorBuilder: (context, index) => SizedBox(height: 24.h),
        itemBuilder: (context, index) {
          final group = groups[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.dateHeader,
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A8278),
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: group.sessions.length,
                  separatorBuilder: (context, i) => Divider(
                    color: const Color(0xFFE8E3DA),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, i) {
                    final session = group.sessions[i];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.timeRange,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF1A1814),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E3DA),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  session.modeName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF8A8278),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (session.isActive) ...[
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                              Text(
                                session.durationFormatted,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF1A1814),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
