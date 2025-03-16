// lib/src/presentation/widgets/common/error_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/widgets/app_error_widget.dart' as core_widgets;

/// Wrapper for the core error widget to maintain backwards compatibility
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return core_widgets.AppErrorWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.error_outline,
      retryText: 'Retry',
    );
  }
}