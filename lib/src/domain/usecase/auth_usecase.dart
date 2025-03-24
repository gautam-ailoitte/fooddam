// lib/src/domain/usecase/auth/auth_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/auth_repo.dart';

/// Consolidated Authentication Use Case
/// 
/// This class combines multiple previously separate use cases related to authentication:
/// - LoginUseCase
/// - LogoutUseCase
/// - RegisterUseCase
/// - IsLoggedInUseCase
/// - GetCurrentUserUseCase
class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  /// Login with email and password
  Future<Either<Failure, String>> login(String email, String password) {
    return repository.login(email, password);
  }

  /// Register a new user
  Future<Either<Failure, String>> register(String email, String password, String phone) {
    return repository.register(email, password, phone);
  }

  /// Log out the current user
  Future<Either<Failure, void>> logout() {
    return repository.logout();
  }

  /// Check if a user is currently logged in
  Future<Either<Failure, bool>> isLoggedIn() {
    return repository.isLoggedIn();
  }

  /// Get the current logged-in user's details
  Future<Either<Failure, User>> getCurrentUser() {
    return repository.getCurrentUser();
  }
}

/// Login parameters data class
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

/// Register parameters data class
class RegisterParams {
  final String email;
  final String password;
  final String phone;

  RegisterParams({
    required this.email, 
    required this.password,
    required this.phone,
  });
}