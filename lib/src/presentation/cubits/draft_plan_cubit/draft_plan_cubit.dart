


import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';
part 'draft_plan_state.dart';

class DraftPlanCubit extends Cubit<DraftPlanState> {
  final PlanRepository planRepository;
  
  DraftPlanCubit({required this.planRepository}) : super(DraftPlanInitial());
  
  Future<void> checkForDraft() async {
    emit(DraftPlanChecking());
    
    final result = await planRepository.getDraftPlan();
    
    result.fold(
      (failure) => emit(DraftPlanNotFound()),
      (plan) => emit(plan != null 
          ? DraftPlanAvailable(plan: plan) 
          : DraftPlanNotFound()),
    );
  }
  
  Future<void> saveDraft(Plan plan) async {
    emit(DraftPlanSaving());
    
    // Make sure it's marked as draft
    final draftPlan = plan.copyWith(isDraft: true);
    
    final result = await planRepository.cacheDraftPlan(draftPlan);
    
    result.fold(
      (failure) => emit(DraftPlanError(StringConstants.unexpectedError)),
      (_) => emit(DraftPlanSaved(plan: draftPlan)),
    );
    
    // After showing the saved state, go back to available state
    Future.delayed(Duration(milliseconds: 500), () {
      emit(DraftPlanAvailable(plan: draftPlan));
    });
  }
  
  Future<void> clearDraft() async {
    emit(DraftPlanClearing());
    
    final result = await planRepository.clearDraftPlan();
    
    result.fold(
      (failure) => emit(DraftPlanError(StringConstants.unexpectedError)),
      (_) => emit(DraftPlanNotFound()),
    );
  }
}