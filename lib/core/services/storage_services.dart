import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/log_print.dart';

class StorageKey {
  StorageKey._privateConstructor();
  static final StorageKey _instance = StorageKey._privateConstructor();
  static StorageKey get instance => _instance;

  final String storageContainerKey = "storageContainerKey";
  final String loginDataStore      = "loginDataStore";
  final String token               = "token";
  final String refreshToken        = "refreshToken";
  final String resetToken          = "resetToken";       // ✅ new
  final String user                = "user";
  final String language            = "language";
  final String isDarkMode          = "isDarkMode";
  final String appFirstTime        = "appFirstTime";
  final String appUserRollData     = "appUserRollData";
  final String selectedRole        = "selectedRole";
}

class StorageServices {
  StorageServices._privateConstructor();
  static final StorageServices _instance = StorageServices._privateConstructor();
  static StorageServices get instance => _instance;

  Future<SharedPreferences> get _pref => SharedPreferences.getInstance();

  // ==================== Login Data ====================
  Future<void> setLogDedData(Map<String, dynamic> data) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.loginDataStore, jsonEncode(data));
    } catch (e) {
      errorLog("setLogDedData", e);
    }
  }

  Future<Map<String, dynamic>> getLogDedData() async {
    try {
      final pref = await _pref;
      final raw = pref.getString(StorageKey.instance.loginDataStore) ?? "";
      if (raw.isEmpty) return {};
      return jsonDecode(raw);
    } catch (e) {
      errorLog("getLogDedData", e);
      return {};
    }
  }

  // ==================== Access Token ====================
  Future<void> setToken(String value) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.token, value);
    } catch (e) {
      errorLog("setToken", e);
    }
  }

  Future<String> getToken() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.token) ?? "";
    } catch (e) {
      errorLog("getToken", e);
      return "";
    }
  }

  // ==================== Refresh Token ====================
  Future<void> setRefreshToken(String value) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.refreshToken, value);
    } catch (e) {
      errorLog("setRefreshToken", e);
    }
  }

  Future<String> getRefreshToken() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.refreshToken) ?? "";
    } catch (e) {
      errorLog("getRefreshToken", e);
      return "";
    }
  }

  // ==================== Reset Token ====================
  Future<void> setResetToken(String value) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.resetToken, value);
    } catch (e) {
      errorLog("setResetToken", e);
    }
  }

  Future<String> getResetToken() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.resetToken) ?? "";
    } catch (e) {
      errorLog("getResetToken", e);
      return "";
    }
  }

  Future<void> clearResetToken() async {
    try {
      final pref = await _pref;
      await pref.remove(StorageKey.instance.resetToken);
    } catch (e) {
      errorLog("clearResetToken", e);
    }
  }

  // ==================== User Role ====================
  Future<void> setAppRoll(String value) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.appUserRollData, value);
    } catch (e) {
      errorLog("setAppRoll", e);
    }
  }

  Future<String> getAppRoll() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.appUserRollData) ?? "";
    } catch (e) {
      errorLog("getAppRoll", e);
      return "";
    }
  }

  // ==================== Selected Role ====================
  Future<void> saveSelectedRole(String role) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.selectedRole, role);
    } catch (e) {
      errorLog("saveSelectedRole", e);
    }
  }

  Future<String?> getSelectedRole() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.selectedRole);
    } catch (e) {
      errorLog("getSelectedRole", e);
      return null;
    }
  }

  Future<void> clearSelectedRole() async {
    try {
      final pref = await _pref;
      await pref.remove(StorageKey.instance.selectedRole);
    } catch (e) {
      errorLog("clearSelectedRole", e);
    }
  }

  // ==================== Language ====================
  Future<void> setLanguage(String value) async {
    final pref = await _pref;
    await pref.setString(StorageKey.instance.language, value);
  }

  Future<String> getLanguage() async {
    final pref = await _pref;
    return pref.getString(StorageKey.instance.language) ?? "";
  }

  // ==================== Dark Mode ====================
  Future<void> setDarkMode(bool value) async {
    final pref = await _pref;
    await pref.setBool(StorageKey.instance.isDarkMode, value);
  }

  Future<bool> isDarkMode() async {
    final pref = await _pref;
    return pref.getBool(StorageKey.instance.isDarkMode) ?? true;
  }

  // ==================== First Time ====================
  Future<void> setAppFirstTime() async {
    try {
      final pref = await _pref;
      await pref.setBool(StorageKey.instance.appFirstTime, false);
    } catch (e) {
      errorLog("setAppFirstTime", e);
    }
  }

  Future<bool> getAppFirstTime() async {
    final pref = await _pref;
    return pref.getBool(StorageKey.instance.appFirstTime) ?? true;
  }

  // ==================== Logout ====================
  Future<void> logout() async {
    try {
      final pref = await _pref;
      await Future.wait([
        pref.remove(StorageKey.instance.token),
        pref.remove(StorageKey.instance.refreshToken),
        pref.remove(StorageKey.instance.resetToken),
        pref.remove(StorageKey.instance.loginDataStore),
        pref.remove(StorageKey.instance.appUserRollData),
        pref.remove(StorageKey.instance.selectedRole),
      ]);
    } catch (e) {
      errorLog("logout", e);
    }
  }
}