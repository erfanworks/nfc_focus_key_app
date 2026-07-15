import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 18.h),
                    _buildPasswordField(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                    ),

                    _buildDivider(),
                    SizedBox(height: 12.h),
                    _buildPasswordField(
                      label: 'New Password',
                      controller: _newPasswordController,
                    ),
                    _buildDivider(),

                    SizedBox(height: 12.h),
                    _buildPasswordField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                    ),

                    _buildDivider(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              'Change Password',
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8278),
              height: 16.5 / 14,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller,
            obscureText: true,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
              letterSpacing: 2.0,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '••••••••',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFB5AFA5),
                letterSpacing: 2.0,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            cursorColor: const Color(0xFF1A1814),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1.h, color: const Color(0xFFE8E3DA));
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: InkWell(
        onTap: () {
          // TODO: Implement save password logic
          Get.back();
        },
        borderRadius: BorderRadius.circular(90.r),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFF141210),
            borderRadius: BorderRadius.circular(90.r),
          ),
          child: Center(
            child: Text(
              'Save',
              style: GoogleFonts.dmSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF7F4EE),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
