// lib/src/domain/usecase/dish/get_dishes_by_dietary_preference_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class GetDishesByDietaryPreferenceUseCase extends UseCaseWithParams<List<Dish>, DietaryPreference> {
  final DishRepository repository;

  GetDishesByDietaryPreferenceUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call(DietaryPreference preference) {
    return repository.getDishesByDietaryPreference(preference);
  }
}