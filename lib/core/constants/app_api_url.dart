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


  // ==================== Profile ====================
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
  const String liveServer = "http://148.230.126.149:5001"; // 🔴live URL
  // const String localServer = "http://10.10.7.93:5001"; // 🟡 local Server

  try {
    if (kDebugMode) return liveServer;
    return liveServer;
  } catch (e) {
    errorLog("_getDomain", e);
    return liveServer;
  }
}

// 10.10.7.93:5001/api/v1
