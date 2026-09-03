import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class LegalInformationPage extends StatefulWidget {
  const LegalInformationPage({super.key});

  @override
  State<LegalInformationPage> createState() => _LegalInformationPageState();
}

class _LegalInformationPageState extends State<LegalInformationPage> {
  bool _isLoading = true;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    final title = Get.parameters['title'] ?? 'Terms & Condition';

    String url;
    switch (title) {
      case 'Privacy Policy':
        url = AppApiUrl.instance.privacy;
        break;
      case 'About Us':
        url = AppApiUrl.instance.about;
        break;
      case 'Terms & Condition':
      default:
        url = AppApiUrl.instance.terms;
    }

    try {
      final response = await ApiServices.instance.getServices(url);
      if (response != null && response["success"] == true) {
        _content = response["data"]?["content"] ?? '';
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Get.parameters['title'] ?? 'Terms & Condition';
    final showDate = title == 'Terms & Condition';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(title),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Last Updated: October 24, 2026',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    _buildParagraph(_content),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 8.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.back(),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: const Color(0xFF1A1814),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24.sp,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF1A1814),
                height: 1.0,
                letterSpacing: 0.4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1814),
        letterSpacing: 0.2.w,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF8A8278),
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h, left: 16.w, right: 8.w),
          child: Container(
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: Color(0xFF8A8278),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8278),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      color: const Color(0xFFE8E3DA),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
    );
  }
}