import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';

import '../../../../core/widgets/focus_icons.dart';

class NewModeController extends GetxController {
  final modeNameController = TextEditingController();
  final descriptionController = TextEditingController();

  final modeName = ''.obs;
  final selectedIconIndex = 0.obs;
  
  final isEditMode = false.obs;
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
      // Pre-fill description and icon if needed
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

  void onStartMode() {
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
  }

  void deleteMode() {
    // In a real app, delete from repository/controller. For now, navigate back.
    Get.back();
  }
}
