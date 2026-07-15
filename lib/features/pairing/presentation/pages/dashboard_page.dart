import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../../lock/presentation/pages/lock_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const LockPage(),
      const HistoryPage(),
      FriendsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 84.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4EE).withValues(alpha: 0.90),
            border: const Border(
              top: BorderSide(
                color: Color(0x0DC4A97D), // 5% opacity of C4A97D
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1814).withValues(alpha: 0.02),
                offset: const Offset(0, -10),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Focus',
                icon: Icons.vpn_key_outlined,
                activeIcon: Icons.vpn_key,
              ),
              _buildNavItem(
                index: 1,
                label: 'History',
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
              ),
              _buildNavItem(
                index: 2,
                label: 'Partners',
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Settings',
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected
          ? const Color(0xFF1A1814)
          : const Color(0xFFB5AFA5);

      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 70.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 22.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 15.0 / 10.0,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
