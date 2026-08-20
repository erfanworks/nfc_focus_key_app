import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/app_selection_controller.dart';

class AppSelectionPage extends GetView<AppSelectionController> {
  const AppSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final String modeName = (args?['modeName'] ?? 'Deep Work')
        .toString()
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: const Color(0xFF1A1814),
          ),
          onPressed: () => Get.back(),
        ),
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
                    modeName,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC4A97D),
                      letterSpacing: 1.5.w,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Protect your focus.',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1814),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (!Platform.isIOS)
                    Obx(() {
                      final isBlock = controller.isBlockMode.value;
                      return Container(
                        width: double.infinity,
                        height: 44.h,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE6DD),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.setBlockMode(true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isBlock
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9.r),
                                    boxShadow: isBlock
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Block',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1A1814),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.setBlockMode(false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !isBlock
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9.r),
                                    boxShadow: !isBlock
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Allow only',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isBlock
                                            ? const Color(0xFF8A8278)
                                            : const Color(0xFF1A1814),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (!Platform.isIOS) SizedBox(height: 16.h),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final isBlock = controller.isBlockMode.value;
                    return Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC05C3E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isBlock
                              ? 'These go quiet. Everything else stays open.'
                              : 'These stay open. Everything else goes quiet.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A8278),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            Expanded(
              child: Platform.isIOS
                  ? _buildIOSAppPicker(context)
                  : Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.apps.isEmpty) {
                        return Center(
                          child: Text(
                            'No apps found on this device.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              color: const Color(0xFF8A8278),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.apps.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final app = controller.apps[index];
                          return Obx(() {
                            final isSelected = controller.isSelected(
                              app.packageName,
                            );
                            return GestureDetector(
                              onTap: () =>
                                  controller.toggleApp(app.packageName),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 56.h,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 28.w,
                                      height: 28.w,
                                      child: app.icon != null
                                          ? Image.memory(
                                              app.icon!,
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(
                                              Icons.apps,
                                              color: Color(0xFF8A8278),
                                            ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        app.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF141210),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 42.w,
                                      height: 24.h,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: CupertinoSwitch(
                                          value: isSelected,
                                          onChanged: (val) => controller
                                              .toggleApp(app.packageName),
                                          activeColor: const Color(0xFF1A1814),
                                          trackColor: const Color(0xFFE8E3DA),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      );
                    }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: Text(
                  'Calls and Messages always come through.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final args = Get.arguments as Map<String, dynamic>?;
    final isEditMode = args?['isEditMode'] == true;

    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;
      return GestureDetector(
        onTap: isSubmitting ? null : controller.onDone,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1814),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Center(
            child: isSubmitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFF7F4EE)),
                    ),
                  )
                : isEditMode
                ? Text(
                    'Save',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF7F4EE),
                    ),
                  )
                : Builder(builder: (_) {
              if (Platform.isIOS) {
                return Obx(() {
                  final count = controller.iosSelectedAppsCount.value;
                  return Text(
                    count == 0 ? 'Save mode' : 'Block $count app${count == 1 ? '' : 's'}',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF7F4EE),
                    ),
                  );
                });
              }
              final count = controller.selectedCount;
              final isBlock = controller.isBlockMode.value;
              final action = isBlock ? 'Block' : 'Allow';
              final text = count == 1 ? '$action 1 app' : '$action $count apps';
              return Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF7F4EE),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  Widget _buildIOSAppPicker(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEBE6DD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.square_grid_2x2,
                size: 32.sp,
                color: const Color(0xFFC4A97D),
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() {
              final count = controller.iosSelectedAppsCount.value;
              return Text(
                count == 0
                    ? 'No apps selected yet'
                    : '$count app${count == 1 ? '' : 's'} selected',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1814),
                ),
              );
            }),
            SizedBox(height: 8.h),
            Text(
              'iOS chooses apps through its own picker for your privacy — app names aren\'t shared with Focus Key.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8278),
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() {
              final busy = controller.isIOSBusy.value;
              return GestureDetector(
                onTap: busy ? null : controller.onIOSSelectApps,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1814),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Center(
                    child: busy
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFF7F4EE),
                              ),
                            ),
                          )
                        : Text(
                            'Select Apps to Lock',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF7F4EE),
                            ),
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
}
