import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
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

  // iOS-only state
  final iosSelectedAppsCount = 0.obs;
  final iosSelectedCategoriesCount = 0.obs;
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
      if (isEditMode && _modeId != null) {
        _loadInitialDataIOS();
      } else {
        isLoading.value = false;
        iosSelectedAppsCount.value = (_args?['totalLockedApps'] as int?) ?? 0;
      }
    } else {
      /*
      [START NEW CHANGE - Performance Optimization]
      Calling _loadInitialData which handles parallel loading for better performance.
      */
      _loadInitialData();
      /* [END NEW CHANGE] */
    }
  }

  Future<void> _loadInitialDataIOS() async {
    try {
      isLoading.value = true;
      await _fetchIOSSelectionCounts();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchIOSSelectionCounts() async {
    if (_modeId == null) return;
    final counts = await Get.find<AppLockNativeService>().getIOSSelectedCounts(_modeId!);
    iosSelectedAppsCount.value = counts["apps"] ?? 0;
    iosSelectedCategoriesCount.value = counts["categories"] ?? 0;
  }

  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      
      // Parallel execution: Load apps and fetch selections at the same time
      await Future.wait([
        _loadInstalledApps(),
        if (isEditMode && _modeId != null) _fetchExistingSelections(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchExistingSelections() async {
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.updateMoodById(_modeId!),
      );

      if (response != null && response["success"] == true) {
        final List? lockedApps = response["data"]?["lockedApps"];
        if (lockedApps != null) {
          final packageNames = lockedApps.map((e) => e["packageName"] as String).toList();
          selectedForBlock.addAll(packageNames);
        }
      }
    } catch (e) {
      print("Error fetching existing selections: $e");
    }
  }

  Future<void> _loadInstalledApps() async {
    try {
      // Fetching apps with icons is heavy, but we've parallelized it with the API call
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

      final counts = await native.presentIOSAppPicker(_modeId!);
      iosSelectedAppsCount.value = counts["apps"] ?? 0;
      iosSelectedCategoriesCount.value = counts["categories"] ?? 0;
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

      final totalCount = iosSelectedAppsCount.value + iosSelectedCategoriesCount.value;

      final body = {
        "name": _args?['modeName'] ?? 'Custom Mode',
        "description": _args?['description'] ?? 'Custom blocklist',
        "icon": _iconToString(_args?['icon'] as FKIcon? ?? FKIcon.values.first),
        "lockedApps": [],
        "totalLockedApps": totalCount,
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