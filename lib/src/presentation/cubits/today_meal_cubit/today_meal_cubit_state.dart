// lib/src/presentation/cubits/today_meal/today_meal_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

abstract class TodayMealState extends Equatable {
  const TodayMealState();
  
  @override
  List<Object?> get props => [];
}

class TodayMealInitial extends TodayMealState {}

class TodayMealLoading extends TodayMealState {}

class TodayMealLoaded extends TodayMealState {
  final List<MealOrder> orders;
  final Map<String, List<MealOrder>> ordersByType;
  final String currentMealPeriod;
  
  const TodayMealLoaded({
    required this.orders,
    required this.ordersByType,
    required this.currentMealPeriod,
  });
  
  @override
  List<Object?> get props => [orders, ordersByType, currentMealPeriod];
  
  bool get hasMealsToday => orders.isNotEmpty;
  
  bool get hasBreakfast => ordersByType['Breakfast']?.isNotEmpty ?? false;
  bool get hasLunch => ordersByType['Lunch']?.isNotEmpty ?? false;
  bool get hasDinner => ordersByType['Dinner']?.isNotEmpty ?? false;
  
  int get breakfastCount => ordersByType['Breakfast']?.length ?? 0;
  int get lunchCount => ordersByType['Lunch']?.length ?? 0;
  int get dinnerCount => ordersByType['Dinner']?.length ?? 0;
  
  bool get hasUpcomingDeliveries => 
      orders.any((order) => order.status == OrderStatus.coming);
  
  List<MealOrder> get upcomingDeliveries => 
      orders.where((order) => order.status == OrderStatus.coming).toList();
      
  List<MealOrder> get deliveredMeals => 
      orders.where((order) => order.status == OrderStatus.delivered).toList();
      
  // Has meals for the current period
  bool get hasMealsForCurrentPeriod => 
      ordersByType[currentMealPeriod]?.isNotEmpty ?? false;
  
  // Get meals for the current period
  List<MealOrder> get currentPeriodMeals => 
      ordersByType[currentMealPeriod] ?? [];
}

class TodayMealError extends TodayMealState {
  final String message;
  
  const TodayMealError(this.message);
  
  @override
  List<Object?> get props => [message];
}