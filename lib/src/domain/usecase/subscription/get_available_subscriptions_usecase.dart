// lib/src/domain/usecase/subscription/get_available_subscriptions_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class GetAvailableSubscriptionsUseCase extends UseCase<List<Subscription>> {
  final SubscriptionRepository repository;

  GetAvailableSubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Subscription>>> call() {
    return repository.getAvailableSubscriptions();
  }
}