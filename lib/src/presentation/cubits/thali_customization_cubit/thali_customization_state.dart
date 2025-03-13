// Fixed thali_customization_state.dart
part of 'thali_cutomization_cubit.dart';

abstract class ThaliCustomizationState extends Equatable {
  const ThaliCustomizationState();
  
  @override
  List<Object?> get props => [];
}

class ThaliCustomizationInitial extends ThaliCustomizationState {}

class ThaliBeingCustomized extends ThaliCustomizationState {
  final Thali originalThali;
  final List<Meal> currentSelection;
  final MealType mealType;
  final DayOfWeek day;
  final String thaliId;
  
  const ThaliBeingCustomized({
    required this.originalThali,
    required this.currentSelection,
    required this.mealType,
    required this.day,
    required this.thaliId,
  });
  
  @override
  List<Object?> get props => [originalThali, currentSelection, mealType, day, thaliId];
}

class ThaliCustomizationLoading extends ThaliBeingCustomized {
  const ThaliCustomizationLoading({
    required super.originalThali,
    required super.currentSelection,
    required super.mealType,
    required super.day,
    required super.thaliId,
  });
}

class MealOptionsLoaded extends ThaliBeingCustomized {
  final List<Meal> availableMeals;
  final bool isProcessing; // New field to track save in progress
  
  const MealOptionsLoaded({
    required super.originalThali,
    required super.currentSelection,
    required this.availableMeals,
    required super.mealType,
    required super.day,
    required super.thaliId,
    this.isProcessing = false,
  });
  
  @override
  List<Object?> get props => [
    originalThali, 
    currentSelection, 
    availableMeals, 
    mealType, 
    day, 
    thaliId, 
    isProcessing
  ];
  
  // Calculate additional price based on selections
  double get additionalPrice {
    double extra = 0.0;
    for (final meal in currentSelection) {
      if (!originalThali.defaultMeals.contains(meal)) {
        extra += meal.price;
      }
    }
    return extra;
  }
  
  // Calculate total price
  double get totalPrice {
    return originalThali.basePrice + additionalPrice;
  }
  
  // Check if the selection has changed from the original
  bool get hasChanges {
    if (currentSelection.length != originalThali.selectedMeals.length) {
      return true;
    }
    
    // Sort both lists to ensure consistent comparison
    final sortedOriginal = List<Meal>.from(originalThali.selectedMeals)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sortedCurrent = List<Meal>.from(currentSelection)
      ..sort((a, b) => a.id.compareTo(b.id));
    
    // Compare each meal
    for (int i = 0; i < sortedOriginal.length; i++) {
      if (sortedOriginal[i].id != sortedCurrent[i].id) {
        return true;
      }
    }
    
    return false;
  }
}

class ThaliCustomizationError extends ThaliCustomizationState {
  final String message;
  
  const ThaliCustomizationError(this.message);
  
  @override
  List<Object?> get props => [message];
}