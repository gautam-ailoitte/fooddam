// lib/core/widgets/app_loading.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? customIndicator;

  const AppLoading({
    super.key,
    this.message,
    this.color = AppColors.primary,
    this.size = 36,
    this.strokeWidth = 4,
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          customIndicator ?? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}