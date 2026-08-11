import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/utils/log_print.dart';
import '../../../../core/widgets/custom_snackbar.dart';

import '../../../../core/widgets/focus_icons.dart';

class ModeItem {
  final String? id;
  final String title;
  final String description;
  final FKIcon icon;
  final bool isActive;
  final int totalLockedApps;

  ModeItem(
      this.title,
      this.description,
      this.icon, {
        this.id,
        this.isActive = false,
        this.totalLockedApps = 0,
      });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon.name,
    'isActive': isActive,
    'totalLockedApps': totalLockedApps,
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
      totalLockedApps: json['totalLockedApps'] ?? 0,
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
      totalLockedApps: json['totalLockedApps'] ?? 0,
    );
  }
}

class ModesController extends GetxController {
  final modes = <ModeItem>[].obs;
  final selectedIndex = 0.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  bool _hadCache = false;

  @override
  void onInit() {
    super.onInit();
    _loadCachedModes();
    fetchModes();
  }

  Future<void> _loadCachedModes() async {
    final cached = await StorageServices.instance.getCachedModes();
    if (cached.isNotEmpty) {
      modes.value = cached.map((e) => ModeItem.fromJson(e)).toList();
      _hadCache = true;
      return;
    }
    // Default modes shown before the first successful server fetch.
    modes.value = [
      ModeItem('Deep work.', 'Blocks social media, games, entertainment', FKIcon.deepwork),
      ModeItem('Step away.', 'Blocks all social apps. Keeps utilities.', FKIcon.outdoors),
      ModeItem('Nothing gets through.', 'Blocks everything except calls and messages.', FKIcon.dnd),
    ];
  }

  // Fetch real modes from backend so mode selection carries a real
  // backend id (required to lock/unlock via toggle-activation).
  Future<void> fetchModes() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.getAllMood,
      );

      if (response == null || response["success"] != true) {
        hasError.value = !_hadCache;
        return;
      }

      final data = response["data"];
      final List<dynamic> modesJson = data?["modes"] ?? [];
      if (modesJson.isEmpty) return;

      modes.value = modesJson
          .map((e) => ModeItem.fromApi(e as Map<String, dynamic>))
          .toList();
      _hadCache = true;
      hasError.value = false;
      _saveModes();
    } catch (e) {
      // Only a real problem if we also have nothing cached to fall back on.
      hasError.value = !_hadCache;
      errorLog("fetchModes", e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveModes() async {
    await StorageServices.instance.cacheModes(
      modes.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> retryFetchModes() => fetchModes();

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
    final selectedMode = modes[selectedIndex.value];

    if (selectedMode.id == null || selectedMode.id!.isEmpty) {
      CustomSnackbar.show(
        title: 'Please wait',
        message: 'Still loading your modes — try again in a moment.',
        isError: true,
      );
      return;
    }

    if (isNudgeFlow) {
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