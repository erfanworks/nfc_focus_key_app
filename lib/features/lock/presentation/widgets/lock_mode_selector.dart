import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../../../../core/widgets/focus_icons.dart';

class LockModeSelector extends StatelessWidget {
  final LockController controller;

  const LockModeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final modesController = Get.isRegistered<ModesController>()
          ? Get.find<ModesController>()
          : Get.put<ModesController>(ModesController());
      final modeTitle = controller.selectedMode.value;

      if (modesController.modes.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedItem = modesController.modes.firstWhere(
            (m) => m.title == modeTitle,
        orElse: () => modesController.modes.first,
      );

      if (controller.selectedModeId == null && modesController.modes.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selectMode(modesController.modes.first);
        });
      }

      return GestureDetector(
        onTap: () => _showModesDialog(context, modesController),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FocusIcon(
                selectedItem.icon,
                color: const Color(0xFFC4A97D),
                size: 16.r,
              ),
              SizedBox(width: 4.w),
              Text(
                selectedItem.title.replaceAll('.', ''),
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8278),
                  letterSpacing: 0.55,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF8A8278),
                size: 16.r,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showModesDialog(BuildContext context, ModesController modesController) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4EE),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1814).withValues(alpha: 0.08),
                offset: const Offset(0, 10),
                blurRadius: 30.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: modesController.modes.length,
                itemBuilder: (context, index) {
                  return _buildDialogItem(modesController.modes[index]);
                },
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.15),
    );
  }

  Widget _buildDialogItem(ModeItem mode) {
    return Obx(() {
      final isSelected = controller.selectedMode.value == mode.title;
      final Color color = isSelected
          ? const Color(0xFFC4A97D)
          : const Color(0xFF8A8278);

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: GestureDetector(
          onTap: () {
            controller.selectMode(mode);
            Get.back();
          },
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0EBE2) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              border: isSelected
                  ? Border.all(color: const Color(0xFFE8E3DA), width: 1.0)
                  : null,
            ),
            child: Row(
              children: [
                FocusIcon(mode.icon, color: color, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  mode.title.replaceAll('.', '').toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: const Color(0xFFC4A97D),
                    size: 12.sp,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}