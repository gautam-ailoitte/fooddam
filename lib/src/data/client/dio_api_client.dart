// lib/src/data/datasource/dio_api_client.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
// import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';

/// DioApiClient - A Dio-based API client for network requests
class DioApiClient {
  final Dio _dio;
  final LocalDataSource _localDataSource;
  final String _baseUrl;
  //  final LoggerService _logger = LoggerService();

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
          final token = await _localDataSource.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized errors
          if (e.response?.statusCode == 401) {
            // Token expired or invalid - could handle logout here
            // await _localDataSource.clearToken();
          }
          return handler.next(e);
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: false, // Disable request body logging
        requestHeader: false, // Disable request headers logging
        responseHeader: false, // Disable response headers
        responseBody: false, // Disable full response body logging
        error: true, // Keep error logging enabled
      ),
    );

    // Add logging interceptor for development
    if (AppConstants.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
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
