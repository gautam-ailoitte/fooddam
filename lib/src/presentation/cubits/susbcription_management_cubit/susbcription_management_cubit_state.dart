// lib/src/presentation/cubits/subscription/active_subscriptions_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';

abstract class ActiveSubscriptionsState extends Equatable {
  const ActiveSubscriptionsState();
  
  @override
  List<Object?> get props => [];
}

class ActiveSubscriptionsInitial extends ActiveSubscriptionsState {}

class ActiveSubscriptionsLoading extends ActiveSubscriptionsState {}

class ActiveSubscriptionsLoaded extends ActiveSubscriptionsState {
  final List<Subscription> subscriptions;
  final List<Subscription> activeSubscriptions;
  final List<Subscription> pausedSubscriptions;
  
  const ActiveSubscriptionsLoaded({
    required this.subscriptions,
    required this.activeSubscriptions,
    required this.pausedSubscriptions,
  });
  
  @override
  List<Object?> get props => [subscriptions, activeSubscriptions, pausedSubscriptions];
}

class ActiveSubscriptionsError extends ActiveSubscriptionsState {
  final String message;
  
  const ActiveSubscriptionsError(this.message);
  
  @override
  List<Object?> get props => [message];
}