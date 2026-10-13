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
  final isNavigatingNewMode = false.obs;
  final isStartingMode = false.obs;
  final navigatingEditModeId = RxnString();
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
    modes.value = [
      ModeItem('Deep work.', 'Blocks social media, games, entertainment', FKIcon.deepwork),
      ModeItem('Step away.', 'Blocks all social apps. Keeps utilities.', FKIcon.outdoors),
      ModeItem('Nothing gets through.', 'Blocks everything except calls and messages.', FKIcon.dnd),
    ];
  }

  Future<void> fetchModes() async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return; // Skip if logged out

      isLoading.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.getAllMood,
      );

      if (response == null || response["success"] != true) {
        hasError.value = !_hadCache;
        if (response != null && response["success"] == false) {
           CustomSnackbar.show(title: "Sync Failed", message: response["message"] ?? "Could not load focus modes.", isError: true);
        }
        return;
      }

      final data = response["data"];
      final List<dynamic> modesJson = data?["modes"] ?? [];
      
      // If server returns empty list, update local state
      if (modesJson.isEmpty) {
        modes.clear();
        _saveModes();
        return;
      }

      modes.value = modesJson
          .map((e) => ModeItem.fromApi(e as Map<String, dynamic>))
          .toList();
      _hadCache = true;
      hasError.value = false;
      _saveModes();
    } catch (e) {
      hasError.value = !_hadCache;
      errorLog("fetchModes", e);
      CustomSnackbar.show(title: "Network Error", message: "Failed to sync your focus modes.", isError: true);
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

  Future<void> onAddNewMode() async {
    if (isNavigatingNewMode.value) return;
    isNavigatingNewMode.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    Get.toNamed(Routes.newMode);
    await Future.delayed(const Duration(milliseconds: 500));
    isNavigatingNewMode.value = false;
  }

  Future<void> onEditMode(ModeItem mode) async {
    if (navigatingEditModeId.value != null) return;
    navigatingEditModeId.value = mode.id;
    
    await Future.delayed(const Duration(milliseconds: 300));
    Get.toNamed(
      Routes.newMode,
      arguments: {
        'modeId': mode.id,
        'modeName': mode.title,
        'totalLockedApps': mode.totalLockedApps,
        'isEditMode': true,
        'icon': mode.icon,
      },
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    navigatingEditModeId.value = null;
  }

  Future<void> onStartMode() async {
    if (isStartingMode.value) return;

    final selectedMode = modes[selectedIndex.value];

    if (selectedMode.id == null || selectedMode.id!.isEmpty) {
      CustomSnackbar.show(
        title: 'Please wait',
        message: 'Still loading your modes — try again in a moment.',
        isError: true,
      );
      return;
    }

    try {
      isStartingMode.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      StorageServices.instance.setCompletedInitialSetup();
      Get.offAllNamed(Routes.lock);

      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isStartingMode.value = false;
    }
  }
}
