// lib/src/domain/usecases/plan/customize_plan_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class UpdatePlanMealParams extends Equatable {
  final Plan plan;
  final DayOfWeek day;
  final MealType mealType;
  final Thali thali;

  const UpdatePlanMealParams({
    required this.plan,
    required this.day,
    required this.mealType,
    required this.thali,
  });

  @override
  List<Object?> get props => [plan, day, mealType, thali];
}

class CustomizePlanUseCase implements UseCaseWithParams<Plan, UpdatePlanMealParams> {
  final PlanRepository planRepository;

  CustomizePlanUseCase({required this.planRepository});

  @override
  Future<Either<Failure, Plan>> call(UpdatePlanMealParams params) {
    // Use the repository's updateMealInPlan method directly
    return planRepository.updateMealInPlan(
      plan: params.plan,
      day: params.day,
      type: params.mealType,
      thali: params.thali,
    );
  }
}