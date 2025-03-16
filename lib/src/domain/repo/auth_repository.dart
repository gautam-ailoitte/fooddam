import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, User>> login(String email, String password);

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get the current logged in user
  Future<Either<Failure, User>> getCurrentUser();

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if user has active subscription
  Future<Either<Failure, bool>> hasActiveSubscription();
}
