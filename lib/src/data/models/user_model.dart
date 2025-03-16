

import 'package:foodam/src/domain/entities/user_entity.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.hasActivePlan,
    super.activePlanId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      hasActivePlan: json['hasActivePlan'] ?? false,
      activePlanId: json['activePlanId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'hasActivePlan': hasActivePlan,
      'activePlanId': activePlanId,
    };
  }
}



