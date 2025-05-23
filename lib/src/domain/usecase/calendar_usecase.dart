// lib/src/domain/usecase/calendar_usecase.dart (NEW)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/repo/calendar_repo.dart';

class CalendarUseCase {
  final CalendarRepository repository;

  CalendarUseCase(this.repository);

  /// Get calculated meal plan based on preferences and dates
  Future<Either<Failure, CalculatedPlan>> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  }) {
    return repository.getCalculatedPlan(
      dietaryPreference: dietaryPreference,
      week: week,
      startDate: startDate,
    );
  }

  /// Get vegetarian plan for specific week and date
  Future<Either<Failure, CalculatedPlan>> getVegetarianPlan({
    required int week,
    required DateTime startDate,
  }) {
    return repository.getCalculatedPlan(
      dietaryPreference: 'vegetarian',
      week: week,
      startDate: startDate,
    );
  }

  /// Get non-vegetarian plan for specific week and date
  Future<Either<Failure, CalculatedPlan>> getNonVegetarianPlan({
    required int week,
    required DateTime startDate,
  }) {
    return repository.getCalculatedPlan(
      dietaryPreference: 'non-vegetarian',
      week: week,
      startDate: startDate,
    );
  }

  /// Get meal plan starting from today
  Future<Either<Failure, CalculatedPlan>> getPlanStartingToday({
    required String dietaryPreference,
    required int week,
  }) {
    final today = DateTime.now();
    // Reset time to start of day
    final startDate = DateTime(today.year, today.month, today.day);

    return repository.getCalculatedPlan(
      dietaryPreference: dietaryPreference,
      week: week,
      startDate: startDate,
    );
  }
}
