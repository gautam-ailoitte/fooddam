// lib/src/domain/usecase/user/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class UpdateProfileParams {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final Address? address;
  final List<DietaryPreference>? dietaryPreferences;
  final List<String>? allergies;

  UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.dietaryPreferences,
    this.allergies,
  });
}

class UpdateProfileUseCase extends UseCaseWithParams<User, UpdateProfileParams> {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      address: params.address,
      dietaryPreferences: params.dietaryPreferences,
      allergies: params.allergies,
    );
  }
}