// lib/src/presentation/cubits/meal_configuration/meal_configuration_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/usecase/dish/get_dish_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_category_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_dietary_preference_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal_configuration/meal_configuration_state.dart';

class MealConfigurationCubit extends Cubit<MealConfigurationState> {
  final GetMealsUseCase _getMealsUseCase;
  final GetMealByIdUseCase _getMealByIdUseCase;
  final GetDishByIdUseCase _getDishByIdUseCase;
  final GetDishesByCategoryUseCase _getDishesByCategoryUseCase;
  final GetDishesByDietaryPreferenceUseCase _getDishesByDietaryPreferenceUseCase;

  MealConfigurationCubit({
    required GetMealsUseCase getMealsUseCase,
    required GetMealByIdUseCase getMealByIdUseCase,
    required GetDishByIdUseCase getDishByIdUseCase,
    required GetDishesByCategoryUseCase getDishesByCategoryUseCase,
    required GetDishesByDietaryPreferenceUseCase getDishesByDietaryPreferenceUseCase,
  }) : _getMealsUseCase = getMealsUseCase,
       _getMealByIdUseCase = getMealByIdUseCase,
       _getDishByIdUseCase = getDishByIdUseCase,
       _getDishesByCategoryUseCase = getDishesByCategoryUseCase,
       _getDishesByDietaryPreferenceUseCase = getDishesByDietaryPreferenceUseCase,
       super(const MealConfigurationState());

  // Initialize meal configuration for a new subscription
  Future<void> initializeMealConfiguration(DietaryPreference preference) async {
    emit(state.copyWith(
      status: MealConfigurationStatus.loading,
      isLoading: true,
    ));

    try {
      // Load meals based on dietary preference
      final mealsParams = GetMealsParams(dietaryPreference: preference);
      final mealsResult = await _getMealsUseCase(mealsParams);

       mealsResult.fold(
        (failure) => emit(state.copyWith(
          status: MealConfigurationStatus.error,
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        )),
        (meals) async {
          if (meals.isEmpty) {
            emit(state.copyWith(
              status: MealConfigurationStatus.error,
              isLoading: false,
              errorMessage: 'No meals found for the selected preference.',
            ));
            return;
          }

          // Let's assume we're initializing with the first meal type for all days
          final mealTemplate = meals.first;
          
          // Create a days map with default meals
          final Map<int, DayMeals> dayMealsMap = {};
          final Map<String, Dish> dishesCache = {};
          
          // For all 7 days
          for (int day = 0; day < 7; day++) {
            // For each meal type (breakfast, lunch, dinner)
            final Map<String, Meal> dayMeals = {
              'breakfast': mealTemplate,
              'lunch': mealTemplate,
              'dinner': mealTemplate,
            };
            
            // Initialize selections for each meal type
            final Map<String, List<DishSelectionEntry>> selections = {};
            
            // For each meal type
            for (final mealType in ['breakfast', 'lunch', 'dinner']) {
              final List<DishSelectionEntry> mealSelections = [];
              
              // For each category, select minimum required dishes
              for (final category in mealTemplate.categories) {
                final requiredSelections = category.minSelections;
                
                // Take the first 'requiredSelections' options as default
                for (int i = 0; i < requiredSelections && i < category.options.length; i++) {
                  final option = category.options[i];
                  
                  // Get detailed dish information to add to cache
                  final dishResult = await _getDishByIdUseCase(option.dishId);
                  
                  await dishResult.fold(
                    (failure) => null, // Skip if dish not found
                    (dish) {
                      // Add to dishes cache
                      dishesCache[dish.id] = dish;
                      
                      // Add to selections
                      mealSelections.add(DishSelectionEntry(
                        dishId: dish.id,
                        categoryName: category.name,
                        isOriginal: true,
                      ));
                    },
                  );
                }
              }
              
              selections[mealType] = mealSelections;
            }
            
            dayMealsMap[day] = DayMeals(
              dayIndex: day,
              meals: dayMeals,
              selections: selections,
            );
          }
          
          emit(state.copyWith(
            status: MealConfigurationStatus.loaded,
            dayMealsMap: dayMealsMap,
            dishesCache: dishesCache,
            isLoading: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: MealConfigurationStatus.error,
        isLoading: false,
        errorMessage: 'Failed to initialize meal configuration: $e',
      ));
    }
  }

  // Change the selected day
  void selectDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < 7) {
      emit(state.copyWith(selectedDayIndex: dayIndex));
    }
  }

  // Change the selected meal type
  void selectMealType(String mealType) {
    if (['breakfast', 'lunch', 'dinner'].contains(mealType)) {
      emit(state.copyWith(selectedMealType: mealType));
    }
  }

  // Toggle dish selection for the current meal
  Future<void> toggleDishSelection(String dishId, String categoryName) async {
    if (state.selectedDayMeals == null) return;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final dayMeals = state.selectedDayMeals!;
      final mealType = state.selectedMealType;
      final meal = dayMeals.getMeal(mealType);
      
      if (meal == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      
      // Find the category
      final category = meal.categories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => throw Exception('Category not found: $categoryName'),
      );
      
      // Get current selections for this meal
      final currentSelections = dayMeals.getSelections(mealType);
      
      // Check if dish is already selected
      final isSelected = currentSelections.any((entry) => entry.dishId == dishId);
      
      if (isSelected) {
        // Remove the dish if it's selected
        final entry = currentSelections.firstWhere((entry) => entry.dishId == dishId);
        
        // Don't allow removing if it would break minimum selection requirements
        final categorySelections = currentSelections
            .where((entry) => entry.categoryName == categoryName)
            .length;
            
        if (category.isRequired && categorySelections <= category.minSelections) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Cannot remove dish. Minimum ${category.minSelections} dish(es) required for ${category.name}.',
          ));
          return;
        }
        
        // Remove the dish
        final updatedSelections = List<DishSelectionEntry>.from(currentSelections)
          ..removeWhere((e) => e.dishId == dishId);
          
        // Update additional cost if needed
        double additionalCost = state.totalAdditionalCost;
        if (entry.isAdditional) {
          final dish = state.dishesCache[dishId];
          if (dish != null) {
            additionalCost -= dish.price;
          }
        }
        
        // Update the selections for this meal
        final updatedDaySelections = Map<String, List<DishSelectionEntry>>.from(dayMeals.selections)
          ..update(mealType, (_) => updatedSelections);
          
        // Update the day meals
        final updatedDayMeals = dayMeals.copyWith(selections: updatedDaySelections);
        
        // Update the overall day meals map
        final updatedDayMealsMap = Map<int, DayMeals>.from(state.dayMealsMap)
          ..update(state.selectedDayIndex, (_) => updatedDayMeals);
          
        emit(state.copyWith(
          dayMealsMap: updatedDayMealsMap,
          totalAdditionalCost: additionalCost,
          isLoading: false,
        ));
      } else {
        // Add the dish if it's not selected
        // First, check if we're at the maximum for this category
        final categorySelections = currentSelections
            .where((entry) => entry.categoryName == categoryName)
            .length;
            
        if (categorySelections >= category.maxSelections) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Cannot add more dishes. Maximum ${category.maxSelections} dish(es) allowed for ${category.name}.',
          ));
          return;
        }
        
        // Determine if this is a swap or an additional dish
        final isSwap = categorySelections == category.minSelections;
        final isAdditional = categorySelections > category.minSelections;
        
        // Get the dish details if not in cache
        if (!state.dishesCache.containsKey(dishId)) {
          final dishResult = await _getDishByIdUseCase(dishId);
          
          await dishResult.fold(
            (failure) {
              emit(state.copyWith(
                isLoading: false,
                errorMessage: 'Failed to fetch dish details: ${_mapFailureToMessage(failure)}',
              ));
              return;
            },
            (dish) {
              // Add to cache
              final updatedCache = Map<String, Dish>.from(state.dishesCache)
                ..putIfAbsent(dish.id, () => dish);
                
              emit(state.copyWith(dishesCache: updatedCache));
            },
          );
        }
        
        // Add the dish
        final updatedSelections = List<DishSelectionEntry>.from(currentSelections)
          ..add(DishSelectionEntry(
            dishId: dishId,
            categoryName: categoryName,
            isOriginal: false,
            isSwapped: isSwap,
            isAdditional: isAdditional,
          ));
          
        // Update additional cost if needed
        double additionalCost = state.totalAdditionalCost;
        if (isAdditional) {
          final dish = state.dishesCache[dishId];
          if (dish != null) {
            additionalCost += dish.price;
          }
        }
        
        // Update the selections for this meal
        final updatedDaySelections = Map<String, List<DishSelectionEntry>>.from(dayMeals.selections)
          ..update(mealType, (_) => updatedSelections);
          
        // Update the day meals
        final updatedDayMeals = dayMeals.copyWith(selections: updatedDaySelections);
        
        // Update the overall day meals map
        final updatedDayMealsMap = Map<int, DayMeals>.from(state.dayMealsMap)
          ..update(state.selectedDayIndex, (_) => updatedDayMeals);
          
        emit(state.copyWith(
          dayMealsMap: updatedDayMealsMap,
          totalAdditionalCost: additionalCost,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating selection: $e',
      ));
    }
  }

  // Reset current meal to defaults
  Future<void> resetCurrentMeal() async {
    if (state.selectedDayMeals == null) return;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final dayMeals = state.selectedDayMeals!;
      final mealType = state.selectedMealType;
      final meal = dayMeals.getMeal(mealType);
      
      if (meal == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      
      // Initialize selections for the meal
      final List<DishSelectionEntry> mealSelections = [];
      
      // For each category, select minimum required dishes
      for (final category in meal.categories) {
        final requiredSelections = category.minSelections;
        
        // Take the first 'requiredSelections' options as default
        for (int i = 0; i < requiredSelections && i < category.options.length; i++) {
          final option = category.options[i];
          
          mealSelections.add(DishSelectionEntry(
            dishId: option.dishId,
            categoryName: category.name,
            isOriginal: true,
          ));
        }
      }
      
      // Update the selections for this meal
      final updatedDaySelections = Map<String, List<DishSelectionEntry>>.from(dayMeals.selections)
        ..update(mealType, (_) => mealSelections);
        
      // Update the day meals
      final updatedDayMeals = dayMeals.copyWith(selections: updatedDaySelections);
      
      // Update the overall day meals map
      final updatedDayMealsMap = Map<int, DayMeals>.from(state.dayMealsMap)
        ..update(state.selectedDayIndex, (_) => updatedDayMeals);
        
      // Recalculate total additional cost
      double totalAdditionalCost = 0.0;
      for (final dayMeal in updatedDayMealsMap.values) {
        for (final mealSelectionsList in dayMeal.selections.values) {
          for (final selection in mealSelectionsList) {
            if (selection.isAdditional) {
              final dish = state.dishesCache[selection.dishId];
              if (dish != null) {
                totalAdditionalCost += dish.price;
              }
            }
          }
        }
      }
      
      emit(state.copyWith(
        dayMealsMap: updatedDayMealsMap,
        totalAdditionalCost: totalAdditionalCost,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error resetting meal: $e',
      ));
    }
  }

  // Apply current meal configuration to all days
  void applyCurrentMealToAll() {
    if (state.selectedDayMeals == null) return;
    
    final dayMeals = state.selectedDayMeals!;
    final mealType = state.selectedMealType;
    final currentSelections = dayMeals.getSelections(mealType);
    
    // Update all days with these selections for the same meal type
    final updatedDayMealsMap = Map<int, DayMeals>.from(state.dayMealsMap);
    
    for (int day = 0; day < 7; day++) {
      if (day == state.selectedDayIndex) continue; // Skip current day
      
      final otherDayMeals = updatedDayMealsMap[day];
      if (otherDayMeals == null) continue;
      
      // Update selections for this meal type
      final updatedSelections = Map<String, List<DishSelectionEntry>>.from(otherDayMeals.selections)
        ..update(mealType, (_) => List.from(currentSelections));
        
      // Update the day meals
      updatedDayMealsMap[day] = otherDayMeals.copyWith(selections: updatedSelections);
    }
    
    // Recalculate total additional cost
    double totalAdditionalCost = 0.0;
    for (final dayMeal in updatedDayMealsMap.values) {
      for (final mealSelectionsList in dayMeal.selections.values) {
        for (final selection in mealSelectionsList) {
          if (selection.isAdditional) {
            final dish = state.dishesCache[selection.dishId];
            if (dish != null) {
              totalAdditionalCost += dish.price;
            }
          }
        }
      }
    }
    
    emit(state.copyWith(
      dayMealsMap: updatedDayMealsMap,
      totalAdditionalCost: totalAdditionalCost,
    ));
  }

  // Complete meal configuration
  void completeMealConfiguration() {
    if (state.isAllMealsValid) {
      emit(state.copyWith(status: MealConfigurationStatus.completed));
    } else {
      emit(state.copyWith(
        errorMessage: 'Please ensure all meals meet the minimum selection requirements.',
      ));
    }
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}