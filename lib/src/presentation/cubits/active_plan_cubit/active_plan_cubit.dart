// lib/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

part 'active_plan_state.dart';

class ActivePlanCubit extends Cubit<ActivePlanState> {
  final PlanRepository planRepository;
  
  ActivePlanCubit({required this.planRepository}) : super(ActivePlanInitial());
  
  // Load the user's active plan
  Future<void> loadActivePlan() async {
    emit(ActivePlanLoading());
    
    try {
      final result = await planRepository.getActivePlan();
      
      result.fold(
        (failure) => emit(ActivePlanError('Failed to load active plan')),
        (plan) => emit(plan != null 
            ? ActivePlanLoaded(activePlan: plan) 
            : ActivePlanNotFound()),
      );
    } catch (e) {
      emit(ActivePlanError('Error loading active plan: ${e.toString()}'));
    }
  }
  
  // Set an active plan (e.g. after successful payment)
  void setActivePlan(Plan plan) {
    emit(ActivePlanLoaded(activePlan: plan));
  }
  
  // Cancel the active plan
  Future<void> cancelPlan() async {
    if (state is ActivePlanLoaded) {
      emit(ActivePlanLoading());
      
      // In a real app, this would make an API call to cancel the plan
      await Future.delayed(Duration(milliseconds: 800)); // Mock delay
      
      emit(ActivePlanNotFound());
    }
  }
  
  // Handle plan completion (when end date is reached)
  void checkPlanExpiration() {
    if (state is ActivePlanLoaded) {
      final currentState = state as ActivePlanLoaded;
      final plan = currentState.activePlan;
      
      // Check if plan has ended
      if (plan.endDate != null && plan.endDate!.isBefore(DateTime.now())) {
        emit(ActivePlanNotFound());
      }
    }
  }
}