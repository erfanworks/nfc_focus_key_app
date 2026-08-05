import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';

class BreakCard extends StatefulWidget {
  final LockController controller;

  const BreakCard({super.key, required this.controller});

  @override
  State<BreakCard> createState() => _BreakCardState();
}

class _BreakCardState extends State<BreakCard> with TickerProviderStateMixin {
  late AnimationController _activateController;
  late AnimationController _cancelController;
  Timer? _vibrationTimer;


  @override
  void initState() {
    super.initState();
    _activateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _cancelController = AnimationController(
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

    _cancelController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopVibration();
        HapticFeedback.vibrate();
        widget.controller.endBreak();
        _cancelController.reset();
        widget.controller.isHoldingCancel.value = false;
      }
    });
  }

  void _startVibration() {
    _vibrationTimer?.cancel();
    HapticFeedback.vibrate();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
    _cancelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isOnBreak.value) {
        return Container(
          width: 337.w,
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
          ),
          child: Row(
            children: [
              // No icon! (Removed coffee cup as per feedback)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Break ends in ',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1A1814),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.controller.formattedBreakTime,
                        style: GoogleFonts.dmSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC4A97D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
              const Spacer(),
              // Cancel button disabled — backend has no break-cancel/end-early
              // endpoint yet. Breaks currently must run their full duration
              // and end automatically. Uncomment this block if/when a
              // cancel endpoint becomes available.
              /*
              GestureDetector(
                onTapDown: (_) {
                  widget.controller.isHoldingCancel.value = true;
                  _startVibration();
                  _cancelController.forward();
                },
                onTapUp: (_) {
                  _stopVibration();
                  widget.controller.isHoldingCancel.value = false;
                  if (_cancelController.status != AnimationStatus.completed) {
                    _cancelController.reverse();
                  }
                },
                onTapCancel: () {
                  _stopVibration();
                  widget.controller.isHoldingCancel.value = false;
                  if (_cancelController.status != AnimationStatus.completed) {
                    _cancelController.reverse();
                  }
                },
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8E3DA),
                            width: 1.5.w,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _cancelController,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: widget.controller.isHoldingCancel.value
                                ? _cancelController.value
                                : 0.0,
                            strokeWidth: 1.5.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFC4A97D),
                            ),
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                      Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFC4A97D),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
              */
            ],
          ),
        );
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
                        translation: Offset(_activateController.value - 1.0, 0.0),
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
                      // No icon! (Removed phone dotted line as per feedback)
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
                          Text(
                            '${widget.controller.breakDurationMinutes.value} min • ${widget.controller.breaksLeft.value} left today',
                            style: GoogleFonts.dmSans(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8278),
                              height: 1.0,
                              letterSpacing: 0.55,
                            ),
                          ),
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
}