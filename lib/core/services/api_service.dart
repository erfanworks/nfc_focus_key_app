import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:focus_key/core/services/storage_services.dart';
import '../utils/log_print.dart';
import '../widgets/AppSbackBar/app_snack_bar.dart';
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

      AppSnackBar.error("Unexpected response: $code");
      return null;
    } on SocketException catch (e) {
      errorLog('SocketException', e);
      AppSnackBar.error("Check your internet connection");
      return null;
    } on TimeoutException catch (e) {
      errorLog('TimeoutException', e);
      AppSnackBar.error("Request timed out. Please try again.");
      return null;
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      errorLog('UnknownException', e);
      AppSnackBar.error("Something went wrong");
      return null;
    }
  }

  // ==================== Dio Error Handler ====================
  Future<dynamic> _handleDioException(DioException e) async {
    errorLog('DioException', e);

    if (e.response != null) {
      // 401 is already handled in AppApi interceptor (token refresh + redirect)
      final message = e.response?.data?["message"];
      AppSnackBar.error(message != null ? "$message" : "Error: ${e.response?.statusCode}");
    } else {
      AppSnackBar.error("Network error. Please check your connection.");
    }

    return null;
  }
}