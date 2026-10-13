import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_row_item.dart';
import '../../../../core/utils/timezone_helper.dart';

import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedEntrance(
              delay: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 24.h,
                  bottom: 16.h,
                ),
                child: Text(
                  'Settings',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF1A1814),
                    height: 1.0,
                    letterSpacing: 0.4.w,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _AnimatedEntrance(delay: 200, child: _buildSectionHeader('ACCOUNT')),
                  _AnimatedEntrance(
                    delay: 250,
                    child: SettingsGroupCard(
                      children: [
                        SettingsRowItem(
                          title: 'Account Details',
                          onTap: () => Get.toNamed(Routes.personalInformation),
                        ),
                        SettingsRowItem(
                          title: 'Change Password',
                          onTap: () => Get.toNamed(Routes.changePassword),
                        ),
                        Obx(() => SettingsRowItem(
                              title: 'Timezone',
                              trailingText: controller.userTimezone.value,
                              onTap: () => _showTimezonePicker(context),
                            )),
                        SettingsRowItem(
                          title: 'Delete account',
                          titleColor: const Color(0xFFC0392B),
                          showChevron: false,
                          onTap: () => Get.toNamed(Routes.deleteAccount),
                        ),
                      ],
                    ),
                  ),
                  /*
                  [START NEW CHANGE - Remove MODES from Settings]
                  As per client request, modes are now managed directly from the Focus screen.
                  Removed this section to simplify settings.
                  */
                  /*
                  SizedBox(height: 24.h),
                  _AnimatedEntrance(delay: 350, child: _buildSectionHeader('MODES')),
                  Builder(builder: (_) {
                    final modesController = Get.isRegistered<ModesController>()
                        ? Get.find<ModesController>()
                        : Get.put<ModesController>(ModesController());
                    const defaultTitles = ['Deep work.', 'Step away.', 'Nothing gets through.'];

                    return Obx(() {
                      final defaultModes = modesController.modes
                          .where((m) => defaultTitles.contains(m.title))
                          .toList();

                      return _AnimatedEntrance(
                        delay: 400,
                        child: SettingsGroupCard(
                          children: [
                            ...defaultModes.map((mode) {
                              return SettingsRowItem(
                                title: mode.title,
                                trailingText: '${mode.totalLockedApps} apps',
                                onTap: () => Get.toNamed(
                                  Routes.newMode,
                                  arguments: {
                                    'modeId': mode.id,
                                    'modeName': mode.title,
                                    'totalLockedApps': mode.totalLockedApps,
                                    'isEditMode': true,
                                  },
                                ),
                              );
                            }),
                            SettingsRowItem(
                              title: 'All modes',
                              onTap: () => Get.toNamed(Routes.modes, arguments: {'isManageMode': true}),
                            ),
                            SettingsRowItem(
                              title: 'Total Focus',
                              onTap: () => Get.toNamed(Routes.totalFocusApps),
                            ),
                            SettingsRowItem(
                              title: 'Add new mode',
                              titleColor: const Color(0xFFC4A97D),
                              showChevron: false,
                              onTap: () => Get.toNamed(Routes.newMode),
                            ),
                          ],
                        ),
                      );
                    });
                  }),
                  */
                  /* [END NEW CHANGE - MODES Section Removed] */
                  SizedBox(height: 24.h),
                  _AnimatedEntrance(delay: 500, child: _buildSectionHeader('FOCUS')),
                  Obx(() {
                    final hasReminder =
                        controller.personalReminder.value.isNotEmpty &&
                        controller.personalReminder.value !=
                            'I want to stay focused for..';
                    return _AnimatedEntrance(
                      delay: 550,
                      child: SettingsGroupCard(
                        children: [
                          SettingsRowItem(
                            title: 'Personal Reminder',
                            trailingText: hasReminder ? 'Set' : 'Not Set',
                            trailingTextColor: hasReminder
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFB5AFA5),
                            onTap: () => Get.toNamed(Routes.personalReminder),
                          ),
                          SettingsRowItem(
                            title: 'Key status',
                            trailingText: 'Paired',
                            trailingTextColor: const Color(0xFF2ECC71),
                            showChevron: false,
                            onTap: () => Get.toNamed(Routes.keyStatus),
                          ),
                          SettingsRowItem(
                            title: 'Break',
                            onTap: () => Get.toNamed(Routes.takeBreak),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 24.h),
                  _AnimatedEntrance(delay: 650, child: _buildSectionHeader('YOUR DATA')),
                  _AnimatedEntrance(
                    delay: 700,
                    child: SettingsGroupCard(
                      children: [
                        SettingsRowItem(
                          title: 'Focus history',
                          onTap: () => Get.toNamed(Routes.focusHistory),
                        ),
                        SettingsRowItem(
                          title: 'Export data',
                          onTap: () => Get.toNamed(Routes.exportData),
                        ),
                        SettingsRowItem(
                          title: 'Clear all data',
                          titleColor: const Color(0xFFC0392B),
                          showChevron: false,
                          onTap: () => _showClearDataDialog(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _AnimatedEntrance(delay: 800, child: _buildSectionHeader('ABOUT')),
                  _AnimatedEntrance(
                    delay: 850,
                    child: SettingsGroupCard(
                      children: [
                        SettingsRowItem(
                          title: 'Terms and conditions',
                          onTap: () => Get.toNamed(Routes.legalInformation, parameters: {'title': 'Terms & Condition'}),
                        ),
                        SettingsRowItem(
                          title: 'Privacy policy',
                          onTap: () => Get.toNamed(Routes.legalInformation, parameters: {'title': 'Privacy Policy'}),
                        ),
                        SettingsRowItem(
                          title: 'About us',
                          onTap: () => Get.toNamed(Routes.legalInformation, parameters: {'title': 'About Us'}),
                        ),
                        SettingsRowItem(
                          title: 'Focus Key',
                          trailingText: 'v1.0.0',
                          showChevron: false,
                        ),
                        SettingsRowItem(
                          title: 'focus.co.sg',
                          trailingText: 'Contact Support',
                          showChevron: false,
                          onTap: () {},
                        ),
                        /// Notification test debug section
                        /*
                        if (kDebugMode)
                          SettingsRowItem(
                            title: 'Debug Notification',
                            titleColor: const Color(0xFFC4A97D),
                            onTap: () => Get.toNamed(Routes.notificationDebug),
                          ),
                        */
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _AnimatedEntrance(
                    delay: 950,
                    child: SettingsGroupCard(
                      backgroundColor: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFE8E3DA),
                        width: 1.0,
                      ),
                      children: [
                        SettingsRowItem(
                          title: 'Log Out',
                          titleColor: const Color(0xFFC0392B),
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 0.w, bottom: 8.h),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8A8278),
          height: 1.5,
          letterSpacing: 0.6.w,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFF7F4EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log out',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1814),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'Logging out will temporarily close your digital sanctuary. You can return whenever you are ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    height: 22.0 / 14.0,
                  ),
                ),
                SizedBox(height: 22.h),
                Obx(() {
                  final isLoading = controller.isLoggingOut.value;
                  return InkWell(
                    onTap: isLoading
                        ? null
                        : () async {
                            controller.isLoggingOut.value = true;
                            try {
                              await ApiServices.instance.logoutAndRedirect();
                            } finally {
                              controller.isLoggingOut.value = false;
                            }
                          },
                    borderRadius: BorderRadius.circular(90.r),
                    child: Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B),
                        borderRadius: BorderRadius.circular(90.r),
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Log out',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 22.h),
                GestureDetector(
                  onTap: () => Get.back(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF141210),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimezonePicker(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final List<String> allTz = TimezoneHelper.allTimezones;
    final RxList<String> filteredTimezones = allTz.obs;

    Get.bottomSheet(
      Container(
        height: 0.8.sh,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E3DA),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                'Select Timezone',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1814),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search city or country...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8278)),
                  filled: true,
                  fillColor: const Color(0xFFE8E3DA).withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: (value) {
                  filteredTimezones.value = allTz
                      .where((tz) => tz.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isProfileLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC4A97D),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: filteredTimezones.length,
                  separatorBuilder: (context, index) => Divider(
                    color: const Color(0xFFE8E3DA),
                    height: 1.h,
                  ),
                  itemBuilder: (context, index) {
                    final tz = filteredTimezones[index];
                    return ListTile(
                      title: Text(
                        tz,
                        style: GoogleFonts.dmSans(
                          fontSize: 15.sp,
                          color: const Color(0xFF1A1814),
                        ),
                      ),
                      trailing: controller.userTimezone.value == tz
                          ? const Icon(Icons.check, color: Color(0xFFC4A97D))
                          : null,
                      onTap: () async {
                        final success = await controller.updateTimezone(tz);
                        if (success) {
                          Get.back();
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFF7F4EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clear all data?',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1814),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'This will permanently delete all your focus history, modes, and settings. This action cannot be undone.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    height: 22.0 / 14.0,
                  ),
                ),
                SizedBox(height: 22.h),
                InkWell(
                  onTap: () async {
                    final success = await controller.clearAllData();
                    Get.back();
                    if (success) {
                      CustomSnackbar.show(
                        title: 'Success',
                        message: 'All data has been cleared',
                      );
                    } else {
                      CustomSnackbar.show(
                        title: 'Error',
                        message: 'Failed to clear data',
                        isError: true,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(90.r),
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0392B),
                      borderRadius: BorderRadius.circular(90.r),
                    ),
                    child: Obx(
                          () => Center(
                        child: controller.isClearingData.value
                            ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          'Clear Everything',
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(90.r),
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9C5BF),
                      borderRadius: BorderRadius.circular(90.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1A1814),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum EntranceType { slide, scale }

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  final EntranceType type;

  const _AnimatedEntrance({
    required this.child,
    this.delay = 0,
    this.type = EntranceType.slide,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform(
            alignment: Alignment.center,
            transform: type == EntranceType.scale
                ? (Matrix4.identity()..scale(0.95 + (0.05 * value)))
                : (Matrix4.identity()..translate(0.0, 10 * (1.0 - value))),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
