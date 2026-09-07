import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _waveController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _waterHeightAnimation;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _waterHeightAnimation = Tween<double>(
      begin: 1.0, // Start below screen
      end: 0.85,  // Rise to 15% height
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F1),
      body: Stack(
        children: [
          // Background Water Wave
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_waveController, _waterHeightAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _SplashWavePainter(
                    wavePhase: _waveController.value,
                    heightPercent: _waterHeightAnimation.value,
                    color: const Color(0xFFC4A97D).withValues(alpha: 0.08),
                  ),
                );
              },
            ),
          ),
          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FocusKey',
                      style: GoogleFonts.lora(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF152026),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'by Presence Labs',
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF152026),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  final double wavePhase;
  final double heightPercent;
  final Color color;

  _SplashWavePainter({
    required this.wavePhase,
    required this.heightPercent,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final yOffset = size.height * heightPercent;
    const waveHeight = 15.0;
    const waveFrequency = 0.8;

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
  bool shouldRepaint(covariant _SplashWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase || oldDelegate.heightPercent != heightPercent;
  }
}
