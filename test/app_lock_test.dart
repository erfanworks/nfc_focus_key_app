import 'package:flutter_test/flutter_test.dart';
import 'package:focus_key/core/services/storage_services.dart';
import 'package:focus_key/core/services/app_lock_native_service.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Lock Native Logic Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      
      // Initialize GetX services
      Get.testMode = true;
      if (Get.isRegistered<AppLockNativeService>()) {
        await Get.delete<AppLockNativeService>();
      }
      await Get.putAsync(() => AppLockNativeService().init());
    });

    test('Data Type Fix: is_lock_active should be stored as a boolean for Native side', () async {
      final service = Get.find<AppLockNativeService>();
      
      await service.activateLock(
        modeId: 'test_mode',
        androidPackageNames: ['com.test.app'],
      );

      // Native code expects "flutter.is_lock_active" to be a boolean
      // shared_preferences plugin prefixes keys with 'flutter.'
      expect(prefs.getBool('is_lock_active'), isTrue);
      expect(prefs.get('is_lock_active'), isA<bool>());
    });

    test('JSON Format Fix: locked_apps should be a valid JSON list for Native side', () async {
      final service = Get.find<AppLockNativeService>();
      final apps = ['com.instagram.android', 'com.facebook.katana'];
      
      await service.activateLock(
        modeId: 'test_mode',
        androidPackageNames: apps,
      );

      final String? jsonStr = prefs.getString('locked_apps');
      expect(jsonStr, isNotNull);
      
      final decoded = jsonDecode(jsonStr!);
      expect(decoded, isA<List>());
      expect(decoded, contains('com.instagram.android'));
    });

    test('Deactivation: should set is_lock_active to false', () async {
      final service = Get.find<AppLockNativeService>();
      
      await service.activateLock(modeId: 'x', androidPackageNames: []);
      expect(prefs.getBool('is_lock_active'), isTrue);
      
      await service.deactivateLock();
      expect(prefs.getBool('is_lock_active'), isFalse);
    });
  });
}
