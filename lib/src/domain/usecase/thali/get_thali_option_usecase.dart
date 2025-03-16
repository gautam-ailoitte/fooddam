import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/repo/meal_repository.dart';


class GetThaliOptionsUseCase implements UseCaseWithParams<List<Thali>, MealType> {
  final MealRepository mealRepository;

  GetThaliOptionsUseCase({required this.mealRepository});

  @override
  Future<Either<Failure, List<Thali>>> call(MealType mealType) {
    return mealRepository.getThaliOptions(mealType);
  }
}