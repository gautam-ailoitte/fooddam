
import 'package:foodam/src/data/models/meal_model.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

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

