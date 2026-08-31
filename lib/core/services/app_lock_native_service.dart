import 'dart:io';
import 'package:flutter/services.dart';
import 'package:focus_key/core/services/storage_services.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class AppLockNativeService extends GetxService {
  static const MethodChannel _channel =
  MethodChannel('com.presencelabsllp.focuskeyapp/app_lock');

  Future<AppLockNativeService> init() async {
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'showShield':
        final packageName = call.arguments['packageName'] as String? ?? '';
        Get.toNamed(Routes.shield, arguments: {'packageName': packageName});
        break;
    }
  }

  Future<bool> isAccessibilityPermissionGranted() async {
    final result = await _channel.invokeMethod<bool>('isAccessibilityPermissionGranted');
    return result ?? false;
  }

  Future<void> requestAccessibilityPermission() async {
    await _channel.invokeMethod('requestAccessibilityPermission');
  }

  Future<bool> isOverlayPermissionGranted() async {
    final result = await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
    return result ?? false;
  }

  Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  Future<void> requestNotificationPermission() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('requestNotificationPermission');
  }

  Future<bool> isIOSAuthorized() async {
    if (!Platform.isIOS) return false;
    final result = await _channel.invokeMethod<bool>('isAuthorized');
    return result ?? false;
  }

  Future<bool> requestIOSAuthorization() async {
    if (!Platform.isIOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('requestAuthorization');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<int> presentIOSAppPicker(String modeId) async {
    if (!Platform.isIOS) return 0;
    final count = await _channel.invokeMethod<int>('presentAppPicker', {'modeId': modeId});
    return count ?? 0;
  }

  Future<void> applyIOSShield(String modeId) async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod('applyShield', {'modeId': modeId});
  }

  Future<void> removeIOSShield() async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod('removeShield');
  }

  /// Call this after NFC scan toggles lock ON. Handles both platforms.
  Future<void> activateLock({
    required String modeId,
    required List<String> androidPackageNames,
  }) async {
    // FORCE SET both keys for cross-platform and native visibility
    await StorageServices.instance.setLockActive(true);
    // Explicitly update the raw shared preference for Android Native process
    await StorageServices.instance.setValue("is_lock_active", "true"); 
    
    await StorageServices.instance.setLockedApps(androidPackageNames);
    
    print("!!! ANDROID LOCK FORCE ACTIVATED: ${androidPackageNames.length} apps");
    
    if (Platform.isIOS) {
      await applyIOSShield(modeId);
    }
  }

  /// Call this after NFC scan toggles lock OFF. Handles both platforms.
  Future<void> deactivateLock() async {
    await StorageServices.instance.setLockActive(false);
    await StorageServices.instance.setValue("is_lock_active", "false");
    if (Platform.isIOS) {
      await removeIOSShield();
    }
  }
}
