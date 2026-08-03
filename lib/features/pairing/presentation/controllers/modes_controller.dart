import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/utils/log_print.dart';

import '../../../../core/widgets/focus_icons.dart';

class ModeItem {
  final String? id;
  final String title;
  final String description;
  final FKIcon icon;
  final bool isActive;

  ModeItem(
      this.title,
      this.description,
      this.icon, {
        this.id,
        this.isActive = false,
      });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon.name,
    'isActive': isActive,
  };

  factory ModeItem.fromJson(Map<String, dynamic> json) {
    return ModeItem(
      json['title'] ?? '',
      json['description'] ?? '',
      FKIcon.values.firstWhere(
            (e) => e.name == json['icon'],
        orElse: () => FKIcon.deepwork,
      ),
      id: json['id'],
      isActive: json['isActive'] ?? false,
    );
  }

  factory ModeItem.fromApi(Map<String, dynamic> json) {
    return ModeItem(
      json['name'] ?? '',
      json['description'] ?? '',
      FKIcon.values.firstWhere(
            (e) => e.name == json['icon'],
        orElse: () => FKIcon.deepwork,
      ),
      id: json['_id'],
      isActive: json['isActive'] ?? false,
    );
  }
}

class ModesController extends GetxController {
  // NOTE: still using raw GetStorage here (legacy) as an offline cache for
  // the modes list. This is separate from the SharedPreferences-based
  // StorageServices used elsewhere in the app — flagging this inconsistency;
  // can migrate to StorageServices if you'd like it consolidated.
  final _storage = GetStorage();
  final String _storageKey = 'saved_modes';

  final modes = <ModeItem>[].obs;
  final selectedIndex = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedModes();
    fetchModes();
  }

  void _loadCachedModes() {
    final storedData = _storage.read<List>(_storageKey);
    if (storedData != null && storedData.isNotEmpty) {
      modes.value = storedData.map((e) => ModeItem.fromJson(e)).toList();
    } else {
      // Default modes shown before the first successful server fetch.
      modes.value = [
        ModeItem('Deep work.', 'Blocks social media, games, entertainment', FKIcon.deepwork),
        ModeItem('Step away.', 'Blocks all social apps. Keeps utilities.', FKIcon.outdoors),
        ModeItem('Nothing gets through.', 'Blocks everything except calls and messages.', FKIcon.dnd),
      ];
    }
  }

  // Fetch real modes from backend so mode selection carries a real
  // backend id (required to lock/unlock via toggle-activation).
  Future<void> fetchModes() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.getAllMood,
      );

      if (response == null || response["success"] != true) return;

      final List<dynamic> data = response["data"] ?? [];
      if (data.isEmpty) return;

      modes.value = data
          .map((e) => ModeItem.fromApi(e as Map<String, dynamic>))
          .toList();
      _saveModes();
    } catch (e) {
      // Silent — offline is an expected state, cached/default modes stay shown.
      errorLog("fetchModes", e);
    } finally {
      isLoading.value = false;
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
    final args = Get.arguments as Map<String, dynamic>?;
    final isNudgeFlow = args?['isNudgeFlow'] == true;

    if (isNudgeFlow) {
      final selectedMode = modes[selectedIndex.value];
      Get.toNamed(
        Routes.takeBreak,
        arguments: {
          'isNudgeFlow': true,
          'modeId': selectedMode.id,
          'participantIds': args?['participantIds'],
        },
      );
    } else {
      Get.offAllNamed(Routes.lock);
    }
  }
}