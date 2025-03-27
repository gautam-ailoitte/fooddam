// lib/src/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final List<Address>? addresses;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.role,
    this.addresses,
    this.dietaryPreferences,
    this.allergies,
  });

  String? get fullName {
    if (firstName == null && lastName == null) return null;
    return '$firstName $lastName'.trim();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        role,
        addresses,
        dietaryPreferences,
        allergies,
      ];
}