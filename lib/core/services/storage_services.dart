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
  final String resetToken          = "resetToken";
  final String user                = "user";
  final String language            = "language";
  final String isDarkMode          = "isDarkMode";
  final String appFirstTime        = "appFirstTime";
  final String appUserRollData     = "appUserRollData";
  final String selectedRole        = "selectedRole";

  // ==================== NFC Pairing (merged from previous dev's storage_service.dart) ====================
  final String pairedTagId         = "pairedTagId";

  // ==================== Onboarding (merged from previous dev's storage_service.dart) ====================
  final String completedOnboarding = "completedOnboarding";

  // ==================== Modes cache (migrated off GetStorage) ====================
  final String cachedModes = "cachedModes";

  // ==================== App Lock (NFC key lock/unlock, native shield sync) ====================
  final String isLockActiveInternal  = "internal_is_lock_active";
  final String activeModeId          = "active_mode_id";
  final String activeModeName        = "active_mode_name";
  final String isLockActive          = "is_lock_active";
  final String lockedApps            = "locked_apps";
  final String cachedReminderMessage = "cached_reminder_message";
  final String completedInitialSetup = "completedInitialSetup";
  final String lastSelectedModeId    = "last_selected_mode_id";
  final String lastSelectedModeName  = "last_selected_mode_name";
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

  // ==================== NFC Pairing ====================
  // Merged from previous developer's storage_service.dart (GetStorage -> SharedPreferences)

  /// Save the paired NFC tag's unique ID (UID) after successful pairing.
  Future<void> savePairedKeyId(String keyId) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.pairedTagId, keyId);
    } catch (e) {
      errorLog("savePairedKeyId", e);
    }
  }

  /// Get the paired NFC tag's unique ID (UID). Returns null if not paired.
  Future<String?> getPairedKeyId() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.pairedTagId);
    } catch (e) {
      errorLog("getPairedKeyId", e);
      return null;
    }
  }

  /// Clear/unpair the currently stored NFC tag ID.
  Future<void> clearPairedKeyId() async {
    try {
      final pref = await _pref;
      await pref.remove(StorageKey.instance.pairedTagId);
    } catch (e) {
      errorLog("clearPairedKeyId", e);
    }
  }

  /// Check if a tag is currently paired on this device.
  Future<bool> hasPairedKey() async {
    try {
      final pref = await _pref;
      return pref.containsKey(StorageKey.instance.pairedTagId);
    } catch (e) {
      errorLog("hasPairedKey", e);
      return false;
    }
  }

  // ==================== Onboarding ====================
  // Merged from previous developer's storage_service.dart (GetStorage -> SharedPreferences)

  Future<void> setCompletedOnboarding() async {
    try {
      final pref = await _pref;
      await pref.setBool(StorageKey.instance.completedOnboarding, true);
    } catch (e) {
      errorLog("setCompletedOnboarding", e);
    }
  }

  Future<bool> hasCompletedOnboarding() async {
    try {
      final pref = await _pref;
      return pref.getBool(StorageKey.instance.completedOnboarding) ?? false;
    } catch (e) {
      errorLog("hasCompletedOnboarding", e);
      return false;
    }
  }

  Future<void> setCompletedInitialSetup() async {
    try {
      final pref = await _pref;
      await pref.setBool(StorageKey.instance.completedInitialSetup, true);
    } catch (e) {
      errorLog("setCompletedInitialSetup", e);
    }
  }

  Future<bool> hasCompletedInitialSetup() async {
    try {
      final pref = await _pref;
      return pref.getBool(StorageKey.instance.completedInitialSetup) ?? false;
    } catch (e) {
      errorLog("hasCompletedInitialSetup", e);
      return false;
    }
  }

  // ==================== Modes Cache ====================
  Future<void> cacheModes(List<Map<String, dynamic>> modes) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.cachedModes, jsonEncode(modes));
    } catch (e) {
      errorLog("cacheModes", e);
    }
  }

  Future<List<Map<String, dynamic>>> getCachedModes() async {
    try {
      final pref = await _pref;
      final raw = pref.getString(StorageKey.instance.cachedModes) ?? "";
      if (raw.isEmpty) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      errorLog("getCachedModes", e);
      return [];
    }
  }

  // ==================== Generic Key-Value (for feature-level local caches) ====================
  Future<void> setValue(String key, String value) async {
    try {
      final pref = await _pref;
      await pref.setString(key, value);
    } catch (e) {
      errorLog("setValue:$key", e);
    }
  }

  Future<void> setBoolValue(String key, bool value) async {
    try {
      final pref = await _pref;
      await pref.setBool(key, value);
    } catch (e) {
      errorLog("setBoolValue:$key", e);
    }
  }

  Future<String?> getValue(String key) async {
    try {
      final pref = await _pref;
      return pref.getString(key);
    } catch (e) {
      errorLog("getValue:$key", e);
      return null;
    }
  }



  Future<void> setLockActive(bool value) async {
    try {
      final pref = await _pref;
      await pref.setBool(StorageKey.instance.isLockActiveInternal, value);
    } catch (e) {
      errorLog("setLockActive", e);
    }
  }

  Future<bool> isLockActive() async {
    try {
      final pref = await _pref;
      return pref.getBool(StorageKey.instance.isLockActiveInternal) ?? false;
    } catch (e) {
      errorLog("isLockActive", e);
      return false;
    }
  }

  Future<void> setActiveModeId(String? modeId) async {
    try {
      final pref = await _pref;
      if (modeId == null) {
        await pref.remove(StorageKey.instance.activeModeId);
      } else {
        await pref.setString(StorageKey.instance.activeModeId, modeId);
      }
    } catch (e) {
      errorLog("setActiveModeId", e);
    }
  }

  Future<String?> getActiveModeId() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.activeModeId);
    } catch (e) {
      errorLog("getActiveModeId", e);
      return null;
    }
  }

  Future<void> setActiveModeName(String? name) async {
    try {
      final pref = await _pref;
      if (name == null) {
        await pref.remove(StorageKey.instance.activeModeName);
      } else {
        await pref.setString(StorageKey.instance.activeModeName, name);
      }
    } catch (e) {
      errorLog("setActiveModeName", e);
    }
  }

  Future<String?> getActiveModeName() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.activeModeName);
    } catch (e) {
      errorLog("getActiveModeName", e);
      return null;
    }
  }

  /// Android package names only (e.g. com.instagram.android).
  /// iOS locked-app identity (opaque ApplicationToken) native side e alada
  /// App Group storage e thake — eikhane jabe na.
  Future<void> setLockedApps(List<String> packageNames) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.lockedApps, jsonEncode(packageNames));
    } catch (e) {
      errorLog("setLockedApps", e);
    }
  }

  Future<List<String>> getLockedApps() async {
    try {
      final pref = await _pref;
      final raw = pref.getString(StorageKey.instance.lockedApps) ?? "";
      if (raw.isEmpty) return [];
      return List<String>.from(jsonDecode(raw));
    } catch (e) {
      errorLog("getLockedApps", e);
      return [];
    }
  }

  Future<void> cacheReminderMessage(String message) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.cachedReminderMessage, message);
    } catch (e) {
      errorLog("cacheReminderMessage", e);
    }
  }

  Future<String> getCachedReminderMessage() async {
    try {
      final pref = await _pref;
      return pref.getString(StorageKey.instance.cachedReminderMessage) ?? "";
    } catch (e) {
      errorLog("getCachedReminderMessage", e);
      return "";
    }
  }

  // ==================== Selection Persistence ====================
  Future<void> setLastSelectedMode(String id, String name) async {
    try {
      final pref = await _pref;
      await pref.setString(StorageKey.instance.lastSelectedModeId, id);
      await pref.setString(StorageKey.instance.lastSelectedModeName, name);
    } catch (e) {
      errorLog("setLastSelectedMode", e);
    }
  }

  Future<Map<String, String?>> getLastSelectedMode() async {
    try {
      final pref = await _pref;
      return {
        "id": pref.getString(StorageKey.instance.lastSelectedModeId),
        "name": pref.getString(StorageKey.instance.lastSelectedModeName),
      };
    } catch (e) {
      errorLog("getLastSelectedMode", e);
      return {"id": null, "name": null};
    }
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
        pref.remove(StorageKey.instance.cachedModes),
      ]);
    } catch (e) {
      errorLog("logout", e);
    }
  }
}