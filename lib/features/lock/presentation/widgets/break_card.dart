import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';

class BreakCard extends StatefulWidget {
  final LockController controller;

  const BreakCard({super.key, required this.controller});

  @override
  State<BreakCard> createState() => _BreakCardState();
}

class _BreakCardState extends State<BreakCard> with TickerProviderStateMixin {
  late AnimationController _activateController;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _activateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _activateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopVibration();
        HapticFeedback.vibrate();
        widget.controller.startBreak();
        _activateController.reset();
      }
    });
  }

  void _startVibration() {
    _vibrationTimer?.cancel();
    HapticFeedback.vibrate();
    _vibrationTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      HapticFeedback.vibrate();
    });
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  @override
  void dispose() {
    _stopVibration();
    _activateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isOnBreak.value) {
        return Obx(() {
          if (widget.controller.isBreakPaused.value) {
            return _PausedBreakCard(controller: widget.controller);
          }
          return _ActiveBreakCard(controller: widget.controller);
        });
      }

      final friendsController = Get.find<FriendsController>();
      final nudge = friendsController.currentNudge.value;
      final isNudge = nudge != null && nudge.isActive;
      final isLoadingSettings =
          !isNudge && widget.controller.isLoadingBreakSettings.value;
      final breaksLeft =
          isNudge ? nudge.breaksRemaining : widget.controller.breaksLeft.value;

      if (!isLoadingSettings && breaksLeft <= 0) {
        return _buildNoBreaksLeftCard();
      }

      return GestureDetector(
        onTapDown: (_) {
          _startVibration();
          _activateController.forward();
        },
        onTapUp: (_) {
          _stopVibration();
          if (_activateController.status != AnimationStatus.completed) {
            _activateController.reverse();
          }
        },
        onTapCancel: () {
          _stopVibration();
          if (_activateController.status != AnimationStatus.completed) {
            _activateController.reverse();
          }
        },
        child: Container(
          width: 337.w,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _activateController,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation:
                            Offset(_activateController.value - 1.0, 0.0),
                        child: Container(
                          color: const Color(0xFFE5DDD0),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Take a break',
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 15.0 / 12.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(() {
                            final friendsController =
                                Get.find<FriendsController>();
                            final nudge = friendsController.currentNudge.value;
                            final isNudge = nudge != null && nudge.isActive;

                            if (!isNudge &&
                                widget.controller.isLoadingBreakSettings.value) {
                              return Text(
                                '— min • — left today',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFB5AFA5),
                                  height: 1.0,
                                  letterSpacing: 0.55,
                                ),
                              );
                            }

                            final minutes = isNudge
                                ? nudge.breakDurationMinutes
                                : widget.controller.personalBreakLengthMinutes
                                    .value;
                            final left = isNudge
                                ? nudge.breaksRemaining
                                : widget.controller.breaksLeft.value;
                            return Text(
                              '$minutes min • $left left today',
                              style: GoogleFonts.dmSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8A8278),
                                height: 1.0,
                                letterSpacing: 0.55,
                              ),
                            );
                          }),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF8A8278),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNoBreaksLeftCard() {
    return Container(
      width: 337.w,
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: const Color(0xFFB5AFA5),
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'All breaks used today',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                  height: 15.0 / 12.0,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'More available tomorrow',
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB5AFA5),
                  height: 1.0,
                  letterSpacing: 0.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── INTERNAL WIDGETS (PRO STYLE) ──────────────────────────────────────────

class _ActiveBreakCard extends StatelessWidget {
  final LockController controller;
  const _ActiveBreakCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final left = controller.breaksLeft.value;
      return Container(
        width: 337.w,
        height: 82.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE2),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
        ),
        child: Row(
          children: [
            _buildCoffeeIcon(),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Break ends in',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1814),
                    ),
                  ),
                  Text(
                    controller.formattedBreakTime,
                    style: GoogleFonts.dmSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC4A97D),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '$left break${left == 1 ? '' : 's'} left this session',
                    style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8278),
                    ),
                  ),
                ],
              ),
            ),
            _PauseHoldButton(controller: controller),
          ],
        ),
      );
    });
  }

  Widget _buildCoffeeIcon() {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E3DA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.coffee_outlined,
        color: const Color(0xFF8A8278),
        size: 20.sp,
      ),
    );
  }
}

class _PausedBreakCard extends StatelessWidget {
  final LockController controller;
  const _PausedBreakCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: 337.w,
      height: 82.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
      ),
      child: Row(
        children: [
          _buildCoffeeIcon(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Break paused',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1814),
                  ),
                ),
                Text(
                  controller.formattedBreakTime,
                  style: GoogleFonts.dmSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A8278),
                    height: 1.1,
                  ),
                ),
                Text(
                  'Apps are currently locked',
                  style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.resumeBreak,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1814),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Resume',
                style: GoogleFonts.dmSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF7F4EE),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildCoffeeIcon() {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E3DA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.coffee_outlined,
        color: const Color(0xFF8A8278).withOpacity(0.5),
        size: 20.sp,
      ),
    );
  }
}

class _PauseHoldButton extends StatefulWidget {
  final LockController controller;
  const _PauseHoldButton({required this.controller});

  @override
  State<_PauseHoldButton> createState() => _PauseHoldButtonState();
}

class _PauseHoldButtonState extends State<_PauseHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopVibration();
        HapticFeedback.vibrate();
        widget.controller.pauseBreak();
        _holdController.reset();
      }
    });
  }

  void _startVibration() {
    _vibrationTimer?.cancel();
    HapticFeedback.vibrate();
    _vibrationTimer =
        Timer.periodic(const Duration(milliseconds: 200), (_) {
      HapticFeedback.vibrate();
    });
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  @override
  void dispose() {
    _stopVibration();
    _holdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _startVibration();
        _holdController.forward();
      },
      onTapUp: (_) {
        _stopVibration();
        if (_holdController.status != AnimationStatus.completed) {
          _holdController.reverse();
        }
      },
      onTapCancel: () {
        _stopVibration();
        if (_holdController.status != AnimationStatus.completed) {
          _holdController.reverse();
        }
      },
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8E3DA), width: 1.5.w),
              ),
            ),
            AnimatedBuilder(
              animation: _holdController,
              builder: (context, child) => CircularProgressIndicator(
                value: _holdController.value,
                strokeWidth: 2.w,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFC4A97D)),
                backgroundColor: Colors.transparent,
              ),
            ),
            Icon(Icons.pause_rounded, color: const Color(0xFFC4A97D), size: 22.sp),
          ],
        ),
      ),
    );
  }
}
