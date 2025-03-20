// lib/src/domain/repo/user_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/diet_pref_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserDetails();
  Future<Either<Failure, void>> updateUserDetails(User user);
  Future<Either<Failure, void>> updateDietaryPreferences(List<DietaryPreference> preferences);
  Future<Either<Failure, void>> updateAllergies(List<String> allergies);
  Future<Either<Failure, void>> addAddress(Address address);
  Future<Either<Failure, void>> updateAddress(Address address);
  Future<Either<Failure, List<Address>>> getUserAddresses();
}