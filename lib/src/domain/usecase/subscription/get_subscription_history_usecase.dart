import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class GetSubscriptionHistoryUseCase extends UseCase<List<Subscription>> {
  final SubscriptionRepository repository;

  GetSubscriptionHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Subscription>>> call() {
    return repository.getSubscriptionHistory();
  }
}