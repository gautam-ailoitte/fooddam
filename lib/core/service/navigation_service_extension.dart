// lib/core/service/navigation_service_extension.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service.dart';

/// Extension on NavigationService to provide dialog utilities
extension NavigationServiceExtension on NavigationService {
  static final LoggerService _logger = LoggerService();

  /// Show an error dialog with better error handling
  static Future<void> showErrorDialog({
    String? title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool useRootNavigator = true,
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show error dialog - no valid context');
      return;
    }

    return AppDialogs.showAlertDialog(
      context: context,
      title: title ?? StringConstants.error,
      message: message,
      buttonText: buttonText ?? StringConstants.ok,
      onPressed: onPressed,
    );
  }

  /// Show a loading dialog with better management
  static Future<void> showLoadingDialog({
    String? message,
    bool dismissible = false,
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show loading dialog - no valid context');
      return;
    }
    
    return AppDialogs.showLoadingDialog(
      context: context,
      message: message ?? StringConstants.loading,
    );
  }

  /// Hide any active dialog
  static void hideDialog() {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot hide dialog - no valid context');
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show a network error dialog with retry option
  static Future<bool?> showNetworkErrorDialog({
    VoidCallback? onRetry,
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show network error dialog - no valid context');
      return null;
    }

    return AppDialogs.showConfirmationDialog(
      context: context,
      title: StringConstants.networkError,
      message: StringConstants.networkErrorMessage,
      confirmText: StringConstants.retry,
      cancelText: StringConstants.cancel,
    ).then((confirmed) {
      if (confirmed == true && onRetry != null) {
        onRetry();
      }
      return confirmed;
    });
  }

  /// Show a server error dialog with retry option
  static Future<bool?> showServerErrorDialog({
    VoidCallback? onRetry,
    String? message,
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show server error dialog - no valid context');
      return null;
    }

    return AppDialogs.showConfirmationDialog(
      context: context,
      title: StringConstants.serverError,
      message: message ?? StringConstants.serverErrorMessage,
      confirmText: StringConstants.retry,
      cancelText: StringConstants.cancel,
    ).then((confirmed) {
      if (confirmed == true && onRetry != null) {
        onRetry();
      }
      return confirmed;
    });
  }

  /// Show a authentication error dialog
  static Future<void> showAuthErrorDialog({
    String? message,
    VoidCallback? onPressed,
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show auth error dialog - no valid context');
      return;
    }

    return AppDialogs.showAlertDialog(
      context: context,
      title: StringConstants.authError,
      message: message ?? StringConstants.invalidCredentials,
      buttonText: StringConstants.ok,
      onPressed: onPressed,
    );
  }

  /// Show a success dialog
  static Future<void> showSuccessDialog({
    required String title,
    String? message,
    String? buttonText,
    VoidCallback? onPressed,
    bool autoClose = true,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) async {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show success dialog - no valid context');
      return;
    }

    return AppDialogs.showSuccessDialog(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText ?? StringConstants.ok,
      onPressed: onPressed,
      autoClose: autoClose,
      autoCloseDuration: autoCloseDuration,
    );
  }

  /// Show a toast-style message
  static void showToast(String message, {bool isError = false}) {
    final context = NavigationService.context;
    if (context == null) {
      _logger.e('Cannot show toast - no valid context');
      return;
    }

    AppDialogs.showSnackBar(
      context: context,
      message: message,
      isError: isError,
    );
  }
}