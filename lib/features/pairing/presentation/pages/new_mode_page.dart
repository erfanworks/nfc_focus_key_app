import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/focus_icons.dart';
import '../controllers/new_mode_controller.dart';

class NewModePage extends GetView<NewModeController> {
  const NewModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF141210),
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        controller.isEditMode.value ? controller.originalModeName.value : AppStrings.newModeTitle,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1A1814),
                          height: 1.0,
                          letterSpacing: 0,
                        ),
                      )),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.newModeSubtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _buildLabel(AppStrings.modeNameLabel),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        textController: controller.modeNameController,
                        hint: AppStrings.modeNameHint,
                        maxLength: 15,
                        showCounter: true,
                      ),
                      SizedBox(height: 24.h),
                      _buildLabel(AppStrings.descriptionLabel),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        textController: controller.descriptionController,
                        hint: AppStrings.descriptionHint,
                      ),
                      SizedBox(height: 24.h),
                      _buildLabel(AppStrings.selectIconLabel),
                      SizedBox(height: 16.h),
                      _buildIconGrid(context),
                      const Spacer(),
                      SizedBox(height: 24.h),
                      _buildStartButton(),
                      Obx(() {
                        if (controller.isEditMode.value) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: GestureDetector(
                                onTap: controller.deleteMode,
                                child: Container(
                                  width: double.infinity,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28.r),
                                    border: Border.all(
                                      color: const Color(0xFFC0392B),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Obx(() => controller.isDeleting.value
                                        ? SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFC0392B),
                                            ),
                                          )
                                        : Text(
                                            'Delete mode',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFFC0392B),
                                            ),
                                          )),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF8A8278),
        letterSpacing: 1.1,
        height: 16.5 / 11.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String hint,
    int? maxLength,
    bool showCounter = false,
  }) {
    return TextField(
      controller: textController,
      maxLength: maxLength,
      style: GoogleFonts.dmSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF141210),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB5AFA5),
        ),
        counterText: '', // Hide default counter
        suffix: showCounter
            ? Obx(
                () => Text(
                  '${controller.modeName.value.length}/$maxLength',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    color: const Color(0xFFB5AFA5),
                  ),
                ),
              )
            : null,
        contentPadding: EdgeInsets.only(bottom: 12.h, top: 12.h),
        isDense: true,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8E3DA), width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC4A97D), width: 1.0),
        ),
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    // We want 5 items per row, calculate the spacing to distribute evenly
    const int itemsPerRow = 5;
    final double itemSize = 60.w;
    final double totalItemWidth = itemSize * itemsPerRow;
    // Screen width minus the 40.w horizontal padding of the page
    final double remainingWidth =
        MediaQuery.of(context).size.width - 40.w - totalItemWidth;
    final double spacing = (remainingWidth / (itemsPerRow - 1)).clamp(
      0.0,
      double.infinity,
    );

    return Obx(
      () => Wrap(
        spacing: spacing,
        runSpacing: 16.h,
        children: List.generate(controller.icons.length, (index) {
          final isSelected = controller.selectedIconIndex.value == index;
          final icon = controller.icons[index];

          return ModeIconTile(
            icon: icon,
            selected: isSelected,
            onTap: () => controller.selectIcon(index),
            size: itemSize,
          );
        }),
      ),
    );
  }

  Widget _buildStartButton() {
    return Obx(() {
      final isNavigating = controller.isNavigating.value;
      return GestureDetector(
        onTap: isNavigating ? null : controller.onStartMode,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Center(
            child: isNavigating
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF7F4EE),
                    ),
                  )
                : Builder(builder: (_) {
                    if (controller.isEditMode.value) {
                      return Text(
                        'Continue',
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF7F4EE),
                        ),
                      );
                    }
                    final modeNameText = controller.modeName.value.isEmpty
                        ? 'Deep work'
                        : controller.modeName.value;
                    return Text(
                      '${AppStrings.startWithMode}$modeNameText',
                      style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF7F4EE),
                      ),
                    );
                  }),
          ),
        ),
      );
    });
  }
}
