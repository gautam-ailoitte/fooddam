// lib/core/errors/failure.dart
import 'package:equatable/equatable.dart';

/// Base failure class for all application failures
abstract class Failure extends Equatable {
  final String? message;

  const Failure([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
    : super(message ?? 'Network connection error');
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure([String? message])
    : super(message ?? 'Server error occurred');
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String? message])
    : super(message ?? 'Authentication error');
}

/// Invalid credentials failure
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String? message])
    : super(message ?? 'Invalid email or password');
}

/// User already exists failure
class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure([String? message])
    : super(message ?? 'User already exists with this email');
}

/// Email not verified failure
class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure([String? message])
    : super(message ?? 'Email not verified');
}

/// Invalid or expired token failure
class InvalidTokenFailure extends AuthFailure {
  const InvalidTokenFailure([String? message])
    : super(message ?? 'Invalid or expired token');
}

/// Invalid OTP failure
class InvalidOTPFailure extends AuthFailure {
  const InvalidOTPFailure([String? message]) : super(message ?? 'Invalid OTP');
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String? message])
    : super(message ?? 'Validation error');
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure([String? message])
    : super(message ?? 'Cache error occurred');
}

/// Resource not found failures
class ResourceNotFoundFailure extends Failure {
  const ResourceNotFoundFailure([String? message])
    : super(message ?? 'Resource not found');
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([String? message])
    : super(message ?? 'Permission denied');
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String? message])
    : super(message ?? 'An unexpected error occurred');
}
