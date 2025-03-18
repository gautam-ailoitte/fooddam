// lib/src/domain/usecase/dish/get_dish_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class GetDishByIdUseCase extends UseCaseWithParams<Dish, String> {
  final DishRepository repository;

  GetDishByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Dish>> call(String dishId) {
    return repository.getDishById(dishId);
  }
}
