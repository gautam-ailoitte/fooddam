part of 'plan_browse_cubit.dart';


abstract class PlanBrowseState extends Equatable {
  const PlanBrowseState();
  
  @override
  List<Object?> get props => [];
}

class PlanBrowseInitial extends PlanBrowseState {}

class PlanBrowseLoading extends PlanBrowseState {}

class PlanBrowseLoaded extends PlanBrowseState {
  final List<Plan> plans;
  final Plan? selectedPlan;
  
  const PlanBrowseLoaded({
    required this.plans,
    this.selectedPlan,
  });
  
  @override
  List<Object?> get props => [plans, selectedPlan];
}

class PlanBrowseError extends PlanBrowseState {
  final String message;
  
  const PlanBrowseError(this.message);
  
  @override
  List<Object?> get props => [message];
}