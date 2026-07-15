import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String flaskSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> 
  <path d="M7.4 15 H16.6 L18.4 19 a2.2 2.2 0 0 1 -2 3.2 H7.6 a2.2 2.2 0 0 1 -2 -3.2 Z" fill="#E5872E"/> 
  <path d="M10 3.6 H14 M10 3.6 V9.6 L5.6 19 a2.2 2.2 0 0 0 2 3.2 H16.4 a2.2 2.2 0 0 0 2 -3.2 L14 9.6 V3.6" stroke="#20303a" stroke-width="1.3" fill="none" stroke-linejoin="round" stroke-linecap="round"/> 
</svg>
''';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F1),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 34.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value.dy * 40),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/logo_name_only.png',
                    width: 220.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
