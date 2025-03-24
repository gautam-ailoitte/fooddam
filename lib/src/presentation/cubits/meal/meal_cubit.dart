// lib/src/presentation/cubits/meal/meal_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_byid_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_state.dart';

class MealCubit extends Cubit<MealState> {
  final GetMealByIdUseCase _getMealByIdUseCase;
  final LoggerService _logger = LoggerService();

  MealCubit({
    required GetMealByIdUseCase getMealByIdUseCase,
  }) : 
    _getMealByIdUseCase = getMealByIdUseCase,
    super(MealInitial());

  Future<void> getMealById(String mealId) async {
    emit(MealLoading());
    
    final result = await _getMealByIdUseCase(mealId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to get meal details', error: failure);
        emit(MealError('Failed to load meal details'));
      },
      (meal) {
        _logger.i('Meal details loaded: ${meal.id}');
        emit(MealLoaded(meal: meal));
      },
    );
  }
  
  // Helper method to cache multiple meals loaded from other sources
  void cacheMeals(List<Meal> meals) {
    if (meals.isEmpty) {
      return;
    }
    
    _logger.i('Caching ${meals.length} meals from external source');
    emit(MealListLoaded(meals: meals));
  }
}