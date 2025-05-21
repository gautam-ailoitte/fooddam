// lib/src/presentation/cubits/calculator/calculated_plan_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/presentation/cubits/calculator/calculated_plan_state.dart';

class CalculatedPlanCubit extends Cubit<CalculatedPlanState> {
  final CalendarUseCase _calendarUseCase;
  final LoggerService _logger = LoggerService();

  CalculatedPlanCubit({required CalendarUseCase calendarUseCase})
    : _calendarUseCase = calendarUseCase,
      super(CalculatedPlanInitial());

  /// Get calculated plan based on preferences and dates
  Future<void> getCalculatedPlan({
    required String dietaryPreference,
    required String week,
    required DateTime startDate,
    required int durationDays,
  }) async {
    emit(CalculatedPlanLoading());

    final result = await _calendarUseCase.getCalculatedPlan(
      dietaryPreference: dietaryPreference,
      week: week,
      startDate: startDate,
    );

    result.fold(
      (failure) {
        _logger.e('Failed to get calculated plan', error: failure);
        emit(
          CalculatedPlanError(
            failure.message ?? 'Failed to generate meal plan',
          ),
        );
      },
      (plan) {
        _logger.i('Loaded calculated plan for $durationDays days');

        // Calculate end date based on duration
        final endDate = startDate.add(Duration(days: durationDays - 1));

        emit(
          CalculatedPlanLoaded(
            plan: plan,
            startDate: startDate,
            endDate: endDate,
            durationDays: durationDays,
          ),
        );
      },
    );
  }
}
