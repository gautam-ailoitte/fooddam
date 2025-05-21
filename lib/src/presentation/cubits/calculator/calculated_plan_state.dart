// lib/src/presentation/cubits/calculator/calculated_plan_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';

abstract class CalculatedPlanState extends Equatable {
  const CalculatedPlanState();

  @override
  List<Object?> get props => [];
}

class CalculatedPlanInitial extends CalculatedPlanState {}

class CalculatedPlanLoading extends CalculatedPlanState {}

class CalculatedPlanError extends CalculatedPlanState {
  final String message;

  const CalculatedPlanError(this.message);

  @override
  List<Object?> get props => [message];
}

class CalculatedPlanLoaded extends CalculatedPlanState {
  final CalculatedPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;

  const CalculatedPlanLoaded({
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
  });

  @override
  List<Object?> get props => [plan, startDate, endDate, durationDays];
}
