// lib/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';

part 'plan_customization_state.dart';

class PlanCustomizationCubit extends Cubit<PlanCustomizationState> {
  final PlanRepository planRepository;
  final DraftPlanCubit draftCubit;
  final MealRepository mealRepository;

  PlanCustomizationCubit({
    required this.planRepository,
    required this.draftCubit,
    required this.mealRepository,
  }) : super(PlanCustomizationInitial());

  // Start customization with a template plan
  Future<void> startCustomization(Plan templatePlan) async {
    emit(PlanCustomizationLoading());

    final result = await planRepository.createPlan(templatePlan);

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
  Future<void> resumeCustomization(Plan draftPlan) async {
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
      // Get current daily meals
      final updatedMealsByDay = Map<DayOfWeek, DailyMeals>.from(
        currentPlan.mealsByDay,
      );
      final currentDailyMeals = updatedMealsByDay[day] ?? DailyMealsModel();

      // Create a properly typed update
      DailyMealsModel updatedDailyMeals;

      // Build the updated daily meals
      if (currentDailyMeals is DailyMealsModel) {
        // If it's already a DailyMealsModel, use it as is
        switch (mealType) {
          case MealType.breakfast:
            updatedDailyMeals = DailyMealsModel(
              breakfast: thali,
              lunch: currentDailyMeals.lunch,
              dinner: currentDailyMeals.dinner,
            );
            break;
          case MealType.lunch:
            updatedDailyMeals = DailyMealsModel(
              breakfast: currentDailyMeals.breakfast,
              lunch: thali,
              dinner: currentDailyMeals.dinner,
            );
            break;
          case MealType.dinner:
            updatedDailyMeals = DailyMealsModel(
              breakfast: currentDailyMeals.breakfast,
              lunch: currentDailyMeals.lunch,
              dinner: thali,
            );
            break;
        }
      } else {
        // If it's not a DailyMealsModel, create a new one
        switch (mealType) {
          case MealType.breakfast:
            updatedDailyMeals = DailyMealsModel(
              breakfast: thali,
              lunch: null,
              dinner: null,
            );
            break;
          case MealType.lunch:
            updatedDailyMeals = DailyMealsModel(
              breakfast: null,
              lunch: thali,
              dinner: null,
            );
            break;
          case MealType.dinner:
            updatedDailyMeals = DailyMealsModel(
              breakfast: null,
              lunch: null,
              dinner: thali,
            );
            break;
        }
      }

      // Update the map
      updatedMealsByDay[day] = updatedDailyMeals;

      // Create updated plan
      final updatedPlan = currentPlan.copyWith(
        mealsByDay: updatedMealsByDay,
        isCustomized: true,
        isDraft: true,
      );

      // Save plan
      final result = await planRepository.customizePlan(updatedPlan);

      result.fold(
        (failure) => emit(PlanCustomizationError('Failed to update meal')),
        (plan) {
          emit(PlanCustomizationActive(plan: plan));
          // Save draft to ensure persistence
          draftCubit.saveDraft(plan);
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