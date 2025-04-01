import 'dart:collection';
import 'dart:developer';

import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:dio/dio.dart';
import 'package:guardian_bubble/core/extension/auth_error_handler.dart';

import '../../feature/data/data_source/local_data_source/local_data_source.dart';

const String errorInternet = "Your internet is not working it seems";
const String errorUnknown = "Unknown error occurred";
const String errorTypeServer = "Server Error";
const String errorTypeTimeout = "Time Out";

extension MyDioError on DioException {
  void printErrorPath() {
    log("${requestOptions.baseUrl}${requestOptions.path}",
        name: "Logout ${response?.statusCode}");
  }

  String getErrorFromDio({
    bool validateAuthentication = true,
    required final LocalDataSource localDataSource,
  }) {
    if (validateAuthentication &&
        response != null &&
        response!.statusCode != null &&
        response!.statusCode == 401) {
      localDataSource.logout();
      // router.go(AppRoutes.loginRoute);
    }

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return errorNoInternet;
    }

    if (response != null &&
        response?.data != null &&
        response!.statusCode != null &&
        response!.statusCode! <= 410 &&
        response!.statusCode! >= 400) {
      try {
        AuthErrorHandler data = AuthErrorHandler.fromJson(response?.data);
        return data.error?.errors?.first ?? errorUnknown;
      } catch (e) {}
    }

    if (response != null &&
        response!.data != null &&
        response!.data is String) {
      return response!.data.toString();
    }

    if (response != null && response!.data != null && response!.data! is Map) {
      //print(response!.data.toString());
      try {
        if (response!.data["message"] is List) {
          return ""
              .toErrorMessage(List<String>.from(response!.data["message"]));
        } else if (response!.data["error"] is LinkedHashMap) {
          final Map<String, dynamic> errorMap = response!.data["error"];
          if (errorMap.containsKey("errors") && errorMap["errors"] is String) {
            return errorMap["errors"];
          } else if (errorMap.containsKey("errors") &&
              errorMap["errors"] is List &&
              errorMap["errors"].isNotEmpty) {
            final List<dynamic> errors = errorMap["errors"] as List<dynamic>;
            return "".toErrorMessage(List<String>.from(errors));
          } else if (errorMap.containsKey("error_params") &&
              errorMap["error_params"] is List &&
              errorMap["error_params"].isNotEmpty) {
            final List<dynamic> errors =
                errorMap["error_params"] as List<dynamic>;
            return "".toErrorMessageFromMap(List<dynamic>.from(errors));
          }
        } else if (response!.data["error"] is String) {
          return response!.data["error"];
        }
      } on Exception {
        return errorUnknown;
      }
    }
    return errorUnknown;
  }

  String getErrorType() {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return errorTypeTimeout;
    }
    if (response != null && response!.data != null && response!.data! is Map) {
      try {
        if (response!.data["errors"] is LinkedHashMap) {
          final Map<String, dynamic> errorMap = response!.data["error"];
          if (errorMap.containsKey("type") && errorMap["type"] is String) {
            return errorMap["type"];
          }
        }
      } on Exception {
        return errorUnknown;
      }
    }
    return errorUnknown;
  }
}
