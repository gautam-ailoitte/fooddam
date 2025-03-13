// lib/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'meal_customization_state.dart';

class MealCustomizationCubit extends Cubit<MealCustomizationState> {
  final MealRepository mealRepository;
  
  MealCustomizationCubit({
    required this.mealRepository,
  }) : super(MealCustomizationInitial());
  
  // Initialize with a thali to customize
  void initialize(Thali thali, DayOfWeek day, MealType mealType) {
    emit(MealCustomizationLoading());
    
    // Load all available meals for this meal type
    loadAvailableMeals(thali, day, mealType);
  }
  
  // Load available meals for this meal type
  Future<void> loadAvailableMeals(Thali thali, DayOfWeek day, MealType mealType) async {
    try {
      final result = await mealRepository.getMealOptions(mealType);
      
      result.fold(
        (failure) => emit(MealCustomizationError('Failed to load meal options')),
        (meals) => emit(MealCustomizationActive(
          originalThali: thali,
          currentSelection: List.from(thali.selectedMeals),
          availableMeals: meals,
          day: day,
          mealType: mealType,
        )),
      );
    } catch (e) {
      emit(MealCustomizationError('Failed to load meal options: ${e.toString()}'));
    }
  }
  
  // Toggle meal selection
  void toggleMeal(Meal meal) {
    if (state is MealCustomizationActive) {
      final currentState = state as MealCustomizationActive;
      
      // Create a new list to avoid modifying the original
      final updatedSelection = List<Meal>.from(currentState.currentSelection);
      
      if (updatedSelection.contains(meal)) {
        // Remove the meal
        updatedSelection.removeWhere((m) => m.id == meal.id);
      } else {
        // Add the meal if under max customizations
        if (updatedSelection.length < currentState.originalThali.maxCustomizations) {
          updatedSelection.add(meal);
        } else {
          // If max reached, don't update the state
          return;
        }
      }
      
      emit(MealCustomizationActive(
        originalThali: currentState.originalThali,
        currentSelection: updatedSelection,
        availableMeals: currentState.availableMeals,
        day: currentState.day,
        mealType: currentState.mealType,
      ));
    }
  }
  
  // Reset to original selection
  void resetToOriginal() {
    if (state is MealCustomizationActive) {
      final currentState = state as MealCustomizationActive;
      
      emit(MealCustomizationActive(
        originalThali: currentState.originalThali,
        currentSelection: List.from(currentState.originalThali.selectedMeals),
        availableMeals: currentState.availableMeals,
        day: currentState.day,
        mealType: currentState.mealType,
      ));
    }
  }
  
  // Save customization
  Future<void> saveCustomization() async {
    if (state is MealCustomizationActive) {
      final currentState = state as MealCustomizationActive;
      
      // Check if there are changes by comparing the meal lists
      final originalThali = currentState.originalThali;
      final tempThali = originalThali.copyWith(selectedMeals: currentState.currentSelection);
      final hasChanges = !originalThali.hasSameMeals(tempThali);
      
      // If no changes, complete immediately
      if (!hasChanges) {
        emit(MealCustomizationComplete(
          customizedThali: currentState.originalThali,
          day: currentState.day,
          mealType: currentState.mealType,
        ));
        return;
      }
      
      // Otherwise, process customization
      emit(MealCustomizationSaving(
        originalThali: currentState.originalThali,
        currentSelection: currentState.currentSelection,
        availableMeals: currentState.availableMeals,
        day: currentState.day,
        mealType: currentState.mealType,
      ));
      
      try {
        final result = await mealRepository.customizeThali(
          currentState.originalThali,
          currentState.currentSelection,
        );
        
        result.fold(
          (failure) => emit(MealCustomizationError('Failed to save customization')),
          (customizedThali) => emit(MealCustomizationComplete(
            customizedThali: customizedThali,
            day: currentState.day,
            mealType: currentState.mealType,
          )),
        );
      } catch (e) {
        emit(MealCustomizationError('Failed to save customization: ${e.toString()}'));
      }
    }
  }
  
  // Checking if meal selections are equal using the Thali entity functionality
  
  // Check if a meal is in the current selection
  bool isMealSelected(Meal meal) {
    if (state is MealCustomizationActive) {
      final currentState = state as MealCustomizationActive;
      return currentState.currentSelection.any((m) => m.id == meal.id);
    }
    return false;
  }
  
  // Reset to initial state
  void reset() {
    emit(MealCustomizationInitial());
  }
}