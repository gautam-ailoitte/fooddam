// lib/src/presentation/cubits/meal_customization_cubit/meal_customization_state.dart
part of 'meal_customization_cubit.dart';

abstract class MealCustomizationState extends Equatable {
  const MealCustomizationState();
  
  @override
  List<Object?> get props => [];
}

class MealCustomizationInitial extends MealCustomizationState {}

class MealCustomizationLoading extends MealCustomizationState {}

class MealCustomizationActive extends MealCustomizationState {
  final Thali originalThali;
  final List<Meal> currentSelection;
  final List<Meal> availableMeals;
  final DayOfWeek day;
  final MealType mealType;
  
  const MealCustomizationActive({
    required this.originalThali,
    required this.currentSelection,
    required this.availableMeals,
    required this.day,
    required this.mealType,
  });
  
  @override
  List<Object?> get props => [originalThali, currentSelection, availableMeals, day, mealType];
  
  // Calculate additional price based on selections
  double get additionalPrice {
    double extra = 0.0;
    for (final meal in currentSelection) {
      if (!originalThali.defaultMeals.any((defaultMeal) => defaultMeal.id == meal.id)) {
        extra += meal.price;
      }
    }
    return extra;
  }
  
  // Calculate total price
  double get totalPrice => originalThali.basePrice + additionalPrice;
  
  // Check if there are changes
  bool get hasChanges {
    if (currentSelection.length != originalThali.selectedMeals.length) {
      return true;
    }
    
    // Sort both lists by ID for consistent comparison
    final sortedOriginal = List<Meal>.from(originalThali.selectedMeals)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sortedCurrent = List<Meal>.from(currentSelection)
      ..sort((a, b) => a.id.compareTo(b.id));
    
    // Compare each meal
    for (int i = 0; i < sortedOriginal.length; i++) {
      if (sortedOriginal[i].id != sortedCurrent[i].id) return true;
    }
    
    return false;
  }
}

class MealCustomizationSaving extends MealCustomizationActive {
  const MealCustomizationSaving({
    required super.originalThali,
    required super.currentSelection,
    required super.availableMeals,
    required super.day,
    required super.mealType,
  });
}

class MealCustomizationComplete extends MealCustomizationState {
  final Thali customizedThali;
  final DayOfWeek day;
  final MealType mealType;
  
  const MealCustomizationComplete({
    required this.customizedThali,
    required this.day,
    required this.mealType,
  });
  
  @override
  List<Object?> get props => [customizedThali, day, mealType];
}

class MealCustomizationError extends MealCustomizationState {
  final String message;
  
  const MealCustomizationError(this.message);
  
  @override
  List<Object?> get props => [message];
}