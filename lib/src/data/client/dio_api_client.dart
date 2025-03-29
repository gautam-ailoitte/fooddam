// lib/src/data/client/dio_api_client.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';

/// DioApiClient - A Dio-based API client for network requests
class DioApiClient {
  final Dio _dio;
  final LocalDataSource _localDataSource;
  final String _baseUrl;
  final LoggingManager _loggingManager = LoggingManager();

  DioApiClient({
    required String baseUrl,
    required LocalDataSource localDataSource,
  }) : _baseUrl = baseUrl,
       _localDataSource = localDataSource,
       _dio = Dio() {
    _configureDio();
  }

  /// Configure Dio instance with interceptors and options
  void _configureDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get auth token from local storage for each request
          final token = await _localDataSource.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _loggingManager.logger.d('Adding token to request', tag: 'API_CLIENT');
          } else {
            _loggingManager.logger.d('No token available for request', tag: 'API_CLIENT');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized errors by clearing token
          if (e.response?.statusCode == 401) {
            _loggingManager.logger.w('Got 401 error, clearing auth tokens', tag: 'API_CLIENT');
            // Clear both tokens to ensure clean logout
            await _localDataSource.clearToken();
            await _localDataSource.clearRefreshToken();
            
            // Optionally, could implement token refresh here if refresh token is available
            final refreshToken = await _localDataSource.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              _loggingManager.logger.d('Refresh token available, could implement token refresh', tag: 'API_CLIENT');
              // Token refresh implementation would go here
              // For now, we just log it as a possibility
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Only add logging interceptors if appropriate log level is set
    if (_loggingManager.shouldLogApi()) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          responseHeader: true,
          // Only log full request/response body at verbose level
          requestBody: _loggingManager.shouldLogDetailedApi(),
          responseBody: _loggingManager.shouldLogDetailedApi(),
          error: true,
        ),
      );
    }
  }

  /// Perform a GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Perform a POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Perform a PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Perform a PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Perform a DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  /// Process API response
  Map<String, dynamic> _processResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // Handle empty responses
      if (response.data == null ||
          (response.data is String && (response.data as String).isEmpty)) {
        return {};
      }

      // Return response data
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        // Handle string response by parsing JSON
        try {
          return Map<String, dynamic>.from(
            response.data is String
                ? (response.data as String).isEmpty
                    ? {}
                    : jsonDecode(response.data as String)
                : response.data,
          );
        } catch (_) {
          return {'data': response.data};
        }
      }
      return {'data': response.data};
    } else {
      throw ServerException();
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException();
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return UnauthorizedException();
      }
      if (e.response!.statusCode == 403) {
        return ForbiddenException();
      }
      if (e.response!.statusCode == 404) {
        return NotFoundException();
      }
      if (e.response!.statusCode! >= 500) {
        return ServerException();
      }
    }

    return ServerException();
  }
}