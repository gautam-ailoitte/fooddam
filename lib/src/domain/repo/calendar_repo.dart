// lib/src/domain/repo/calendar_repo.dart (NEW)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';

abstract class CalendarRepository {
  Future<Either<Failure, CalculatedPlan>> getCalculatedPlan({
    required String dietaryPreference,
    required String week,
    required DateTime startDate,
  });
}
