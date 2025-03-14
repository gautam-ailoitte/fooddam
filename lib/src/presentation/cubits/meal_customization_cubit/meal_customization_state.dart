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
    // Start with 0 additional price
    double extra = 0.0;
    
    // First, calculate the total price of all default meals
    double defaultMealsTotal = 0.0;
    for (final meal in originalThali.defaultMeals) {
      defaultMealsTotal += meal.price;
    }
    
    // Then calculate the total price of current selection
    double currentSelectionTotal = 0.0;
    for (final meal in currentSelection) {
      currentSelectionTotal += meal.price;
    }
    
    // The difference is the additional price
    // If negative (removed default meals), set to 0
    extra = currentSelectionTotal - defaultMealsTotal;
    return extra > 0 ? extra : 0;
  }
  
  // Calculate total price for the customized thali
  double get totalPrice {
    // For fully customized thali, calculate directly from selected meals
    if (originalThali.defaultMeals.length != currentSelection.length) {
      // Base price plus any additional cost
      return originalThali.basePrice + additionalPrice;
    } else {
      // If same number of items, check if there's any customization
      bool hasCustomization = false;
      for (final meal in currentSelection) {
        if (!originalThali.defaultMeals.any((defaultMeal) => defaultMeal.id == meal.id)) {
          hasCustomization = true;
          break;
        }
      }
      
      if (hasCustomization) {
        // If customized, use custom price
        return originalThali.basePrice + additionalPrice;
      } else {
        // If identical to default, use original price
        return originalThali.basePrice;
      }
    }
  }
  
  // Check if there are changes using Thali entity functionality
  bool get hasChanges {
    // Create a temporary thali with the current selection
    final tempThali = originalThali.copyWith(selectedMeals: currentSelection);
    
    // Use the hasSameMeals method to check for differences
    return !originalThali.hasSameMeals(tempThali);
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