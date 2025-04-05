// lib/src/domain/usecase/auth_usecase.dart
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
/// - ValidateTokenUseCase
/// - RefreshTokenUseCase
/// - RequestOTPUseCase
/// - VerifyOTPUseCase
class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  /// Login with email and password
  Future<Either<Failure, String>> login(LoginParams params) {
    return repository.login(params.email, params.password);
  }

  /// Register a new user with email
  Future<Either<Failure, String>> register(RegisterParams params) {
    if (!params.acceptTerms) {
      return Future.value(
        Left(ValidationFailure('You must accept the terms and conditions')),
      );
    }
    return repository.register(params.email, params.password, params.phone);
  }

  /// Register with mobile number
  Future<Either<Failure, String>> registerWithMobile(
    RegisterMobileParams params,
  ) {
    if (!params.acceptTerms) {
      return Future.value(
        Left(ValidationFailure('You must accept the terms and conditions')),
      );
    }
    return repository.registerWithMobile(params.mobile);
  }

  /// Request OTP for login
  Future<Either<Failure, String>> requestLoginOTP(String mobile) {
    return repository.requestLoginOTP(mobile);
  }

  /// Verify login OTP
  Future<Either<Failure, String>> verifyLoginOTP(String mobile, String otp) {
    return repository.verifyLoginOTP(mobile, otp);
  }

  /// Verify mobile OTP for registration
  Future<Either<Failure, String>> verifyMobileOTP(String mobile, String otp) {
    return repository.verifyMobileOTP(mobile, otp);
  }

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) {
    return repository.resetPassword(token, newPassword);
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

  /// Validate token
  Future<Either<Failure, bool>> validateToken(String token) {
    return repository.validateToken(token);
  }

  /// Refresh token
  Future<Either<Failure, String>> refreshToken(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }

  /// Request password reset for a user
  Future<Either<Failure, void>> forgotPassword(String email) {
    return repository.forgotPassword(email);
  }
}

/// Login parameters data class
class LoginParams {
  final String email;
  final String password;
  final bool rememberMe;

  LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

/// Register with email parameters data class
class RegisterParams {
  final String email;
  final String password;
  final String phone;
  final bool acceptTerms;

  RegisterParams({
    required this.email,
    required this.password,
    required this.phone,
    required this.acceptTerms,
  });
}

/// Register with mobile parameters data class
class RegisterMobileParams {
  final String mobile;

  final bool acceptTerms;

  RegisterMobileParams({required this.mobile, required this.acceptTerms});
}
