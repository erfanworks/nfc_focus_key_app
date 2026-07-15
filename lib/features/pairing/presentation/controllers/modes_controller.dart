import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';

import '../../../../core/widgets/focus_icons.dart';

class ModeItem {
  final String title;
  final String description;
  final FKIcon icon;

  ModeItem(this.title, this.description, this.icon);

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'icon': icon.name,
      };

  factory ModeItem.fromJson(Map<String, dynamic> json) {
    return ModeItem(
      json['title'] ?? '',
      json['description'] ?? '',
      FKIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => FKIcon.deepwork,
      ),
    );
  }
}

class ModesController extends GetxController {
  final _storage = GetStorage();
  final String _storageKey = 'saved_modes';

  final modes = <ModeItem>[].obs;
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadModes();
  }

  void _loadModes() {
    final storedData = _storage.read<List>(_storageKey);
    if (storedData != null && storedData.isNotEmpty) {
      modes.value = storedData.map((e) => ModeItem.fromJson(e)).toList();
    } else {
      // Default modes
      modes.value = [
        ModeItem(
          'Deep work.',
          'Blocks social media, games, entertainment',
          FKIcon.deepwork,
        ),
        ModeItem(
          'Step away.',
          'Blocks all social apps. Keeps utilities.',
          FKIcon.outdoors,
        ),
        ModeItem(
          'Nothing gets through.',
          'Blocks everything except calls and messages.',
          FKIcon.dnd,
        ),
      ];
    }
  }

  void _saveModes() {
    _storage.write(_storageKey, modes.map((e) => e.toJson()).toList());
  }

  void addMode(ModeItem mode) {
    modes.add(mode);
    _saveModes();
  }

  void selectMode(int index) {
    selectedIndex.value = index;
  }

  void onAddNewMode() {
    Get.toNamed(Routes.newMode);
  }

  void onStartMode() {
    Get.offAllNamed(Routes.lock);
  }
}
