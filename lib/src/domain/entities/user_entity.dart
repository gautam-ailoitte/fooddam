// lib/src/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'dish_entity.dart'; // For DietaryPreference

enum UserRole {
  user,
  admin
}

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Address address;
  final List<DietaryPreference>? dietaryPreferences;
  final List<String>? allergies;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    this.dietaryPreferences,
    this.allergies,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  bool get hasActivePlan => false; // This will be determined by subscription service

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    address,
    dietaryPreferences,
    allergies,
    role,
    createdAt,
    updatedAt,
  ];
}