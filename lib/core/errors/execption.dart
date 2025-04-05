// lib/core/errors/execption.dart

/// Base exception for app-specific exceptions
class AppException implements Exception {
  final String message;

  AppException([this.message = 'An unexpected error occurred']);

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred']);
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException([super.message = 'Network connection issue']);
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException([super.message = 'Cache error occurred']);
}

/// Authentication-related exceptions
class UnauthenticatedException extends AppException {
  UnauthenticatedException([super.message = 'User not authenticated']);
}

/// Authorization-related exceptions
class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'Access forbidden']);
}

/// Invalid credentials exception
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException([super.message = 'Invalid credentials']);
}

/// User already exists exception
class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException([super.message = 'User already exists']);
}

/// Email not verified exception
class EmailNotVerifiedException extends AppException {
  EmailNotVerifiedException([super.message = 'Email not verified']);
}

/// Invalid token exception
class InvalidTokenException extends AppException {
  InvalidTokenException([super.message = 'Invalid or expired token']);
}

/// Invalid OTP exception
class InvalidOTPException extends AppException {
  InvalidOTPException([super.message = 'Invalid OTP']);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  ValidationException([super.message = 'Validation error']);
}

/// Resource not found exception
class ResourceNotFoundException extends AppException {
  ResourceNotFoundException([super.message = 'Resource not found']);
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException([super.message = 'Operation timed out']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'Resource not found']);
}
