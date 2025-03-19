// lib/src/presentation/cubits/meal_configuration/meal_configuration_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

// Helper class to track dish selection status
class DishSelectionEntry extends Equatable {
  final String dishId;
  final String categoryName;
  final bool isOriginal; // If true, this was part of the original meal
  final bool isSwapped; // If true, this was swapped from another dish in the same category
  final bool isAdditional; // If true, this is an additional dish beyond min requirements

  const DishSelectionEntry({
    required this.dishId,
    required this.categoryName,
    this.isOriginal = false,
    this.isSwapped = false,
    this.isAdditional = false,
  });

  DishSelectionEntry copyWith({
    String? dishId,
    String? categoryName,
    bool? isOriginal,
    bool? isSwapped,
    bool? isAdditional,
  }) {
    return DishSelectionEntry(
      dishId: dishId ?? this.dishId,
      categoryName: categoryName ?? this.categoryName,
      isOriginal: isOriginal ?? this.isOriginal,
      isSwapped: isSwapped ?? this.isSwapped,
      isAdditional: isAdditional ?? this.isAdditional,
    );
  }

  @override
  List<Object?> get props => [
    dishId,
    categoryName,
    isOriginal,
    isSwapped,
    isAdditional,
  ];
}

// Helper class to represent a day's meals
class DayMeals extends Equatable {
  final int dayIndex; // 0-6 for a week
  final Map<String, Meal> meals; // breakfast, lunch, dinner
  final Map<String, List<DishSelectionEntry>> selections; // Map of meal type to selected dishes

  const DayMeals({
    required this.dayIndex,
    required this.meals,
    required this.selections,
  });

  DayMeals copyWith({
    int? dayIndex,
    Map<String, Meal>? meals,
    Map<String, List<DishSelectionEntry>>? selections,
  }) {
    return DayMeals(
      dayIndex: dayIndex ?? this.dayIndex,
      meals: meals ?? this.meals,
      selections: selections ?? this.selections,
    );
  }

  // Get meal by type
  Meal? getMeal(String mealType) => meals[mealType];
  
  // Get selections for a meal
  List<DishSelectionEntry> getSelections(String mealType) => 
      selections[mealType] ?? [];

  @override
  List<Object?> get props => [dayIndex, meals, selections];
}

enum MealConfigurationStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
  completed
}

class MealConfigurationState extends Equatable {
  final MealConfigurationStatus status;
  final Map<int, DayMeals> dayMealsMap; // Maps day index to DayMeals
  final int selectedDayIndex;
  final String selectedMealType; // breakfast, lunch, dinner
  final Map<String, Dish> dishesCache; // Cache of dishes by ID for quick lookup
  final double totalAdditionalCost;
  final bool isLoading;
  final String? errorMessage;

  const MealConfigurationState({
    this.status = MealConfigurationStatus.initial,
    this.dayMealsMap = const {},
    this.selectedDayIndex = 0,
    this.selectedMealType = 'lunch',
    this.dishesCache = const {},
    this.totalAdditionalCost = 0.0,
    this.isLoading = false,
    this.errorMessage,
  });

  MealConfigurationState copyWith({
    MealConfigurationStatus? status,
    Map<int, DayMeals>? dayMealsMap,
    int? selectedDayIndex,
    String? selectedMealType,
    Map<String, Dish>? dishesCache,
    double? totalAdditionalCost,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MealConfigurationState(
      status: status ?? this.status,
      dayMealsMap: dayMealsMap ?? this.dayMealsMap,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      dishesCache: dishesCache ?? this.dishesCache,
      totalAdditionalCost: totalAdditionalCost ?? this.totalAdditionalCost,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Get currently selected day's meals
  DayMeals? get selectedDayMeals => dayMealsMap[selectedDayIndex];
  
  // Get currently selected meal
  Meal? get selectedMeal => selectedDayMeals?.getMeal(selectedMealType);
  
  // Get currently selected meal's selections
  List<DishSelectionEntry> get currentSelections => 
      selectedDayMeals?.getSelections(selectedMealType) ?? [];

  // Check if a dish is selected in the current meal
  bool isDishSelected(String dishId) {
    return currentSelections.any((entry) => entry.dishId == dishId);
  }

  // Check if the current meal configuration is valid
  bool get isCurrentMealValid {
    if (selectedMeal == null) return false;
    
    // Check if all required categories have minimum selections
    for (final category in selectedMeal!.categories) {
      if (category.isRequired) {
        // Count valid selections for this category
        final categorySelections = currentSelections
            .where((entry) => entry.categoryName == category.name)
            .length;
            
        if (categorySelections < category.minSelections) {
          return false;
        }
      }
    }
    
    return true;
  }

  // Check if all meal configurations are valid
  bool get isAllMealsValid {
    // For a subscription of 7 days with 3 meals each
    for (int day = 0; day < 7; day++) {
      final dayMeals = dayMealsMap[day];
      if (dayMeals == null) return false;
      
      for (final mealType in ['breakfast', 'lunch', 'dinner']) {
        final meal = dayMeals.getMeal(mealType);
        if (meal == null) return false;
        
        // Check if all required categories have minimum selections
        for (final category in meal.categories) {
          if (category.isRequired) {
            // Count valid selections for this category
            final categorySelections = dayMeals.getSelections(mealType)
                .where((entry) => entry.categoryName == category.name)
                .length;
                
            if (categorySelections < category.minSelections) {
              return false;
            }
          }
        }
      }
    }
    
    return true;
  }

  @override
  List<Object?> get props => [
    status,
    dayMealsMap,
    selectedDayIndex,
    selectedMealType,
    dishesCache,
    totalAdditionalCost,
    isLoading,
    errorMessage,
  ];
}