import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class FocusMode {
  final String id;
  final String name;
  final String icon;

  const FocusMode({required this.id, required this.name, required this.icon});

  factory FocusMode.fromJson(Map<String, dynamic> json) {
    return FocusMode(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class SevenDayStat {
  final String dayLabel;
  final int totalMinutes;

  const SevenDayStat({required this.dayLabel, required this.totalMinutes});

  factory SevenDayStat.fromJson(Map<String, dynamic> json) {
    return SevenDayStat(
      dayLabel: json['dayLabel'] ?? '',
      totalMinutes: json['totalMinutes'] ?? 0,
    );
  }
}

class FocusHistorySession {
  final String modeName;
  final String timeRange;
  final String durationFormatted;
  final bool isActive;

  const FocusHistorySession({
    required this.modeName,
    required this.timeRange,
    required this.durationFormatted,
    required this.isActive,
  });

  factory FocusHistorySession.fromJson(Map<String, dynamic> json) {
    String displayTimeRange = json['timeRange'] ?? '';

    try {
      final startRaw = json['startTime'] ?? json['startedAt'] ?? json['createdAt'];
      final endRaw = json['endTime'] ?? json['endedAt'] ?? json['updatedAt'];

      if (startRaw != null) {
        final start = DateTime.parse(startRaw.toString()).toLocal();
        final startStr = _formatTime(start);

        if (json['status'] == 'active') {
          displayTimeRange = 'Started at $startStr';
        } else if (endRaw != null) {
          final end = DateTime.parse(endRaw.toString()).toLocal();
          final endStr = _formatTime(end);
          displayTimeRange = '$startStr - $endStr';
        }
      }
    } catch (_) {}

    return FocusHistorySession(
      modeName: json['modeName'] ?? '',
      timeRange: displayTimeRange,
      durationFormatted: json['duration']?['formatted'] ?? '',
      isActive: json['status'] == 'active',
    );
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class FocusHistoryDayGroup {
  final String dateHeader;
  final List<FocusHistorySession> sessions;

  const FocusHistoryDayGroup({
    required this.dateHeader,
    required this.sessions,
  });

  factory FocusHistoryDayGroup.fromJson(Map<String, dynamic> json) {
    return FocusHistoryDayGroup(
      dateHeader: json['dateHeader'] ?? '',
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => FocusHistorySession.fromJson(e))
          .toList(),
    );
  }
}

class FocusHistoryController extends GetxController {
  final totalFocusTime = ''.obs;
  final sinceDate = ''.obs;
  final modes = <FocusMode>[].obs;
  final sevenDaysStats = <SevenDayStat>[].obs;
  final historyGroups = <FocusHistoryDayGroup>[].obs;
  final selectedFilter = 'All'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFocusHistory();
  }

  List<String> get filterLabels => ['All', ...modes.map((m) => m.name)];

  List<FocusHistoryDayGroup> get filteredHistoryGroups {
    if (selectedFilter.value == 'All') return historyGroups;
    return historyGroups
        .map((g) => FocusHistoryDayGroup(
      dateHeader: g.dateHeader,
      sessions: g.sessions
          .where((s) => s.modeName == selectedFilter.value)
          .toList(),
    ))
        .where((g) => g.sessions.isNotEmpty)
        .toList();
  }

  void selectFilter(String filter) => selectedFilter.value = filter;

  Future<void> fetchFocusHistory() async {
    isLoading.value = true;
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.focusHistory,
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        if (data is! Map<String, dynamic>) return;

        totalFocusTime.value =
            data['summary']?['totalFocusTime']?['formatted']?.toString() ?? '';
        sinceDate.value = data['summary']?['sinceDate']?.toString() ?? '';

        if (data['modes'] is List) {
          modes.assignAll((data['modes'] as List)
              .map((e) => FocusMode.fromJson(e as Map<String, dynamic>))
              .toList());
        }

        if (data['sevenDaysStats'] is List) {
          sevenDaysStats.assignAll((data['sevenDaysStats'] as List)
              .map((e) => SevenDayStat.fromJson(e as Map<String, dynamic>))
              .toList());
        }

        if (data['history'] is List) {
          historyGroups.assignAll((data['history'] as List)
              .map((e) => FocusHistoryDayGroup.fromJson(e as Map<String, dynamic>))
              .toList());
        }
      }
    } catch (e) {
      // Silent error handling to avoid UI crashes
    } finally {
      isLoading.value = false;
    }
  }
}