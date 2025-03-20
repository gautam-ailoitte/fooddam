// lib/src/presentation/cubits/subscription/subscription_plans_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

abstract class SubscriptionPlansState extends Equatable {
  const SubscriptionPlansState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionPlansInitial extends SubscriptionPlansState {}

class SubscriptionPlansLoading extends SubscriptionPlansState {}

class SubscriptionPlansLoaded extends SubscriptionPlansState {
  final List<SubscriptionPlan> plans;
  final List<SubscriptionPlan> filteredPlans;
  final String? currentFilter;
  
  const SubscriptionPlansLoaded({
    required this.plans,
    required this.filteredPlans,
    this.currentFilter,
  });
  
  @override
  List<Object?> get props => [plans, filteredPlans, currentFilter];
}

class SubscriptionPlansError extends SubscriptionPlansState {
  final String message;
  
  const SubscriptionPlansError(this.message);
  
  @override
  List<Object?> get props => [message];
}