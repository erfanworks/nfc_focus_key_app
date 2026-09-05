import 'dart:developer';

import 'package:flutter/foundation.dart';

void errorLog(String message, dynamic e, {String title = "Error form"}) {
  try {
    if (kDebugMode) {
      // Don't log 401 unauthorized errors with emojis to keep console clean during logout
      if (e.toString().contains('401')) return;

      debugPrint("👿😈😡😡😡😡 $title ➡️➡️➡️➡️➡️➡️ $message >>> 😭😭😭😭 ${e.toString()} 🔚🔚");
    }
  } catch (e) {
    ///////
  }
}

void appLog(dynamic message) {
  try {
    if (kDebugMode) {
      debugPrint("""
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$message

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

""");
    }
  } catch (e) {
    errorLog("app log", e);
  }
}
