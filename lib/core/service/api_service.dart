// lib/core/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:foodam/core/service/logger_service.dart';
import 'package:http/http.dart' as http;
import 'package:foodam/core/constants/app_constants.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Standardized API response
class ApiResponse<T> {
  final int statusCode;
  final T data;
  final String? message;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.data,
    this.message,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse<T>(
      statusCode: json['status_code'] ?? 200,
      data: fromJson(json['data']),
      message: json['message'],
      success: json['success'] ?? true,
    );
  }
}

/// API Service for handling HTTP requests with standardized error handling
class ApiService {
  final http.Client _client;
  final SharedPreferences _sharedPreferences;
  final LoggerService _logger = LoggerService();
  
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeoutDuration;

  ApiService({
    required http.Client client,
    required SharedPreferences sharedPreferences,
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.timeoutDuration = const Duration(seconds: 30),
  }) : 
    _client = client,
    _sharedPreferences = sharedPreferences;

  /// Get auth token from shared preferences
  Future<String?> _getToken() async {
    return _sharedPreferences.getString(AppConstants.tokenKey);
  }

  /// Create headers including auth token if available
  Future<Map<String, String>> _createHeaders([Map<String, String>? additionalHeaders]) async {
    final headers = Map<String, String>.from(defaultHeaders);
    
    // Add auth token if available
    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  /// Handle network errors uniformly
  Exception _handleError(dynamic error, String url) {
    _logger.e('API Error on $url', error: error);
    
    if (error is SocketException || error is http.ClientException) {
      return NetworkException();
    } else if (error is http.Response) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return UnauthorizedException();
      } else {
        return ServerException();
      }
    } else {
      return ServerException();
    }
  }

  /// Process response and handle errors
  dynamic _processResponse(http.Response response) {
    _logger.d('API Response [${response.statusCode}] for ${response.request?.url}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthorizedException();
    } else {
      _logger.e(
        'Server error [${response.statusCode}]',
        error: response.body,
        tag: 'API',
      );
      throw ServerException();
    }
  }

  /// GET request
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters,
      );
      
      _logger.d('GET request to $fullUrl', tag: 'API');
      
      final response = await _client
          .get(
            fullUrl,
            headers: await _createHeaders(headers),
          )
          .timeout(timeoutDuration);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }

  /// POST request
  Future<T> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('POST request to $fullUrl', tag: 'API');
      
      if (body != null) {
        _logger.d('Body: $body', tag: 'API');
      }
      
      final response = await _client
          .post(
            fullUrl,
            headers: await _createHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('PUT request to $fullUrl', tag: 'API');
      
      if (body != null) {
        _logger.d('Body: $body', tag: 'API');
      }
      
      final response = await _client
          .put(
            fullUrl,
            headers: await _createHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }

  /// PATCH request
  Future<T> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('PATCH request to $fullUrl', tag: 'API');
      
      if (body != null) {
        _logger.d('Body: $body', tag: 'API');
      }
      
      final response = await _client
          .patch(
            fullUrl,
            headers: await _createHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('DELETE request to $fullUrl', tag: 'API');
      
      final response = await _client
          .delete(
            fullUrl,
            headers: await _createHeaders(headers),
          )
          .timeout(timeoutDuration);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }

  /// Upload file with multipart request
  Future<T> uploadFile<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fullUrl = Uri.parse('$baseUrl$endpoint');
      
      _logger.d('UPLOAD to $fullUrl', tag: 'API');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', fullUrl);
      
      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      // Add headers
      final requestHeaders = await _createHeaders(headers);
      request.headers.addAll(requestHeaders);
      
      // Add fields if available
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Send request
      final streamedResponse = await request.send().timeout(timeoutDuration);
      
      // Convert to Response object
      final response = await http.Response.fromStream(streamedResponse);
      
      final data = _processResponse(response);
      
      if (fromJson != null) {
        return fromJson(data);
      } else {
        return data as T;
      }
    } catch (error) {
      throw _handleError(error, endpoint);
    }
  }
}