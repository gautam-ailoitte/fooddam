// lib/src/presentation/widgets/common/fixed_app_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_loading.dart';

enum FixedAppButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum FixedAppButtonSize {
  small,
  medium,
  large,
}

class FixedAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding; // Made optional
  final FixedAppButtonType buttonType;
  final FixedAppButtonSize buttonSize;
  final IconData? icon;
  final bool iconTrailing;
  
  const FixedAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding, // Optional parameter
    this.buttonType = FixedAppButtonType.primary,
    this.buttonSize = FixedAppButtonSize.medium,
    this.icon,
    this.iconTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get color scheme based on button type
    final colors = _getButtonColors();
    
    // Get padding based on button size or use provided padding
    final buttonPadding = padding ?? _getButtonPadding(); // Use the method if no padding provided
    
    // Base button
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colors.background,
        foregroundColor: textColor ?? colors.text,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: buttonType == FixedAppButtonType.outline
            ? BorderSide(color: textColor ?? colors.text)
            : BorderSide.none,
        ),
        elevation: buttonType == FixedAppButtonType.text ? 0 : 1,
      ),
      child: _buildButtonContent(colors),
    );
    
    // Apply full width if needed
    if (isFullWidth) {
      // Use a more reliable approach to set full width
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          child: button,
        ),
      );
    }
    
    return button;
  }
  
  Widget _buildButtonContent(_ButtonColors colors) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: AppLoading(
          color: textColor ?? colors.text,
        ),
      );
    }
    
    // Button with icon
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!iconTrailing) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
          if (iconTrailing) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      );
    }
    
    // Simple text button
    return Text(label);
  }
  
  EdgeInsetsGeometry _getButtonPadding() {
    switch (buttonSize) {
      case FixedAppButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
      case FixedAppButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0);
      case FixedAppButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0);
    }
  }
  
  _ButtonColors _getButtonColors() {
    switch (buttonType) {
      case FixedAppButtonType.primary:
        return _ButtonColors(
          background: AppColors.primary,
          text: Colors.white,
        );
      case FixedAppButtonType.secondary:
        return _ButtonColors(
          background: const Color.fromARGB(255, 168, 133, 133),
          text: Colors.white,
        );
      case FixedAppButtonType.outline:
        return _ButtonColors(
          background: Colors.transparent,
          text: AppColors.primary,
        );
      case FixedAppButtonType.text:
        return _ButtonColors(
          background: Colors.transparent,
          text: AppColors.primary,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color text;
  
  _ButtonColors({
    required this.background,
    required this.text,
  });
}