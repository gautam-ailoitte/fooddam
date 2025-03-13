part of 'active_plan_cubit.dart';




abstract class ActivePlanState extends Equatable {
  const ActivePlanState();
  
  @override
  List<Object?> get props => [];
}

class ActivePlanInitial extends ActivePlanState {}

class ActivePlanLoading extends ActivePlanState {}

class ActivePlanLoaded extends ActivePlanState {
  final Plan activePlan;
  
  const ActivePlanLoaded({required this.activePlan});
  
  @override
  List<Object?> get props => [activePlan];
}

class ActivePlanNotFound extends ActivePlanState {}

class ActivePlanError extends ActivePlanState {
  final String message;
  
  const ActivePlanError(this.message);
  
  @override
  List<Object?> get props => [message];
}