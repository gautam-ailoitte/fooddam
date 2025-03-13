import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse {
  final int statusCode;
  final dynamic data;

  ApiResponse({
    required this.statusCode,
    required this.data,
  });
}

class ApiClient {
  final http.Client httpClient;
  final SharedPreferences sharedPreferences;
  final String baseUrl;

  ApiClient({
    required this.httpClient,
    required this.sharedPreferences,
    required this.baseUrl,
  });

  Future<String?> _getToken() async {
    return sharedPreferences.getString('CACHED_TOKEN');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: queryParameters);

    final response = await httpClient.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await httpClient.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _processResponse(response);
  }

  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await httpClient.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return _processResponse(response);
  }

  Future<ApiResponse> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await httpClient.delete(uri, headers: headers);
    return _processResponse(response);
  }

  ApiResponse _processResponse(http.Response response) {
    return ApiResponse(
      statusCode: response.statusCode,
      data: response.body.isNotEmpty ? json.decode(response.body) : null,
    );
  }
}