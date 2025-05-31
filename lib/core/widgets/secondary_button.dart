// lib/core/widgets/secondary_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive design (consistent with PrimaryButton)
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Responsive font size
    final responsiveFontSize = fontSize ?? (isSmallScreen ? 13 : 14);

    // Responsive button height (matching PrimaryButton)
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
                  textColor ?? borderColor ?? AppColors.primary,
                ),
                strokeWidth: 2,
              ),
            )
            : _buildButtonContent(responsiveFontSize);

    return SizedBox(
      width: fullWidth ? (width ?? double.infinity) : width,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(
            color: borderColor ?? AppColors.primary,
            width: borderWidth ?? 1.5,
          ),
          backgroundColor: backgroundColor ?? Colors.transparent,
          disabledForegroundColor: (textColor ?? AppColors.primary).withOpacity(
            0.6,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 4, // Match PrimaryButton padding
          ),
          // Ensure minimum button constraints (consistent with PrimaryButton)
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
          color: textColor ?? AppColors.primary,
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
        color: textColor ?? AppColors.primary,
        height: 1.2, // Proper line height (consistent with PrimaryButton)
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

// Extension for common secondary button variants
extension SecondaryButtonVariants on SecondaryButton {
  static SecondaryButton small({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      fullWidth: false,
      height: 36,
      fontSize: 12,
    );
  }

  static SecondaryButton large({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      height: 56,
      fontSize: 16,
    );
  }

  static SecondaryButton danger({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      textColor: Colors.red.shade600,
      borderColor: Colors.red.shade600,
    );
  }

  static SecondaryButton success({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      textColor: Colors.green.shade600,
      borderColor: Colors.green.shade600,
    );
  }
}
