// lib/core/widgets/primary_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Responsive font size
    final responsiveFontSize = fontSize ?? (isSmallScreen ? 13 : 14);

    // Responsive button height
    final buttonHeight = height ?? (isSmallScreen ? 44 : 48);

    // Responsive padding
    final horizontalPadding =
        isSmallScreen ? AppDimensions.marginSmall : AppDimensions.marginMedium;

    final buttonChild =
        isLoading
            ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? Colors.white,
                ),
                strokeWidth: 2,
              ),
            )
            : _buildButtonContent(responsiveFontSize);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: onPressed != null ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 4,
          ),
          // Ensure minimum button constraints
          minimumSize: Size(0, buttonHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildButtonContent(double fontSize) {
    if (icon != null) {
      return _buildButtonWithIcon(fontSize);
    } else {
      return _buildTextOnly(fontSize);
    }
  }

  Widget _buildButtonWithIcon(double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: fontSize + 2, // Icon slightly larger than text
          color: textColor ?? Colors.white,
        ),
        SizedBox(width: 4),
        Flexible(child: _buildTextWidget(fontSize)),
      ],
    );
  }

  Widget _buildTextOnly(double fontSize) {
    return _buildTextWidget(fontSize);
  }

  Widget _buildTextWidget(double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: textColor ?? Colors.white,
        height: 1.2, // Proper line height
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

// Extension for common button variants
extension PrimaryButtonVariants on PrimaryButton {
  static PrimaryButton small({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fullWidth: false,
      height: 36,
      fontSize: 12,
    );
  }

  static PrimaryButton large({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      height: 56,
      fontSize: 16,
    );
  }

  static PrimaryButton outline({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? borderColor,
    Color? textColor,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppColors.primary,
    );
  }
}
