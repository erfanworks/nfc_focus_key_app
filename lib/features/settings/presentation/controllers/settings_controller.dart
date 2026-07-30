import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class ModeSetting {
  final String name;
  final RxInt appCount;
  final RxList<String> blockedApps;

  ModeSetting({
    required this.name,
    required int initialAppCount,
    required List<String> initialBlockedApps,
  }) : appCount = initialAppCount.obs,
        blockedApps = initialBlockedApps.obs;
}

class SettingsController extends GetxController {
  final modes = <ModeSetting>[
    ModeSetting(
      name: 'Study',
      initialAppCount: 3,
      initialBlockedApps: ['TikTok', 'Instagram', 'Youtube'],
    ),
    ModeSetting(
      name: 'Detox',
      initialAppCount: 8,
      initialBlockedApps: [
        'TikTok',
        'Instagram',
        'Youtube',
        'Twitter',
        'Reddit',
        'Snapchat',
        'Telegram',
        'Safari',
      ],
    ),
    ModeSetting(
      name: 'Total Focus',
      initialAppCount: 12,
      initialBlockedApps: [
        'TikTok',
        'Instagram',
        'Youtube',
        'Twitter',
        'Reddit',
        'Snapchat',
        'Telegram',
        'Safari',
        'Facebook',
        'Netflix',
        'WhatsApp',
        'Messenger',
      ],
    ),
  ].obs;

  final personalReminder = 'I want to stay focused for..'.obs;

  final userName = 'Jhon Lura'.obs;
  final userContact = '+88 9999 9999'.obs;
  final userEmail = 'jhon@mail.com'.obs;

  final isProfileLoading = false.obs;

  void updateBlockedApps(String modeName, List<String> newBlockedApps) {
    final mode = modes.firstWhereOrNull((m) => m.name == modeName);
    if (mode != null) {
      mode.blockedApps.assignAll(newBlockedApps);
      mode.appCount.value = newBlockedApps.length;
    }
  }

  Future<void> fetchProfile() async {
    isProfileLoading.value = true;
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.userProfile,
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        userName.value = data["name"] ?? userName.value;
        userEmail.value = data["email"] ?? userEmail.value;
        if (data["phone"] != null) {
          userContact.value = "${data["countryCode"] ?? ''} ${data["phone"]}".trim();
        }
      }
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<bool> updateProfile(String name) async {
    isProfileLoading.value = true;
    try {
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.updateProfile,
        body: {"name": name},
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        userName.value = data["name"] ?? name;
        return true;
      }
      return false;
    } finally {
      isProfileLoading.value = false;
    }
  }
}