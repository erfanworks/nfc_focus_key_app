import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/modes_controller.dart';
import '../../../../core/widgets/focus_icons.dart';

class AppItem {
  final String name;
  final String iconPath;
  RxBool isSelected;

  AppItem({required this.name, required this.iconPath, bool isSelected = false})
    : isSelected = isSelected.obs;
}

class AppSelectionController extends GetxController {
  final apps = <AppItem>[
    AppItem(
      name: 'TikTok',
      iconPath: 'assets/icons/tiktok.svg',
      isSelected: true,
    ),
    AppItem(
      name: 'Instagram',
      iconPath: 'assets/icons/instagram.svg',
      isSelected: true,
    ),
    AppItem(name: 'YouTube', iconPath: 'assets/icons/youtube.svg'),
    AppItem(name: 'X', iconPath: 'assets/icons/x.svg'),
    AppItem(name: 'Reddit', iconPath: 'assets/icons/reddit.svg'),
    AppItem(name: 'Snapchat', iconPath: 'assets/icons/snapchat.svg'),
    AppItem(name: 'Telegram', iconPath: 'assets/icons/telegram.svg'),
    AppItem(name: 'Facebook', iconPath: 'assets/icons/facebook.svg'),
    AppItem(name: 'WhatsApp', iconPath: 'assets/icons/whatsapp.svg'),
  ].obs;

  final isBlockMode = true.obs;

  int get selectedCount => apps.where((app) => app.isSelected.value).length;

  void toggleApp(int index) {
    apps[index].isSelected.value = !apps[index].isSelected.value;
  }

  void setBlockMode(bool val) {
    isBlockMode.value = val;
  }

  void onDone() {
    final args = Get.arguments as Map<String, dynamic>?;
    final isEditMode = args?['isEditMode'] == true;

    if (!isEditMode && args != null) {
      try {
        final modesController = Get.find<ModesController>();
        modesController.addMode(ModeItem(
          args['modeName'] ?? 'Custom Mode',
          args['description'] ?? 'Custom blocklist',
          args['icon'] as FKIcon,
        ));
      } catch (_) {}
    }

    if (isEditMode) {
      Get.until((route) => route.settings.name == Routes.lock);
    } else {
      Get.until((route) => route.settings.name == Routes.modes);
    }
  }
}
