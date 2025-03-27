// lib/core/errors/failure.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure([this.message = '']);
  
  @override
  List<Object> get props => [message];
  
  @override
  String toString() => message.isEmpty ? runtimeType.toString() : '$runtimeType: $message';
}

// Server related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failure']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

// Auth related failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failure']);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([super.message = 'Invalid email or password']);
}

class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure([super.message = 'User already exists']);
}

// Cache and data related failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class DataConversionFailure extends Failure {
  const DataConversionFailure([super.message = 'Failed to convert data']);
}

class ResourceNotFoundFailure extends Failure {
  const ResourceNotFoundFailure([super.message = 'Resource not found']);
}

// Other general failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}