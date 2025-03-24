// lib/src/presentation/cubits/subscription/subscription_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class SubscriptionDetailState extends Equatable {
  const SubscriptionDetailState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionDetailInitial extends SubscriptionDetailState {}

class SubscriptionDetailLoading extends SubscriptionDetailState {}

class SubscriptionDetailActionInProgress extends SubscriptionDetailState {
  final String action;
  
  const SubscriptionDetailActionInProgress(this.action);
  
  @override
  List<Object?> get props => [action];
}

class SubscriptionDetailLoaded extends SubscriptionDetailState {
  final Subscription subscription;
  final List<MealOrder>? upcomingOrders;
  final int daysRemaining;
  final Map<String, Map<String, List<MealOrder>>>? ordersByDayAndType;
  
  const SubscriptionDetailLoaded({
    required this.subscription,
    this.upcomingOrders,
    required this.daysRemaining,
    this.ordersByDayAndType,
  });
  
  @override
  List<Object?> get props => [
    subscription, 
    upcomingOrders, 
    daysRemaining,
    ordersByDayAndType,
  ];
  
  bool get canBePaused => 
    subscription.status == SubscriptionStatus.active && 
    !subscription.isPaused;
    
  bool get canBeResumed => 
    subscription.status == SubscriptionStatus.active && 
    subscription.isPaused;
    
  bool get canBeCancelled =>
    subscription.status == SubscriptionStatus.active ||
    subscription.status == SubscriptionStatus.paused;
    
  bool get isActive => 
    subscription.status == SubscriptionStatus.active && 
    !subscription.isPaused;
    
  bool get isPaused => 
    subscription.status == SubscriptionStatus.paused || 
    subscription.isPaused;
    
  bool get isCancelled => 
    subscription.status == SubscriptionStatus.cancelled;
    
  bool get isExpired => 
    subscription.status == SubscriptionStatus.expired;
  
  // Helper to check if orders are available
  bool get hasOrders => upcomingOrders != null && upcomingOrders!.isNotEmpty;
  
  // Get the number of upcoming deliveries
  int get upcomingDeliveryCount => upcomingOrders?.length ?? 0;
}

class SubscriptionDetailActionSuccess extends SubscriptionDetailState {
  final String action;
  final String message;
  
  const SubscriptionDetailActionSuccess({
    required this.action,
    required this.message,
  });
  
  @override
  List<Object?> get props => [action, message];
}

class SubscriptionDetailError extends SubscriptionDetailState {
  final String message;
  
  const SubscriptionDetailError(this.message);
  
  @override
  List<Object?> get props => [message];
}