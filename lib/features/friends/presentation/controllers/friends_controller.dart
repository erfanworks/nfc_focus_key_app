import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/storage_services.dart';
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
  final String? modeId;
  final String? modeName;
  final List<NudgeParticipant> participants;
  final int breaksRemaining;
  final int breaksPerDayTotal;
  final int breakDurationMinutes;
  final String todayFormatted;
  final String weekFormatted;

  CurrentNudgeStatus({
    required this.isActive,
    this.nudgeId,
    required this.isLocked,
    this.modeId,
    this.modeName,
    required this.participants,
    required this.breaksRemaining,
    required this.breaksPerDayTotal,
    required this.breakDurationMinutes,
    required this.todayFormatted,
    required this.weekFormatted,
  });

  factory CurrentNudgeStatus.empty() => CurrentNudgeStatus(
        isActive: false,
        isLocked: false,
        participants: [],
        breaksRemaining: 0,
        breaksPerDayTotal: 0,
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
      modeId: currentMode != null ? currentMode['_id'] : null,
      modeName: currentMode != null ? currentMode['name'] : null,
      participants: joined.map((e) => NudgeParticipant.fromJson(e as Map<String, dynamic>)).toList(),
      breaksRemaining: breakStats['remaining'] ?? 0,
      breaksPerDayTotal: breakStats['totalAllowed'] ?? 0,
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
      const Duration(seconds: 30),
      (_) => fetchCurrentNudgeStatus(),
    );
  }

  @override
  void onClose() {
    _nudgeStatusTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchFriendsList(),
      fetchCurrentNudgeStatus(),
    ]);
  }

  // ==================== Friends List ====================
  Future<void> fetchFriendsList() async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return; // Skip if logged out

      isLoadingFriends.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendsList,
      );
      if (response == null || response["success"] != true) {
         if (response != null && response["success"] == false) {
           CustomSnackbar.show(title: "Update Failed", message: response["message"] ?? "Could not load friends.", isError: true);
         }
         return;
      }

      final List<dynamic> data = response["data"] ?? [];
      final List<FriendModel> list = data.map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList();
      
      // Deduplication logic: ensure unique friends by their ID
      final Map<String, FriendModel> uniqueFriends = {};
      for (var friend in list) {
        uniqueFriends[friend.id] = friend;
      }
      
      addedFriends.value = uniqueFriends.values.toList();
    } catch (e) {
      CustomSnackbar.show(title: "Network Error", message: "Failed to sync friends list.", isError: true);
    } finally {
      isLoadingFriends.value = false;
    }
  }

  // ==================== Browse / Search Users ====================
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
        title: "Search Error",
        message: "Could not find users. Check your connection.",
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
          title: "Request Failed",
          message: response?["message"] ?? "Could not add friend.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(title: "Friend Added", message: "Successfully added to your list.");
      await Future.delayed(const Duration(milliseconds: 800));
      await fetchFriendsList();
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to send friend request.",
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
          title: "Action Failed",
          message: response?["message"] ?? "Could not remove friend.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(title: "Friend Removed", message: "Successfully removed from your list.");
      addedFriends.removeWhere((f) => f.id == friendId);
    } catch (e) {
      CustomSnackbar.show(
        title: "Network Error",
        message: "Failed to remove friend. Try again.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Nudge (Accountability Tap) ====================
  Future<NudgePreview?> initiateNudge({
    required List<String> participantIds,
    required String modeId,
    required int breaksPerDay,
    required int breakDurationMinutes,
  }) async {
    try {
      isSubmitting.value = true;
      final initResponse = await ApiServices.instance.postServices(
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

      if (initResponse == null || initResponse["success"] != true) {
        lastError.value = initResponse?["message"] ?? "Please try again.";
        CustomSnackbar.show(
          title: "Nudge Failed",
          message: lastError.value,
          isError: true,
        );
        return null;
      }

      final previewId = initResponse["data"]?["previewId"] as String?;
      if (previewId == null || previewId.isEmpty) {
        lastError.value = "Missing session info from server.";
        CustomSnackbar.show(title: "Data Error", message: lastError.value, isError: true);
        return null;
      }

      final detailsResponse = await ApiServices.instance.getServices(
        AppApiUrl.instance.nudgePreviewByDetails(previewId),
      );

      if (detailsResponse == null || detailsResponse["success"] != true) {
        lastError.value = detailsResponse?["message"] ?? "Please try again.";
        CustomSnackbar.show(title: "Load Error", message: lastError.value, isError: true);
        return null;
      }

      return NudgePreview.fromJson(detailsResponse["data"] as Map<String, dynamic>);
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to initiate nudge session.",
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
          title: "Confirmation Failed",
          message: response?["message"] ?? "Could not send nudge invitation.",
          isError: true,
        );
        return false;
      }
      
      CustomSnackbar.show(title: "Nudge Sent", message: "Your friends have been notified.");
      await Future.delayed(const Duration(milliseconds: 1200));
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "Failed to confirm nudge. Check your internet.",
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
          title: "Action Failed",
          message: response?["message"] ?? "Could not leave session.",
          isError: true,
        );
        return;
      }
      CustomSnackbar.show(title: "Session Left", message: "You are no longer in the nudge.");
      await fetchCurrentNudgeStatus();
    } catch (e) {
      CustomSnackbar.show(
        title: "Network Error",
        message: "Failed to leave nudge session.",
        isError: true,
      );
    }
  }

  Future<bool> joinCurrentNudge() async {
    final nudge = currentNudge.value;
    if (nudge == null || nudge.nudgeId == null || nudge.modeId == null) {
      CustomSnackbar.show(
        title: "Join Error",
        message: "Nudge session data is missing.",
        isError: true,
      );
      return false;
    }

    return joinNudge(
      nudgeId: nudge.nudgeId!,
      participantIds: nudge.participants.map((p) => p.id).toList(),
      modeId: nudge.modeId!,
      breaksPerDay: nudge.breaksPerDayTotal,
      breakDurationMinutes: nudge.breakDurationMinutes,
    );
  }

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
          title: "Join Failed",
          message: response?["message"] ?? "Could not join nudge.",
          isError: true,
        );
        return false;
      }
      
      CustomSnackbar.show(title: "Joined!", message: "Successfully joined the nudge session.");
      await Future.delayed(const Duration(milliseconds: 1000));
      await fetchCurrentNudgeStatus();
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to join. Please try again.",
        isError: true,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchCurrentNudgeStatus() async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return; // Skip if logged out

      isLoadingNudgeStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.currentNudgeStatus,
      );
      if (response == null || response["success"] != true) return;

      final data = response["data"];
      currentNudge.value = data != null ? CurrentNudgeStatus.fromJson(data as Map<String, dynamic>) : CurrentNudgeStatus.empty();
    } catch (e) {
    } finally {
      isLoadingNudgeStatus.value = false;
    }
  }

  Future<void> fetchNudgeHistory({int page = 1}) async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return;

      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendsNudgeHistory,
        queryParameters: {'page': page},
      );
      if (response == null || response["success"] != true) return;
      nudgeHistoryRaw.value = List<Map<String, dynamic>>.from(response["data"] ?? []);
    } catch (e) {
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
          title: "Break Error",
          message: response?["message"] ?? "Could not start nudge break.",
          isError: true,
        );
        return;
      }
      CustomSnackbar.show(title: "Break Started", message: "Enjoy your team break.");
      await fetchCurrentNudgeStatus();
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "Failed to start break. Check your connection.",
        isError: true,
      );
    }
  }

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
          title: "Action Failed",
          message: response?["message"] ?? "Could not remove participant.",
          isError: true,
        );
        return;
      }
      CustomSnackbar.show(title: "Removed", message: "Participant removed from preview.");
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "Connection failed. Please try again.",
        isError: true,
      );
    }
  }
}
