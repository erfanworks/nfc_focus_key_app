import 'package:get/get.dart';

class FocusSession {
  final String timeRange;
  final String duration;
  final String mode;

  const FocusSession({
    required this.timeRange,
    required this.duration,
    required this.mode,
  });
}

class HistoryGroup {
  final String date;
  final List<FocusSession> sessions;

  const HistoryGroup({required this.date, required this.sessions});
}

class HistoryController extends GetxController {
  final totalFocusTime = '48h 32m'.obs;
  final sinceDate = 'Since April 1, 2026'.obs;
  final todayTime = '4m'.obs;
  final thisWeekTime = '2h 14m'.obs;

  final historyGroups = <HistoryGroup>[
    const HistoryGroup(
      date: 'TODAY',
      sessions: [
        FocusSession(
          timeRange: '8:14 AM – 10:02 AM',
          duration: '1h 48m',
          mode: 'Study',
        ),
        FocusSession(
          timeRange: '2:30 PM – 3:45 PM',
          duration: '1h 15m',
          mode: 'Study',
        ),
      ],
    ),
    const HistoryGroup(
      date: 'YESTERDAY',
      sessions: [
        FocusSession(
          timeRange: '9:00 AM – 11:30 AM',
          duration: '2h 30m',
          mode: 'Detox',
        ),
        FocusSession(
          timeRange: '3:00 PM – 4:15 PM',
          duration: '1h 15m',
          mode: 'Study',
        ),
      ],
    ),
    const HistoryGroup(
      date: 'APR 30',
      sessions: [
        FocusSession(
          timeRange: '7:45 AM – 10:00 AM',
          duration: '2h 15m',
          mode: 'Study',
        ),
        FocusSession(
          timeRange: '1:00 PM – 2:30 PM',
          duration: '1h 30m',
          mode: 'Study',
        ),
      ],
    ),
  ].obs;
}
