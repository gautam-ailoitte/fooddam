// lib/src/domain/usecase/subscription/clear_draft_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class ClearDraftSubscriptionUseCase extends UseCaseNoParamsNoReturn {
  final SubscriptionRepository repository;

  ClearDraftSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() {
    return repository.clearDraftSubscription();
  }
}