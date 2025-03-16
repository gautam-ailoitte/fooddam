import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';


class CreatePlanUseCase implements UseCaseWithParams<Plan, Plan> {
  final PlanRepository planRepository;

  CreatePlanUseCase({required this.planRepository});

  @override
  Future<Either<Failure, Plan>> call(Plan templatePlan) {
    return planRepository.createPlan(templatePlan);
  }
}