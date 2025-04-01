// lib/src/domain/usecase/user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

/// Consolidated User Use Case
///
/// This class combines multiple previously separate use cases related to user management:
/// - GetUserDetailsUseCase
/// - UpdateUserDetailsUseCase
/// - GetUserAddressesUseCase
/// - AddAddressUseCase
/// - UpdateAddressUseCase
/// - DeleteAddressUseCase
class UserUseCase {
  final UserRepository repository;

  UserUseCase(this.repository);

  /// Get user profile details
  Future<Either<Failure, User>> getUserDetails() {
    return repository.getUserDetails();
  }

  /// Update user profile details
  /// 
  /// This method takes a User entity with the fields that need to be updated
  /// and sends them to the repository.
  Future<Either<Failure, void>> updateUserDetails(User user) {
    return repository.updateUserDetails(user);
  }

  /// Get all addresses for the current user
  Future<Either<Failure, List<Address>>> getUserAddresses() {
    return repository.getUserAddresses();
  }

  /// Add a new address
  Future<Either<Failure, Address>> addAddress(Address address) {
    return repository.addAddress(address);
  }

  /// Update an existing address
  Future<Either<Failure, void>> updateAddress(Address address) {
    return repository.updateAddress(address);
  }

  /// Delete an address by ID
  Future<Either<Failure, void>> deleteAddress(String addressId) {
    return repository.deleteAddress(addressId);
  }
}