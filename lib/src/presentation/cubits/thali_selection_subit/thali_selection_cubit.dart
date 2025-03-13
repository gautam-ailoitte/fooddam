// lib/src/presentation/cubits/thali_selection/thali_selection_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'thali_selection_state.dart';

class ThaliSelectionCubit extends Cubit<ThaliSelectionState> {
  final MealRepository mealRepository;
  
  ThaliSelectionCubit({
    required this.mealRepository,
  }) : super(ThaliSelectionInitial());
  
  // Load available thali options for a specific meal type
  Future<void> loadThaliOptions(MealType mealType, DayOfWeek day) async {
    emit(ThaliSelectionLoading());
    
    try {
      final result = await mealRepository.getThaliOptions(mealType);
      
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