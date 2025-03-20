import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class GetActiveSubscriptionsUseCase implements UseCase<List<Subscription>> {
  final SubscriptionRepository repository;

  GetActiveSubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Subscription>>> call() {
    return repository.getActiveSubscriptions();
  }
}
