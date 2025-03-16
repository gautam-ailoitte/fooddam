// lib/src/presentation/cubits/thali_selection_subit/thali_selection_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/usecase/thali/get_thali_option_usecase.dart';

part 'thali_selection_state.dart';

class ThaliSelectionCubit extends Cubit<ThaliSelectionState> {
  final GetThaliOptionsUseCase getThaliOptionsUseCase;
  
  ThaliSelectionCubit({
    required this.getThaliOptionsUseCase,
  }) : super(ThaliSelectionInitial());
  
  // Load available thali options for a specific meal type
  Future<void> loadThaliOptions(MealType mealType, DayOfWeek day) async {
    emit(ThaliSelectionLoading());
    
    try {
      final result = await getThaliOptionsUseCase(mealType);
      
      result.fold(
        (failure) => emit(ThaliSelectionError('Failed to load thali options')),
        (thalis) => emit(ThaliOptionsLoaded(
          thaliOptions: thalis,
          mealType: mealType,
          day: day,
        )),
      );
    } catch (e) {
      emit(ThaliSelectionError('Failed to load thali options: ${e.toString()}'));
    }
  }
  
  // Select a thali without customization
  void selectThali(Thali thali, DayOfWeek day, MealType mealType) {
    emit(ThaliSelected(
      selectedThali: thali,
      mealType: mealType,
      day: day,
    ));
  }
  
  // Reset selection
  void reset() {
    emit(ThaliSelectionInitial());
  }
}