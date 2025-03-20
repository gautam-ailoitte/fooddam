// lib/src/presentation/cubits/today_meals/today_meals_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

abstract class TodayMealsState extends Equatable {
  const TodayMealsState();
  
  @override
  List<Object?> get props => [];
}

class TodayMealsInitial extends TodayMealsState {}

class TodayMealsLoading extends TodayMealsState {}

class TodayMealsLoaded extends TodayMealsState {
  final List<MealOrder> orders;
  final Map<String, List<MealOrder>> ordersByType;
  
  const TodayMealsLoaded({
    required this.orders,
    required this.ordersByType,
  });
  
  @override
  List<Object?> get props => [orders, ordersByType];
}

class TodayMealsError extends TodayMealsState {
  final String message;
  
  const TodayMealsError(this.message);
  
  @override
  List<Object?> get props => [message];
}