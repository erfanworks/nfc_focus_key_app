import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:focus_key/core/services/storage_services.dart';
import '../utils/log_print.dart';
import 'api.dart';

class ApiServices {
  ApiServices._privateConstructor();
  static final ApiServices _instance = ApiServices._privateConstructor();
  static ApiServices get instance => _instance;

  final _api = AppApi.instance;
  final _storage = StorageServices.instance;

  // ==================== GET ====================
  Future<dynamic> getServices(
      String url, {
        int statusCode = 200,
        Map<String, dynamic>? queryParameters,
        dynamic body,
      }) async {
    return _handleRequest(
          () => _api.sendRequest.get(
        url,
        queryParameters: queryParameters,
        data: body,
      ),
      statusCode: statusCode,
    );
  }

  // ==================== POST ====================
  Future<dynamic> postServices({
    required String url,
    dynamic body,
    int statusCodeStart = 200,
    int statusCodeEnd = 299,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return _handleRequest(
          () => _api.sendRequest.post(url, data: body, queryParameters: query, options: options),
      statusCodeStart: statusCodeStart,
      statusCodeEnd: statusCodeEnd,
    );
  }

  // ==================== PUT ====================
  Future<dynamic> putServices({
    required String url,
    dynamic body,
    int statusCode = 200,
    Map<String, dynamic>? query,
  }) async {
    return _handleRequest(
          () => _api.sendRequest.put(url, data: body, queryParameters: query),
      statusCode: statusCode,
    );
  }

  // ==================== PATCH ====================
  Future<dynamic> patchServices({
    required String url,
    Object? body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return _handleRequest(
          () => _api.sendRequest.patch(
        url,
        data: body,
        queryParameters: query,
        options: options,
      ),
      statusCode: statusCode,
    );
  }

  // ==================== DELETE ====================
  Future<dynamic> deleteServices({
    required String url,
    Object? body,
    int statusCode = 200,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return _handleRequest(
          () => _api.sendRequest.delete(
        url,
        data: body,
        queryParameters: query,
        options: options,
      ),
      statusCode: statusCode,
    );
  }

  // ==================== Core Handler ====================
  Future<dynamic> _handleRequest(
      Future<Response> Function() request, {
        int? statusCode,
        int? statusCodeStart,
        int? statusCodeEnd,
      }) async {
    try {
      final response = await request();
      final code = response.statusCode ?? 0;

      final bool isSuccess = statusCode != null
          ? code == statusCode
          : (statusCodeStart != null && statusCodeEnd != null)
          ? code >= statusCodeStart && code <= statusCodeEnd
          : false;

      if (isSuccess) return response.data;

      return _errorResult("Unexpected response ($code). Please try again.");
    } on SocketException catch (e) {
      errorLog('SocketException', e);
      return _errorResult("Check your internet connection.");
    } on TimeoutException catch (e) {
      errorLog('TimeoutException', e);
      return _errorResult("Request timed out. Please try again.");
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      errorLog('UnknownException', e);
      return _errorResult("Something went wrong. Please try again.");
    }
  }

  // ==================== Dio Error Handler ====================
  Future<dynamic> _handleDioException(DioException e) async {
    errorLog('DioException', e);

    if (e.response != null) {
      // 401 is already handled in AppApi interceptor (token refresh + redirect)
      final data = e.response?.data;
      final message = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "Error ${e.response?.statusCode}. Please try again.";
      return _errorResult(message);
    }

    return _errorResult("Network error. Please check your connection.");
  }

  // Every failure path returns this shape so callers can rely on a single,
  // consistent check: `response == null || response["success"] != true`,
  // and always get the REAL backend message via `response["message"]`
  // instead of a generic fallback.
  Map<String, dynamic> _errorResult(String message) => {
    "success": false,
    "message": message,
  };
}