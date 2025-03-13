

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

// lib/data/models/meal_model.dart


class MealModel extends Meal {
  MealModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.isVeg,
    required super.type,
    required super.imageUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      isVeg: json['isVeg'],
      type: MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${json['type']}',
        orElse: () => MealType.lunch,
      ),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isVeg': isVeg,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
    };
  }
}

// lib/data/models/thali_model.dart

class ThaliModel extends Thali {
  ThaliModel({
    required super.id,
    required super.name,
    required super.type,
    required super.basePrice,
    required super.defaultMeals,
    required super.selectedMeals,
    required super.maxCustomizations,
  });

  factory ThaliModel.fromJson(Map<String, dynamic> json) {
    return ThaliModel(
      id: json['id'],
      name: json['name'],
      type: ThaliType.values.firstWhere(
        (e) => e.toString() == 'ThaliType.${json['type']}',
        orElse: () => ThaliType.normal,
      ),
      basePrice: json['basePrice'].toDouble(),
      defaultMeals: (json['defaultMeals'] as List)
          .map((meal) => MealModel.fromJson(meal))
          .toList(),
      selectedMeals: (json['selectedMeals'] as List)
          .map((meal) => MealModel.fromJson(meal))
          .toList(),
      maxCustomizations: json['maxCustomizations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'basePrice': basePrice,
      'defaultMeals': defaultMeals.map((meal) => (meal as MealModel).toJson()).toList(),
      'selectedMeals': selectedMeals.map((meal) => (meal as MealModel).toJson()).toList(),
      'maxCustomizations': maxCustomizations,
    };
  }
}

// lib/data/models/plan_model.dart


class DailyMealsModel extends DailyMeals {
  DailyMealsModel({
    super.breakfast,
    super.lunch,
    super.dinner,
  });

  factory DailyMealsModel.fromJson(Map<String, dynamic> json) {
    return DailyMealsModel(
      breakfast: json['breakfast'] != null ? ThaliModel.fromJson(json['breakfast']) : null,
      lunch: json['lunch'] != null ? ThaliModel.fromJson(json['lunch']) : null,
      dinner: json['dinner'] != null ? ThaliModel.fromJson(json['dinner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast != null ? (breakfast as ThaliModel).toJson() : null,
      'lunch': lunch != null ? (lunch as ThaliModel).toJson() : null,
      'dinner': dinner != null ? (dinner as ThaliModel).toJson() : null,
    };
  }
}

class PlanModel extends Plan {
  PlanModel({
    required super.id,
    required super.name,
    required super.isVeg,
    required super.duration,
    super.startDate,
    super.endDate,
    required super.mealsByDay,
    required super.basePrice,
    required super.isCustomized,
     required super.isDraft,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final Map<DayOfWeek, DailyMeals> mealsByDay = {};
    (json['mealsByDay'] as Map<String, dynamic>).forEach((key, value) {
      final dayOfWeek = DayOfWeek.values.firstWhere(
        (e) => e.toString() == 'DayOfWeek.$key',
        orElse: () => DayOfWeek.monday,
      );
      mealsByDay[dayOfWeek] = DailyMealsModel.fromJson(value);
    });

    return PlanModel(
      id: json['id'],
      name: json['name'],
      isVeg: json['isVeg'],
      duration: PlanDuration.values.firstWhere(
        (e) => e.toString() == 'PlanDuration.${json['duration']}',
        orElse: () => PlanDuration.sevenDays,
      ),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      mealsByDay: mealsByDay,
      basePrice: json['basePrice'].toDouble(),
      isCustomized: json['isCustomized'], isDraft: json['isDraft'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mealsByDayJson = {};
    mealsByDay.forEach((key, value) {
      mealsByDayJson[key.toString().split('.').last] = (value as DailyMealsModel).toJson();
    });

    return {
      'id': id,
      'name': name,
      'isVeg': isVeg,
      'duration': duration.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'mealsByDay': mealsByDayJson,
      'basePrice': basePrice,
      'isCustomized': isCustomized,
    };
  }
  @override
  PlanModel copyWith({
  String? id,
  String? name,
  bool? isVeg,
  PlanDuration? duration,
  DateTime? startDate,
  DateTime? endDate,
  Map<DayOfWeek, DailyMeals>? mealsByDay,
  double? basePrice,
  bool? isCustomized,
  bool? isDraft,
}) {
  return PlanModel(
    id: id ?? this.id,
    name: name ?? this.name,
    isVeg: isVeg ?? this.isVeg,
    duration: duration ?? this.duration,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    mealsByDay: mealsByDay ?? this.mealsByDay,
    basePrice: basePrice ?? this.basePrice,
    isCustomized: isCustomized ?? this.isCustomized,
    isDraft: isDraft ?? this.isDraft,
  );
}
}