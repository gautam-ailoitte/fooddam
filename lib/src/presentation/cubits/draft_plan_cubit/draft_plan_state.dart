
part of 'draft_plan_cubit.dart';

abstract class DraftPlanState extends Equatable {
  const DraftPlanState();
  
  @override
  List<Object?> get props => [];
}

class DraftPlanInitial extends DraftPlanState {}

class DraftPlanChecking extends DraftPlanState {}

class DraftPlanAvailable extends DraftPlanState {
  final Plan plan;
  
  const DraftPlanAvailable({required this.plan});
  
  @override
  List<Object?> get props => [plan];
}

class DraftPlanNotFound extends DraftPlanState {}

class DraftPlanSaving extends DraftPlanState {}

class DraftPlanSaved extends DraftPlanState {
  final Plan plan;
  
  const DraftPlanSaved({required this.plan});
  
  @override
  List<Object?> get props => [plan];
}

class DraftPlanClearing extends DraftPlanState {}

class DraftPlanError extends DraftPlanState {
  final String message;
  
  const DraftPlanError(this.message);
  
  @override
  List<Object?> get props => [message];
}