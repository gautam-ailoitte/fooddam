// lib/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/usecase/plan/clear_draft_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/get_draft_plan_usecase.dart';
import 'package:foodam/src/domain/usecase/plan/save_draft_plan_usecase.dart';
part 'draft_plan_state.dart';

class DraftPlanCubit extends Cubit<DraftPlanState> {
  final GetDraftPlanUseCase getDraftPlanUseCase;
  final SaveDraftPlanUseCase saveDraftPlanUseCase;
  final ClearDraftPlanUseCase clearDraftPlanUseCase;
  
  DraftPlanCubit({
    required this.getDraftPlanUseCase,
    required this.saveDraftPlanUseCase,
    required this.clearDraftPlanUseCase,
  }) : super(DraftPlanInitial());
  
  // Check if a draft plan exists
  Future<void> checkForDraft() async {
    emit(DraftPlanChecking());
    
    try {
      final result = await getDraftPlanUseCase();
      
      result.fold(
        (failure) => emit(DraftPlanNotFound()),
        (plan) => emit(plan != null 
            ? DraftPlanAvailable(plan: plan) 
            : DraftPlanNotFound()),
      );
    } catch (e) {
      emit(DraftPlanError('Error checking for draft plan: ${e.toString()}'));
    }
  }
  
  // Save a plan as draft
  Future<void> saveDraft(Plan plan) async {
    emit(DraftPlanSaving());
    
    try {
      // Make sure it's marked as draft
      final draftPlan = plan.copyWith(isDraft: true);
      
      final result = await saveDraftPlanUseCase(draftPlan);
      
      result.fold(
        (failure) => emit(DraftPlanError(StringConstants.unexpectedError)),
        (_) => emit(DraftPlanSaved(plan: draftPlan)),
      );
      
      // After briefly showing the saved state, go back to available state
      await Future.delayed(Duration(milliseconds: 500));
      emit(DraftPlanAvailable(plan: draftPlan));
    } catch (e) {
      emit(DraftPlanError('Error saving draft plan: ${e.toString()}'));
    }
  }
  
  // Clear the draft plan
  Future<void> clearDraft() async {
    emit(DraftPlanClearing());
    
    try {
      final result = await clearDraftPlanUseCase();
      
      result.fold(
        (failure) => emit(DraftPlanError(StringConstants.unexpectedError)),
        (_) => emit(DraftPlanNotFound()),
      );
    } catch (e) {
      emit(DraftPlanError('Error clearing draft plan: ${e.toString()}'));
    }
  }
  
  // Update an existing draft plan
  Future<void> updateDraft(Plan plan) async {
    if (state is DraftPlanAvailable) {
      emit(DraftPlanSaving());
      
      try {
        // Ensure its marked as draft
        final updatedPlan = plan.copyWith(isDraft: true);
        
        final result = await saveDraftPlanUseCase(updatedPlan);
        
        result.fold(
          (failure) => emit(DraftPlanError(StringConstants.unexpectedError)),
          (_) {
            emit(DraftPlanSaved(plan: updatedPlan));
            
            // After briefly showing the saved state, go back to available state
            Future.delayed(Duration(milliseconds: 500), () {
              emit(DraftPlanAvailable(plan: updatedPlan));
            });
          },
        );
      } catch (e) {
        emit(DraftPlanError('Error updating draft plan: ${e.toString()}'));
      }
    }
  }
}