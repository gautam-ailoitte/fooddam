
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class GetSubscriptionPlansUseCase implements UseCase<List<SubscriptionPlan>> {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> call() {
    return repository.getSubscriptionPlans();
  }
}