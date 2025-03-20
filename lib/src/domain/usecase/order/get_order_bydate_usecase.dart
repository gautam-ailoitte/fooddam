import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class GetMealOrdersByDateUseCase implements UseCaseWithParams<List<MealOrder>, DateTime> {
  final SubscriptionRepository repository;

  GetMealOrdersByDateUseCase(this.repository);

  @override
  Future<Either<Failure, List<MealOrder>>> call(DateTime params) {
    return repository.getMealOrdersByDate(params);
  }
}
