import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class CustomizeThaliParams extends Equatable {
  final Thali originalThali;
  final List<Meal> selectedMeals;

  const CustomizeThaliParams({
    required this.originalThali,
    required this.selectedMeals,
  });

  @override
  List<Object?> get props => [originalThali, selectedMeals];
}

class CustomizeThaliUseCase implements UseCaseWithParams<Thali, CustomizeThaliParams> {
  final MealRepository mealRepository;

  CustomizeThaliUseCase({required this.mealRepository});

  @override
  Future<Either<Failure, Thali>> call(CustomizeThaliParams params) {
    return mealRepository.customizeThali(
      params.originalThali,
      params.selectedMeals,
    );
  }
}
