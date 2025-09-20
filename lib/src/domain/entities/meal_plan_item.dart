// lib/src/domain/entities/meal_plan_item.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

/// Represents a single meal option available for selection from the calculated plan
/// This replaces the old MealOption class with a cleaner structure
class MealPlanItem extends Equatable {
  final String dishId; // The dish ID from calculated plan
  final String dishName;
  final String dishDescription;
  final String day; // monday, tuesday, etc.
  final String timing; // breakfast, lunch, dinner
  final List<String> dietaryPreferences;
  final bool isAvailable;
  final String? imageUrl;
  final String? mealName; // NEW: Set name like "Veg Set 1", "Veg Set 2", etc.

  const MealPlanItem({
    required this.dishId,
    required this.dishName,
    required this.dishDescription,
    required this.day,
    required this.timing,
    this.dietaryPreferences = const [],
    this.isAvailable = true,
    this.imageUrl,
    this.mealName, // NEW: Optional meal/set name
  });

  @override
  List<Object?> get props => [
    dishId,
    dishName,
    dishDescription,
    day,
    timing,
    dietaryPreferences,
    isAvailable,
    imageUrl,
    mealName, // NEW: Include in props
  ];

  /// Factory to create from Dish entity with metadata
  factory MealPlanItem.fromDish({
    required Dish dish,
    required String day,
    required String timing,
    String? mealName, // NEW: Optional meal name parameter
  }) {
    return MealPlanItem(
      dishId: dish.id,
      dishName: dish.name,
      dishDescription: dish.description,
      day: day,
      timing: timing,
      dietaryPreferences: dish.dietaryPreferences,
      isAvailable: dish.isAvailable,
      imageUrl: dish.imageUrl,
      mealName: mealName, // NEW: Pass meal name
    );
  }

  /// Helper getters
  String get mealType => timing;
  String get formattedDay => _capitalize(day);
  String get formattedTiming => _capitalize(timing);
  String get displayText => '$formattedTiming on $formattedDay';

  bool get isBreakfast => timing.toLowerCase() == 'breakfast';
  bool get isLunch => timing.toLowerCase() == 'lunch';
  bool get isDinner => timing.toLowerCase() == 'dinner';

  bool get isVegetarian => dietaryPreferences.contains('vegetarian');
  bool get isNonVegetarian => dietaryPreferences.contains('non-vegetarian');

  /// Check if this item is for today
  bool isToday(DateTime startDate, int week) {
    final itemDate = _calculateItemDate(startDate, week);
    final now = DateTime.now();
    return itemDate.year == now.year &&
        itemDate.month == now.month &&
        itemDate.day == now.day;
  }

  /// Calculate the actual date for this meal plan item
  DateTime calculateDate(DateTime startDate, int week) {
    return _calculateItemDate(startDate, week);
  }

  DateTime _calculateItemDate(DateTime startDate, int week) {
    // Calculate week start date
    final weekStartDate = startDate.add(Duration(days: (week - 1) * 7));

    // Calculate day offset within the week
    final dayOffset = _getDayOffset(day);

    return weekStartDate.add(Duration(days: dayOffset));
  }

  int _getDayOffset(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 0;
      case 'tuesday':
        return 1;
      case 'wednesday':
        return 2;
      case 'thursday':
        return 3;
      case 'friday':
        return 4;
      case 'saturday':
        return 5;
      case 'sunday':
        return 6;
      default:
        return 0;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Copy with new values
  MealPlanItem copyWith({
    String? dishId,
    String? dishName,
    String? dishDescription,
    String? day,
    String? timing,
    List<String>? dietaryPreferences,
    bool? isAvailable,
    String? imageUrl,
    String? mealName, // NEW: Add mealName to copyWith
  }) {
    return MealPlanItem(
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      dishDescription: dishDescription ?? this.dishDescription,
      day: day ?? this.day,
      timing: timing ?? this.timing,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      mealName: mealName ?? this.mealName, // NEW: Copy mealName
    );
  }
}
