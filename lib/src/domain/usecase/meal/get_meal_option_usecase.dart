import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repository.dart';


class GetMealOptionsUseCase implements UseCaseWithParams<List<Meal>, MealType> {
  final MealRepository mealRepository;

  GetMealOptionsUseCase({required this.mealRepository});

  @override
  Future<Either<Failure, List<Meal>>> call(MealType mealType) {
    return mealRepository.getMealOptions(mealType);
  }
}