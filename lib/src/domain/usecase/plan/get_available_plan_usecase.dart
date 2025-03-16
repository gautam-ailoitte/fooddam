import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';


class GetAvailablePlansUseCase implements UseCase<List<Plan>> {
  final PlanRepository planRepository;

  GetAvailablePlansUseCase({required this.planRepository});

  @override
  Future<Either<Failure, List<Plan>>> call() {
    return planRepository.getAvailablePlans();
  }
}