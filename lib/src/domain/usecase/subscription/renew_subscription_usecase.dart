// lib/src/domain/usecase/subscription/renew_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class RenewSubscriptionUseCase extends UseCaseWithParams<Subscription, String> {
  final SubscriptionRepository repository;

  RenewSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(String subscriptionId) {
    return repository.renewSubscription(subscriptionId);
  }
}