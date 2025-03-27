// lib/src/data/model/user_model.dart
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final List<AddressModel>? addresses;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<AddressModel>? addressList;
    if (json['address'] != null) {
      addressList = (json['address'] as List)
          .map((addr) => AddressModel.fromJson(addr))
          .toList();
    }

    List<String>? dietList;
    if (json['dietaryPreferences'] != null) {
      dietList = List<String>.from(json['dietaryPreferences']);
    }

    List<String>? allergyList;
    if (json['allergies'] != null) {
      allergyList = List<String>.from(json['allergies']);
    }

    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: json['role'],
      addresses: addressList,
      dietaryPreferences: dietList,
      allergies: allergyList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'role': role,
    };

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (addresses != null) {
      data['address'] = addresses!.map((addr) => addr.toJson()).toList();
    }
    if (dietaryPreferences != null) {
      data['dietaryPreferences'] = dietaryPreferences;
    }
    if (allergies != null) {
      data['allergies'] = allergies;
    }

    return data;
  }

  // Mapper to convert model to entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: role,
      // Keep addresses as an entity list, or null if not available
      addresses: addresses?.map((addr) => addr.toEntity()).toList(),
      dietaryPreferences: dietaryPreferences,
      allergies: allergies,
    );
  }

  // Mapper to convert entity to model
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      role: entity.role,
      addresses: entity.addresses?.map((addr) => AddressModel.fromEntity(addr)).toList(),
      dietaryPreferences: entity.dietaryPreferences,
      allergies: entity.allergies,
    );
  }
}