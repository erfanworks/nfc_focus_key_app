import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';

// ==================== Models ====================

class FriendModel {
  final String id;
  final String name;
  final String userName;
  final String profileImage;
  final bool isLocked;
  final String lastFocusInfo;

  FriendModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.profileImage,
    required this.isLocked,
    required this.lastFocusInfo,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        userName: json['userName'] ?? '',
        profileImage: json['profileImage'] ?? '',
        isLocked: json['isLocked'] ?? false,
        lastFocusInfo: json['lastFocusInfo'] ?? '',
      );

  // Preserved for existing UI bindings that expect these.
  String get handle => '@$userName';
  String get status => lastFocusInfo;
  bool get isFocusing => isLocked || lastFocusInfo.toLowerCase().contains('now');
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + second).toUpperCase();
  }

  // Deterministic (not random) cosmetic avatar variant — purely decorative.
  bool get isDarkAvatar => id.hashCode.isEven;
}

class AppUserModel {
  final String id;
  final String name;
  final String userName;
  final String profileImage;
  final bool isFriend;
  final bool isLocked;
  final String lastFocusInfo;

  AppUserModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.profileImage,
    required this.isFriend,
    required this.isLocked,
    required this.lastFocusInfo,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) => AppUserModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        userName: json['userName'] ?? '',
        profileImage: json['profileImage'] ?? '',
        isFriend: json['isFriend'] ?? false,
        isLocked: json['isLocked'] ?? false,
        lastFocusInfo: json['lastFocusInfo'] ?? '',
      );
}

class NudgeParticipant {
  final String id;
  final String name;
  final String profileImage;
  final bool isFocused;
  final bool isOnBreak;

  NudgeParticipant({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.isFocused,
    required this.isOnBreak,
  });

  factory NudgeParticipant.fromJson(Map<String, dynamic> json) => NudgeParticipant(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        profileImage: json['profileImage'] ?? '',
        isFocused: json['isFocused'] ?? false,
        isOnBreak: json['isOnBreak'] ?? false,
      );
}

class SharedStats {
  final String togetherThisWeek;
  final int streak;
  final List<dynamic> highlightedDays;

  SharedStats({
    required this.togetherThisWeek,
    required this.streak,
    required this.highlightedDays,
  });

  factory SharedStats.fromJson(Map<String, dynamic> json) => SharedStats(
        togetherThisWeek: json['togetherThisWeek'] ?? '0m',
        streak: json['streak'] ?? 0,
        highlightedDays: json['highlightedDays'] ?? [],
      );
}

class PreviewParticipant {
  final String id;
  final String name;
  final String userName;
  final String profileImage;
  final bool isLocked;
  final String lastFocusInfo;
  final SharedStats sharedStats;

  PreviewParticipant({
    required this.id,
    required this.name,
    required this.userName,
    required this.profileImage,
    required this.isLocked,
    required this.lastFocusInfo,
    required this.sharedStats,
  });

  factory PreviewParticipant.fromJson(Map<String, dynamic> json) => PreviewParticipant(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        userName: json['userName'] ?? '',
        profileImage: json['profileImage'] ?? '',
        isLocked: json['isLocked'] ?? false,
        lastFocusInfo: json['lastFocusInfo'] ?? '',
        sharedStats: SharedStats.fromJson(json['sharedStats'] ?? {}),
      );

  // Preserved getters matching FriendModel's UI-facing shape.
  bool get isFocusing => isLocked || lastFocusInfo.toLowerCase().contains('now');
  String get status => lastFocusInfo;
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + second).toUpperCase();
  }

  bool get isDarkAvatar => id.hashCode.isEven;
}

class NudgePreview {
  final String previewId;
  final String status;
  final String? expiresAt;
  final int remainingMinutes;
  final String modeId;
  final String modeName;
  final List<PreviewParticipant> participants;

  NudgePreview({
    required this.previewId,
    required this.status,
    this.expiresAt,
    required this.remainingMinutes,
    required this.modeId,
    required this.modeName,
    required this.participants,
  });

  factory NudgePreview.fromJson(Map<String, dynamic> json) {
    final mode = json['mode'] ?? {};
    final List<dynamic> participantsJson = json['participants'] ?? [];
    return NudgePreview(
      previewId: json['previewId'] ?? '',
      status: json['status'] ?? '',
      expiresAt: json['expiresAt'],
      remainingMinutes: json['remainingMinutes'] ?? 0,
      modeId: mode['_id'] ?? '',
      modeName: mode['name'] ?? '',
      participants: participantsJson.map((e) => PreviewParticipant.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class CurrentNudgeStatus {
  final bool isActive;
  final String? nudgeId;
  final bool isLocked;
  final String? modeName;
  final List<NudgeParticipant> participants;
  final int breaksRemaining;
  final int breakDurationMinutes;
  final String todayFormatted;
  final String weekFormatted;

  CurrentNudgeStatus({
    required this.isActive,
    this.nudgeId,
    required this.isLocked,
    this.modeName,
    required this.participants,
    required this.breaksRemaining,
    required this.breakDurationMinutes,
    required this.todayFormatted,
    required this.weekFormatted,
  });

  factory CurrentNudgeStatus.empty() => CurrentNudgeStatus(
        isActive: false,
        isLocked: false,
        participants: [],
        breaksRemaining: 0,
        breakDurationMinutes: 0,
        todayFormatted: '0h 0m',
        weekFormatted: '0h 0m',
      );

  factory CurrentNudgeStatus.fromJson(Map<String, dynamic> json) {
    final breakStats = json['breakStats'] ?? {};
    final focusStats = json['focusStats'] ?? {};
    final currentMode = json['currentMode'];
    final joined = (json['joinedParticipants'] as List?) ?? [];

    return CurrentNudgeStatus(
      isActive: json['isActive'] ?? false,
      nudgeId: json['nudgeId'],
      isLocked: json['isLocked'] ?? false,
      modeName: currentMode != null ? currentMode['name'] : null,
      participants: joined.map((e) => NudgeParticipant.fromJson(e as Map<String, dynamic>)).toList(),
      breaksRemaining: breakStats['remaining'] ?? 0,
      breakDurationMinutes: breakStats['durationMinutes'] ?? 0,
      todayFormatted: focusStats['todayFormatted'] ?? '0h 0m',
      weekFormatted: focusStats['weekFormatted'] ?? '0h 0m',
    );
  }
}

// ==================== Controller ====================

class FriendsController extends GetxController {
  final RxList<FriendModel> addedFriends = <FriendModel>[].obs;
  final RxList<AppUserModel> appUsers = <AppUserModel>[].obs;

  final isLoadingFriends = false.obs;
  final isLoadingAppUsers = false.obs;
  final isSubmitting = false.obs;

  final Rxn<CurrentNudgeStatus> currentNudge = Rxn<CurrentNudgeStatus>();
  final isLoadingNudgeStatus = false.obs;
  final _isFetchingNudgeStatus = false.obs;

  // Multi-select state for picking friends to start a new nudge with.
  final RxSet<String> selectedForNudge = <String>{}.obs;
  final RxString lastError = ''.obs;

  bool isSelectedForNudge(String id) => selectedForNudge.contains(id);

  void toggleNudgeSelection(String id) {
    if (selectedForNudge.contains(id)) {
      selectedForNudge.remove(id);
    } else {
      selectedForNudge.add(id);
    }
  }

  void clearNudgeSelection() => selectedForNudge.clear();

  List<FriendModel> get selectedFriendModels => addedFriends.where((f) => selectedForNudge.contains(f.id)).toList();

  Timer? _nudgeStatusTimer;

  @override
  void onInit() {
    super.onInit();
    fetchFriendsList();
    fetchCurrentNudgeStatus();
    _nudgeStatusTimer = Timer.periodic(
      const Duration(seconds: 40),
      (_) => fetchCurrentNudgeStatus(silent: true),
    );
  }

  @override
  void onClose() {
    _nudgeStatusTimer?.cancel();
    super.onClose();
  }

  // ==================== Friends List ====================
  Future<void> fetchFriendsList() async {
    try {
      isLoadingFriends.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendsList,
      );
      if (response == null || response["success"] != true) return;

      final List<dynamic> data = response["data"] ?? [];
      addedFriends.value = data.map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Silent — cached list stays shown if offline.
    } finally {
      isLoadingFriends.value = false;
    }
  }

  // ==================== Browse / Search Users ====================
  // NOTE: `search` query param name is unconfirmed with backend — verify.
  Future<void> fetchAppUsers({String? search, int page = 1}) async {
    try {
      isLoadingAppUsers.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.seeAppUsers,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'searchTerm': search,
        },
      );
      if (response == null || response["success"] != true) return;

      final List<dynamic> data = response["data"] ?? [];
      appUsers.value = data.map((e) => AppUserModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      CustomSnackbar.show(
        title: "Couldn't load users",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isLoadingAppUsers.value = false;
    }
  }

  // ==================== Add / Remove Friend ====================
  bool isFriendAdded(String id) => addedFriends.any((f) => f.id == id);

  Future<void> addFriend(String friendId) async {
    if (isSubmitting.value) return;
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.addFriend,
        body: {"friendId": friendId},
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't add friend",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }

      await fetchFriendsList();
      CustomSnackbar.show(title: "Friend added", message: "");
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> removeFriend(String friendId) async {
    if (isSubmitting.value) return;
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.deleteServices(
        url: AppApiUrl.instance.removeFriend(friendId),
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't remove friend",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }

      addedFriends.removeWhere((f) => f.id == friendId);
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Nudge (Accountability Tap) ====================
  // New flow: initiate -> shows a preview (with real shared stats) -> confirm.
  Future<NudgePreview?> initiateNudge({
    required List<String> participantIds,
    required String modeId,
    required int breaksPerDay,
    required int breakDurationMinutes,
  }) async {
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.initiateNudge,
        body: {
          "participants": participantIds,
          "modeId": modeId,
          "breakConfig": {
            "breaksPerDay": breaksPerDay,
            "breakDurationMinutes": breakDurationMinutes,
          },
        },
      );

      if (response == null || response["success"] != true) {
        lastError.value = response?["message"] ?? "Please try again.";
        CustomSnackbar.show(
          title: "Couldn't start nudge",
          message: lastError.value,
          isError: true,
        );
        return null;
      }
      return NudgePreview.fromJson(response["data"] as Map<String, dynamic>);
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> confirmNudge(String previewId) async {
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.midgeConfirmById(previewId),
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't send nudge",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return false;
      }
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> leaveNudge(String nudgeId) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.leaveNudgeBYID(nudgeId),
      );
      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't leave",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }
      await fetchCurrentNudgeStatus();
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    }
  }

  // Future notification-flow use — accepting an invite to an already-created nudge.

  // TODO: Notifications list — backend endpoint not ready yet.
  // final RxList<dynamic> notifications = <dynamic>[].obs;
  // Future<void> fetchNotifications() async { ... }

  // NOTE: body mirrors createNudge's per backend's given sample — confirm
  // with backend dev whether join really needs participants/modeId/breakConfig
  // again, since the nudge already defines these.
  Future<bool> joinNudge({
    required String nudgeId,
    required List<String> participantIds,
    required String modeId,
    required int breaksPerDay,
    required int breakDurationMinutes,
  }) async {
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.joinNudge(nudgeId),
        body: {
          "participants": participantIds,
          "modeId": modeId,
          "breakConfig": {
            "breaksPerDay": breaksPerDay,
            "breakDurationMinutes": breakDurationMinutes,
          },
        },
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't join",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return false;
      }
      await fetchCurrentNudgeStatus();
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchCurrentNudgeStatus({bool silent = false}) async {
    if (_isFetchingNudgeStatus.value) return;
    try {
      _isFetchingNudgeStatus.value = true;
      if (!silent) isLoadingNudgeStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.currentNudgeStatus,
      );
      if (response == null || response["success"] != true) return;

      final data = response["data"];
      currentNudge.value = data != null ? CurrentNudgeStatus.fromJson(data as Map<String, dynamic>) : CurrentNudgeStatus.empty();
    } catch (e) {
      // Silent background refresh — keep last known status if offline.
    } finally {
      _isFetchingNudgeStatus.value = false;
      if (!silent) isLoadingNudgeStatus.value = false;
    }
  }

  Future<void> fetchNudgeHistory({int page = 1}) async {
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendsNudgeHistory,
        queryParameters: {'page': page},
      );
      if (response == null || response["success"] != true) return;
      // Expose raw list — build a typed model here if a dedicated
      // history screen needs richer parsing than currentNudge's shape.
      nudgeHistoryRaw.value = List<Map<String, dynamic>>.from(response["data"] ?? []);
    } catch (e) {
      // Silent — history is non-critical, cached view stays.
    }
  }

  final RxList<Map<String, dynamic>> nudgeHistoryRaw = <Map<String, dynamic>>[].obs;

  Future<void> takeNudgeBreak(String nudgeId) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.takeNudgeBreak(nudgeId),
      );
      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't start break",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }
      await fetchCurrentNudgeStatus();

      // Notify LockController to refresh its state so the Lock screen UI stays in sync.
      if (Get.isRegistered<LockController>()) {
        Get.find<LockController>().fetchLockStatus();
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    }
  }

  // Confirmed against real Postman sample — removes a participant from a
  // pending nudge preview (before it's confirmed).
  Future<void> removeParticipant({
    required String previewId,
    required String participantId,
  }) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.removeParticipant,
        body: {"previewId": previewId, "participantId": participantId},
      );
      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't remove",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    }
  }
}
