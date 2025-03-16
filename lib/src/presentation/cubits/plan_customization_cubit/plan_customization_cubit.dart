// lib/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/usecase/plan/create_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/customize_plan_usecase.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';

part 'plan_customization_state.dart';

class PlanCustomizationCubit extends Cubit<PlanCustomizationState> {
  final CreatePlanUseCase createPlanUseCase;
  final CustomizePlanUseCase customizePlanUseCase;
  final DraftPlanCubit draftCubit;

  PlanCustomizationCubit({
    required this.createPlanUseCase,
    required this.customizePlanUseCase,
    required this.draftCubit,
  }) : super(PlanCustomizationInitial());

  // Start customization with a template plan
  Future<void> startCustomization(Plan templatePlan) async {
    emit(PlanCustomizationLoading());

    final result = await createPlanUseCase(templatePlan);

    result.fold(
      (failure) => emit(PlanCustomizationError(StringConstants.unexpectedError)),
      (createdPlan) async {
        // Mark as draft
        final draftPlan = createdPlan.copyWith(isDraft: true);

        // Save as draft using draft cubit
        await draftCubit.saveDraft(draftPlan);

        emit(PlanCustomizationActive(plan: draftPlan));
      },
    );
  }

  // Resume customization with an existing draft plan
  void resumeCustomization(Plan draftPlan) {
    emit(PlanCustomizationActive(plan: draftPlan));
  }

  // Update a meal in the plan
  Future<void> updateMeal({
    required DayOfWeek day,
    required MealType mealType,
    required Thali thali,
  }) async {
    final currentState = state;
    if (currentState is! PlanCustomizationActive) {
      emit(PlanCustomizationError("No plan is currently being customized"));
      return;
    }

    final currentPlan = currentState.plan;
    emit(PlanCustomizationLoading());

    try {
      // Create the params for the use case
      final params = UpdatePlanMealParams(
        plan: currentPlan,
        day: day,
        mealType: mealType,
        thali: thali,
      );

      // Call the use case
      final result = await customizePlanUseCase(params);

      result.fold(
        (failure) => emit(PlanCustomizationError('Failed to update meal')),
        (updatedPlan) {
          emit(PlanCustomizationActive(plan: updatedPlan));
          // Save draft to ensure persistence
          draftCubit.saveDraft(updatedPlan);
        },
      );
    } catch (e) {
      emit(PlanCustomizationError('Error updating meal: ${e.toString()}'));
    }
  }

  // Save the customized plan and complete the process
  Future<void> saveCustomization() async {
    final currentState = state;
    if (currentState is! PlanCustomizationActive) {
      emit(PlanCustomizationError("No plan is currently being customized"));
      return;
    }

    try {
      final plan = currentState.plan;
      
      // Mark as non-draft for final submission
      final finalPlan = plan.copyWith(isDraft: false);
      
      // Emit the completed state
      emit(PlanCustomizationCompleted(plan: finalPlan));
      
      // Clear draft since we're completing the customization
      await draftCubit.clearDraft();
    } catch (e) {
      emit(PlanCustomizationError('Error saving customization: ${e.toString()}'));
    }
  }

  // Reset the customization state
  void reset() {
    emit(PlanCustomizationInitial());
  }

  // Get current plan if available
  Plan? getCurrentPlan() {
    if (state is PlanCustomizationActive) {
      return (state as PlanCustomizationActive).plan;
    }
    return null;
  }
}