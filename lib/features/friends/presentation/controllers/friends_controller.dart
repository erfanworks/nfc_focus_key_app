import 'dart:async';
import 'package:flutter/services.dart';
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

// ==================== Controller ====================

class FriendsController extends GetxController {
  final RxList<FriendModel> addedFriends = <FriendModel>[].obs;
  final RxList<AppUserModel> appUsers = <AppUserModel>[].obs;

  final isLoadingFriends = false.obs;
  final isLoadingAppUsers = false.obs;
  final isSubmitting = false.obs;
  final loadingUserId = ''.obs;

  final Rxn<FriendModel> friendDetails = Rxn<FriendModel>();
  final isLoadingFriendDetails = false.obs;
  final isSendingNudge = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFriendsList();
    fetchFriendsFocusingStatus();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchFriendsList(),
      fetchFriendsFocusingStatus(),
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
    if (isSubmitting.value || loadingUserId.value.isNotEmpty) return;
    try {
      loadingUserId.value = friendId;
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
      
      // Remove from search list after a short delay for feedback
      await Future.delayed(const Duration(milliseconds: 500));
      appUsers.removeWhere((user) => user.id == friendId);
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to send friend request.",
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
      loadingUserId.value = '';
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

  // ==================== Friend Details (Details Page) ====================
  Future<void> fetchFriendDetails(String friendId) async {
    try {
      isLoadingFriendDetails.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendDetails(friendId),
      );
      if (response == null || response["success"] != true) return;
      final data = response["data"];
      if (data is Map<String, dynamic>) {
        friendDetails.value = FriendModel.fromJson(data);
      }
    } catch (e) {
      // Non-fatal — page keeps showing the FriendModel passed via arguments
    } finally {
      isLoadingFriendDetails.value = false;
    }
  }

  // ==================== Nudge (Pure Notification — no session/lock) ====================
  Future<bool> sendNudge(String friendId) async {
    if (isSendingNudge.value) return false;
    try {
      isSendingNudge.value = true;
      await HapticFeedback.lightImpact();
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.sendNudge(friendId),
      );
      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Nudge Failed",
          message: response?["message"] ?? "Could not send nudge.",
          isError: true,
        );
        return false;
      }
      CustomSnackbar.show(
        title: "Nudge Sent",
        message: response["data"]?["notificationText"] ?? "Your friend has been notified.",
      );
      return true;
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to send nudge. Check your internet.",
        isError: true,
      );
      return false;
    } finally {
      isSendingNudge.value = false;
    }
  }

  // ==================== Friends Focusing Status (Home Screen, informational) ====================
  final activeFocusingCount = 0.obs;
  final Rxn<String> focusingDisplayMessage = Rxn<String>();
  final RxList<FriendModel> activeFocusingFriends = <FriendModel>[].obs;

  Future<void> fetchFriendsFocusingStatus() async {
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.friendsFocusingStatus,
      );
      if (response == null || response["success"] != true) return;
      final data = response["data"];
      if (data is Map<String, dynamic>) {
        activeFocusingCount.value = data["activeCount"] ?? 0;
        focusingDisplayMessage.value = data["displayMessage"];
        final List<dynamic> friendsJson = data["activeFriends"] ?? [];
        activeFocusingFriends.value = friendsJson
            .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Non-fatal — purely informational status
    }
  }
}
