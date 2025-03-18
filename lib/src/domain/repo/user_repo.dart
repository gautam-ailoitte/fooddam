// lib/src/domain/repositories/user_repository.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

abstract class UserRepository {
  /// Register a new user
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required Address address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  });

  /// Login a user
  Future<Either<Failure, User>> login(String email, String password);

  /// Get the current logged in user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Address? address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  });

  /// Update user password
  Future<Either<Failure, bool>> updatePassword(String currentPassword, String newPassword);

  /// Logout the current user
  Future<Either<Failure, void>> logout();
  
  /// Request password reset
  Future<Either<Failure, bool>> requestPasswordReset(String email);
  
  /// Verify email address
  Future<Either<Failure, bool>> verifyEmail(String token);
  
  /// Add a new address for the user
  Future<Either<Failure, Address>> addAddress(Address address);
  
  /// Update an existing address
  Future<Either<Failure, Address>> updateAddress(String addressId, Address address);
  
  /// Delete an address
  Future<Either<Failure, bool>> deleteAddress(String addressId);
  
  /// Get all user addresses
  Future<Either<Failure, List<Address>>> getUserAddresses();
}