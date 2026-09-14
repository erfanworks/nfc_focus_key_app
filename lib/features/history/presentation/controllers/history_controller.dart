import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/widgets/custom_snackbar.dart';

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
    String displayTimeRange = json['timeRange'] ?? '';
    String displayDuration = '';

    // Handle duration which can be a string or a map
    final durationData = json['duration'];
    if (durationData is Map) {
      displayDuration = durationData['formatted']?.toString() ?? '';
    } else {
      displayDuration = durationData?.toString() ?? '';
    }

    try {
      final startRaw = json['startTime'] ?? json['startedAt'] ?? json['createdAt'];
      final endRaw = json['endTime'] ?? json['endedAt'] ?? json['updatedAt'];

      if (startRaw != null) {
        // Ensure we parse as UTC if it doesn't have a timezone indicator
        String startStrRaw = startRaw.toString();
        if (!startStrRaw.contains('Z') && !startStrRaw.contains('+')) {
          startStrRaw += 'Z';
        }
        
        final start = DateTime.parse(startStrRaw).toLocal();
        final startStr = _formatTime(start);

        if (json['status'] == 'active') {
          displayTimeRange = 'Started at $startStr';
        } else if (endRaw != null) {
          String endStrRaw = endRaw.toString();
          if (!endStrRaw.contains('Z') && !endStrRaw.contains('+')) {
            endStrRaw += 'Z';
          }
          final end = DateTime.parse(endStrRaw).toLocal();
          final endStr = _formatTime(end);
          displayTimeRange = '$startStr - $endStr';
        }
      }
    } catch (e) {
      // Fallback to timeRange if parsing fails
    }

    return FocusSession(
      timeRange: displayTimeRange,
      duration: displayDuration,
      mode: json['modeName'] ?? '',
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

class HistoryGroup {
  final String date;
  final List<FocusSession> sessions;

  const HistoryGroup({required this.date, required this.sessions});

  factory HistoryGroup.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionList = json['sessions'] as List<dynamic>? ?? [];
    
    // Sort sessions within the group by startTime/createdAt descending (most recent first)
    sessionList.sort((a, b) {
      try {
        final aTime = DateTime.parse(a['startTime'] ?? a['startedAt'] ?? a['createdAt'] ?? DateTime.now().toIso8601String());
        final bTime = DateTime.parse(b['startTime'] ?? b['startedAt'] ?? b['createdAt'] ?? DateTime.now().toIso8601String());
        return bTime.compareTo(aTime); // Latest session first
      } catch (_) {
        return 0;
      }
    });

    return HistoryGroup(
      date: json['dateGroup'] ?? '',
      sessions: sessionList.map((e) => FocusSession.fromJson(e)).toList(),
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
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return; // Skip if logged out

      isLoading.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.history,
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        
        final totalFocus = data['totalFocusTime'];
        if (totalFocus is Map) {
          totalFocusTime.value = totalFocus['formatted']?.toString() ?? '';
        } else {
          totalFocusTime.value = totalFocus?.toString() ?? '';
        }
        
        sinceDate.value = data['sinceDate']?.toString() ?? '';
        
        final List<dynamic> historyData = data['history'] ?? [];
        final List<HistoryGroup> groups = historyData
            .map((e) => HistoryGroup.fromJson(e))
            .toList();
            
        // Final sanity check: If the first group is older than the last group (e.g. Yesterday before Today), 
        // we reverse them to ensure Newest First.
        if (groups.length > 1 && groups.first.date.toLowerCase().contains('yesterday') && 
            groups.any((g) => g.date.toLowerCase().contains('today'))) {
          historyGroups.value = groups.reversed.toList();
        } else {
          historyGroups.value = groups;
        }
      } else if (response != null) {
        CustomSnackbar.show(
          title: "Update Failed",
          message: response["message"] ?? "Could not sync history data.",
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to load history. Please check your internet.",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
