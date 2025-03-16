import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';


class SaveDraftPlanUseCase implements UseCaseWithParams<void, Plan> {
  final PlanRepository planRepository;

  SaveDraftPlanUseCase({required this.planRepository});

  @override
  Future<Either<Failure, void>> call(Plan plan) {
    return planRepository.cacheDraftPlan(plan);
  }
}