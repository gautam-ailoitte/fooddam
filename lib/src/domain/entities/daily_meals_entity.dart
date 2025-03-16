

// lib/domain/entities/plan.dart
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum PlanDuration { sevenDays, fourteenDays, twentyEightDays }

class DailyMeals {
  final Thali? breakfast;
  final Thali? lunch;
  final Thali? dinner;

  // Calculate total price for all meals in a day
  double get dailyTotal {
    double total = 0;

    // Add price for each selected meal (breakfast, lunch, dinner)
    if (breakfast != null) total += breakfast!.totalPrice;
    if (lunch != null) total += lunch!.totalPrice;
    if (dinner != null) total += dinner!.totalPrice;

    return total;
  }

  // Get the sum of additional prices from all customized meals
  double get totalAdditionalPrice {
    double total = 0;
    if (breakfast != null) total += breakfast!.additionalPrice;
    if (lunch != null) total += lunch!.additionalPrice;
    if (dinner != null) total += dinner!.additionalPrice;
    return total;
  }

  // Check if this day has any customized meals
  bool get hasCustomizedMeals {
    if (breakfast != null && breakfast!.isCustomized) return true;
    if (lunch != null && lunch!.isCustomized) return true;
    if (dinner != null && dinner!.isCustomized) return true;
    return false;
  }

  // Get a summary of the day's meals
  String get summary {
    List<String> mealNames = [];
    if (breakfast != null) mealNames.add(breakfast!.name);
    if (lunch != null) mealNames.add(lunch!.name);
    if (dinner != null) mealNames.add(dinner!.name);

    if (mealNames.isEmpty) return "No meals selected";
    return mealNames.join(", ");
  }

  // Constructor
  DailyMeals({this.breakfast, this.lunch, this.dinner});

  // CopyWith method for creating modified instances
  DailyMeals copyWith({Thali? breakfast, Thali? lunch, Thali? dinner}) {
    return DailyMeals(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }

  // Get meal by type
  Thali? getMealByType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return breakfast;
      case MealType.lunch:
        return lunch;
      case MealType.dinner:
        return dinner;
    }
  }

  // Update meal of a specific type
  DailyMeals updateMeal(MealType type, Thali thali) {
    switch (type) {
      case MealType.breakfast:
        return copyWith(breakfast: thali);
      case MealType.lunch:
        return copyWith(lunch: thali);
      case MealType.dinner:
        return copyWith(dinner: thali);
    }
  }

  // Check if all meals are selected for this day
  bool get isComplete {
    return breakfast != null && lunch != null && dinner != null;
  }

  // Count how many meals are selected
  int get mealCount {
    int count = 0;
    if (breakfast != null) count++;
    if (lunch != null) count++;
    if (dinner != null) count++;
    return count;
  }
}

// Enhanced Plan entity

