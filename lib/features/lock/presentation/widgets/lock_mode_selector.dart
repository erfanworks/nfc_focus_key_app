import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
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
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.selectMode),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE2),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFC4A97D), width: 1.2.w, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: const Color(0xFFC4A97D), size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'CREATE MODE',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1814),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final selectedItem = modesController.modes.firstWhereOrNull((m) => m.title == modeTitle) ??
          ModeItem(modeTitle, '', FKIcon.deepwork);

      if (controller.selectedModeId == null && modesController.modes.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selectMode(modesController.modes.first);
        });
      }

      /*
      [START NEW CHANGE - LockModeSelector UX Update]
      Updated to be bigger and point to a new SelectModePage instead of a dialog.
      */
      return GestureDetector(
        onTap: () => Get.toNamed(Routes.selectMode),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), // Increased padding
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(24.r), // Slightly more rounded
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.2.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FocusIcon(
                selectedItem.icon,
                color: const Color(0xFFC4A97D),
                size: 20.r, // Increased icon size
              ),
              SizedBox(width: 8.w), // Increased spacing
              Text(
                selectedItem.title.replaceAll('.', ''),
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp, // Increased font size
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1814), // Darker text for prominence
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8.w), // Increased spacing
              Icon(
                Icons.chevron_right_rounded, // Changed to right arrow
                color: const Color(0xFFC4A97D),
                size: 20.r, // Increased arrow size
              ),
            ],
          ),
        ),
      );
      /* [END NEW CHANGE - LockModeSelector] */
    });
  }

  // Obsolete: Dialog is replaced by SelectModePage
  // void _showModesDialog(BuildContext context, ModesController modesController) { ... }

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