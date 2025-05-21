import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/price_option.dart';
import 'package:foodam/src/domain/entities/price_range.dart';

import 'day_meal.dart';

class Package extends Equatable {
  final String id;
  final String name;
  final String description;
  final int week;
  final PriceRange? priceRange;
  final List<PriceOption>? priceOptions;
  final List<String>? dietaryPreferences;
  final int noOfSlots;
  final bool isActive;

  // Only populated in detailed view
  final Map<String, DayMeal>? dailyMeals;

  const Package({
    required this.id,
    required this.name,
    required this.description,
    required this.week,
    this.priceRange,
    this.priceOptions,
    this.dietaryPreferences,
    required this.noOfSlots,
    required this.isActive,
    this.dailyMeals,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    week,
    priceRange,
    priceOptions,
    dietaryPreferences,
    noOfSlots,
    isActive,
    dailyMeals,
  ];

  // Helper methods
  bool get isVegetarian => dietaryPreferences?.contains('vegetarian') ?? false;

  bool get isNonVegetarian =>
      dietaryPreferences?.contains('non-vegetarian') ?? false;

  double getPriceForMealCount(int mealCount) {
    if (priceOptions == null || priceOptions!.isEmpty) return 0;

    // Find exact match
    final exactMatch =
        priceOptions!
            .where((option) => option.numberOfMeals == mealCount)
            .toList();

    if (exactMatch.isNotEmpty) return exactMatch.first.price;

    // Find closest match
    priceOptions!.sort(
      (a, b) => (a.numberOfMeals - mealCount).abs().compareTo(
        (b.numberOfMeals - mealCount).abs(),
      ),
    );

    return priceOptions!.first.price;
  }
}
