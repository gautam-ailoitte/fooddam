// lib/core/services/dialog_service.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_text_style.dart';
import 'package:foodam/core/widgets/app_button.dart';

class AppDialogs {
  // Show a simple alert dialog
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            AppButton(
              label: buttonText ?? 'OK',
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
              isFullWidth: false,
              buttonType: AppButtonType.text,
              buttonSize: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }
  
  // Show a confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructiveAction = false,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            AppButton(
              label: cancelText,
              onPressed: () => Navigator.of(context).pop(false),
              isFullWidth: false,
              buttonType: AppButtonType.text,
              buttonSize: AppButtonSize.small,
            ),
            AppButton(
              label: confirmText,
              onPressed: () => Navigator.of(context).pop(true),
              isFullWidth: false,
              buttonType: isDestructiveAction ? AppButtonType.secondary : AppButtonType.primary,
              buttonSize: AppButtonSize.small,
              backgroundColor: isDestructiveAction ? AppColors.error : null,
            ),
          ],
        );
      },
    );
  }
  
  // Show a dialog with custom content
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget content,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
    EdgeInsets contentPadding = const EdgeInsets.all(24),
    EdgeInsets titlePadding = const EdgeInsets.all(16),
    EdgeInsets actionsPadding = const EdgeInsets.only(right: 16, bottom: 16),
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: content,
          actions: actions,
          contentPadding: contentPadding,
          titlePadding: titlePadding,
          actionsPadding: actionsPadding,
        );
      },
    );
  }
  
  // Show a dialog with multiple options
  static Future<String?> showOptionsDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    String? message,
    String cancelText = 'Cancel',
  }) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: [
            if (message != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(message),
              ),
              const Divider(),
            ],
            ...options.map((option) => SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(option),
              child: Text(option),
            )),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                cancelText,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Show a success dialog with animation
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    Duration autoCloseDuration = const Duration(seconds: 3),
    bool autoClose = false,
  }) async {
    // Capture if the dialog should auto-close before showing it
    final shouldAutoClose = autoClose;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        if (shouldAutoClose) {
          // Use dialogContext which is tied to the dialog's lifecycle
          Future.delayed(autoCloseDuration, () {
            // Check if the State object is still in the tree
            if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
              if (onPressed != null) {
                onPressed();
              }
            }
          });
        }
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            AppButton(
              label: buttonText,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
              isFullWidth: false,
              buttonType: AppButtonType.text,
              buttonSize: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }
  
  // Show a bottom sheet dialog
  static Future<T?> showBottomSheetDialog<T>({
    required BuildContext context,
    required Widget content,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) async {
    // Get the proper background color from the theme
    final dialogBgColor = backgroundColor ?? 
        Theme.of(context).dialogTheme.backgroundColor ?? 
        Theme.of(context).colorScheme.surface; // Fallback to surface color
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: dialogBgColor, // Use the properly retrieved color
      elevation: elevation,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar for dragging
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title if provided
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Show a loading dialog
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String? message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message ?? 'Loading...'),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to close dialog
  static void closeDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

 /// Show a snackbar message
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

}