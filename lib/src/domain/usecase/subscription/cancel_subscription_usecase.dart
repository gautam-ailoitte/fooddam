// lib/src/domain/usecase/subscription/cancel_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class CancelSubscriptionParams {
  final String subscriptionId;
  final String reason;

  CancelSubscriptionParams({
    required this.subscriptionId,
    required this.reason,
  });
}

class CancelSubscriptionUseCase
    extends UseCaseWithParams<Subscription, CancelSubscriptionParams> {
  final SubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(CancelSubscriptionParams params) {
    return repository.cancelSubscription(params.subscriptionId, params.reason);
  }
}