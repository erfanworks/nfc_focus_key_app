// import 'package:get_storage/get_storage.dart';
//
// class StorageService {
//   static final GetStorage _box = GetStorage();
//
//   // Initialize storage
//   static Future<void> init() async {
//     await GetStorage.init();
//   }
//
//   // Key for paired NFC unique ID
//   static const String _keyPairedTagId = 'paired_tag_id';
//
//   // Save the paired NFC tag's unique ID
//   static Future<void> savePairedKeyId(String keyId) async {
//     await _box.write(_keyPairedTagId, keyId);
//   }
//
//   // Get the paired NFC tag's unique ID
//   static String? getPairedKeyId() {
//     return _box.read<String>(_keyPairedTagId);
//   }
//
//   // Clear/Unpair the NFC tag
//   static Future<void> clearPairedKeyId() async {
//     await _box.remove(_keyPairedTagId);
//   }
//
//   // Check if a tag is paired
//   static bool hasPairedKey() {
//     return _box.hasData(_keyPairedTagId);
//   }
//
//   static const String _keyCompletedOnboarding = 'completed_onboarding';
//
//   static Future<void> setCompletedOnboarding() async {
//     await _box.write(_keyCompletedOnboarding, true);
//   }
//
//   static bool hasCompletedOnboarding() {
//     return _box.read<bool>(_keyCompletedOnboarding) ?? false;
//   }
// }
