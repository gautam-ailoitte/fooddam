// lib/src/presentation/widgets/common/app_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/widgets/app_button.dart' as core;

/// Wrapper for the core button to maintain backwards compatibility
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return core.AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      padding: padding,
      buttonType: core.AppButtonType.primary,
      buttonSize: core.AppButtonSize.medium,
    );
  }
}