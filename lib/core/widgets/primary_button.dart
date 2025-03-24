// lib/core/widgets/primary_button.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/layout/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconSmall),
                SizedBox(width: 8),
              ],
              Text(text),
            ],
          );
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}