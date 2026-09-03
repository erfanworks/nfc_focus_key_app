import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HoldToLockCircle extends StatefulWidget {
  final bool isLocked;
  final VoidCallback onTrigger;
  final bool isDisabled;
  final VoidCallback? onDisabledTap;

  const HoldToLockCircle({
    super.key,
    required this.isLocked,
    required this.onTrigger,
    this.isDisabled = false,
    this.onDisabledTap,
  });

  @override
  State<HoldToLockCircle> createState() => _HoldToLockCircleState();
}

class _HoldToLockCircleState extends State<HoldToLockCircle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _splashController;
  late Animation<double> _splashScale;
  late Animation<double> _splashOpacity;
  Timer? _vibrationTimer;
  bool _isPressed = false;

  static const String _unlockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36">
  <path fill="currentColor" d="M12 25.14V28h2v-2.77a2.42 2.42 0 1 0-2-.09"/>
  <path fill="currentColor" d="M26 2a8.2 8.2 0 0 0-8 8.36V15H2v17a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2V15h-4v-4.64A6.2 6.2 0 0 1 26 4a6.2 6.2 0 0 1 6 6.36v6.83a1 1 0 0 0 2 0v-6.83A8.2 8.2 0 0 0 26 2m-4 15v15H4V17Z"/>
</svg>
''';

  static const String _lockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36">
  <path fill="currentColor" d="M18.09 20.59A2.41 2.41 0 0 0 17 25.14V28h2v-2.77a2.41 2.41 0 0 0-.91-4.64"/>
  <path fill="currentColor" d="M26 15v-4.28a8.2 8.2 0 0 0-8-8.36a8.2 8.2 0 0 0-8 8.36V15H7v17a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2V15Zm-14-4.28a6.2 6.2 0 0 1 6-6.36a6.2 6.2 0 0 1 6 6.36V15H12ZM9 32V17h18v15Z"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _splashScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutQuad),
    );

    _splashOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutQuad),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopVibration();
        HapticFeedback.heavyImpact(); // Strong haptic for lock commit
        _splashController.forward(from: 0.0);
        widget.onTrigger();
        _controller.reset();
        setState(() => _isPressed = false);
      }
    });
  }

  void _startVibration() {
    _vibrationTimer?.cancel();
    if (!widget.isLocked) {
      HapticFeedback.mediumImpact();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 200), (
          timer,
          ) {
        HapticFeedback.mediumImpact();
      });
    }
  }

  void _stopVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  @override
  void dispose() {
    _stopVibration();
    _controller.dispose();
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.isDisabled) {
          widget.onDisabledTap?.call();
          return;
        }
        setState(() => _isPressed = true);
        _startVibration();
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _stopVibration();
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _stopVibration();
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _splashController]),
        builder: (context, child) {
          return Opacity(
              opacity: widget.isDisabled ? 0.5 : 1.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_splashController.isAnimating)
                    Transform.scale(
                      scale: _splashScale.value,
                      child: Opacity(
                        opacity: _splashOpacity.value,
                        child: Container(
                          width: 170.w,
                          height: 170.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFC4A97D),
                              width: 1.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  AnimatedScale(
                    scale: _isPressed ? 0.965 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      width: 170.w,
                      height: 170.w,
                      child: CustomPaint(
                        foregroundPainter: _CircleProgressPainter(
                          progress: _controller.value,
                          trackColor: const Color(0xFFE8E3DA),
                          progressColor: const Color(0xFFC4A97D),
                          radius: 75.w,
                        ),
                        child: Center(
                          child: Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4EE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x33BD9F63),
                                  offset: const Offset(10, 10),
                                  blurRadius: 20.r,
                                ),
                                const BoxShadow(
                                  color: Color(0xFFFFFFFF),
                                  offset: Offset(-10, -10),
                                  blurRadius: 28,
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.string(
                                widget.isLocked ? _lockSvg : _unlockSvg,
                                width: 28.45.w,
                                height: 28.45.w,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFC4A97D),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double radius;

  _CircleProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.w;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.w
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      final endAngle = startAngle + sweepAngle;
      final knobX = center.dx + radius * math.cos(endAngle);
      final knobY = center.dy + radius * math.sin(endAngle);
      final knobCenter = Offset(knobX, knobY);

      final knobRadius = 6.w;

      final shadowPaint = Paint()
        ..color = const Color(0x331A1814)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        knobCenter + const Offset(0, 1.5),
        knobRadius,
        shadowPaint,
      );

      final knobFillPaint = Paint()
        ..color = const Color(0xFFF7F4EE)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(knobCenter, knobRadius, knobFillPaint);

      final knobBorderPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5.w;
      canvas.drawCircle(knobCenter, knobRadius, knobBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.radius != radius;
  }
}