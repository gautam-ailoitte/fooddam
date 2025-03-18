// lib/src/presentation/cubits/menu/menu_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_dietary_preference_usecase.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final GetMealsUseCase getMealsUseCase;
  final GetDishesByDietaryPreferenceUseCase getDishesByDietaryPreferenceUseCase;

  MenuCubit({
    required this.getMealsUseCase,
    required this.getDishesByDietaryPreferenceUseCase,
  }) : super(MenuInitial());

  // Selected date for viewing menu
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // Selected meal type (Breakfast, Lunch, Dinner)
  String _selectedMealType = 'breakfast';
  String get selectedMealType => _selectedMealType;

  // Initialize menu data
  Future<void> initMenu() async {
    emit(MenuLoading());
    try {
      await loadMenuForDate(_selectedDate);
    } catch (e) {
      emit(MenuError('Failed to load menu: ${e.toString()}'));
    }
  }

  // Load menu for a specific date
  Future<void> loadMenuForDate(DateTime date) async {
    emit(MenuLoading());
    _selectedDate = date;
    
    try {
      // Get meals for the selected date
      final mealsParams = GetMealsParams();
      final mealsResult = await getMealsUseCase(mealsParams);
      
      mealsResult.fold(
        (failure) => emit(MenuError('Failed to load meals')),
        (meals) {
          // Now load dishes for the selected meal type
          _loadDishesForMealType(_selectedMealType, meals);
        },
      );
    } catch (e) {
      emit(MenuError('Failed to load menu: ${e.toString()}'));
    }
  }
  
  // Load dishes for the selected meal type
  Future<void> setMealType(String mealType) async {
    if (_selectedMealType == mealType && state is MenuLoaded) {
      return; // Already loaded, no need to reload
    }
    
    _selectedMealType = mealType;
    
    if (state is MenuLoaded) {
      final loadedState = state as MenuLoaded;
      _loadDishesForMealType(mealType, loadedState.availableMeals);
    } else {
      // If we don't have meals yet, load them first
      await initMenu();
    }
  }
  
  // Helper method to load dishes for a meal type
  Future<void> _loadDishesForMealType(String mealType, List<Meal> availableMeals) async {
    try {
      // Determine which dietary preference to load based on meal type
      // This is a simplification - in a real app, this would be based on user preferences
      final dietaryPreference = mealType == 'breakfast' || mealType == 'dinner'
          ? DietaryPreference.vegetarian
          : DietaryPreference.nonVegetarian;
      
      final dishesResult = await getDishesByDietaryPreferenceUseCase(dietaryPreference);
      
      dishesResult.fold(
        (failure) => emit(MenuError('Failed to load dishes')),
        (dishes) {
          emit(MenuLoaded(
            selectedDate: _selectedDate,
            selectedMealType: mealType,
            availableMeals: availableMeals,
            availableDishes: dishes,
          ));
        },
      );
    } catch (e) {
      emit(MenuError('Failed to load dishes: ${e.toString()}'));
    }
  }
}