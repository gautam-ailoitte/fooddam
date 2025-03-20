// lib/src/presentation/cubits/meal_plan/thali_selection_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/usecase/meal/get_available_meal_usecase.dart';
import 'package:foodam/src/domain/usecase/meal/get_meals_bytype_usecase.dart';
import 'package:foodam/src/presentation/cubits/thali_selection/thali_selection_state.dart';

class ThaliSelectionCubit extends Cubit<ThaliSelectionState> {
  final GetMealsByTypeUseCase _getMealsByTypeUseCase;
  final LoggerService _logger = LoggerService();
  
  Map<String, List<MealDistribution>> _currentDistribution = {};
  List<MealDistribution> _pendingSlots = [];
  MealDistribution? _currentSlot;

  ThaliSelectionCubit({
    required GetAvailableMealsUseCase getAvailableMealsUseCase,
    required GetMealsByTypeUseCase getMealsByTypeUseCase,
  }) : 
    _getMealsByTypeUseCase = getMealsByTypeUseCase,
    super(ThaliSelectionInitial());

  Future<void> initializeThaliSelection(Map<String, List<MealDistribution>> distribution) async {
    emit(ThaliSelectionLoading());
    
    try {
      _currentDistribution = Map<String, List<MealDistribution>>.from(distribution);
      _pendingSlots = [];
      
      // Collect all slots that need meal selection
      distribution.forEach((mealType, slots) {
        _pendingSlots.addAll(slots.where((slot) => slot.mealId == null));
      });
      
      if (_pendingSlots.isEmpty) {
        emit(ThaliSelectionCompleted(_currentDistribution));
        return;
      }
      
      // Start with the first slot
      _currentSlot = _pendingSlots.first;
      
      // Load available meals for this type
      await _loadMealsForCurrentSlot();
    } catch (e) {
      _logger.e('Error initializing thali selection', error: e);
      emit(ThaliSelectionError('Failed to initialize thali selection'));
    }
  }

  Future<void> _loadMealsForCurrentSlot() async {
    if (_currentSlot == null) {
      emit(ThaliSelectionError('No current slot selected'));
      return;
    }
    
    final result = await _getMealsByTypeUseCase(_currentSlot!.mealType);
    
    result.fold(
      (failure) {
        _logger.e('Failed to load meals for type ${_currentSlot!.mealType}', error: failure);
        emit(ThaliSelectionError('Failed to load available meals'));
      },
      (meals) {
        _logger.i('Loaded ${meals.length} meals for ${_currentSlot!.mealType}');
        emit(ThaliSelecting(
          currentSlot: _currentSlot!,
          availableMeals: meals,
        ));
      },
    );
  }

  Future<void> selectMeal(String mealId) async {
    if (state is ThaliSelecting) {
      final currentState = state as ThaliSelecting;
      
      // Find the selected meal
      currentState.availableMeals.firstWhere(
        (meal) => meal.id == mealId,
        orElse: () => throw Exception('Meal not found'),
      );
      
      // Update the current slot
      final updatedSlot = MealDistributionModel(
        mealType: _currentSlot!.mealType,
        date: _currentSlot!.date,
        mealId: mealId,
      );
      
      // Update in distribution
      _updateDistribution(updatedSlot);
      
      // Remove from pending slots
      _pendingSlots.removeWhere((slot) => 
        slot.mealType == _currentSlot!.mealType && 
        slot.date == _currentSlot!.date
      );
      
      _logger.i('Selected meal: $mealId for ${_currentSlot!.mealType} on ${_currentSlot!.date.toIso8601String()}');
      
      // Move to next slot or complete
      if (_pendingSlots.isEmpty) {
        emit(ThaliSelectionCompleted(_currentDistribution));
      } else {
        _currentSlot = _pendingSlots.first;
        await _loadMealsForCurrentSlot();
      }
    } else {
      emit(ThaliSelectionError('Not in selection mode'));
    }
  }

  void _updateDistribution(MealDistribution updatedSlot) {
    final mealType = updatedSlot.mealType;
    
    if (!_currentDistribution.containsKey(mealType)) {
      _currentDistribution[mealType] = [];
    }
    
    // Find and replace the slot with the same date
    final index = _currentDistribution[mealType]!.indexWhere(
      (slot) => slot.date == updatedSlot.date
    );
    
    if (index >= 0) {
      _currentDistribution[mealType]![index] = updatedSlot;
    } else {
      _currentDistribution[mealType]!.add(updatedSlot);
    }
  }

  void skipCurrentSlot() {
    if (_currentSlot != null) {
      _pendingSlots.removeWhere((slot) => 
        slot.mealType == _currentSlot!.mealType && 
        slot.date == _currentSlot!.date
      );
      
      if (_pendingSlots.isEmpty) {
        emit(ThaliSelectionCompleted(_currentDistribution));
      } else {
        _currentSlot = _pendingSlots.first;
        _loadMealsForCurrentSlot();
      }
    }
  }

  Map<String, List<MealDistribution>> getCurrentDistribution() {
    return _currentDistribution;
  }
}