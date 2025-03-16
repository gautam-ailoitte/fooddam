// lib/domain/entities/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final bool hasActivePlan;
  final String? activePlanId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.hasActivePlan,
    this.activePlanId,
  });
}

// lib/domain/entities/meal.dart
