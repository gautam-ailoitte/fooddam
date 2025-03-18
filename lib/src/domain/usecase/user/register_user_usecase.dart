// lib/src/domain/usecase/user/register_user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class RegisterUserParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final Address address;
  final List<DietaryPreference>? dietaryPreferences;
  final List<String>? allergies;

  RegisterUserParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    this.dietaryPreferences,
    this.allergies,
  });
}

class RegisterUserUseCase extends UseCaseWithParams<User, RegisterUserParams> {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterUserParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      phone: params.phone,
      address: params.address,
      dietaryPreferences: params.dietaryPreferences,
      allergies: params.allergies,
    );
  }
}