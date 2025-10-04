// lib/src/domain/entities/meal_planning/calculated_plan_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/package/package_entity.dart';

class CalculatedPlan extends Equatable {
  final String? dietaryPreference;
  final String? requestedWeek;
  final int? actualSystemWeek;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? estimatedPrice;
  final Package? package;
  final List<DailyMeal>? dailyMeals;

  const CalculatedPlan({
    this.dietaryPreference,
    this.requestedWeek,
    this.actualSystemWeek,
    this.startDate,
    this.endDate,
    this.estimatedPrice,
    this.package,
    this.dailyMeals,
  });

  @override
  List<Object?> get props => [
    dietaryPreference,
    requestedWeek,
    actualSystemWeek,
    startDate,
    endDate,
    estimatedPrice,
    package,
    dailyMeals,
  ];
}

class DailyMeal extends Equatable {
  final DateTime? date;
  final String? day;
  final DayMeal? meal;

  const DailyMeal({this.date, this.day, this.meal});

  @override
  List<Object?> get props => [date, day, meal];
}

class DayMeal extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final String? dietaryPreference;
  final int? price;
  final Map<String, MealDish>? dishes;
  final MealImage? image;
  final bool? isAvailable;

  const DayMeal({
    this.id,
    this.name,
    this.description,
    this.dietaryPreference,
    this.price,
    this.dishes,
    this.image,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    dietaryPreference,
    price,
    dishes,
    image,
    isAvailable,
  ];
}

class MealDish extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final int? price;
  final String? dietaryPreference;
  final bool? isAvailable;
  final MealImage? image;
  final String? key;

  const MealDish({
    this.id,
    this.name,
    this.description,
    this.price,
    this.dietaryPreference,
    this.isAvailable,
    this.image,
    this.key,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    dietaryPreference,
    isAvailable,
    image,
    key,
  ];
}

class MealImage extends Equatable {
  final String? id;
  final String? url;
  final String? key;
  final String? fileName;

  const MealImage({this.id, this.url, this.key, this.fileName});

  @override
  List<Object?> get props => [id, url, key, fileName];
}
