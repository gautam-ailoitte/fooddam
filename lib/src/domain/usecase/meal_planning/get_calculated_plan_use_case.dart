// lib/src/domain/usecases/meal_planning/get_calculated_plan_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/domain/repo/meal_planning_repository.dart';

class GetCalculatedPlanUseCase
    implements UseCaseWithParams<CalculatedPlan, GetCalculatedPlanParams> {
  final MealPlanningRepository repository;

  const GetCalculatedPlanUseCase(this.repository);

  @override
  Future<Either<Failure, CalculatedPlan>> call(
    GetCalculatedPlanParams params,
  ) async {
    return await repository.getCalculatedPlan(
      dietaryPreference: params.dietaryPreference,
      week: params.week,
      startDate: params.startDate,
    );
  }
}

class GetCalculatedPlanParams extends Equatable {
  final String dietaryPreference;
  final int week;
  final DateTime startDate;

  const GetCalculatedPlanParams({
    required this.dietaryPreference,
    required this.week,
    required this.startDate,
  });

  @override
  List<Object> get props => [dietaryPreference, week, startDate];
}
