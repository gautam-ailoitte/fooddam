// lib/src/domain/usecases/thali/select_thali_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';


class SelectThaliParams extends Equatable {
  final Thali thali;
  final DayOfWeek day;
  final MealType mealType;

  const SelectThaliParams({
    required this.thali,
    required this.day,
    required this.mealType,
  });

  @override
  List<Object?> get props => [thali, day, mealType];
}

class SelectThaliUseCase implements UseCaseWithParams<Thali, SelectThaliParams> {
  final MealRepository mealRepository;

  SelectThaliUseCase({required this.mealRepository});

  @override
  Future<Either<Failure, Thali>> call(SelectThaliParams params) async {
    // In a real implementation, we might handle validation or additional logic
    // For now, we just return the selected thali
    return Right(params.thali);
  }
}