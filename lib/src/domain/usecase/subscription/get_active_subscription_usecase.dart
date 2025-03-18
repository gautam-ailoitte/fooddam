import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class GetActiveSubscriptionUseCase extends UseCase<Subscription?> {
  final SubscriptionRepository repository;

  GetActiveSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription?>> call() {
    return repository.getActiveSubscription();
  }
}