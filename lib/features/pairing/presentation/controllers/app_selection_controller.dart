import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

import '../../../../routes/app_routes.dart';
import '../../../../core/widgets/focus_icons.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/app_lock_native_service.dart';
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

  final selectedForBlock = <String>{}.obs;
  final selectedForAllowOnly = <String>{}.obs;

  final isBlockMode = true.obs;

  // iOS-only state — FamilyActivityPicker returns a count, not names.
  final iosSelectedAppsCount = 0.obs;
  final isIOSBusy = false.obs;

  Map<String, dynamic>? _args;
  String? _modeId;

  bool get isEditMode => _args?['isEditMode'] == true;

  @override
  void onInit() {
    super.onInit();
    _args = Get.arguments as Map<String, dynamic>?;
    _modeId = _args?['modeId'] as String?;

    if (Platform.isIOS) {
      isLoading.value = false;
      iosSelectedAppsCount.value = (_args?['totalLockedApps'] as int?) ?? 0;
    } else {
      _loadInstalledApps();
    }
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
        title: "App Load Error",
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
    return apps
        .where((a) => !selectedForAllowOnly.contains(a.packageName))
        .map((a) => {"packageName": a.packageName, "appName": a.name})
        .toList();
  }

  // ==================== iOS flow ====================

  Future<void> onIOSSelectApps() async {
    if (isIOSBusy.value) return;
    final native = Get.find<AppLockNativeService>();

    try {
      isIOSBusy.value = true;

      if (!await native.isIOSAuthorized()) {
        final granted = await native.requestIOSAuthorization();
        if (!granted) {
          CustomSnackbar.show(
            title: "Permission Needed",
            message: "Screen Time access is required to select apps to lock.",
            isError: true,
          );
          return;
        }
      }

      if (_modeId == null || _modeId!.isEmpty) {
        final created = await _createDraftMode();
        if (!created) return;
      }

      final count = await native.presentIOSAppPicker(_modeId!);
      iosSelectedAppsCount.value = count;
    } finally {
      isIOSBusy.value = false;
    }
  }

  Future<bool> _createDraftMode() async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.createMood,
        body: {
          "name": _args?['modeName'] ?? 'Custom Mode',
          "description": _args?['description'] ?? 'Custom blocklist',
          "icon": _iconToString(_args?['icon'] as FKIcon? ?? FKIcon.values.first),
          "lockedApps": [],
          "totalLockedApps": 0,
        },
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Save Failed",
          message: response?["message"] ?? "Could not create focus mode.",
          isError: true,
        );
        return false;
      }

      _modeId = response["data"]?["_id"] as String?;
      return _modeId != null && _modeId!.isNotEmpty;
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Issue",
        message: "Failed to create mode. Please check your internet.",
        isError: true,
      );
      return false;
    }
  }

  Future<void> _onDoneIOS() async {
    if (_modeId == null || _modeId!.isEmpty) {
      CustomSnackbar.show(
        title: "Select Apps First",
        message: "Please select at least one app to lock before saving.",
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
        "lockedApps": [],
        "totalLockedApps": iosSelectedAppsCount.value,
      };

      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.updateMoodById(_modeId!),
        body: body,
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Save Failed",
          message: response?["message"] ?? "Could not save focus mode details.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(
        title: isEditMode ? "Mode Updated" : "Mode Created",
        message: "\"${body['name']}\" is ready to use.",
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      Get.close(2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.find<ModesController>().fetchModes();
        } catch (_) {}
      });
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Issue",
        message: "Failed to save mode. Please check your internet.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Shared entry point ====================

  Future<void> onDone() async {
    if (isSubmitting.value) return;

    if (Platform.isIOS) {
      await _onDoneIOS();
      return;
    }

    if (isEditMode && (_modeId == null || _modeId!.isEmpty)) {
      CustomSnackbar.show(
        title: "Update Error",
        message: "Missing mode identifier. Please try again.",
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
          ? await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.updateMoodById(_modeId!),
        body: body,
      )
          : await ApiServices.instance.postServices(
        url: AppApiUrl.instance.createMood,
        body: body,
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Save Failed",
          message: response?["message"] ?? "Could not save focus mode details.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(
        title: isEditMode ? "Mode Updated" : "Mode Created",
        message: "\"${body['name']}\" is ready to use.",
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      Get.close(2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.find<ModesController>().fetchModes();
        } catch (_) {}
      });
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Issue",
        message: "Failed to save mode. Please check your internet.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}