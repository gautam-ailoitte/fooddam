// lib/src/presentation/cubits/menu/menu_state.dart
part of 'menu_cubit.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final DateTime selectedDate;
  final String selectedMealType;
  final List<Meal> availableMeals;
  final List<Dish> availableDishes;

  const MenuLoaded({
    required this.selectedDate,
    required this.selectedMealType,
    required this.availableMeals,
    required this.availableDishes,
  });

  @override
  List<Object> get props => [
    selectedDate,
    selectedMealType,
    availableMeals,
    availableDishes,
  ];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}