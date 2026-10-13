import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controllers/settings_controller.dart';

class PersonalReminderPage extends StatefulWidget {
  const PersonalReminderPage({super.key});

  @override
  State<PersonalReminderPage> createState() => _PersonalReminderPageState();
}

class _PersonalReminderPageState extends State<PersonalReminderPage> {
  late final TextEditingController _controller;
  final RxInt _charCount = 0.obs;
  final RxBool _isSaving = false.obs;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = Get.find<SettingsController>();

    // Initialize with controller value, but only if it's not the old placeholder
    final initialText = _settingsController.personalReminder.value;
    _controller = TextEditingController(text: initialText);
    _charCount.value = _controller.text.length;

    _controller.addListener(() {
      _charCount.value = _controller.text.length;
    });

    _settingsController.fetchPersonalReminder().then((_) {
      if (mounted) {
        _controller.text = _settingsController.personalReminder.value;
        _charCount.value = _controller.text.length;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    _isSaving.value = true;
    final success = await _settingsController.savePersonalReminder(
      _controller.text.trim(),
    );
    _isSaving.value = false;

    if (success) {
      Get.back();
      CustomSnackbar.show(
        title: 'Reminder Updated',
        message: 'Your personal reminder has been saved.',
      );
    } else {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to save reminder message.',
        isError: true,
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a mindful prompt for yourself. This will appear whenever you try to open a blocked app.',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE2).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE8E3DA),
                    width: 1.0,
                  ),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      maxLength: 120,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1A1814),
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Type your reminder here...\n(e.g., "Stay focused on your goals, not your screen.")',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF8A8278).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => Text(
                        '${_charCount.value} / 120',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: _charCount.value >= 110
                              ? Colors.red.shade300
                              : const Color(0xFFB5AFA5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14.sp,
                    color: const Color(0xFFB5AFA5),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'If left empty, a default mindful quote will be shown.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB5AFA5),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => GestureDetector(
                  onTap: _isSaving.value ? null : _handleSave,
                  child: Container(
                    height: 56.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1814),
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSaving.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFF7F4EE),
                              ),
                            )
                          : Text(
                              'Save Reminder',
                              style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF7F4EE),
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
