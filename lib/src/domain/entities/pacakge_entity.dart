// lib/src/domain/entities/pacakge_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/package_slot_entity.dart';
import 'package:foodam/src/domain/entities/price_option.dart';
import 'package:foodam/src/domain/entities/price_range.dart';

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
  final List<PackageSlot> slots;

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
    this.slots = const [],
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
    slots,
  ];

  // Helper methods
  bool get isVegetarian => dietaryPreferences?.contains('vegetarian') ?? false;

  bool get isNonVegetarian =>
      dietaryPreferences?.contains('non-vegetarian') ?? false;

  bool get hasSlots => slots.isNotEmpty;

  double? get minPrice => priceRange?.min;
  double? get maxPrice => priceRange?.max;

  String get priceDisplayText {
    if (priceRange != null) {
      if (priceRange!.min == priceRange!.max) {
        return '₹${priceRange!.min.toStringAsFixed(0)}';
      }
      return '₹${priceRange!.min.toStringAsFixed(0)} - ₹${priceRange!.max.toStringAsFixed(0)}';
    }
    return 'Contact us';
  }

  // Get slot by day
  PackageSlot? getSlotByDay(String day) {
    try {
      return slots.firstWhere(
        (slot) => slot.day.toLowerCase() == day.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all available days
  List<String> get availableDays {
    return slots.where((slot) => slot.hasMeal).map((slot) => slot.day).toList();
  }

  // Get total meals count (for display purposes)
  int get totalMealsInWeek {
    int count = 0;
    for (final slot in slots) {
      if (slot.hasMeal && slot.meal != null) {
        final meal = slot.meal!;
        if (meal.hasBreakfast) count++;
        if (meal.hasLunch) count++;
        if (meal.hasDinner) count++;
      }
    }
    return count;
  }

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
