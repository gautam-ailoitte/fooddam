

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetMealsByTypeUseCase implements UseCaseWithParams<List<Meal>, String> {
  final MealRepository repository;

  GetMealsByTypeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(String params) {
    return repository.getMealsByType(params);
  }
}