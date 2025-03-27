// lib/src/domain/repo/auth_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Logs in a user with email and password
  /// Returns a token if successful, or a Failure otherwise
  Future<Either<Failure, String>> login(String email, String password);
  
  /// Registers a new user with email, password, and phone
  /// Returns a token if successful, or a Failure otherwise
  Future<Either<Failure, String>> register(String email, String password, String phone);
  
  /// Logs out the current user
  /// Clears local tokens and attempts to notify the server
  Future<Either<Failure, void>> logout();
  
  /// Checks if a user is currently logged in
  /// Returns true if logged in, false otherwise
  Future<Either<Failure, bool>> isLoggedIn();
  
  /// Gets the current user details
  /// Returns the user entity if available, or a Failure otherwise
  Future<Either<Failure, User>> getCurrentUser();
  
  /// Validates a token
  /// Returns true if the token is valid, false otherwise
  Future<Either<Failure, bool>> validateToken(String token);
  
  /// Refreshes an expired token using the refresh token
  /// Returns a new token if successful, or a Failure otherwise
  Future<Either<Failure, String>> refreshToken(String refreshToken);
}
