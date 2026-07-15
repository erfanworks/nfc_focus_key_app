import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RippleAnimation extends StatefulWidget {
  final double size;
  const RippleAnimation({super.key, this.size = 280});

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: RippleCirclePainter(
                  progress: _controller.value,
                  color: AppColors.accent,
                ),
              ),
              // Center solid dot
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RippleCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  RippleCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      double t = (progress + (i * 0.25)) % 1.0;
      double radius = maxRadius * (0.2 + (t * 0.8));
      double opacity = (1.0 - t).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RippleCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
