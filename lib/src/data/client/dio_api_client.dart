// lib/src/data/client/dio_api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service_extension.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';

/// DioApiClient - A Dio-based API client for network requests
class DioApiClient {
  final Dio _dio;
  final LocalDataSource _localDataSource;
  final String _baseUrl;
  final LoggerService _logger = LoggerService();

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
    _dio.options.connectTimeout = AppConstants.connectTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Make a copy of the options headers
          options.headers = Map<String, dynamic>.from(options.headers);

          // Get auth token from local storage for each request
          final token = await _localDataSource.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d(
              'Adding token to request: ${options.uri}',
              tag: 'API_CLIENT',
            );
          } else {
            _logger.d(
              'No token available for request: ${options.uri}',
              tag: 'API_CLIENT',
            );
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized errors by clearing token
          if (e.response?.statusCode == 401) {
            _logger.w('Got 401 error, clearing auth tokens', tag: 'API_CLIENT');
            // Clear both tokens to ensure clean logout
            await _localDataSource.clearToken();
            await _localDataSource.clearRefreshToken();

            // Optionally, could implement token refresh here if refresh token is available
            final refreshToken = await _localDataSource.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              _logger.d(
                'Refresh token available, could implement token refresh',
                tag: 'API_CLIENT',
              );
              // Token refresh implementation would go here
              // For now, we just log it as a possibility
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Always add logging interceptors in debug mode

    //   if (kDebugMode) {
    //     _dio.interceptors.add(
    //       InterceptorsWrapper(
    //         onRequest: (options, handler) {
    //           print('🔵 REQUEST[${options.method}] => PATH: ${options.path}');
    //           print('🔵 Headers: ${options.headers}');
    //           print('🔵 Body: ${options.data}');
    //           return handler.next(options);
    //         },
    //         onResponse: (response, handler) {
    //           print(
    //             '🟢 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    //           );
    //           print('🟢 Response data: ${response.data}');
    //           return handler.next(response);
    //         },
    //         onError: (DioException e, handler) {
    //           print(
    //             '🔴 ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
    //           );
    //           print('🔴 Error message: ${e.message}');
    //           print('🔴 Error data: ${e.response?.data}');
    //           return handler.next(e);
    //         },
    //       ),
    //     );
    //   }
    // }
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          responseHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            _logger.d(obj.toString(), tag: 'DIO_API');
          },
        ),
      );
    }
  }

  /// Perform a GET request with improved error handling
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool showErrors = true,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (showErrors) {
        _showErrorDialog(exception, endpoint);
      }
      throw exception;
    } catch (e) {
      if (showErrors) {
        _showGenericErrorDialog();
      }
      throw ServerException(e.toString());
    }
  }

  /// Perform a POST request with improved error handling
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool showErrors = true,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (showErrors) {
        _showErrorDialog(exception, endpoint);
      }
      throw exception;
    } catch (e) {
      if (showErrors) {
        _showGenericErrorDialog();
      }
      throw ServerException(e.toString());
    }
  }

  /// Perform a PATCH request with improved error handling
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool showErrors = true,
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (showErrors) {
        _showErrorDialog(exception, endpoint);
      }
      throw exception;
    } catch (e) {
      if (showErrors) {
        _showGenericErrorDialog();
      }
      throw ServerException(e.toString());
    }
  }

  /// Perform a PUT request with improved error handling
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool showErrors = true,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (showErrors) {
        _showErrorDialog(exception, endpoint);
      }
      throw exception;
    } catch (e) {
      if (showErrors) {
        _showGenericErrorDialog();
      }
      throw ServerException(e.toString());
    }
  }

  /// Perform a DELETE request with improved error handling
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool showErrors = true,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (showErrors) {
        _showErrorDialog(exception, endpoint);
      }
      throw exception;
    } catch (e) {
      if (showErrors) {
        _showGenericErrorDialog();
      }
      throw ServerException(e.toString());
    }
  }

  /// Process API response with improved handling
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
          final jsonData = jsonDecode(response.data as String);
          if (jsonData is Map) {
            return Map<String, dynamic>.from(jsonData);
          } else {
            return {'data': jsonData};
          }
        } catch (_) {
          return {'data': response.data};
        }
      }
      return {'data': response.data};
    } else {
      // Try to extract error message from response
      String errorMessage = 'Server error occurred';
      if (response.data is Map &&
          (response.data as Map).containsKey('message')) {
        errorMessage = (response.data as Map)['message'].toString();
      }
      throw ServerException(errorMessage);
    }
  }

  /// Handle Dio errors with more detailed exceptions
  Exception _handleDioError(DioException e) {
    _logger.e('API Error: ${e.toString()}', tag: 'API_CLIENT');

    // Check for network connectivity issues
    if (e.error is SocketException ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException('Network connection error: ${e.message}');
    }

    // Handle timeout errors
    if (e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('Request timed out: ${e.message}');
    }

    // Handle response errors (when we received a response with error status)
    if (e.response != null) {
      final int statusCode = e.response!.statusCode ?? 0;
      String errorMessage = 'Server error with status code: $statusCode';

      // Try to extract error message from response
      if (e.response!.data is Map) {
        final responseData = e.response!.data as Map;
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else if (responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        }
      }

      switch (statusCode) {
        case 400:
          return ValidationException(errorMessage);
        case 401:
          return UnauthorizedException(errorMessage);
        case 403:
          return ForbiddenException(errorMessage);
        case 404:
          return NotFoundException(errorMessage);
        case 422:
          return ValidationException(errorMessage);
        default:
          if (statusCode >= 500) {
            return ServerException(errorMessage);
          }
          return ServerException(errorMessage);
      }
    }

    // Handle other types of errors
    return ServerException('Unexpected API error: ${e.message}');
  }

  /// Helper method to show appropriate error dialog based on exception type
  void _showErrorDialog(Exception exception, String endpoint) {
    if (!kDebugMode) return; // Only show in debug mode

    if (exception is NetworkException) {
      NavigationServiceExtension.showNetworkErrorDialog();
    } else if (exception is TimeoutException) {
      NavigationServiceExtension.showErrorDialog(
        title: 'Request Timeout',
        message: exception.message,
      );
    } else if (exception is UnauthorizedException) {
      // Don't show dialog for auth errors as they're handled elsewhere
    } else if (exception is ServerException) {
      NavigationServiceExtension.showServerErrorDialog(
        message: '${exception.message}\nEndpoint: $endpoint',
      );
    }
  }

  /// Show generic error dialog
  void _showGenericErrorDialog() {
    NavigationServiceExtension.showErrorDialog(
      title: StringConstants.error,
      message: StringConstants.unexpectedError,
    );
  }
}
