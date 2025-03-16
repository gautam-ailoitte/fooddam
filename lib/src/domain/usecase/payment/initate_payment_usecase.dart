import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class InitiatePaymentUseCase implements UseCaseWithParams<String, Plan> {
  final PlanRepository planRepository;

  InitiatePaymentUseCase({required this.planRepository});

  @override
  Future<Either<Failure, String>> call(Plan plan) {
    return planRepository.savePlanAndGetPaymentUrl(plan);
  }
}