// lib/src/presentation/cubits/thali_customization_cubit/thali_cutomization_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/usecase/meal/customize_thali_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_option_usecase.dart';

part 'thali_customization_state.dart';

// Custom event class for customization completion
class CustomizationCompletedEvent {
  final Thali customizedThali;
  final MealType mealType;
  final DayOfWeek day;
  final String thaliId;
  
  CustomizationCompletedEvent({
    required this.customizedThali,
    required this.mealType,
    required this.day,
    required this.thaliId,
  });
}

class ThaliCustomizationCubit extends Cubit<ThaliCustomizationState> {
  final GetMealOptionsUseCase getMealOptionsUseCase;
  final CustomizeThaliUseCase customizeThaliUseCase;
  
  // Stream controller for completion events
  final _completionController = StreamController<CustomizationCompletedEvent>.broadcast();
  
  // Stream getter for UI to listen to completion events
  Stream<CustomizationCompletedEvent> get completionStream => _completionController.stream;
  
  ThaliCustomizationCubit({
    required this.getMealOptionsUseCase,
    required this.customizeThaliUseCase,
  }) : super(ThaliCustomizationInitial());
  
  @override
  Future<void> close() {
    _completionController.close();
    return super.close();
  }
  
  // Start customizing a thali with context of day and meal type
  void startCustomization(Thali thali, MealType mealType, DayOfWeek day) {
    emit(ThaliBeingCustomized(
      originalThali: thali,
      currentSelection: List.from(thali.selectedMeals),
      mealType: mealType,
      day: day,
      thaliId: thali.id,
    ));
    
    // Load available meal options
    loadMealOptions(mealType);
  }
  
  // Load available meal options for customization
  Future<void> loadMealOptions(MealType mealType) async {
    if (state is ThaliBeingCustomized) {
      final currentState = state as ThaliBeingCustomized;
      emit(ThaliCustomizationLoading(
        originalThali: currentState.originalThali,
        currentSelection: currentState.currentSelection,
        mealType: currentState.mealType,
        day: currentState.day,
        thaliId: currentState.thaliId,
      ));
      
      try {
        final result = await getMealOptionsUseCase(mealType);
        
        result.fold(
          (failure) => emit(ThaliCustomizationError('Failed to load meal options')),
          (meals) {
            if (state is ThaliCustomizationLoading) {
              final loadingState = state as ThaliCustomizationLoading;
              emit(MealOptionsLoaded(
                originalThali: loadingState.originalThali,
                currentSelection: loadingState.currentSelection,
                availableMeals: meals,
                mealType: loadingState.mealType,
                day: loadingState.day,
                thaliId: loadingState.thaliId,
              ));
            }
          },
        );
      } catch (e) {
        emit(ThaliCustomizationError('Failed to load meal options: ${e.toString()}'));
      }
    }
  }
  
  // Toggle a meal selection
  void toggleMealSelection(Meal meal) {
    if (state is MealOptionsLoaded) {
      final currentState = state as MealOptionsLoaded;
      
      // Create a new list to avoid modifying the original
      final updatedSelection = List<Meal>.from(currentState.currentSelection);
      
      if (updatedSelection.contains(meal)) {
        // Remove the meal
        updatedSelection.remove(meal);
      } else {
        // Add the meal if under max customizations
        if (updatedSelection.length < currentState.originalThali.maxCustomizations) {
          updatedSelection.add(meal);
        } else {
          // If max reached, don't update the state
          return;
        }
      }
      
      emit(MealOptionsLoaded(
        originalThali: currentState.originalThali,
        currentSelection: updatedSelection,
        availableMeals: currentState.availableMeals,
        mealType: currentState.mealType,
        day: currentState.day,
        thaliId: currentState.thaliId,
      ));
    }
  }
  
  // Finalize the customization
  Future<void> saveCustomization() async {
    if (state is MealOptionsLoaded) {
      final currentState = state as MealOptionsLoaded;
      
      // Keep the MealOptionsLoaded state but set to loading
      emit(MealOptionsLoaded(
        originalThali: currentState.originalThali,
        currentSelection: currentState.currentSelection,
        availableMeals: currentState.availableMeals,
        mealType: currentState.mealType,
        day: currentState.day,
        thaliId: currentState.thaliId,
        isProcessing: true, // Set loading flag
      ));
      
      try {
        // Check if there are actually changes before proceeding
        if (!currentState.hasChanges) {
          // No changes, emit event directly without calling repository
          _completionController.add(CustomizationCompletedEvent(
            customizedThali: currentState.originalThali,
            mealType: currentState.mealType,
            day: currentState.day,
            thaliId: currentState.thaliId,
          ));
          
          // Return to normal state
          emit(MealOptionsLoaded(
            originalThali: currentState.originalThali,
            currentSelection: currentState.currentSelection,
            availableMeals: currentState.availableMeals,
            mealType: currentState.mealType,
            day: currentState.day,
            thaliId: currentState.thaliId,
            isProcessing: false,
          ));
          
          return;
        }
        
        // Create params for the use case
        final params = CustomizeThaliParams(
          originalThali: currentState.originalThali,
          selectedMeals: currentState.currentSelection,
        );
        
        // Call the use case
        final result = await customizeThaliUseCase(params);
        
        result.fold(
          (failure) {
            // Emit error state
            emit(ThaliCustomizationError('Failed to save customization'));
          },
          (customizedThali) {
            // Add completion event to stream
            _completionController.add(CustomizationCompletedEvent(
              customizedThali: customizedThali,
              mealType: currentState.mealType,
              day: currentState.day,
              thaliId: currentState.thaliId,
            ));
            
            // Return to normal state but with updated selection
            emit(MealOptionsLoaded(
              originalThali: currentState.originalThali,
              currentSelection: currentState.currentSelection,
              availableMeals: currentState.availableMeals,
              mealType: currentState.mealType,
              day: currentState.day,
              thaliId: currentState.thaliId,
              isProcessing: false,
            ));
          },
        );
      } catch (e) {
        emit(ThaliCustomizationError('Failed to save customization: ${e.toString()}'));
      }
    }
  }
  
  // Reset to original thali selections
  void resetToOriginal() {
    if (state is MealOptionsLoaded) {
      final currentState = state as MealOptionsLoaded;
      
      emit(MealOptionsLoaded(
        originalThali: currentState.originalThali,
        currentSelection: List.from(currentState.originalThali.selectedMeals),
        availableMeals: currentState.availableMeals,
        mealType: currentState.mealType,
        day: currentState.day,
        thaliId: currentState.thaliId,
      ));
    }
  }
  
  // Reset to initial state
  void reset() {
    emit(ThaliCustomizationInitial());
  }
  
  // Get the current state's day and meal type
  Map<String, dynamic>? getCustomizationContext() {
    if (state is ThaliBeingCustomized) {
      final currentState = state as ThaliBeingCustomized;
      return {
        'day': currentState.day,
        'mealType': currentState.mealType,
        'thaliId': currentState.thaliId,
      };
    }
    return null;
  }
}