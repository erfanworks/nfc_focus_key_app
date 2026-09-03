import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_api_url.dart';

/// Non-authenticated Dio client.
/// Used for: login, register, refresh token — any request that does NOT need Bearer token.
class NonAuthApi {
  static final NonAuthApi _instance = NonAuthApi._privateConstructor();
  static NonAuthApi get instance => _instance;
  NonAuthApi._privateConstructor() {
    _initDio();
  }

  final Dio _dio = Dio();

  void _initDio() {
    _dio.options
      ..baseUrl = AppApiUrl.instance.baseUrl
      ..connectTimeout = const Duration(seconds: 60)
      ..sendTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 60)
      ..followRedirects = false
      ..contentType = 'application/json'
      ..headers["Accept"] = "application/json";

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = AppApiUrl.instance.baseUrl;
          return handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          request: true,
          compact: true,
          error: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
    ]);
  }

  Dio get sendRequest => _dio;
}