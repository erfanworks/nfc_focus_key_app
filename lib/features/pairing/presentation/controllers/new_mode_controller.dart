import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';
import '../controllers/modes_controller.dart';
import '../../../../core/widgets/focus_icons.dart';

class NewModeController extends GetxController {
  final modeNameController = TextEditingController();
  final descriptionController = TextEditingController();

  final modeName = ''.obs;
  final selectedIconIndex = 0.obs;
  
  final isEditMode = false.obs;
  final isDeleting = false.obs;
  final isNavigating = false.obs;
  final originalModeName = ''.obs;
  String? _modeId;
  int _totalLockedApps = 0;

  final icons = FKIcon.values;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['isEditMode'] == true) {
      isEditMode.value = true;
      originalModeName.value = args['modeName'] ?? '';
      _modeId = args['modeId'] as String?;
      _totalLockedApps = args['totalLockedApps'] as int? ?? 0;
      modeNameController.text = originalModeName.value;
      modeName.value = originalModeName.value;
      
      // Pre-select icon if it was passed in arguments (optional enhancement)
      if (args['icon'] != null && args['icon'] is FKIcon) {
        selectedIconIndex.value = icons.indexOf(args['icon'] as FKIcon);
      }
    }

    modeNameController.addListener(() {
      modeName.value = modeNameController.text;
    });
  }

  @override
  void onClose() {
    modeNameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void selectIcon(int index) {
    selectedIconIndex.value = index;
  }

  void onStartMode() async {
    if (isNavigating.value) return;
    
    isNavigating.value = true;
    
    // Brief delay to allow the loader to be seen and feel smooth
    await Future.delayed(const Duration(milliseconds: 300));

    Get.toNamed(
      Routes.appSelection,
      arguments: {
        'modeName': modeName.value.isEmpty ? 'Deep Work' : modeName.value,
        'description': descriptionController.text.isEmpty ? 'Custom blocklist' : descriptionController.text,
        'icon': icons[selectedIconIndex.value],
        'isEditMode': isEditMode.value,
        'modeId': _modeId,
        'totalLockedApps': _totalLockedApps,
      },
    );
    
    // Reset after a short delay so it's ready if they come back
    await Future.delayed(const Duration(milliseconds: 500));
    isNavigating.value = false;
  }

  Future<void> deleteMode() async {
    if (_modeId == null || _modeId!.isEmpty) return;

    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    try {
      isDeleting.value = true;
      final response = await ApiServices.instance.deleteServices(
        url: "${AppApiUrl.instance.deleteMoodById}/$_modeId",
      );

      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: "Mode Deleted",
          message: "\"${originalModeName.value}\" has been removed.",
        );
        
        // Refresh modes list and handle selected mode cleanup
        try {
          final modesController = Get.find<ModesController>();
          final lockController = Get.find<LockController>();

          // If the deleted mode was the one selected on the lock screen, reset it
          if (lockController.selectedModeId == _modeId) {
            // Find a fallback mode (excluding the one we just deleted)
            final fallbackMode = modesController.modes.firstWhereOrNull((m) => m.id != _modeId);
            if (fallbackMode != null) {
              lockController.selectMode(fallbackMode);
            } else {
              // No other modes left, clear selection
              lockController.selectedMode.value = 'Select Mode';
              lockController.selectedModeIdRx.value = null;
            }
          }
          
          modesController.fetchModes();
        } catch (_) {}

        Get.back(); // Back to previous screen (e.g., Select Mode Page)
      } else {
        CustomSnackbar.show(
          title: "Delete Failed",
          message: response?["message"] ?? "Could not delete this focus mode.",
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Issue",
        message: "Failed to delete mode. Please check your internet.",
        isError: true,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: const Color(0xFFF7F4EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Mode?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1814),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to remove "${originalModeName.value}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: const Color(0xFF8A8278),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8A8278),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
