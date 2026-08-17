import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        Get.toNamed('/shield', arguments: {'packageName': packageName});
        break;
    }
  }

  Future<bool> isAccessibilityPermissionGranted() async {
    final result =
        await _channel.invokeMethod<bool>('isAccessibilityPermissionGranted');
    return result ?? false;
  }

  Future<void> requestAccessibilityPermission() async {
    await _channel.invokeMethod('requestAccessibilityPermission');
  }

  Future<bool> isOverlayPermissionGranted() async {
    final result =
        await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
    return result ?? false;
  }

  Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  Future<void> setLockActive(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flutter.is_lock_active', isActive);
  }

  Future<void> setLockedApps(List<String> packageNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter.locked_apps', jsonEncode(packageNames));
  }

  Future<void> cacheReminderMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter.cached_reminder_message', message);
  }
}
