// lib/core/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDimensions.marginLarge),
              PrimaryButton(
                text: 'Try Again',
                onPressed: onRetry,
                fullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}