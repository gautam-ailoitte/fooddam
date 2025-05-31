// lib/core/utils/error_utils.dart - NEW FILE
class ErrorUtils {
  /// Sanitize error messages to remove technical details before showing to users
  static String sanitizeErrorMessage(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();

    // Remove API endpoints and technical details
    if (lowerMessage.contains('/api/') ||
        lowerMessage.contains('endpoint') ||
        lowerMessage.contains('statuscode') ||
        lowerMessage.contains('dio') ||
        lowerMessage.contains('response') ||
        lowerMessage.contains('request')) {

      // Return generic message for technical errors
      if (lowerMessage.contains('otp')) {
        return 'Invalid OTP. Please check the code and try again.';
      }
      if (lowerMessage.contains('login') || lowerMessage.contains('auth')) {
        return 'Login failed. Please try again.';
      }
      if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
        return 'Please check your internet connection and try again.';
      }

      return 'Something went wrong. Please try again.';
    }

    // Return the message as-is if it's already user-friendly
    return errorMessage;
  }
}