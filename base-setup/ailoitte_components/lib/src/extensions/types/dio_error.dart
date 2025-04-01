import 'dart:collection';
import 'package:ailoitte_components/src/extensions/types/string.dart';
import 'package:dio/dio.dart';

const String errorInternet = "Your internet is not working it seems";
const String errorNoInternet = "No internet available";
const String errorUnknown = "Unknown error occurred";
const String errorTypeServer = "Server Error";
const String errorTypeTimeout = "Time Out";

extension MyDioError on DioError {
  String getErrorFromDio() {
    if (type == DioErrorType.connectionTimeout ||
        type == DioErrorType.receiveTimeout ||
        type == DioErrorType.sendTimeout) {
      return errorNoInternet;
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
    if (type == DioErrorType.connectionTimeout ||
        type == DioErrorType.receiveTimeout ||
        type == DioErrorType.sendTimeout) {
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
