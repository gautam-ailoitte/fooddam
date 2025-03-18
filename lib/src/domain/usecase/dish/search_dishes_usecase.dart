// lib/src/domain/usecase/dish/search_dishes_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class SearchDishesUseCase extends UseCaseWithParams<List<Dish>, String> {
  final DishRepository repository;

  SearchDishesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call(String query) {
    return repository.searchDishes(query);
  }
}