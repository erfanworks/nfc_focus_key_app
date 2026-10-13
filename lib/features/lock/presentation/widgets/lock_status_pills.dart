import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/lock_controller.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../../../../core/widgets/focus_icons.dart';

class LockStatusPills extends StatefulWidget {
  final LockController controller;
  final String mode;

  const LockStatusPills({
    super.key,
    required this.controller,
    required this.mode,
  });

  @override
  State<LockStatusPills> createState() => _LockStatusPillsState();
}

class _LockStatusPillsState extends State<LockStatusPills>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 1.0),
          ),
          child: Obx(() {
            final modesController = Get.isRegistered<ModesController>()
                ? Get.find<ModesController>()
                : Get.put<ModesController>(ModesController());
            final selectedItem = modesController.modes
                    .firstWhereOrNull((m) => m.title == widget.mode) ??
                ModeItem(widget.mode, '', FKIcon.deepwork);

            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FocusIcon(
                  selectedItem.icon,
                  color: const Color(0xFFC4A97D),
                  size: 16.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  selectedItem.title.replaceAll('.', ''),
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8278),
                    letterSpacing: 0.55,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
