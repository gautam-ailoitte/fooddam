
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class CreateSubscriptionUseCase implements UseCaseWithParams<Subscription, MealPlanSelection> {
  final SubscriptionRepository repository;

  CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(MealPlanSelection params) {
    return repository.createSubscription(params);
  }
}
