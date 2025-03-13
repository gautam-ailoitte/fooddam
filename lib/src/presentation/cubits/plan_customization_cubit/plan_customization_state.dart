// lib/src/presentation/cubits/plan_customization_cubit/plan_customization_state.dart
part of 'plan_customization_cubit.dart';

abstract class PlanCustomizationState extends Equatable {
  const PlanCustomizationState();
  
  @override
  List<Object?> get props => [];
}

class PlanCustomizationInitial extends PlanCustomizationState {}

// Base class for active states that contain a plan
abstract class PlanCustomizationStateWithPlan extends PlanCustomizationState {
  final Plan plan;
  
  const PlanCustomizationStateWithPlan({required this.plan});
  
  @override
  List<Object?> get props => [plan];
}

// Loading state with plan
class PlanCustomizationLoading extends PlanCustomizationState {}

// Active editing state
class PlanCustomizationActive extends PlanCustomizationStateWithPlan {
  const PlanCustomizationActive({required super.plan});
}

// Completed state
class PlanCustomizationCompleted extends PlanCustomizationStateWithPlan {
  const PlanCustomizationCompleted({required super.plan});
}

// Error state
class PlanCustomizationError extends PlanCustomizationState {
  final String message;
  
  const PlanCustomizationError(this.message);
  
  @override
  List<Object?> get props => [message];
}