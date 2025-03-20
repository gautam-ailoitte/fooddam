import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class GetMealOrdersBySubscriptionUseCase implements UseCaseWithParams<List<MealOrder>, String> {
  final SubscriptionRepository repository;

  GetMealOrdersBySubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, List<MealOrder>>> call(String params) {
    return repository.getMealOrdersBySubscription(params);
  }
}