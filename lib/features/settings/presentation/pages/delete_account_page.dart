import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter your password',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiServices.instance.deleteServices(
        url: AppApiUrl.instance.deleteAccount,
        body: {"password": _passwordController.text},
      );

      if (response != null && response["success"] == true) {
        await StorageServices.instance.logout();
        CustomSnackbar.show(
          title: 'Success',
          message: response["message"] ?? 'Profile deleted successfully',
        );
        Get.offAllNamed(Routes.login);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    Text(
                      'Deleting your account is permanent. Your focus history, friend connections, and settings will be vanished into the quietude.',
                      style: GoogleFonts.dmSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8278),
                        height: 28.8 / 18.0,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    _buildPasswordField(),
                    SizedBox(height: 32.h),
                    _buildDeleteButton(),
                  ],
                ),
              ),
            ),
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
              'Delete Account',
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A8278),
            height: 16.5 / 14.0,
            letterSpacing: 1.1.w,
          ),
        ),
        Container(
          height: 41.h,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8E3DA), width: 1.0),
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1814),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: '........',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8278).withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            cursorColor: const Color(0xFF1A1814),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _isLoading ? null : _deleteAccount,
      borderRadius: BorderRadius.circular(90.r),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFF141210),
          borderRadius: BorderRadius.circular(90.r),
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFF7F4EE),
            ),
          )
              : Text(
            'Permanently Delete Account',
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF7F4EE),
            ),
          ),
        ),
      ),
    );
  }
}