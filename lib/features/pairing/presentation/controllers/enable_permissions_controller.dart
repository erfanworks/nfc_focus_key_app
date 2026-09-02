import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../routes/app_routes.dart';

class EnablePermissionsController extends GetxController with WidgetsBindingObserver {
  final accessibilityGranted = false.obs;
  final overlayGranted = false.obs;
  final batteryOptimizationIgnored = false.obs;
  final usageAccessGranted = false.obs;

  bool get allGranted =>
      accessibilityGranted.value &&
      overlayGranted.value &&
      batteryOptimizationIgnored.value &&
      usageAccessGranted.value;

  AppLockNativeService get _native => Get.find<AppLockNativeService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _native.requestNotificationPermission();
    _refreshStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus() async { 
    accessibilityGranted.value = await _native.isAccessibilityPermissionGranted();
    overlayGranted.value = await _native.isOverlayPermissionGranted();
    batteryOptimizationIgnored.value = await _native.isBatteryOptimizationIgnored();
    usageAccessGranted.value = await _native.isUsageAccessPermissionGranted();
  }

  Future<void> enableAccessibility() => _native.requestAccessibilityPermission();
  Future<void> enableOverlay() => _native.requestOverlayPermission();
  Future<void> enableBatteryOptimization() => _native.requestIgnoreBatteryOptimization();
  Future<void> enableUsageAccess() => _native.requestUsageAccessPermission();

  void continueToApp() => Get.offNamed(Routes.letsUnlock);

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  static bool get isRelevantOnThisPlatform => Platform.isAndroid;

  Future<bool> checkAllPermissionsGranted() async {
    await _refreshStatus();
    return allGranted;
  }
}