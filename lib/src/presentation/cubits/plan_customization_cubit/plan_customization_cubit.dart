// lib/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';

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
  

  Future<void> startCustomization(Plan templatePlan) async {
    emit(PlanCustomizationLoading());

    final result = await planRepository.createPlan(templatePlan);

    result.fold(
      (failure) =>
          emit(PlanCustomizationError(StringConstants.unexpectedError)),
      (createdPlan) async {
        // Mark as draft
        final draftPlan = createdPlan.copyWith(isDraft: true);

        // Save as draft using draft cubit
        await draftCubit.saveDraft(draftPlan);

        emit(PlanCustomizationActive(plan: draftPlan));
      },
    );
  }

  Future<void> resumeCustomization(Plan draftPlan) async {
    emit(PlanCustomizationActive(plan: draftPlan));
  }

  // Helper method to check if two thalis have the same meals
  // bool _areThaliMealsEqual(Thali thali1, Thali thali2) {
  //   if (thali1.selectedMeals.length != thali2.selectedMeals.length) {
  //     return false;
  //   }

  //   // Sort both lists by ID to ensure consistent comparison
  //   final sortedMeals1 = List<Meal>.from(thali1.selectedMeals)
  //     ..sort((a, b) => a.id.compareTo(b.id));
  //   final sortedMeals2 = List<Meal>.from(thali2.selectedMeals)
  //     ..sort((a, b) => a.id.compareTo(b.id));

  //   for (int i = 0; i < sortedMeals1.length; i++) {
  //     if (sortedMeals1[i].id != sortedMeals2[i].id) {
  //       return false;
  //     }
  //   }

  //   return true;
  // }
  
  // Helper method to check if two meal selections are equal
  bool _areSelectionsEqual(List<Meal> selection1, List<Meal> selection2) {
    if (selection1.length != selection2.length) {
      return false;
    }

    // Sort both lists by ID to ensure consistent comparison
    final sortedSelection1 = List<Meal>.from(selection1)
      ..sort((a, b) => a.id.compareTo(b.id));
    final sortedSelection2 = List<Meal>.from(selection2)
      ..sort((a, b) => a.id.compareTo(b.id));

    for (int i = 0; i < sortedSelection1.length; i++) {
      if (sortedSelection1[i].id != sortedSelection2[i].id) {
        return false;
      }
    }

    return true;
  }

  // lib/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart
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
          draftCubit.saveDraft(plan);
        },
      );
    } catch (e) {
      emit(PlanCustomizationError('Error updating meal: ${e.toString()}'));
    }
  }

 // In meal_customization_cubit.dart
Future<void> saveCustomization() async {
  if (state is! MealCustomizationActive) {
    emit(MealCustomizationError("No active customization in progress") as PlanCustomizationState);
    return;
  }

  final currentState = state as MealCustomizationActive;
  
  // Check if there are changes to save
  final hasChanges = !_areSelectionsEqual(
    currentState.originalThali.selectedMeals,
    currentState.currentSelection
  );
  
  // If no changes, complete immediately
  if (!hasChanges) {
    emit(MealCustomizationComplete(
      customizedThali: currentState.originalThali,
      day: currentState.day,
      mealType: currentState.mealType,
    ) as PlanCustomizationState);
    return;
  }
  
  // Show saving state
  emit(MealCustomizationSaving(
    originalThali: currentState.originalThali,
    currentSelection: currentState.currentSelection,
    availableMeals: currentState.availableMeals,
    day: currentState.day,
    mealType: currentState.mealType,
  ) as PlanCustomizationState);
  
  try {
    // Make sure this is a ThaliModel if your repository expects it
    final thaliToCustomize = currentState.originalThali;
    List<Meal> selectedMeals = List.from(currentState.currentSelection);
    
    // Add debug logging
    print('Customizing thali: ${thaliToCustomize.id} with ${selectedMeals.length} meals');
    
    final result = await mealRepository.customizeThali(
      thaliToCustomize,
      selectedMeals,
    );
    
    result.fold(
      (failure) {
        // Log the error for debugging
        print('Error customizing thali: ${failure.toString()}');
        emit(MealCustomizationError('Failed to save customization: ${failure.toString()}') as PlanCustomizationState);
      },
      (customizedThali) {
        // Log success
        print('Successfully customized thali: ${customizedThali.id}');
        emit(MealCustomizationComplete(
          customizedThali: customizedThali,
          day: currentState.day,
          mealType: currentState.mealType,
        ) as PlanCustomizationState);
      },
    );
  } catch (e) {
    // Catch and log any unexpected errors
    print('Exception during thali customization: ${e.toString()}');
    emit(MealCustomizationError('An unexpected error occurred: ${e.toString()}') as PlanCustomizationState);
  }
} void reset() {
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
