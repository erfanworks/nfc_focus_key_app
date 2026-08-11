import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/lock_controller.dart';
import '../widgets/hold_to_lock_circle.dart';
import '../widgets/lock_mode_selector.dart';
import '../widgets/lock_header.dart';
import '../widgets/lock_status_section.dart';
import '../widgets/lock_status_pills.dart';
import '../widgets/break_card.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class LockPage extends GetView<LockController> {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Obx(() {
            final isLocked = controller.isLocked.value;
            final mode = controller.selectedMode.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: 16.h),
                LockHeader(controller: controller),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 4),
                      HoldToLockCircle(
                        isLocked: controller.isOnBreak.value ? false : isLocked,
                        isDisabled:
                            !isLocked && controller.selectedModeId == null,
                        onDisabledTap: () => CustomSnackbar.show(
                          title: 'Select a mode',
                          message: 'Pick a mode before locking.',
                          isError: true,
                        ),
                        onTrigger: controller.isOnBreak.value
                            ? controller.endBreak
                            : controller.toggleLock,
                      ),
                      // SizedBox(height: 16.h),
                      LockStatusSection(
                        controller: controller,
                        isLocked: isLocked,
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 140.h,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: isLocked
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LockStatusPills(
                                      controller: controller,
                                      mode: mode,
                                    ),
                                    SizedBox(height: 16.h),
                                    BreakCard(controller: controller),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 8.h),
                                    LockModeSelector(controller: controller),
                                  ],
                                ),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
