// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';

enum AppButtonType { primary, secondary, outline, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonType buttonType;
  final AppButtonSize buttonSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? iconSize;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.buttonType = AppButtonType.primary,
    this.buttonSize = AppButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define sizes based on buttonSize
    final double height;
    final double fontSize;
    final double iconSizeValue;
    final EdgeInsetsGeometry paddingValue;
    
    switch (buttonSize) {
      case AppButtonSize.small:
        height = 36;
        fontSize = 14;
        iconSizeValue = iconSize ?? 18;
        paddingValue = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case AppButtonSize.medium:
        height = 48;
        fontSize = 16;
        iconSizeValue = iconSize ?? 20;
        paddingValue = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        break;
      case AppButtonSize.large:
        height = 56;
        fontSize = 18;
        iconSizeValue = iconSize ?? 24;
        paddingValue = padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        break;
    }
    
    // Choose button style based on type
    final ButtonStyle buttonStyle;
    final Widget buttonLabel;
    final BorderRadius borderRadiusValue = BorderRadius.circular(borderRadius ?? 8);
    
    switch (buttonType) {
      case AppButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: paddingValue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusValue,
          ),
          minimumSize: Size(0, height),
        );
        break;
      
      case AppButtonType.secondary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.accent,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: paddingValue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusValue,
          ),
          minimumSize: Size(0, height),
        );
        break;
      
      case AppButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: textColor ?? theme.primaryColor,
          side: BorderSide(color: backgroundColor ?? theme.primaryColor, width: 1.5),
          padding: paddingValue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusValue,
          ),
          minimumSize: Size(0, height),
        );
        break;
      
      case AppButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: textColor ?? theme.primaryColor,
          padding: paddingValue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusValue,
          ),
          minimumSize: Size(0, height),
        );
        break;
    }
    
    // Build the button content with icons if provided
    if (isLoading) {
      buttonLabel = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            buttonType == AppButtonType.outline || buttonType == AppButtonType.text
                ? textColor ?? theme.primaryColor
                : textColor ?? Colors.white,
          ),
        ),
      );
    } else if (leadingIcon != null && trailingIcon != null) {
      buttonLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: iconSizeValue),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(trailingIcon, size: iconSizeValue),
        ],
      );
    } else if (leadingIcon != null) {
      buttonLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: iconSizeValue),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (trailingIcon != null) {
      buttonLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(trailingIcon, size: iconSizeValue),
        ],
      );
    } else {
      buttonLabel = Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    // Build the final button
    Widget button;
    
    switch (buttonType) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonLabel,
        );
        break;
      
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonLabel,
        );
        break;
      
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonLabel,
        );
        break;
    }
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }
}