import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';

class NotificationModel {
  final String id;
  final String title;
  final String text;
  final String referenceModel;
  final Map<String, dynamic>? referenceId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.text,
    required this.referenceModel,
    required this.referenceId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['_id'] ?? '',
        title: json['title'] ?? 'Notification',
        text: json['text'] ?? '',
        referenceModel: json['referenceModel'] ?? '',
        referenceId: json['referenceId'] is Map<String, dynamic>
            ? json['referenceId']
            : null,
        read: json['read'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      return NotificationModel(
        id: '',
        title: 'Notification',
        text: '',
        referenceModel: '',
        referenceId: null,
        read: true,
        createdAt: DateTime.now(),
      );
    }
  }

  // --- World Class Text Formatting ---
  String get displayMessage {
    final lowTitle = title.toLowerCase();
    final lowText = text.toLowerCase();
    final isAccepted = lowTitle.contains('accepted') || lowText.contains('accepted');
    final isJoined = lowTitle.contains('joined') || lowText.contains('joined');

    if (text.isEmpty || text.contains('/') || text.contains('http') || text.contains('_id')) {
      switch (referenceModel) {
        case 'Nudge':
          if (isAccepted || isJoined) {
            return "Great news! Your focus invitation was accepted. Get ready to dive in!";
          }
          return "Invited you to a shared focus session. Join now to stay productive together!";
        case 'FriendRequest':
          return "Sent you a partner request. Connect to build focus habits together.";
        default:
          return "You have a new update from Focus Key. Tap to see details.";
      }
    }
    
    // If text is not empty but contains "accepted", ensure it's clean
    if (isAccepted && !text.contains('accepted')) {
       return "Focus session accepted! Your partner is ready.";
    }

    return text;
  }

  bool get isJoinableNudge {
    final isNudge = referenceModel == 'Nudge' && referenceId != null;
    final isActive = referenceId!['status'] == 'active';
    
    // --- Logic Fix: Hide Join button for Acceptance/Status updates ---
    final lowTitle = title.toLowerCase();
    final lowText = text.toLowerCase();
    
    final isStatusUpdate = lowTitle.contains('accepted') || 
                           lowText.contains('accepted') || 
                           lowTitle.contains('joined') || 
                           lowText.contains('joined');

    return isNudge && isActive && !isStatusUpdate;
  }

  bool get isExpiredNudge =>
      referenceModel == 'Nudge' &&
          referenceId != null &&
          referenceId!['status'] == 'completed';

  String? get nudgeCreatorId => referenceModel == 'Nudge'
      ? (referenceId?['creatorId'] as String?)
      : null;

  int get nudgeBreaksPerDay =>
      (referenceId?['breakConfig']?['breaksPerDay'] as int?) ?? 3;

  int get nudgeBreakDurationMinutes =>
      (referenceId?['breakConfig']?['breakDurationMinutes'] as int?) ?? 10;

  List<String> get nudgeParticipantIds {
    try {
      final list = referenceId?['participants'] as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((p) => (p as Map<String, dynamic>)['userId'] as String?)
          .whereType<String>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class NotificationGroup {
  final String label;
  final List<NotificationModel> items;

  NotificationGroup({required this.label, required this.items});
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final unreadCount = 0.obs;
  String? currentUserId;

  int _page = 1;
  int _totalPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
    fetchNotifications();
  }

  Future<void> _loadUserId() async {
    final userData = await StorageServices.instance.getLogDedData();
    // Assuming the user data map contains 'id' or '_id'
    currentUserId = userData['id'] ?? userData['_id'] ?? userData['data']?['_id'];
  }

  @override
  void onClose() {
    _markAllAsReadSilently();
    super.onClose();
  }

  Future<void> _markAllAsReadSilently() async {
    try {
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.readNotifications,
      );
      if (response != null && response["success"] == true) {
        unreadCount.value = 0;
      }
    } catch (_) {}
  }

  bool get hasMore => _page < _totalPage;

  List<NotificationGroup> get groupedNotifications {
    final Map<String, List<NotificationModel>> groups = {};
    final now = DateTime.now();

    for (final n in notifications) {
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(
        DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day),
      )
          .inDays;

      final label = diffDays == 0
          ? 'TODAY'
          : diffDays == 1
          ? 'YESTERDAY'
          : '${_monthShort(n.createdAt.month)} ${n.createdAt.day}'
          .toUpperCase();

      groups.putIfAbsent(label, () => []).add(n);
    }

    return groups.entries
        .map((e) => NotificationGroup(label: e.key, items: e.value))
        .toList();
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  Future<void> fetchNotifications({bool refresh = true}) async {
    if (refresh) {
      isLoading.value = true;
      _page = 1;
    } else {
      if (!hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
      _page++;
    }

    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.notifications,
        queryParameters: {"page": _page, "limit": _limit},
      );

      if (response != null && response["success"] == true) {
        final list = (response["data"] as List<dynamic>? ?? [])
            .map((e) => NotificationModel.fromJson(e))
            .where((n) => n.id.isNotEmpty)
            .toList();

        if (refresh) {
          notifications.value = list;
        } else {
          notifications.addAll(list);
        }

        final meta = response["meta"];
        _totalPage = meta?['totalPage'] ?? 1;
        unreadCount.value = meta?['unreadCount'] ?? 0;
      }
    } catch (e) {
      if (refresh) {
        CustomSnackbar.show(
          title: "Update Error",
          message: "Could not sync notifications. Please pull to refresh.",
          isError: true,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() => fetchNotifications(refresh: false);

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].read) return;

    try {
      final old = notifications[index];
      // Local update for immediate feedback
      notifications[index] = NotificationModel(
        id: old.id,
        title: old.title,
        text: old.text,
        referenceModel: old.referenceModel,
        referenceId: old.referenceId,
        read: true,
        createdAt: old.createdAt,
      );
      if (unreadCount.value > 0) unreadCount.value--;

      await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.markNotificationAsRead(id),
      );
    } catch (_) {}
  }

  Future<bool> joinNudge({
    required String nudgeId,
    required String modeId,
    required int breaksPerDay,
    required int breakDurationMinutes,
    required List<String> participantIds,
  }) async {
    try {
      isLoading.value = true;
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
      
      if (response != null && response["success"] == true) {
        if (Get.isRegistered<FriendsController>()) {
          Get.find<FriendsController>().fetchCurrentNudgeStatus();
        }
        
        CustomSnackbar.show(
          title: "Focus Started!",
          message: "You have successfully joined the session. Getting everything ready...",
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        return true;
      } else {
        CustomSnackbar.show(
          title: "Session Unavailable",
          message: response?["message"] ?? "This session may have already ended or reached capacity.",
          isError: true,
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to join session. Please check your internet.",
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
