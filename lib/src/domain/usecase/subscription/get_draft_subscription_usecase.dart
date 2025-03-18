// lib/src/domain/usecase/subscription/get_draft_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class GetDraftSubscriptionUseCase extends UseCase<Subscription?> {
  final SubscriptionRepository repository;

  GetDraftSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription?>> call() {
    return repository.getDraftSubscription();
  }
}