import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class EditInformationPage extends StatefulWidget {
  const EditInformationPage({super.key});

  @override
  State<EditInformationPage> createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  late final SettingsController _settingsController;
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _settingsController = Get.find<SettingsController>();
    _nameController = TextEditingController(text: _settingsController.userName.value);
    _contactController = TextEditingController(text: _settingsController.userContact.value);
    _emailController = TextEditingController(text: _settingsController.userEmail.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
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
                    _buildTextField(label: 'NAME', controller: _nameController),
                    _buildDivider(),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      label: 'CONTACT NO',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDivider(),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      label: 'EMAIL',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
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
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 8.h),
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
              'Edit Information',
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
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
            keyboardType: keyboardType,
            enabled: enabled,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: enabled
                  ? const Color(0xFF1A1814)
                  : const Color(0xFF1A1814).withValues(alpha: 0.5),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
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
          _settingsController.userName.value = _nameController.text.trim();
          _settingsController.userContact.value = _contactController.text.trim();
          _settingsController.userEmail.value = _emailController.text.trim();
          Get.back();
          Get.snackbar(
            'Success',
            'Information updated successfully.',
            backgroundColor: const Color(0xFFF0EBE2),
            colorText: const Color(0xFF1A1814),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(20.w),
            borderRadius: 14.r,
          );
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
              'Save Change',
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
