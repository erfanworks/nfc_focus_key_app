import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../../../../core/widgets/focus_icons.dart';

class LockStatusPills extends StatefulWidget {
  final LockController controller;
  final String mode;

  const LockStatusPills({
    super.key,
    required this.controller,
    required this.mode,
  });

  @override
  State<LockStatusPills> createState() => _LockStatusPillsState();
}

class _LockStatusPillsState extends State<LockStatusPills>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _PillWavePainter(
                        wavePhase: _waveController.value,
                        color: const Color(0xFFC4A97D).withValues(alpha: 0.12), // Higher visibility
                      ),
                    );
                  },
                ),
              ),
              Obx(() {
                final modesController = Get.isRegistered<ModesController>()
                    ? Get.find<ModesController>()
                    : Get.put<ModesController>(ModesController());
                final selectedItem = modesController.modes
                        .firstWhereOrNull((m) => m.title == widget.mode) ??
                    ModeItem(widget.mode, '', FKIcon.deepwork);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FocusIcon(
                      selectedItem.icon,
                      color: const Color(0xFFC4A97D),
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      selectedItem.title.replaceAll('.', ''),
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8278),
                        letterSpacing: 0.55,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillWavePainter extends CustomPainter {
  final double wavePhase;
  final Color color;

  _PillWavePainter({
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Increase area and movement for visibility
    final yOffset = size.height * 0.65; // Cover more area
    const waveHeight = 6.0; // Slightly taller waves
    const waveFrequency = 1.2;

    path.moveTo(0, yOffset);

    for (double x = 0; x <= size.width; x++) {
      final y = yOffset +
          math.sin((x / size.width * 2 * math.pi * waveFrequency) +
                  (wavePhase * 2 * math.pi)) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PillWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase;
  }
}
