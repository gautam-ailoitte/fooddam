// lib/src/domain/entities/meal_planning/meal_planning_config_entity.dart
import 'package:equatable/equatable.dart';

class MealPlanningConfig extends Equatable {
  final DateTime startDate;
  final String dietaryPreference;
  final int durationDays;
  final int mealCountPerWeek;
  final int numberOfWeeks;
  final int noOfPersons;
  final String? addressId;
  final String? instructions;

  const MealPlanningConfig({
    required this.startDate,
    required this.dietaryPreference,
    required this.durationDays,
    required this.mealCountPerWeek,
    required this.numberOfWeeks,
    this.noOfPersons = 1,
    this.addressId,
    this.instructions,
  });

  // Calculate end date based on start date and duration
  DateTime get endDate => startDate.add(Duration(days: durationDays));

  // Validate configuration
  bool get isValid {
    return startDate.isAfter(DateTime.now()) &&
        durationDays > 0 &&
        numberOfWeeks > 0 &&
        mealCountPerWeek > 0 &&
        noOfPersons > 0 &&
        _isValidDietaryPreference &&
        _isValidMealCount;
  }

  // Get estimated total price
  double get estimatedTotalPrice {
    return numberOfWeeks *
        mealCountPerWeek *
        _getPricePerMeal(mealCountPerWeek);
  }

  // Copy with updated values
  MealPlanningConfig copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? durationDays,
    int? mealCountPerWeek,
    int? numberOfWeeks,
    int? noOfPersons,
    String? addressId,
    String? instructions,
  }) {
    return MealPlanningConfig(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      durationDays: durationDays ?? this.durationDays,
      mealCountPerWeek: mealCountPerWeek ?? this.mealCountPerWeek,
      numberOfWeeks: numberOfWeeks ?? this.numberOfWeeks,
      noOfPersons: noOfPersons ?? this.noOfPersons,
      addressId: addressId ?? this.addressId,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    durationDays,
    mealCountPerWeek,
    numberOfWeeks,
    noOfPersons,
    addressId,
    instructions,
  ];

  // Private validation helpers
  bool get _isValidDietaryPreference {
    return dietaryPreference == 'vegetarian' ||
        dietaryPreference == 'non-vegetarian';
  }

  bool get _isValidMealCount {
    return [10, 15, 21].contains(mealCountPerWeek);
  }

  double _getPricePerMeal(int mealCount) {
    switch (mealCount) {
      case 10:
        return 45.0;
      case 15:
        return 42.0;
      case 21:
        return 38.0;
      default:
        return 40.0;
    }
  }
}

// Factory for creating meal planning configurations
class MealPlanningConfigFactory {
  static MealPlanningConfig createWeekly({
    required DateTime startDate,
    required String dietaryPreference,
    required int mealCountPerWeek,
    int numberOfWeeks = 1,
    int noOfPersons = 1,
    String? addressId,
    String? instructions,
  }) {
    return MealPlanningConfig(
      startDate: startDate,
      dietaryPreference: dietaryPreference,
      durationDays: numberOfWeeks * 7,
      mealCountPerWeek: mealCountPerWeek,
      numberOfWeeks: numberOfWeeks,
      noOfPersons: noOfPersons,
      addressId: addressId,
      instructions: instructions,
    );
  }

  static MealPlanningConfig createBiweekly({
    required DateTime startDate,
    required String dietaryPreference,
    required int mealCountPerWeek,
    int noOfPersons = 1,
    String? addressId,
    String? instructions,
  }) {
    return createWeekly(
      startDate: startDate,
      dietaryPreference: dietaryPreference,
      mealCountPerWeek: mealCountPerWeek,
      numberOfWeeks: 2,
      noOfPersons: noOfPersons,
      addressId: addressId,
      instructions: instructions,
    );
  }
}
