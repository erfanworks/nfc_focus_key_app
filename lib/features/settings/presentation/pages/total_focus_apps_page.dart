import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../controllers/settings_controller.dart';

class TotalFocusAppsPage extends StatefulWidget {
  const TotalFocusAppsPage({super.key});

  @override
  State<TotalFocusAppsPage> createState() => _TotalFocusAppsPageState();
}

class _TotalFocusAppsPageState extends State<TotalFocusAppsPage> {
  final SettingsController controller = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      final modesController = Get.find<ModesController>();
      if (modesController.modes.isEmpty) {
        modesController.fetchModes();
      }
    } else {
      controller.fetchTotalFocusApps();
    }
  }
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
              _buildHeader(),
              SizedBox(height: 8.h),
              Text(
                'Every app that gets blocked when Total Focus is active.',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF8A8278),
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(child: Obx(() => _buildBody())),
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
            'Total Focus',
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

  Widget _buildBody() {
    if (Platform.isIOS) {
      return _buildIOSSummary();
    }

    if (controller.isLoadingTotalFocusApps.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final apps = controller.totalFocusApps;

    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block_flipped, size: 32.sp, color: const Color(0xFF8A8278)),
              SizedBox(height: 12.h),
              Text(
                'No apps are blocked under Total Focus yet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13.sp, color: const Color(0xFF8A8278)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: apps.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: const Color(0xFFE8E3DA)),
      itemBuilder: (context, index) {
        final app = apps[index];
        final appName = app['appName']?.toString() ?? 'Unknown app';
        final packageName = app['packageName']?.toString() ?? '';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.apps_rounded, size: 18.sp, color: const Color(0xFF8A8278)),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1814)),
                    ),
                    if (packageName.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        packageName,
                        style: GoogleFonts.dmSans(fontSize: 11.sp, color: const Color(0xFFB5AFA5)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildIOSSummary() {
    final modesController = Get.find<ModesController>();

    if (modesController.isLoading.value && modesController.modes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeModes = modesController.modes
        .where((m) => m.totalLockedApps > 0)
        .toList();
    final totalApps = activeModes.fold<int>(0, (sum, m) => sum + m.totalLockedApps);

    if (totalApps == 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block_flipped, size: 32.sp, color: const Color(0xFF8A8278)),
              SizedBox(height: 12.h),
              Text(
                'No apps are blocked yet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13.sp, color: const Color(0xFF8A8278)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFC4A97D).withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$totalApps',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1814),
                  height: 1.0,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                totalApps == 1
                    ? 'app protected across ${activeModes.length} mode${activeModes.length == 1 ? '' : 's'}'
                    : 'apps protected across ${activeModes.length} mode${activeModes.length == 1 ? '' : 's'}',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'On iOS, app names stay private to your device — Focus Key only knows how many are protected.',
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8A8278),
            height: 1.5,
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: activeModes.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: const Color(0xFFE8E3DA)),
            itemBuilder: (context, index) {
              final mode = activeModes[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.shield_outlined, size: 18.sp, color: const Color(0xFF8A8278)),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        mode.title,
                        style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1814)),
                      ),
                    ),
                    Text(
                      '${mode.totalLockedApps} app${mode.totalLockedApps == 1 ? '' : 's'}',
                      style: GoogleFonts.dmSans(fontSize: 13.sp, color: const Color(0xFF8A8278)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}