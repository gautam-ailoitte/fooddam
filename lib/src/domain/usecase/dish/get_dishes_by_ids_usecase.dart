// lib/src/domain/usecase/dish/get_dishes_by_ids_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class GetDishesByIdsUseCase extends UseCaseWithParams<List<Dish>, List<String>> {
  final DishRepository repository;

  GetDishesByIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call(List<String> dishIds) {
    return repository.getDishesByIds(dishIds);
  }
}