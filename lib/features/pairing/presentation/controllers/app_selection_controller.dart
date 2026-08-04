import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/focus_icons.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../controllers/modes_controller.dart';

class AppItem {
  final String packageName;
  final String name;
  final Uint8List? icon;

  AppItem({required this.packageName, required this.name, this.icon});
}

class AppSelectionController extends GetxController {
  final apps = <AppItem>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  // Independent selections per tab — Block tab picks apps to block,
  // Allow-only tab picks apps to keep allowed (everything else gets blocked).
  final selectedForBlock = <String>{}.obs;
  final selectedForAllowOnly = <String>{}.obs;

  final isBlockMode = true.obs;

  Map<String, dynamic>? _args;
  String? _modeId;

  @override
  void onInit() {
    super.onInit();
    _args = Get.arguments as Map<String, dynamic>?;
    _modeId = _args?['modeId'] as String?;
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    try {
      isLoading.value = true;
      final List<AppInfo> installed = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      apps.value = installed
          .map((a) => AppItem(
        packageName: a.packageName,
        name: a.name,
        icon: a.icon,
      ))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      CustomSnackbar.show(
        title: "Couldn't load apps",
        message: "Failed to fetch installed apps from this device.",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  RxSet<String> get _activeSelection =>
      isBlockMode.value ? selectedForBlock : selectedForAllowOnly;

  bool isSelected(String packageName) =>
      _activeSelection.contains(packageName);

  int get selectedCount => _activeSelection.length;

  void toggleApp(String packageName) {
    if (_activeSelection.contains(packageName)) {
      _activeSelection.remove(packageName);
    } else {
      _activeSelection.add(packageName);
    }
  }

  void setBlockMode(bool val) {
    isBlockMode.value = val;
  }

  String _iconToString(FKIcon icon) => icon.name;

  List<Map<String, String>> _computeLockedApps() {
    if (isBlockMode.value) {
      return apps
          .where((a) => selectedForBlock.contains(a.packageName))
          .map((a) => {"packageName": a.packageName, "appName": a.name})
          .toList();
    }
    // Allow-only mode: everything NOT selected gets locked.
    return apps
        .where((a) => !selectedForAllowOnly.contains(a.packageName))
        .map((a) => {"packageName": a.packageName, "appName": a.name})
        .toList();
  }

  Future<void> onDone() async {
    if (isSubmitting.value) return;

    final isEditMode = _args?['isEditMode'] == true;
    if (isEditMode && (_modeId == null || _modeId!.isEmpty)) {
      CustomSnackbar.show(
        title: "Cannot update mode",
        message: "Missing mode ID for this edit session.",
        isError: true,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final body = {
        "name": _args?['modeName'] ?? 'Custom Mode',
        "description": _args?['description'] ?? 'Custom blocklist',
        "icon": _iconToString(_args?['icon'] as FKIcon? ?? FKIcon.values.first),
        "lockedApps": _computeLockedApps(),
      };

      final response = isEditMode
          ? await ApiServices.instance.putServices(
        url: AppApiUrl.instance.updateMoodById(_modeId!),
        body: body,
      )
          : await ApiServices.instance.postServices(
        url: AppApiUrl.instance.createMood,
        body: body,
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Failed",
          message: response?["message"] ?? "Could not save this mode.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(
        title: isEditMode ? "Mode updated" : "Mode created",
        message: "\"${body['name']}\" is ready.",
      );

      Get.close(2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.find<ModesController>().fetchModes();
        } catch (_) {}
      });
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}