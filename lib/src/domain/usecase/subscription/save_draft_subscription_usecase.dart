// lib/src/domain/usecase/subscription/save_draft_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class SaveDraftSubscriptionUseCase extends UseCaseWithParams<Subscription, Subscription> {
  final SubscriptionRepository repository;

  SaveDraftSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(Subscription subscription) {
    return repository.saveDraftSubscription(subscription);
  }
}