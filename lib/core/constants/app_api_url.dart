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
  final String register = "/users";
  final String registerVerifyOtp = "/auth/verify-email";
  final String singIn = "/auth/login";
  final String forgotPassword = "/auth/forget-password";
  final String forgotVerifyOtp = "/auth/verify-email";
  final String resetPassword = "/auth/reset-password";

  // ==================== Home Screen ====================
  final String nearbyListingProperty = "/listings/nearby";
  final String listingById = "/listings";
  final String listingsSearch = "/listings/search";
  final String popularLocations = "/popular-locations";

  // ==================== Saved Screen ====================
  final String addFavouriteProperty = "/favorite-properties/toggle";
  final String favouriteProperties = "/favorite-properties";
  final String savedSearches = "/saved-searches";
  final String deleteSavedSearch = "/saved-searches";

  // ==================== Enquires ====================
  final String createEnquiries = "/enquiries";
  final String myEnquiries = "/enquiries/my-enqueries";
  final String myEnquiriesById = "/enquiries/my-enqueries";

  // ==================== Profile ====================
  final String userProfile = "/users";
  final String userProfileInfo = "/users/profile";
  final String userDeleteProfile = "/users/profile";
  final String changePassword = "/auth/change-password";
  final String about = "/rules/about";
  final String privacy = "/rules/privacy";
  final String terms = "/rules/terms";
  final String faqs = "/faqs";
  final String refreshToken = "/refreshToken";

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
