import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  static List<String> get allTimezones {
    try {
      tz.initializeTimeZones();
    } catch (_) {}
    
    final locations = tz.timeZoneDatabase.locations.keys.toList();
    locations.sort();
    return locations;
  }

  static Future<String> getCurrentTimezone() async {
    try {
      final currentTimezone = await FlutterTimezone.getLocalTimezone();
      return currentTimezone.toString();
    } catch (e) {
      return "UTC";
    }
  }
}
