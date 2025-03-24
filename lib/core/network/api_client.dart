import 'dart:convert';
import 'package:foodam/core/errors/execption.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodam/core/constants/app_constants.dart';

class ApiClient {
  final http.Client httpClient;
  final SharedPreferences sharedPreferences;
  final String baseUrl;

  ApiClient({
    required this.httpClient,
    required this.sharedPreferences,
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = sharedPreferences.getString(AppConstants.tokenKey);

    final response = await httpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = sharedPreferences.getString(AppConstants.tokenKey);

    final response = await httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
      body: body != null ? json.encode(body) : null,
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = sharedPreferences.getString(AppConstants.tokenKey);

    final response = await httpClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
      body: body != null ? json.encode(body) : null,
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = sharedPreferences.getString(AppConstants.tokenKey);

    final response = await httpClient.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      },
    );

    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ServerException();
    }
  }
}