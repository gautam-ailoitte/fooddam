// lib/src/domain/entities/user.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/diet_pref_entity.dart';


class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final Address address;
  final List<DietaryPreference>? dietaryPreferences;
  final List<String>? allergies;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    this.dietaryPreferences,
    this.allergies,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        role,
        address,
        dietaryPreferences,
        allergies,
      ];
}


