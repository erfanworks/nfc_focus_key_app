import 'package:flutter/foundation.dart';
import '../utils/log_print.dart';

class AppApiUrl {
  AppApiUrl._privateConstructor();

  static final AppApiUrl _instance = AppApiUrl._privateConstructor();

  static AppApiUrl get instance => _instance;

  // ==================== Domain ====================
  static final String domain = _getDomain();
  static final String socket = _getDomain();
  final String baseUrl = "$domain/api/v1";
  final String imgBaseUrl = domain;

  // ==================== Auth ====================
  final String singIn = "/auth/login";
  final String singUp = "/users";
  final String forgotPassword = "/auth/forget-password";
  final String resetPassword = "/auth/reset-password";
  final String verifyEmailOtp = "/auth/verify-email";
  final String forgotOtp = "/auth/verify-email";
  final String resendOtp = "/auth/resend-otp";
  final String googleLogin = "/auth/google-login";

  // ==================== App ========================
  final String pairing = "/users/pair-device";
  final String unpairing = "/users/unpair-device";
  final String createMood = "/modes";
  final String getAllMood = "/modes";
  final String getMoodById = "/modes";
  String updateMoodById(String modeId) => "/modes/$modeId";
  final String deleteMoodById = "/modes";
  String toggleModeActivation(String modeId) =>
      "/modes/$modeId/toggle-activation";
  final String lockStatus = "/modes/lock-status";
  final String lock = "/modes/lock-status";
  // String updateLockUnlock(String modeId) =>
  //     "/modes/$modeId/toggle-activation";

  // ==================== Break ========================
  final String breakCreateOrUpdateGlobally = "/breaks/config";
  final String breakConfig = "/breaks/config";
  final String breakStart = "/breaks/start";
  final String breakStatus = "/breaks/status";
  final String breakRemaining = "/breaks/remaining";

  // ==================== Friends ========================
  final String seeAppUsers = "/friends/users"; // GET METHOD
  final String addFriend = "/friends/add-friend"; // POST METHOD
  final String friendsList = "/friends/list"; // GET METHOD
  String removeFriend(String friendId) =>
      "/friends/remove-friend/$friendId";  // DELETE METHOD
  final String createNudge = "/friends/create-nudge"; // POST METHOD
  String joinNudge(String nudgeId) =>
      "/friends/join-nudge/$nudgeId"; // POST METHOD
  final String removeParticipant = "/friends/remove-participant"; // POST METHOD
  final String friendsNudgeHistory = "/friends/nudge-history"; // GET METHOD
  final String currentNudgeStatus = "/friends/current-nudge-status"; // GET METHOD
  String takeNudgeBreak(String nudgeId) =>
      "/friends/take-nudge-break/$nudgeId";
  // final String initiateNudge = "/friends/current-nudge-status"; // POST METHOD
  // String nudgePreviewByDetails(String previewId) =>  // GET METHOD
  //     "/friends/nudge/preview/$previewId";
  // String midgeConfirmById(String previewId) =>  // POST METHOD
  //     "/friends/nudge/confirm/$previewId";
  // String leaveNudgeBYID(String nudgeId) => // POST METHOD
  //     "/friends/leave-nudge/$nudgeId";
  final String initiateNudge = "/friends/nudge/initiate";
  String nudgePreviewByDetails(String previewId) => "/friends/nudge/preview/$previewId";
  String midgeConfirmById(String previewId) => "/friends/nudge/confirm/$previewId";
  String leaveNudgeBYID(String nudgeId) => "/friends/leave-nudge/$nudgeId";

  // ==================== Settings ====================
  final String refreshToken = "/refreshToken";
  final String changePassword = "/auth/change-password";
  final String userProfile = "/users/profile";
  final String updateProfile = "/users";
  final String deleteAccount = "/users/profile";
  final String helpAndSupport = "/supports";
  final String faq = "/faqs";
  final String about = "/rules/about";
  final String privacy = "/rules/privacy";
  final String terms = "/rules/terms";
  final String history = "/dashboard/history-v2"; // GET METHOD
  final String focusHistory = "/focus-sessions/history-v2"; // GET METHOD
  final String sessionsStatus = "/focus-sessions/stats"; // GET METHOD
  final String exportCsv = "/focus-sessions/export-csv"; // GET METHOD

  // ==================== Banner ====================
  final String banner = "/banners";

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty || path.toLowerCase().contains("null")) {
      return "";
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final String base = instance.imgBaseUrl.endsWith('/')
        ? instance.imgBaseUrl.substring(0, instance.imgBaseUrl.length - 1)
        : instance.imgBaseUrl;

    final String cleanPath = path.startsWith('/') ? path : '/$path';

    return "$base$cleanPath";
  }
}

String _getDomain() {
  // const String liveServer = "http://148.230.126.149:5001"; // 🔴live URL
  const String localServer = "http://10.10.7.10:5002"; // 🟡 local Server

  try {
    if (kDebugMode) return localServer;
    return localServer;
  } catch (e) {
    errorLog("_getDomain", e);
    return localServer;
  }
}

// 10.10.7.93:5001/api/v1
