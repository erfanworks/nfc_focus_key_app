import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';

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
      participants: joined
          .map((e) => NudgeParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
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

  // Multi-select state for picking friends to start a new nudge with.
  final RxSet<String> selectedForNudge = <String>{}.obs;

  bool isSelectedForNudge(String id) => selectedForNudge.contains(id);

  void toggleNudgeSelection(String id) {
    if (selectedForNudge.contains(id)) {
      selectedForNudge.remove(id);
    } else {
      selectedForNudge.add(id);
    }
  }

  void clearNudgeSelection() => selectedForNudge.clear();

  List<FriendModel> get selectedFriendModels =>
      addedFriends.where((f) => selectedForNudge.contains(f.id)).toList();

  @override
  void onInit() {
    super.onInit();
    fetchFriendsList();
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
      addedFriends.value =
          data.map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList();
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
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      if (response == null || response["success"] != true) return;

      final List<dynamic> data = response["data"] ?? [];
      appUsers.value =
          data.map((e) => AppUserModel.fromJson(e as Map<String, dynamic>)).toList();
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
  Future<bool> createNudge({
    required List<String> participantIds,
    required String modeId,
    required int breaksPerDay,
    required int breakDurationMinutes,
  }) async {
    try {
      isSubmitting.value = true;
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.createNudge,
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
          title: "Couldn't start nudge",
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

  Future<void> fetchCurrentNudgeStatus() async {
    try {
      isLoadingNudgeStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.currentNudgeStatus,
      );
      if (response == null || response["success"] != true) return;

      final data = response["data"];
      currentNudge.value = data != null
          ? CurrentNudgeStatus.fromJson(data as Map<String, dynamic>)
          : CurrentNudgeStatus.empty();
    } catch (e) {
      // Silent background refresh — keep last known status if offline.
    } finally {
      isLoadingNudgeStatus.value = false;
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
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    }
  }

  // NOTE: body shape is an assumption (nudgeId + participantId) — confirm
  // against the real Postman sample when it's shared, then adjust if needed.
  Future<void> removeParticipant({
    required String nudgeId,
    required String participantId,
  }) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.removeParticipant,
        body: {"nudgeId": nudgeId, "participantId": participantId},
      );
      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Couldn't remove",
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
}