// lib/core/errors/execption.dart - JUST UPDATE THE DEFAULT MESSAGES

/// Base exception for app-specific exceptions
class AppException implements Exception {
  final String message;

  AppException([this.message = 'Something went wrong. Please try again.']);

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  ServerException([super.message = 'Unable to connect to server. Please try again later.']);
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException([super.message = 'Please check your internet connection and try again.']);
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException([super.message = 'Something went wrong. Please try again.']);
}

/// Authentication-related exceptions
class UnauthenticatedException extends AppException {
  UnauthenticatedException([super.message = 'Please log in again.']);
}

/// Authorization-related exceptions
class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'You do not have permission to perform this action.']);
}

/// Invalid credentials exception
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException([super.message = 'Invalid email or password. Please try again.']);
}

/// User already exists exception
class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException([super.message = 'An account with this email already exists.']);
}

/// Email not verified exception
class EmailNotVerifiedException extends AppException {
  EmailNotVerifiedException([super.message = 'Please verify your email before logging in.']);
}

/// Invalid token exception
class InvalidTokenException extends AppException {
  InvalidTokenException([super.message = 'Session expired. Please log in again.']);
}

/// Invalid OTP exception
class InvalidOTPException extends AppException {
  InvalidOTPException([super.message = 'Invalid OTP. Please check the code and try again.']);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  ValidationException([super.message = 'Please check your information and try again.']);
}

/// Resource not found exception
class ResourceNotFoundException extends AppException {
  ResourceNotFoundException([super.message = 'The requested information could not be found.']);
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException([super.message = 'Request timed out. Please try again.']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'You are not authorized to perform this action.']);
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'The requested information could not be found.']);
}