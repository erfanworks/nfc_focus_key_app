import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/pairing_scanner_controller.dart';
import '../widgets/ripple_animation.dart';

class PairingScannerPage extends StatefulWidget {
  const PairingScannerPage({super.key});

  @override
  _PairingScannerPageState createState() => _PairingScannerPageState();
}

class _PairingScannerPageState extends State<PairingScannerPage> {
  final PairingScannerController controller =
      Get.find<PairingScannerController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Concentric Animated Ripple Radar
            GestureDetector(
              onTap: controller.startPairing,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Obx(
                  () => Opacity(
                    opacity: controller.isPairing.value ? 0.6 : 1.0,
                    child: RippleAnimation(size: 280.w),
                  ),
                ),
              ),
            ),
            SizedBox(height: 22.h),
            // Text Content Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Obx(
                () => Column(
                  children: [
                    // "Tap to start pairing"
                    Text(
                      controller.isPairing.value ? 'Pairing...' : AppStrings.tapToStartPairing,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1814),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    // "Hold your FocusKey up to the front-facing camera to pair."
                    Text(
                      controller.statusMessage.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8278),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
