// lib/src/presentation/widgets/common/app_loading.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_loading.dart' as core;

/// Wrapper for the core loading widget to maintain backwards compatibility
class AppLoading extends StatelessWidget {
  final String? message;
  final Color color;

  const AppLoading({
    super.key,
    this.message,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return core.AppLoading(
      message: message,
      color: color,
    );
  }
}