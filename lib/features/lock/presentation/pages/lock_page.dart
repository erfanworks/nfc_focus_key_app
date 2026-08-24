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
            final isLocked = controller.isLocked.value || controller.isOnBreak.value;
            final mode = controller.selectedMode.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AnimatedEntrance(
                  delay: 100,
                  child: LockHeader(controller: controller),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 4),
                      _AnimatedEntrance(
                        delay: 300,
                        type: EntranceType.scale,
                        child: HoldToLockCircle(
                          isLocked: controller.isOnBreak.value ? false : isLocked,
                          isDisabled: !isLocked && controller.selectedModeId == null,
                          onDisabledTap: () => CustomSnackbar.show(
                            title: 'Select a mode',
                            message: 'Pick a focus mode before locking.',
                            isError: true,
                          ),
                          onTrigger: controller.isOnBreak.value
                              ? controller.endBreak
                              : controller.toggleLock,
                        ),
                      ),
                      _AnimatedEntrance(
                        delay: 500,
                        child: LockStatusSection(
                          controller: controller,
                          isLocked: isLocked,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 140.h,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: isLocked
                              ? _AnimatedEntrance(
                                  delay: 700,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LockStatusPills(
                                        controller: controller,
                                        mode: mode,
                                      ),
                                      SizedBox(height: 16.h),
                                      BreakCard(controller: controller),
                                    ],
                                  ),
                                )
                              : _AnimatedEntrance(
                                  delay: 700,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 8.h),
                                      LockModeSelector(controller: controller),
                                    ],
                                  ),
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
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform(
            alignment: Alignment.center,
            transform: type == EntranceType.scale
                ? (Matrix4.identity()..scale(0.8 + (0.2 * value)))
                : (Matrix4.identity()..translate(0.0, 20 * (1.0 - value))),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
