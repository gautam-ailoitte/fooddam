// lib/src/presentation/cubits/meal_customization/meal_customization_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/usecase/dish/get_dish_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_category_usecase.dart';
import 'package:foodam/src/domain/usecase/dish/get_dishes_by_dietary_preference_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_state.dart';

class MealCustomizationCubit extends Cubit<MealCustomizationState> {
  final GetMealByIdUseCase _getMealByIdUseCase;
  final GetMealsUseCase _getMealsUseCase;
  final GetDishByIdUseCase _getDishByIdUseCase;
  final GetDishesByCategoryUseCase _getDishesByCategoryUseCase;
  final GetDishesByDietaryPreferenceUseCase _getDishesByDietaryPreferenceUseCase;

  // Store the currently customized meal and selected dishes
  Meal? _currentMeal;
  final Map<String, List<String>> _selectedDishIds = {}; // categoryId -> list of dishIds
  final Map<String, List<Dish>> _availableAdditionalDishes = {}; // categoryId -> list of dishes
  double _totalCustomizationPrice = 0.0;

  MealCustomizationCubit({
    required GetMealByIdUseCase getMealByIdUseCase,
    required GetMealsUseCase getMealsUseCase,
    required GetDishByIdUseCase getDishByIdUseCase,
    required GetDishesByCategoryUseCase getDishesByCategoryUseCase,
    required GetDishesByDietaryPreferenceUseCase getDishesByDietaryPreferenceUseCase,
  })  : _getMealByIdUseCase = getMealByIdUseCase,
        _getMealsUseCase = getMealsUseCase,
        _getDishByIdUseCase = getDishByIdUseCase,
        _getDishesByCategoryUseCase = getDishesByCategoryUseCase,
        _getDishesByDietaryPreferenceUseCase = getDishesByDietaryPreferenceUseCase,
        super(MealCustomizationInitial());

  // Get available meals for selection
  Future<void> getAvailableMeals({
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
  }) async {
    emit(MealCustomizationLoading());

    final params = GetMealsParams(
      dietaryPreference: dietaryPreference,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    final result = await _getMealsUseCase(params);

    result.fold(
      (failure) => emit(MealCustomizationError(message: _mapFailureToMessage(failure))),
      (meals) => emit(MealsLoaded(meals: meals)),
    );
  }

  // Start customizing a specific meal
  Future<void> startCustomizingMeal(String mealId) async {
    emit(MealCustomizationLoading());

    // Reset customization state
    _selectedDishIds.clear();
    _availableAdditionalDishes.clear();
    _totalCustomizationPrice = 0.0;

    final result = await _getMealByIdUseCase(mealId);

    result.fold(
      (failure) => emit(MealCustomizationError(message: _mapFailureToMessage(failure))),
      (meal) async {
        _currentMeal = meal;
        
        // Initialize selected dishes with default options
        for (var category in meal.categories) {
          _selectedDishIds[category.name] = [];
          
          // Add default selections if there are minimum selections required
          if (category.minSelections > 0 && category.options.isNotEmpty) {
            final defaultOptions = category.options.take(category.minSelections).toList();
            for (var option in defaultOptions) {
              _selectedDishIds[category.name]!.add(option.dishId);
            }
          }
        }
        
        // Load all dishes for each category to allow additional customization
        await _loadAdditionalDishesForCategories(meal);
        
        emit(MealCustomizationReady(
          meal: meal,
          selectedDishIds: Map.from(_selectedDishIds),
          availableAdditionalDishes: _availableAdditionalDishes,
          totalCustomizationPrice: _totalCustomizationPrice,
        ));
      },
    );
  }

  // Load additional dishes available for each category
  Future<void> _loadAdditionalDishesForCategories(Meal meal) async {
    for (var category in meal.categories) {
      final FoodCategory? foodCategory = _mapMealCategoryToFoodCategory(category.name);
      
      if (foodCategory != null) {
        final result = await _getDishesByCategoryUseCase(foodCategory);
        
        result.fold(
          (failure) => emit(MealCustomizationError(message: _mapFailureToMessage(failure))),
          (dishes) {
            // Filter out dishes that are already default options in the meal
            final additionalDishes = dishes.where((dish) {
              bool isIncluded = false;
              for (var option in category.options) {
                if (option.dishId == dish.id) {
                  isIncluded = true;
                  break;
                }
              }
              return !isIncluded;
            }).toList();
            
            _availableAdditionalDishes[category.name] = additionalDishes;
          },
        );
      }
    }
  }

  // Select a dish for a category
  Future<void> selectDish(String categoryName, String dishId) async {
    if (_currentMeal == null) {
      emit(MealCustomizationError(message: 'No meal is being customized'));
      return;
    }

    // Find the category
    final category = _currentMeal!.categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => throw Exception('Category not found'),
    );

    // Check if we're within the maximum selections limit
    if (_selectedDishIds[categoryName]!.length >= category.maxSelections) {
      emit(MealCustomizationError(
        message: 'You can select up to ${category.maxSelections} items for ${category.name}',
      ));
      return;
    }

    // Check if dish is already selected
    if (_selectedDishIds[categoryName]!.contains(dishId)) {
      emit(MealCustomizationError(message: 'This dish is already selected'));
      return;
    }

    // Add dish to selections
    _selectedDishIds[categoryName]!.add(dishId);

    // Check if this is an additional dish (not in default options)
    bool isAdditionalDish = true;
    for (var option in category.options) {
      if (option.dishId == dishId) {
        isAdditionalDish = false;
        break;
      }
    }

    // If it's an additional dish, add its price to customization
    if (isAdditionalDish) {
      final dish = _availableAdditionalDishes[categoryName]?.firstWhere(
        (d) => d.id == dishId,
        orElse: () => throw Exception('Dish not found'),
      );

      if (dish != null) {
        _totalCustomizationPrice += dish.price;
      }
    }

    emit(MealCustomizationReady(
      meal: _currentMeal!,
      selectedDishIds: Map.from(_selectedDishIds),
      availableAdditionalDishes: _availableAdditionalDishes,
      totalCustomizationPrice: _totalCustomizationPrice,
    ));
  }

  // Remove a dish from a category
  Future<void> removeDish(String categoryName, String dishId) async {
    if (_currentMeal == null) {
      emit(MealCustomizationError(message: 'No meal is being customized'));
      return;
    }

    // Find the category
    final category = _currentMeal!.categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => throw Exception('Category not found'),
    );

    // Check if we're at the minimum selections limit
    if (_selectedDishIds[categoryName]!.length <= category.minSelections) {
      emit(MealCustomizationError(
        message: 'You must select at least ${category.minSelections} items for ${category.name}',
      ));
      return;
    }

    // Check if dish is not selected
    if (!_selectedDishIds[categoryName]!.contains(dishId)) {
      emit(MealCustomizationError(message: 'This dish is not selected'));
      return;
    }

    // Remove dish from selections
    _selectedDishIds[categoryName]!.remove(dishId);

    // Check if this is an additional dish (not in default options)
    bool isAdditionalDish = true;
    for (var option in category.options) {
      if (option.dishId == dishId) {
        isAdditionalDish = false;
        break;
      }
    }

    // If it's an additional dish, subtract its price from customization
    if (isAdditionalDish) {
      final dish = _availableAdditionalDishes[categoryName]?.firstWhere(
        (d) => d.id == dishId,
        orElse: () => throw Exception('Dish not found'),
      );

      if (dish != null) {
        _totalCustomizationPrice -= dish.price;
      }
    }

    emit(MealCustomizationReady(
      meal: _currentMeal!,
      selectedDishIds: Map.from(_selectedDishIds),
      availableAdditionalDishes: _availableAdditionalDishes,
      totalCustomizationPrice: _totalCustomizationPrice,
    ));
  }

  // Reset customization to default selections
  void resetCustomization() {
    if (_currentMeal == null) {
      emit(MealCustomizationError(message: 'No meal is being customized'));
      return;
    }

    // Reset to default selections
    _selectedDishIds.clear();
    _totalCustomizationPrice = 0.0;

    for (var category in _currentMeal!.categories) {
      _selectedDishIds[category.name] = [];
      
      // Add default selections
      if (category.minSelections > 0 && category.options.isNotEmpty) {
        final defaultOptions = category.options.take(category.minSelections).toList();
        for (var option in defaultOptions) {
          _selectedDishIds[category.name]!.add(option.dishId);
        }
      }
    }

    emit(MealCustomizationReady(
      meal: _currentMeal!,
      selectedDishIds: Map.from(_selectedDishIds),
      availableAdditionalDishes: _availableAdditionalDishes,
      totalCustomizationPrice: _totalCustomizationPrice,
    ));
  }

  // Complete customization and generate final customized meal
  void completeCustomization() {
    if (_currentMeal == null) {
      emit(MealCustomizationError(message: 'No meal is being customized'));
      return;
    }

    // Check if all categories meet minimum requirements
    for (var category in _currentMeal!.categories) {
      if (_selectedDishIds[category.name]!.length < category.minSelections) {
        emit(MealCustomizationError(
          message: 'Please select at least ${category.minSelections} items for ${category.name}',
        ));
        return;
      }
    }

    // Calculate total price (base price + customization price)
    final totalPrice = _currentMeal!.basePrice + _totalCustomizationPrice;

    emit(MealCustomizationCompleted(
      meal: _currentMeal!,
      selectedDishIds: Map.from(_selectedDishIds),
      totalCustomizationPrice: _totalCustomizationPrice,
      totalPrice: totalPrice,
    ));
  }

  // Helper method to map meal category name to food category enum
  FoodCategory? _mapMealCategoryToFoodCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'curry':
      case 'main curry':
        return FoodCategory.mainCourse;
      case 'rice':
      case 'grain':
      case 'rice/grain':
        return FoodCategory.sideDish;
      case 'bread':
        return FoodCategory.sideDish;
      case 'dessert':
        return FoodCategory.dessert;
      case 'appetizer':
        return FoodCategory.appetizer;
      case 'salad':
        return FoodCategory.salad;
      case 'soup':
        return FoodCategory.soup;
      case 'beverage':
        return FoodCategory.beverage;
      case 'breakfast':
        return FoodCategory.breakfast;
      case 'snack':
        return FoodCategory.snack;
      default:
        return null;
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error occurred. Please check your connection.';
      case CacheFailure:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}