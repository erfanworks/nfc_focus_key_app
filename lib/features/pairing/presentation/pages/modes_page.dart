import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/focus_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/modes_controller.dart';

class ModesPage extends GetView<ModesController> {
  const ModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isManageMode = args?['isManageMode'] == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1814)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.modesTitle,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1814),
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppStrings.modesSubtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF8A8278),
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(() => GestureDetector(
                    onTap: controller.onAddNewMode,
                    child: Container(
                      width: double.infinity,
                      height: 46.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: const Color(0xFFC4A97D),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: controller.isNavigatingNewMode.value
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4A97D)),
                                ),
                              )
                            : Text(
                                AppStrings.addNewMode,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFC4A97D),
                                ),
                              ),
                      ),
                    ),
                  )),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: controller.modes.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final mode = controller.modes[index];
                  
                  return Obx(() {
                    final isSelected = controller.selectedIndex.value == index && !isManageMode;
                    return GestureDetector(
                      onTap: () {
                        if (isManageMode) {
                          Get.toNamed(
                            Routes.newMode,
                            arguments: {
                              'modeId': mode.id,
                              'modeName': mode.title,
                              'totalLockedApps': mode.totalLockedApps,
                              'isEditMode': true,
                              'icon': mode.icon,
                            },
                          );
                        } else {
                          controller.selectMode(index);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 18.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEEE8DC)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFC4A97D)
                                : const Color(0xFFC4A97D).withValues(alpha: 0.20),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.title,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF141210)
                                        : const Color(0xFF1A1814),
                                    height: 30.0 / 20.0,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  mode.description,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8A8278),
                                    height: 18.0 / 12.0,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: FocusIcon(
                                mode.icon,
                                size: 24.w,
                                color: isSelected
                                    ? const Color(0xFFC4A97D)
                                    : const Color(0xFFC4A97D).withValues(alpha: 0.20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              )),
            ),
            if (!isManageMode)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: _buildStartButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Obx(() => GestureDetector(
      onTap: controller.isStartingMode.value ? null : controller.onStartMode,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Center(
          child: controller.isStartingMode.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF7F4EE)),
                  ),
                )
              : Obx(() {
                  if (controller.modes.isEmpty) return const SizedBox.shrink();

                  final selectedMode = controller
                      .modes[controller.selectedIndex.value]
                      .title
                      .replaceAll('.', '');
                  return Text(
                    'Start with $selectedMode',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF7F4EE),
                    ),
                  );
                }),
        ),
      ),
    ));
  }
}