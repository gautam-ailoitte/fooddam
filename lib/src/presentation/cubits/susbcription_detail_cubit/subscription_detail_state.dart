// lib/src/presentation/cubits/subscription/subscription_details_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';

abstract class SubscriptionDetailsState extends Equatable {
  const SubscriptionDetailsState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionDetailsInitial extends SubscriptionDetailsState {}

class SubscriptionDetailsLoading extends SubscriptionDetailsState {}

class SubscriptionDetailsActionInProgress extends SubscriptionDetailsState {
  final String action;
  
  const SubscriptionDetailsActionInProgress(this.action);
  
  @override
  List<Object?> get props => [action];
}

class SubscriptionDetailsLoaded extends SubscriptionDetailsState {
  final Subscription subscription;
  final List<MealOrder>? upcomingOrders;
  final int daysRemaining;
  final int totalMeals;
  final int consumedMeals;
  
  const SubscriptionDetailsLoaded({
    required this.subscription,
    this.upcomingOrders,
    required this.daysRemaining,
    required this.totalMeals,
    required this.consumedMeals,
  });
  
  @override
  List<Object?> get props => [subscription, upcomingOrders, daysRemaining, totalMeals, consumedMeals];
}

class SubscriptionDetailsActionSuccess extends SubscriptionDetailsState {
  final String action;
  final String message;
  
  const SubscriptionDetailsActionSuccess({
    required this.action,
    required this.message,
  });
  
  @override
  List<Object?> get props => [action, message];
}

class SubscriptionDetailsError extends SubscriptionDetailsState {
  final String message;
  
  const SubscriptionDetailsError(this.message);
  
  @override
  List<Object?> get props => [message];
}