import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/focus_icons.dart';
import '../../../../routes/app_routes.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';
import '../controllers/modes_controller.dart';

/*
  [START NEW CHANGE - SelectModePage implementation for testing]
  This page allows users to select a focus mode or edit an existing one.
  Part of the UX overhaul to move mode management from settings to the lock screen.
*/
class SelectModePage extends GetView<ModesController> {
  const SelectModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lockController = Get.find<LockController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF1A1814),
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Mode',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1814),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              if (controller.isLoading.value && controller.modes.isNotEmpty) {
                return const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFC4A97D)),
                );
              }
              return SizedBox(height: 2.h);
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.modes.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFC4A97D)));
                }

                if (controller.modes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 64.sp,
                          color: const Color(0xFFE8E3DA),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No modes found',
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8A8278),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Create a new mode to get started.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            color: const Color(0xFFB5AFA5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: controller.modes.length,
                  itemBuilder: (context, index) {
                    final mode = controller.modes[index];
                    final isSelected = lockController.selectedMode.value == mode.title;

                    return _buildModeCard(mode, isSelected, lockController);
                  },
                );
              }),
            ),
            _buildAddNewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(ModeItem mode, bool isSelected, LockController lockController) {
    return GestureDetector(
      onTap: () {
        lockController.selectMode(mode);
        Get.back();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0EBE2) : const Color(0xFFF7F4EE),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC4A97D) : const Color(0xFFE8E3DA),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC4A97D).withAlpha(15) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FocusIcon(
                  mode.icon,
                  color: const Color(0xFFC4A97D),
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title.replaceAll('.', ''),
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1814),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildModeSubtitle(mode),
                ],
              ),
            ),
            Obx(() {
              final isNavigating = controller.navigatingEditModeId.value == mode.id;
              return GestureDetector(
                onTap: isNavigating ? null : () => controller.onEditMode(mode),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC4A97D) : const Color(0xFFE8E3DA),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1814).withOpacity(isSelected ? 0.08 : 0.04),
                        blurRadius: isSelected ? 6 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isNavigating
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Color(0xFFC4A97D)),
                            ),
                          )
                        : Icon(
                            Icons.edit_outlined,
                            color: const Color(0xFFC4A97D),
                            size: 16.sp,
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSubtitle(ModeItem mode) {
    if (!GetPlatform.isIOS) {
      return Text(
        '${mode.totalLockedApps} apps locked',
        style: GoogleFonts.dmSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8A8278),
        ),
      );
    }

    // For iOS, fetch breakdown from native side
    return FutureBuilder<Map<String, int>>(
      future: Get.find<AppLockNativeService>().getIOSSelectedCounts(mode.id ?? ''),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            '${mode.totalLockedApps} items locked',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8278),
            ),
          );
        }

        final apps = snapshot.data!["apps"] ?? 0;
        final cats = snapshot.data!["categories"] ?? 0;

        String text;
        if (apps == 0 && cats == 0) {
          text = 'No items locked';
        } else if (apps > 0 && cats > 0) {
          text = '$apps app${apps == 1 ? '' : 's'} & $cats cat locked';
        } else if (cats > 0) {
          text = '$cats category${cats == 1 ? '' : 'ies'} locked';
        } else {
          text = '$apps app${apps == 1 ? '' : 's'} locked';
        }

        return Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8A8278),
          ),
        );
      },
    );
  }

  Widget _buildAddNewButton() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Obx(() {
        final isNavigating = controller.isNavigatingNewMode.value;
        return GestureDetector(
          onTap: isNavigating ? null : controller.onAddNewMode,
          child: Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1814),
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isNavigating)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else ...[
                  Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Add new mode',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
/* [END NEW CHANGE - SelectModePage] */
