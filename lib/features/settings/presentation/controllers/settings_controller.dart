import 'package:get/get.dart';

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

  void updateBlockedApps(String modeName, List<String> newBlockedApps) {
    final mode = modes.firstWhereOrNull((m) => m.name == modeName);
    if (mode != null) {
      mode.blockedApps.assignAll(newBlockedApps);
      mode.appCount.value = newBlockedApps.length;
    }
  }
}
