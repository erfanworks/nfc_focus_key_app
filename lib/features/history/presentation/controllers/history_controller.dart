import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class FocusSession {
  final String timeRange;
  final String duration;
  final String mode;
  final bool isActive;

  const FocusSession({
    required this.timeRange,
    required this.duration,
    required this.mode,
    this.isActive = false,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      timeRange: json['timeRange'] ?? '',
      duration: json['duration'] ?? '',
      mode: json['modeName'] ?? '',
      isActive: json['status'] == 'active',
    );
  }
}

class HistoryGroup {
  final String date;
  final List<FocusSession> sessions;

  const HistoryGroup({required this.date, required this.sessions});

  factory HistoryGroup.fromJson(Map<String, dynamic> json) {
    return HistoryGroup(
      date: json['dateGroup'] ?? '',
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => FocusSession.fromJson(e))
          .toList(),
    );
  }
}

class HistoryController extends GetxController {
  final totalFocusTime = ''.obs;
  final sinceDate = ''.obs;
  final historyGroups = <HistoryGroup>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.history,
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        totalFocusTime.value = data['totalFocusTime'] ?? '';
        sinceDate.value = data['sinceDate'] ?? '';
        historyGroups.value = (data['history'] as List<dynamic>? ?? [])
            .map((e) => HistoryGroup.fromJson(e))
            .toList();
      }
    } finally {
      isLoading.value = false;
    }
  }
}