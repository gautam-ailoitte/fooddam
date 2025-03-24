// lib/src/presentation/cubits/subscription/active_subscription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class ActiveSubscriptionState extends Equatable {
  const ActiveSubscriptionState();
  
  @override
  List<Object?> get props => [];
}

class ActiveSubscriptionInitial extends ActiveSubscriptionState {}

class ActiveSubscriptionLoading extends ActiveSubscriptionState {}

class ActiveSubscriptionLoaded extends ActiveSubscriptionState {
  final List<Subscription> subscriptions;
  final List<Subscription> activeSubscriptions;
  final List<Subscription> pausedSubscriptions;
  
  const ActiveSubscriptionLoaded({
    required this.subscriptions,
    required this.activeSubscriptions,
    required this.pausedSubscriptions,
  });
  
  @override
  List<Object?> get props => [subscriptions, activeSubscriptions, pausedSubscriptions];
  
  bool get hasActiveSubscriptions => activeSubscriptions.isNotEmpty;
  bool get hasPausedSubscriptions => pausedSubscriptions.isNotEmpty;
  bool get hasAnySubscriptions => subscriptions.isNotEmpty;
}

class ActiveSubscriptionFiltered extends ActiveSubscriptionLoaded {
  final List<Subscription> filteredSubscriptions;
  final String filterType;
  final String filterValue;
  
  const ActiveSubscriptionFiltered({
    required super.subscriptions,
    required super.activeSubscriptions,
    required super.pausedSubscriptions,
    required this.filteredSubscriptions,
    required this.filterType,
    required this.filterValue,
  });
  
  @override
  List<Object?> get props => [
    ...super.props, 
    filteredSubscriptions, 
    filterType, 
    filterValue
  ];
}

class ActiveSubscriptionError extends ActiveSubscriptionState {
  final String message;
  
  const ActiveSubscriptionError(this.message);
  
  @override
  List<Object?> get props => [message];
}