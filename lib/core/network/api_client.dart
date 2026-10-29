import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/network/api_response.dart';
import 'package:product_listing_demo/core/storage/local_storage_service.dart';
import 'package:product_listing_demo/core/utils/debug_console.dart';

enum _RefreshResult { refreshed, rejected, failed }

class ApiClient {
  ApiClient._({HttpClientAdapter? adapter}) {
    _dio = Dio(_baseOptions())..interceptors.add(_defaultInterceptor());
    _refreshDio = Dio(_baseOptions());
    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
      _refreshDio.httpClientAdapter = adapter;
    }
  }

  static ApiClient? _instance;

  static ApiClient get instance => _instance ??= ApiClient._();

  @visibleForTesting
  static ApiClient resetForTesting({HttpClientAdapter? adapter}) => _instance = ApiClient._(adapter: adapter);

  late final Dio _dio;
  late final Dio _refreshDio;

  void Function()? _onSessionExpired;
  Future<_RefreshResult>? _refreshInFlight;

  static const _requiresAuthKey = 'requiresAuth';
  static const _isRetryKey = 'isRetry';
  static const _timeout = Duration(seconds: 20);
  static const _refreshTimeout = Duration(seconds: 15);

  LocalStorageService get _storage => LocalStorageService.instance;

  void configure({void Function()? onSessionExpired}) {
    _onSessionExpired = onSessionExpired;
  }

  // ==================== HTTP Methods ====================

  Future<ApiResponse<T>> get<T>(
    String path, {
    required ResponseParser<T> parser,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _send(
      parser,
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(requiresAuth),
        cancelToken: cancelToken,
      ),
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    required ResponseParser<T> parser,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) {
    return _send(
      parser,
      () => _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(requiresAuth),
        cancelToken: cancelToken,
      ),
    );
  }

  // ==================== Request / Response ====================

  Future<ApiResponse<T>> _send<T>(ResponseParser<T> parser, Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      final body = _decodeBody(response.data);
      try {
        return ApiResponse.success(body, parser, statusCode: response.statusCode);
      } catch (error) {
        console('Parse failed for ${response.requestOptions.uri}: $error', tag: 'API', type: DebugType.error);
        return ApiResponse.failure('Unexpected response from server.', statusCode: response.statusCode);
      }
    } on DioException catch (error) {
      return ApiResponse.failure(
        _handleError(error),
        statusCode: error.response?.statusCode,
        failureType: _failureType(error),
      );
    } catch (error) {
      console('Request failed: $error', tag: 'API', type: DebugType.error);
      return ApiResponse.failure('Something went wrong. Please try again.');
    }
  }

  // ==================== Interceptor ====================

  Interceptor _defaultInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.extra[_requiresAuthKey] != false) {
          final token = _storage.accessToken;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }
        }
        _logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logResponse(response);
        handler.next(response);
      },
      onError: (error, handler) async {
        _logError(error);
        if (!_shouldRefresh(error)) return handler.next(error);

        final request = error.requestOptions;
        final sentToken = _bearerToken(request.headers['Authorization']);
        final currentToken = _storage.accessToken;

        // Another request already got a new token while this one was in flight.
        final tokenAlreadyReplaced = currentToken.isNotEmpty && currentToken != sentToken;
        final result = tokenAlreadyReplaced ? _RefreshResult.refreshed : await _refreshTokens();

        switch (result) {
          case _RefreshResult.refreshed:
            try {
              return handler.resolve(await _dio.fetch<Object?>(_retryOptions(request)));
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          case _RefreshResult.rejected:
            _expireSession();
            return handler.next(error);
          case _RefreshResult.failed:
            return handler.next(error);
        }
      },
    );
  }

  bool _shouldRefresh(DioException error) {
    final request = error.requestOptions;
    return error.response?.statusCode == 401 &&
        request.extra[_requiresAuthKey] != false &&
        request.extra[_isRetryKey] != true &&
        _storage.refreshToken.isNotEmpty;
  }

  RequestOptions _retryOptions(RequestOptions request) {
    return request.copyWith(extra: {...request.extra, _isRetryKey: true});
  }

  // ==================== Token Refresh ====================

  Future<_RefreshResult> _refreshTokens() {
    return _refreshInFlight ??= _performTokenRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<_RefreshResult> _performTokenRefresh() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken.isEmpty) return _RefreshResult.rejected;

    console('Refreshing access token', tag: 'API', type: DebugType.alert);

    try {
      final response = await _refreshDio
          .post<Object?>(
            Apis.refreshToken,
            data: {'refreshToken': refreshToken, 'expiresInMins': AppConstants.tokenLifetimeMins},
          )
          .timeout(_refreshTimeout);

      final body = _decodeBody(response.data);
      final accessToken = body['accessToken'];
      if (accessToken is! String || accessToken.isEmpty) return _RefreshResult.rejected;

      final newRefreshToken = body['refreshToken'];
      _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken is String && newRefreshToken.isNotEmpty ? newRefreshToken : refreshToken,
      );
      return _RefreshResult.refreshed;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != null && status >= 400 && status < 500) return _RefreshResult.rejected;
      console('Token refresh failed: ${error.message}', tag: 'API', type: DebugType.error);
      return _RefreshResult.failed;
    } catch (error) {
      console('Token refresh failed: $error', tag: 'API', type: DebugType.error);
      return _RefreshResult.failed;
    }
  }

  void _expireSession() {
    if (!_storage.hasSession) return;
    _storage.clearTokens();
    _onSessionExpired?.call();
  }

  // ==================== Helpers ====================

  BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: Apis.baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      responseType: ResponseType.json,
      headers: {Headers.acceptHeader: Headers.jsonContentType, Headers.contentTypeHeader: Headers.jsonContentType},
    );
  }

  Options _buildOptions(bool requiresAuth) => Options(extra: {_requiresAuthKey: requiresAuth});

  Map<String, dynamic> _decodeBody(Object? data) {
    if (data == null || data == '') return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  String? _bearerToken(Object? header) {
    if (header is! String) return null;
    return header.startsWith('Bearer ') ? header.substring(7) : header;
  }

  // ==================== Error Handling ====================

  String _handleError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => 'Connection timeout. Please try again.',
      DioExceptionType.badResponse =>
        _extractErrorMessage(error.response?.data) ??
            'Server error: ${error.response?.statusMessage ?? error.response?.statusCode ?? ''}',
      DioExceptionType.cancel => 'Request was cancelled',
      DioExceptionType.connectionError => 'No internet connection. Please check your network.',
      DioExceptionType.badCertificate => 'Certificate verification failed',
      DioExceptionType.unknown => 'Something went wrong. Please try again.',
    };
  }

  String? _extractErrorMessage(Object? data) {
    if (data is Map) {
      for (final key in const ['message', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
      return null;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  ApiFailureType _failureType(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiFailureType.timeout,
      DioExceptionType.connectionError => ApiFailureType.network,
      DioExceptionType.cancel => ApiFailureType.cancelled,
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
        401 => ApiFailureType.unauthorized,
        final code? when code >= 500 => ApiFailureType.server,
        _ => ApiFailureType.unknown,
      },
      _ => ApiFailureType.unknown,
    };
  }

  // ==================== Logging ====================

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    console(
      '${options.method} ${options.uri}\n'
      'Headers: ${_masked(options.headers)}'
      '${options.data == null ? '' : '\nData: ${_maskedData(options.data)}'}',
      tag: 'REQUEST',
      type: DebugType.url,
    );
  }

  void _logResponse(Response<Object?> response) {
    if (!kDebugMode) return;
    console('${response.statusCode} ${response.requestOptions.uri}', tag: 'RESPONSE', type: DebugType.response);
  }

  void _logError(DioException error) {
    if (!kDebugMode) return;
    console(
      '${error.response?.statusCode} ${error.requestOptions.uri}\n'
      'Message: ${error.message}\nResponse: ${error.response?.data}',
      tag: 'ERROR',
      type: DebugType.error,
    );
  }

  static const _secretKeys = ['authorization', 'token', 'password'];

  Map<String, dynamic> _masked(Map<String, dynamic> map) {
    return map.map((key, value) {
      final lower = key.toLowerCase();
      return MapEntry(key, _secretKeys.any(lower.contains) ? '***' : value);
    });
  }

  Object? _maskedData(Object? data) => data is Map ? _masked(Map<String, dynamic>.from(data)) : data;
}
