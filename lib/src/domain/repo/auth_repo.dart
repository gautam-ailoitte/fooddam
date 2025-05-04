// lib/src/domain/repo/auth_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Logs in a user with email and password
  Future<Either<Failure, String>> login(String email, String password);

  /// Registers a new user with email, password, and phone
  Future<Either<Failure, String>> register(
    String email,
    String password,
    String phone,
  );

  /// Registers a new user with mobile and password
  Future<Either<Failure, String>> registerWithMobile(String mobile);

  /// Request OTP for mobile login
  Future<Either<Failure, String>> requestLoginOTP(String mobile);

  /// Verify OTP for mobile login
  Future<Either<Failure, String>> verifyLoginOTP(String mobile, String otp);

  /// Verify mobile OTP for registration
  Future<Either<Failure, String>> verifyMobileOTP(String mobile, String otp);

  /// Resend OTP for mobile (both login and registration)
  Future<Either<Failure, String>> resendOTP(String mobile, bool isRegistration);

  /// Logs out the current user
  Future<Either<Failure, void>> logout();

  /// Checks if a user is currently logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Gets the current user details
  Future<Either<Failure, User>> getCurrentUser();

  /// Validates a token
  Future<Either<Failure, bool>> validateToken(String token);

  /// Refreshes an expired token using the refresh token
  Future<Either<Failure, String>> refreshToken(String refreshToken);

  /// Request password reset OTP for email
  Future<Either<Failure, String>> forgotPassword(String email);

  /// Reset password with email, OTP and new password
  Future<Either<Failure, void>> resetPassword(
    String email,
    String otp,
    String newPassword,
  );
}
