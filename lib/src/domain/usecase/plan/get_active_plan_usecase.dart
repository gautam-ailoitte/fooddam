import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class GetActivePlanUseCase implements UseCase<Plan?> {
  final PlanRepository planRepository;

  GetActivePlanUseCase({required this.planRepository});

  @override
  Future<Either<Failure, Plan?>> call() {
    return planRepository.getActivePlan();
  }
}