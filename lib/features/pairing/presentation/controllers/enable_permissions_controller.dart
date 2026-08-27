import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../routes/app_routes.dart';

class EnablePermissionsController extends GetxController with WidgetsBindingObserver {
  final accessibilityGranted = false.obs;
  final overlayGranted = false.obs;

  bool get allGranted => accessibilityGranted.value && overlayGranted.value;

  AppLockNativeService get _native => Get.find<AppLockNativeService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    accessibilityGranted.value = await _native.isAccessibilityPermissionGranted();
    overlayGranted.value = await _native.isOverlayPermissionGranted();
  }

  Future<void> enableAccessibility() => _native.requestAccessibilityPermission();
  Future<void> enableOverlay() => _native.requestOverlayPermission();

  void continueToApp() => Get.offNamed(Routes.letsUnlock);

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  static bool get isRelevantOnThisPlatform => Platform.isAndroid;
}