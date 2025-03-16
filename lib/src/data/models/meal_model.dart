import 'package:foodam/src/domain/entities/meal_entity.dart';

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
