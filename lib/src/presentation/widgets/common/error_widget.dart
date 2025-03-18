// lib/src/presentation/widgets/common/app_error_display.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/widgets/app_button.dart';

class AppErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData icon;
  final bool isFullScreen;

  const AppErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon = Icons.error_outline,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: retryText ?? StringConstants.retry,
                onPressed: onRetry!,
                buttonType: AppButtonType.outline,
                buttonSize: AppButtonSize.medium,
                isFullWidth: false,
                textColor: AppColors.primary,
                backgroundColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        body: SafeArea(
          child: errorWidget,
        ),
      );
    }

    return errorWidget;
  }
}

class AppNetworkError extends AppErrorDisplay {
  const AppNetworkError({
    super.key,
    super.onRetry,
    super.retryText,
    super.isFullScreen,
  }) : super(
          message:"No internet connection. Please check your connection and try again.",
          icon: Icons.wifi_off,
        );
}

class AppEmptyDataError extends AppErrorDisplay {
  const AppEmptyDataError({
    super.key,
    required super.message,
    super.onRetry,
    super.retryText,
    super.icon = Icons.inbox,
    super.isFullScreen,
  });
}