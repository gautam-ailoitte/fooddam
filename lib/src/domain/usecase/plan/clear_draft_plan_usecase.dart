import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class ClearDraftPlanUseCase implements UseCaseNoParamsNoReturn {
  final PlanRepository planRepository;

  ClearDraftPlanUseCase({required this.planRepository});

  @override
  Future<Either<Failure, void>> call() {
    return planRepository.clearDraftPlan();
  }
}
