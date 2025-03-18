// lib/src/domain/usecase/subscription/pause_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class PauseSubscriptionParams {
  final String subscriptionId;
  final DateTime resumeDate;

  PauseSubscriptionParams({
    required this.subscriptionId,
    required this.resumeDate,
  });
}

class PauseSubscriptionUseCase
    extends UseCaseWithParams<Subscription, PauseSubscriptionParams> {
  final SubscriptionRepository repository;

  PauseSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(PauseSubscriptionParams params) {
    return repository.pauseSubscription(params.subscriptionId, params.resumeDate);
  }
}