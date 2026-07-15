import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class PersonalReminderPage extends StatefulWidget {
  const PersonalReminderPage({super.key});

  @override
  State<PersonalReminderPage> createState() => _PersonalReminderPageState();
}

class _PersonalReminderPageState extends State<PersonalReminderPage> {
  late final TextEditingController _controller;
  final RxInt _charCount = 0.obs;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = Get.find<SettingsController>();
    _controller = TextEditingController(
      text: _settingsController.personalReminder.value,
    );
    _charCount.value = _controller.text.length;
    _controller.addListener(() {
      _charCount.value = _controller.text.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 260.w,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: const Color(0xFF1A1814),
              ),
              SizedBox(width: 6.w),
              Text(
                'Personal Reminder',
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Write a short message to yourself for moments you feel distracted.',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                  height: 1.43,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                height: 149.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFE8E3DA),
                    width: 1.0,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: 120,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1814),
                  ),
                  decoration: InputDecoration(
                    hintText: 'I want to stay focused for..',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF8A8278).withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shown when you try to open a locked app.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFB5AFA5),
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${_charCount.value}/120',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1A1814).withValues(alpha: 0.40),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _settingsController.personalReminder.value = _controller.text;
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Reminder message saved successfully.',
                    backgroundColor: const Color(0xFFF0EBE2),
                    colorText: const Color(0xFF1A1814),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: EdgeInsets.all(20.w),
                    borderRadius: 14.r,
                  );
                },
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1814),
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Center(
                    child: Text(
                      'Save Message',
                      style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF7F4EE),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
