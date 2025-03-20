
import 'package:foodam/src/domain/entities/diet_pref_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'address_model.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.role,
    required AddressModel super.address,
    super.dietaryPreferences,
    super.allergies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      address: AddressModel.fromJson(json['address']),
      dietaryPreferences: json['dietaryPreferences'] != null
          ? (json['dietaryPreferences'] as List)
              .map((pref) => _mapStringToDietaryPreference(pref))
              .toList()
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
    );
  }

  static DietaryPreference _mapStringToDietaryPreference(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return DietaryPreference.vegetarian;
      case 'non-vegetarian':
        return DietaryPreference.nonVegetarian;
      case 'vegan':
        return DietaryPreference.vegan;
      case 'gluten-free':
        return DietaryPreference.glutenFree;
      case 'dairy-free':
        return DietaryPreference.dairyFree;
      default:
        return DietaryPreference.vegetarian;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'address': (address as AddressModel).toJson(),
      'dietaryPreferences': dietaryPreferences?.map((pref) => _mapDietaryPreferenceToString(pref)).toList(),
      'allergies': allergies,
    };
  }

  static String _mapDietaryPreferenceToString(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return 'vegetarian';
      case DietaryPreference.nonVegetarian:
        return 'non-vegetarian';
      case DietaryPreference.vegan:
        return 'vegan';
      case DietaryPreference.glutenFree:
        return 'gluten-free';
      case DietaryPreference.dairyFree:
        return 'dairy-free';
    }
  }
}

