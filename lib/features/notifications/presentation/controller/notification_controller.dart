import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';

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
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      referenceModel: json['referenceModel'] ?? '',
      referenceId: json['referenceId'] is Map<String, dynamic>
          ? json['referenceId']
          : null,
      read: json['read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isJoinableNudge =>
      referenceModel == 'Nudge' && referenceId != null && referenceId!['status'] == 'active';

  bool get isExpiredNudge =>
      referenceModel == 'Nudge' && referenceId != null && referenceId!['status'] == 'completed';
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

  int _page = 1;
  int _totalPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  bool get hasMore => _page < _totalPage;

  List<NotificationGroup> get groupedNotifications {
    final Map<String, List<NotificationModel>> groups = {};
    final now = DateTime.now();

    for (final n in notifications) {
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day))
          .inDays;

      final label = diffDays == 0
          ? 'TODAY'
          : diffDays == 1
          ? 'YESTERDAY'
          : '${_monthShort(n.createdAt.month)} ${n.createdAt.day}'.toUpperCase();

      groups.putIfAbsent(label, () => []).add(n);
    }

    return groups.entries.map((e) => NotificationGroup(label: e.key, items: e.value)).toList();
  }

  String _monthShort(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
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
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.markNotificationAsRead(id),
      );
      if (response != null && response["success"] == true) {
        final old = notifications[index];
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
      }
    } catch (_) {}
  }

  Future<bool> joinNudge({
    required String nudgeId,
    required String modeId,
  }) async {
    try {
      final userId = (await StorageServices.instance.getLogDedData())['_id'] ?? '';
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.joinNudge(nudgeId),
        body: {
          "participants": [userId],
          "modeId": modeId,
          "breakConfig": {"breaksPerDay": 3, "breakDurationMinutes": 10},
        },
      );
      return response != null && response["success"] == true;
    } catch (_) {
      return false;
    }
  }
}