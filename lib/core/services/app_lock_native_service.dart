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
    // Native handles the shield now, no need for Dart listener
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    return null;
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

  Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
    return result ?? true;
  }

  Future<void> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('requestIgnoreBatteryOptimization');
  }

  Future<bool> isUsageAccessPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    final result = await _channel.invokeMethod<bool>('isUsageAccessPermissionGranted');
    return result ?? true;
  }

  Future<void> requestUsageAccessPermission() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('requestUsageAccessPermission');
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

  Future<Map<String, int>> presentIOSAppPicker(String modeId) async {
    if (!Platform.isIOS) return {"apps": 0, "categories": 0};
    try {
      final result = await _channel.invokeMapMethod<String, int>('presentAppPicker', {'modeId': modeId});
      if (result != null) {
        return {
          "apps": result["apps"] ?? 0,
          "categories": result["categories"] ?? 0,
        };
      }
    } catch (e) {
      print("Error presenting iOS app picker: $e");
    }
    return {"apps": 0, "categories": 0};
  }

  Future<Map<String, int>> getIOSSelectedCounts(String modeId) async {
    if (!Platform.isIOS) return {"apps": 0, "categories": 0};
    try {
      final result = await _channel.invokeMapMethod<String, int>('getSelectedCounts', {'modeId': modeId});
      if (result != null) {
        return {
          "apps": result["apps"] ?? 0,
          "categories": result["categories"] ?? 0,
        };
      }
    } catch (e) {
      print("Error fetching iOS selection counts: $e");
    }
    return {"apps": 0, "categories": 0};
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
    // Use setBoolValue to ensure the native side can read it as a Boolean
    await StorageServices.instance.setBoolValue("is_lock_active", true);
    
    await StorageServices.instance.setLockedApps(androidPackageNames);
    
    print("!!! ANDROID LOCK FORCE ACTIVATED: ${androidPackageNames.length} apps");
    
    if (Platform.isIOS) {
      await applyIOSShield(modeId);
    }
  }

  Future<void> cacheReminderMessage(String message) async {
    await StorageServices.instance.cacheReminderMessage(message);
    if (Platform.isIOS) {
      await _channel.invokeMethod('cacheReminderMessage', {'message': message});
    }
  }
  /// Call this after NFC scan toggles lock OFF. Handles both platforms.
  Future<void> deactivateLock() async {
    await StorageServices.instance.setLockActive(false);
    await StorageServices.instance.setBoolValue("is_lock_active", false);
    if (Platform.isIOS) {
      await removeIOSShield();
    }
  }
}
