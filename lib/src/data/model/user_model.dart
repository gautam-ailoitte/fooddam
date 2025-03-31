// lib/src/data/model/fixed_user_model.dart
import 'package:flutter/foundation.dart';
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
    // debugPrint('Parsing UserModel from JSON: ${json.toString()}');
    
    // Parse address list
    List<AddressModel>? addressList;
    if (json['address'] != null) {
      try {
        addressList = (json['address'] as List)
            .map((addr) => AddressModel.fromJson(addr as Map<String, dynamic>))
            .toList();
        // debugPrint('Successfully parsed ${addressList.length} addresses');
      } catch (e) {
        debugPrint('Error parsing address list: $e');
        addressList = null;
      }
    }

    // Parse dietary preferences
    List<String>? dietList;
    if (json['dietaryPreferences'] != null) {
      try {
        dietList = List<String>.from(json['dietaryPreferences'] as List);
        // debugPrint('Successfully parsed ${dietList.length} dietary preferences');
      } catch (e) {
        debugPrint('Error parsing dietary preferences: $e');
        dietList = [];
      }
    }

    // Parse allergies
    List<String>? allergyList;
    if (json['allergies'] != null) {
      try {
        allergyList = List<String>.from(json['allergies'] as List);
        // debugPrint('Successfully parsed ${allergyList.length} allergies');
      } catch (e) {
        debugPrint('Error parsing allergies: $e');
        allergyList = [];
      }
    }

    // Extract primitive fields with explicit debug information
    final id = json['id']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    final phone = json['phone']?.toString();
    final role = json['role']?.toString() ?? 'user';
    final firstName = json['firstName']?.toString();
    final lastName = json['lastName']?.toString();
    
    // debugPrint('UserModel parsed with: id=$id, email=$email, phone=$phone, role=$role');

    return UserModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: role,
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