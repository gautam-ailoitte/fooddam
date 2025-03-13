// lib/src/presentation/cubits/thali_selection/thali_selection_state.dart
part of 'thali_selection_cubit.dart';

abstract class ThaliSelectionState extends Equatable {
  const ThaliSelectionState();
  
  @override
  List<Object?> get props => [];
}

class ThaliSelectionInitial extends ThaliSelectionState {}

class ThaliSelectionLoading extends ThaliSelectionState {}

class ThaliOptionsLoaded extends ThaliSelectionState {
  final List<Thali> thaliOptions;
  final MealType mealType;
  final DayOfWeek day;
  
  const ThaliOptionsLoaded({
    required this.thaliOptions,
    required this.mealType,
    required this.day,
  });
  
  @override
  List<Object?> get props => [thaliOptions, mealType, day];
}

class ThaliSelected extends ThaliSelectionState {
  final Thali selectedThali;
  final MealType mealType;
  final DayOfWeek day;
  
  const ThaliSelected({
    required this.selectedThali,
    required this.mealType,
    required this.day,
  });
  
  @override
  List<Object?> get props => [selectedThali, mealType, day];
}

class ThaliSelectionError extends ThaliSelectionState {
  final String message;
  
  const ThaliSelectionError(this.message);
  
  @override
  List<Object?> get props => [message];
}