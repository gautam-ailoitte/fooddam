// lib/src/domain/entities/meal_dishes_entity.dart
import 'package:equatable/equatable.dart';

import '../dish/dish_entity.dart';

class MealDishes extends Equatable {
  final Dish? breakfast;
  final Dish? lunch;
  final Dish? dinner;

  const MealDishes({this.breakfast, this.lunch, this.dinner});

  @override
  List<Object?> get props => [breakfast, lunch, dinner];

  bool get hasBreakfast => breakfast != null;
  bool get hasLunch => lunch != null;
  bool get hasDinner => dinner != null;

  int get mealCount =>
      [breakfast, lunch, dinner].where((meal) => meal != null).length;

  List<Dish> get availableMeals =>
      [
        breakfast,
        lunch,
        dinner,
      ].where((meal) => meal != null).cast<Dish>().toList();
}
