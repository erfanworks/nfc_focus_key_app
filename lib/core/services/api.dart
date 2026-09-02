import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:focus_key/core/services/storage_services.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../routes/app_routes.dart';
import '../constants/app_api_url.dart';
import '../utils/log_print.dart';
import 'non_auth_api.dart';
import 'push_notification_service.dart';

class AppApi {
  AppApi._privateConstructor() {
    _initDio();
  }
  static final AppApi _instance = AppApi._privateConstructor();
  static AppApi get instance => _instance;

  final Dio _dio = Dio();
  final _storage = StorageServices.instance;

  void _initDio() {
    _dio.options
      ..baseUrl = AppApiUrl.instance.baseUrl
      ..connectTimeout = const Duration(seconds: 120)
      ..sendTimeout = const Duration(seconds: 120)
      ..receiveTimeout = const Duration(seconds: 120)
      ..followRedirects = false;

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
      // if (kDebugMode)
      //   PrettyDioLogger(
      //     requestHeader: true,
      //     request: true,
      //     compact: true,
      //     error: true,
      //     requestBody: true,
      //     responseHeader: true,
      //     responseBody: true,
      //   ),
    ]);
  }

  // ==================== Request Interceptor ====================
  Future<void> _onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    options.baseUrl = AppApiUrl.instance.baseUrl;
    options.contentType = 'application/json';
    options.headers["Accept"] = "application/json";

    final hasCustomAuth = options.headers.containsKey("Authorization") &&
        (options.headers["Authorization"] as String? ?? "").isNotEmpty;

    if (!hasCustomAuth) {
      final token = await _storage.getToken();
      if (token.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $token";
      }
    }

    return handler.next(options);
  }

  // ==================== Error Interceptor ====================
  Future<void> _onError(
      DioException error,
      ErrorInterceptorHandler handler,
      ) async {
    // Silently handle 401 without flooding logs
    if (error.response?.statusCode == 401) {
      await _handle401(error, handler);
      return;
    }

    appLog("""
API Error ►
  Status  : ${error.response?.statusCode}
  Message : ${error.message}
  URL     : ${error.requestOptions.path}
""");

    return handler.next(error);
  }

  // ==================== 401 Handler ====================
  Future<void> _handle401(
      DioException error,
      ErrorInterceptorHandler handler,
      ) async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken.isEmpty) {
        await _logoutAndRedirect();
        // Silent rejection to stop propagation to controllers/UI
        return handler.reject(error); 
      }

      final newAccessToken = await reFreshNewAccessToken(refreshToken);

      if (newAccessToken.isNotEmpty) {
        _dio.options.headers["Authorization"] = "Bearer $newAccessToken";
        final retryResponse = await _dio.fetch(error.requestOptions);
        return handler.resolve(retryResponse);
      } else {
        await _logoutAndRedirect();
        return handler.reject(error);
      }
    } catch (e) {
      errorLog("_handle401", e);
      return handler.reject(error);
    }
  }

  // ==================== Logout Helper ====================
  bool _isRedirecting = false;
  Future<void> logoutAndRedirect() async {
    if (_isRedirecting) return;
    _isRedirecting = true;
    
    await _storage.logout();
    
    try {
      if (Get.isRegistered<PushNotificationService>()) {
        await Get.find<PushNotificationService>().resetSyncState();
      }
    } catch (e) {
      errorLog("logoutAndRedirect.resetSyncState", e);
    }

    _dio.options.headers.remove("Authorization");
    
    // Check if we are already on login page or if the route is being disposed
    if (Get.currentRoute != Routes.login) {
      Get.offAllNamed(Routes.login);
    }
    
    // Reset flag after a delay to allow navigation to complete
    await Future.delayed(const Duration(seconds: 1));
    _isRedirecting = false;
  }

  Future<void> _logoutAndRedirect() => logoutAndRedirect();

  Dio get sendRequest => _dio;
}

// ==================== Token Refresh ====================
Future<String> reFreshNewAccessToken(String refreshToken) async {
  try {
    final response = await NonAuthApi.instance.sendRequest.post(
      AppApiUrl.instance.refreshToken,
      data: {"token": refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data?["data"];
      if (data is Map && data["accessToken"] is String) {
        final newToken = data["accessToken"] as String;
        await StorageServices.instance.setToken(newToken);
        return newToken;
      }
    } else {
      await StorageServices.instance.logout();
    }
  } catch (e) {
    errorLog("reFreshNewAccessToken", e);
  }
  return "";
}