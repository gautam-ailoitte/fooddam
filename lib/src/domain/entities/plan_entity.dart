// lib/src/domain/entities/plan_entity.dart

import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

class Plan {
  final String id;
  final String name;
  final bool isVeg;
  final PlanDuration duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<DayOfWeek, DailyMeals> mealsByDay;
  final double basePrice;
  final bool isCustomized;
  final bool isDraft;

  // Calculate total price considering all meals and any duration-based discounts
  double get totalPrice {
    double total = 0;

    // Sum up the price of all meals
    mealsByDay.forEach((day, meals) {
      total += meals.dailyTotal;
    });

    // Apply duration-based discounts
    switch (duration) {
      case PlanDuration.sevenDays:
        // No discount for 7 days
        break;
      case PlanDuration.fourteenDays:
        // 5% discount for 14 days
        total = total * 0.95;
        break;
      case PlanDuration.twentyEightDays:
        // 10% discount for 28 days
        total = total * 0.90;
        break;
    }

    return total;
  }

  // Get the number of days in the plan
  int get durationDays {
    switch (duration) {
      case PlanDuration.sevenDays:
        return 7;
      case PlanDuration.fourteenDays:
        return 14;
      case PlanDuration.twentyEightDays:
        return 28;
    }
  }

  // Get duration as readable text
  String get durationText {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
    }
  }

  // Check if the plan has been modified from template
  bool get isModified {
    if (!isCustomized) return false;

    // Count non-null meals
    int mealCount = 0;
    mealsByDay.forEach((day, meals) {
      if (meals.breakfast != null) mealCount++;
      if (meals.lunch != null) mealCount++;
      if (meals.dinner != null) mealCount++;
    });

    return mealCount > 0;
  }

  // Get short description of the plan
  String get shortDescription {
    return '$name (${isVeg ? 'Veg' : 'Non-Veg'}) - $durationText';
  }

  // Method for updating a specific meal
  Plan updateMeal({
    required DayOfWeek day,
    required MealType mealType,
    required Thali thali,
  }) {
    // Create a copy of the current plan's meals
    final updatedMealsByDay = Map<DayOfWeek, DailyMeals>.from(mealsByDay);

    // Get the current daily meals or create new
    final currentDailyMeals = updatedMealsByDay[day] ?? DailyMeals();

    // Create updated daily meals
    DailyMeals updatedDailyMeals;
    switch (mealType) {
      case MealType.breakfast:
        updatedDailyMeals = currentDailyMeals.copyWith(breakfast: thali);
        break;
      case MealType.lunch:
        updatedDailyMeals = currentDailyMeals.copyWith(lunch: thali);
        break;
      case MealType.dinner:
        updatedDailyMeals = currentDailyMeals.copyWith(dinner: thali);
        break;
    }

    // Update the map
    updatedMealsByDay[day] = updatedDailyMeals;

    // Return new plan
    return copyWith(mealsByDay: updatedMealsByDay, isCustomized: true);
  }

  // Method to get a specific meal
  Thali? getMeal(DayOfWeek day, MealType mealType) {
    if (!mealsByDay.containsKey(day)) return null;

    final dailyMeals = mealsByDay[day]!;

    switch (mealType) {
      case MealType.breakfast:
        return dailyMeals.breakfast;
      case MealType.lunch:
        return dailyMeals.lunch;
      case MealType.dinner:
        return dailyMeals.dinner;
    }
  }

  // Check if the plan is fully configured (all meals selected)
  bool get isComplete {
    final requiredDays = DayOfWeek.values.length;
    final requiredMealsPerDay = 3; // breakfast, lunch, dinner

    int totalMeals = 0;
    mealsByDay.forEach((day, meals) {
      if (meals.breakfast != null) totalMeals++;
      if (meals.lunch != null) totalMeals++;
      if (meals.dinner != null) totalMeals++;
    });

    return totalMeals == requiredDays * requiredMealsPerDay;
  }

  // Constructor
  Plan({
    required this.id,
    required this.name,
    required this.isVeg,
    required this.duration,
    this.startDate,
    this.endDate,
    required this.mealsByDay,
    required this.basePrice,
    required this.isCustomized,
    this.isDraft = false,
  });

  // CopyWith method for creating modified instances
  Plan copyWith({
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
    return Plan(
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
