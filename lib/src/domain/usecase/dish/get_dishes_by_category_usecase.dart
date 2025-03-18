// lib/src/domain/usecase/dish/get_dishes_by_category_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class GetDishesByCategoryUseCase extends UseCaseWithParams<List<Dish>, FoodCategory> {
  final DishRepository repository;

  GetDishesByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call(FoodCategory category) {
    return repository.getDishesByCategory(category);
  }
}