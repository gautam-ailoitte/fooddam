// lib/core/errors/execption.dart
/// Base exception
abstract class AppException implements Exception {
  final String message;

  AppException([this.message = '']);

  @override
  String toString() => message.isEmpty ? runtimeType.toString() : '$runtimeType: $message';
}

/// Server exceptions
class ServerException extends AppException {
  ServerException([super.message = 'An error occurred on the server']);
}

class TimeoutException extends ServerException {
  TimeoutException([super.message = 'Connection timed out']);
}

class NetworkException extends ServerException {
  NetworkException([super.message = 'No internet connection']);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class ForbiddenException extends ServerException {
  ForbiddenException([super.message = 'Access forbidden']);
}

class NotFoundException extends ServerException {
  NotFoundException([super.message = 'Resource not found']);
}

/// Authentication exceptions
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException([super.message = 'Invalid email or password']);
}

class UnauthenticatedException extends AppException {
  UnauthenticatedException([super.message = 'User not authenticated']);
}

class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException([super.message = 'User already exists']);
}

/// Data exceptions
class CacheException extends AppException {
  CacheException([super.message = 'Cache operation failed']);
}

class ResourceNotFoundException extends AppException {
  ResourceNotFoundException([super.message = 'Resource not found']);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Validation failed']);
}