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

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: Shorter text for better fit
    final displayText = _getShortText(text);

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
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18), // FIXED: Smaller icon
                  const SizedBox(width: 6), // FIXED: Less spacing
                ],
                Flexible(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14, // FIXED: Smaller font
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // FIXED: Handle overflow
                    maxLines: 1,
                  ),
                ),
              ],
            );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48, // FIXED: Standard height
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
            horizontal: AppDimensions.marginMedium,
            vertical: AppDimensions.marginSmall,
          ),
        ),
        child: buttonChild,
      ),
    );
  }

  // FIXED: Shorter text variants to prevent overflow
  String _getShortText(String originalText) {
    switch (originalText.toLowerCase()) {
      case 'complete planning':
        return 'Complete';
      case 'proceed to checkout':
        return 'Checkout';
      case 'previous week':
        return 'Previous';
      case 'next week':
        return 'Next Week';
      case 'start planning':
        return 'Start';
      case 'edit selection':
        return 'Edit';
      default:
        // If text is too long, truncate intelligently
        if (originalText.length > 12) {
          final words = originalText.split(' ');
          if (words.length > 1) {
            // Return first word + abbreviated second word
            return words.length > 1
                ? '${words[0]} ${words[1].substring(0, 1).toUpperCase()}'
                : words[0];
          }
          return '${originalText.substring(0, 10)}...';
        }
        return originalText;
    }
  }
}
