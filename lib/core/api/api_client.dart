import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:project_ease/core/services/storage/token_service.dart';

import 'api_endpoints.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return ApiClient(tokenService);
});

class ApiClient {
  final TokenService _tokenService;
  late final Dio _dio;

  ApiClient(this._tokenService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor (JWT)
    _dio.interceptors.add(AuthInterceptor(_tokenService));

    // Retry on network errors
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Logger only in debug
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // ===== HTTP METHODS =====

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  AuthInterceptor(this._tokenService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        options.path == ApiEndpoints.login ||
        options.path == ApiEndpoints.register;

    if (!isAuthEndpoint) {
      final token = await _tokenService.getToken();
      if (token != null && token.isNotEmpty) {
        final cleanToken = token.replaceFirst('Bearer ', '');
        options.headers['Authorization'] = 'Bearer $cleanToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _tokenService.removeToken();
    }
    handler.next(err);
  }
}
